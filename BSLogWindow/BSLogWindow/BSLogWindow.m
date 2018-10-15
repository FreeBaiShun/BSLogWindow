//
//  BSLogWindow.m
//  HAMLogOutputWindowDemo
//
//  Created by BaiShun on 2018/10/9.
//  Copyright © 2018年 Find the Lamp Studio. All rights reserved.
//

#import "BSLogWindow.h"
#import <WMDragView.h>

#define kSereenWidth [UIScreen mainScreen].bounds.size.width
#define kSereenHeight [UIScreen mainScreen].bounds.size.height

static BSLogWindow *logWindow = nil;
static BSLogWindow *instance = nil;


/**
 BSLogModel
 */
@interface BSLogModel : NSObject
@property (assign, nonatomic) double timeStamp;
@property (copy, nonatomic) NSString *strLog;

@end

@implementation BSLogModel
+ (instancetype)logWithStr:(NSString *)str{
    BSLogModel *model = [[BSLogModel alloc] init];
    model.timeStamp = [[NSDate date] timeIntervalSince1970];
    model.strLog = str;
    
    return model;
}

@end



/**
 BSLogWindow
 */
@interface BSLogWindow()

@property (weak, nonatomic) UITextView* textView;
@property (strong, nonatomic) NSMutableArray* logsArrM;

@end

@implementation BSLogWindow


/**
 单利部分
 */
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


/**
 视图部分
 */
- (void)setUpUI{
    // self
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self];
    [self setBackgroundColor:[UIColor blackColor]];
    
    // text view
    UITextView* textView = [[UITextView alloc] initWithFrame:self.bounds];
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.textColor = [UIColor whiteColor];
    textView.backgroundColor = [UIColor clearColor];
    textView.scrollsToTop = NO;
    [self addSubview:textView];
    self.textView = textView;
    
    //可拖拽的调试按钮
    WMDragView *viewWindowBtn = [[WMDragView alloc] initWithFrame:CGRectMake(kSereenWidth-40, kSereenHeight/2.0-20, 40, 40)];
    viewWindowBtn.layer.cornerRadius = 20.0;
    viewWindowBtn.layer.masksToBounds = YES;
    viewWindowBtn.dragEnable = YES;
    viewWindowBtn.isKeepBounds = YES;
    viewWindowBtn.clickDragViewBlock = ^(WMDragView *dragView) {
        CGRect rect = self.frame;
        if (rect.size.width != 0) {
            //有
            self.frame = CGRectMake(0, 0, 0, 0);
        }else{
            self.frame = CGRectMake(0, 20, kSereenWidth, kSereenHeight/2.0+20.0);
        }
        
    };
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(btnShowLongClick:)];
    longPressGR.minimumPressDuration = 1.5;
    [viewWindowBtn addGestureRecognizer:longPressGR];
    
    UIButton *btnShow = [[UIButton alloc] initWithFrame:viewWindowBtn.bounds];
    btnShow.backgroundColor = [UIColor orangeColor];
    [btnShow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnShow.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [btnShow setTitle:@"日志" forState:UIControlStateNormal];
    [viewWindowBtn addSubview:btnShow];
    [window addSubview:viewWindowBtn];
    
    self.frame = CGRectMake(0, 0, 0, 0);
    self.layer.masksToBounds = YES;
    
    // string
    self.logsArrM = [NSMutableArray array];
}

//悬浮按钮被长按
- (void)btnShowLongClick:(UILongPressGestureRecognizer *)gr{
    if (gr.state==UIGestureRecognizerStateBegan) {
        //长按手势回调
        [BSLogWindow clear];
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(0, 20, kSereenWidth, kSereenHeight/2.0+20.0)];
    if (self) {
        logWindow = self;
        [self setUpUI];
        [self redirectSTD:STDERR_FILENO];
    }
    
    return self;
}

+ (void)clear {
    dispatch_async(dispatch_get_main_queue(),^{
        [[self sharedInstance] clear];
    });
}

- (void)clear {
    self.textView.text = @"";
    self.logsArrM = [NSMutableArray array];
}

+ (void)printLog:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(),^{
        [[self sharedInstance] printLog:text];
    });
}

- (void)printLog:(NSString*)newLog {
    if (newLog.length == 0) {
        return;
    }
    
    @synchronized (self) {
        newLog = [NSString stringWithFormat:@"%@\n", newLog]; // add new line
        BSLogModel* log = [BSLogModel logWithStr:newLog];
        
        // data
        if (!log) {
            return;
        }
        [self.logsArrM addObject:log];
        if (self.logsArrM.count > 20) {
            [self.logsArrM removeObjectAtIndex:0];
        }
        
        // view
        [self refreshLogDisplay];
    }
}
- (void)refreshLogDisplay {
    // attributed text
    NSMutableAttributedString* attributedString = [NSMutableAttributedString new];
    
    double currentTimestamp = [[NSDate date] timeIntervalSince1970];
    for (BSLogModel* log in self.logsArrM) {
        if (log.strLog.length == 0) {
            return;
        }
        
        NSMutableAttributedString* logString = [[NSMutableAttributedString alloc] initWithString:log.strLog];
        UIColor* logColor = currentTimestamp - log.timeStamp > 0.1 ? [UIColor whiteColor] : [UIColor yellowColor]; // yellow if new, white if more than 0.1 second ago
        [logString addAttribute:NSForegroundColorAttributeName value:logColor range:NSMakeRange(0, logString.length)];
        
        [attributedString appendAttributedString:logString];
    }
    
    self.textView.attributedText = attributedString;
    
    // scroll to bottom
    if(attributedString.length > 0) {
        NSRange bottom = NSMakeRange(attributedString.length - 1, 1);
        [self.textView scrollRangeToVisible:bottom];
    }
}


/**
 hook NSLog部分
 */

//方案1. 通过c语言中dup2函数映射到pipe端口，监听端口读取打印的文字显示在界面上。
- (void)redirectSTD:(int )fd{
    NSPipe * pipe = [NSPipe pipe] ;
        NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
     int pipeFileHandle = [[pipe fileHandleForWriting] fileDescriptor];
     dup2(pipeFileHandle, fd);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(redirectNotificationHandle:)
            name:NSFileHandleReadCompletionNotification
                                                   object:pipeReadHandle] ;
        [pipeReadHandle readInBackgroundAndNotify];
}
- (void)redirectNotificationHandle:(NSNotification *)nf{
        NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
        printf("%s", [str UTF8String]);
        [BSLogWindow printLog:str];
    if(self.printBlock){
        self.printBlock(str);
    }
    
        [[nf object] readInBackgroundAndNotify];
}


/**
 返回打印的内容
 */
- (void)printReturnStr:(NSString *)str{
    if (self.printBlock) {
        self.printBlock(str);
    }
}
@end













