//
//  BSLogWindow.m
//  HAMLogOutputWindowDemo
//
//  Created by BaiShun on 2018/10/9.
//  Copyright © 2018年 Find the Lamp Studio. All rights reserved.
//

#import "BSLogWindow.h"
#import <WMDragView/WMDragView.h>

#define BSLogWindowSereenWidth [UIScreen mainScreen].bounds.size.width
#define BSLogWindowSereenHeight [UIScreen mainScreen].bounds.size.height
#define BSLogWindowIPhoneX ((BSLogWindowSereenWidth == 375.f || BSLogWindowSereenWidth == 414.f)  && (BSLogWindowSereenHeight == 812.f || BSLogWindowSereenHeight == 896.f) ? YES : NO)
#define BSLogWindowNAVTOP (BSLogWindowIPhoneX ? 44 : 20)

static BSLogWindow *instance = nil;
static int showLogWindow;

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

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) NSMutableArray *logsArrM;

@end

@implementation BSLogWindow{
    UITextView *textViewScreen;
    WMDragView *viewWindowBtn;
    UIButton *btnShow;
}

+ (void)showWindow:(BOOL)isShow{
    if (isShow) {
        showLogWindow = 1;
    }else{
        showLogWindow = 0;
    }
    [self sharedInstance];
}

/**
 单例
 */
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (showLogWindow) {
            instance = [[BSLogWindow alloc] init];
        }else{
            instance = nil;
        }
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
    
    if (!textViewScreen) {
         textViewScreen = [[UITextView alloc] initWithFrame:self.bounds];
    }
    textViewScreen.font = [UIFont systemFontOfSize:15.0f];
    textViewScreen.textColor = [UIColor whiteColor];
    textViewScreen.backgroundColor = [UIColor blackColor];
    textViewScreen.showsVerticalScrollIndicator = YES;
    textViewScreen.scrollsToTop = NO;
    [self addSubview:textViewScreen];
    self.textView = textViewScreen;
    
    //可拖拽的调试按钮
    if (!viewWindowBtn) {
        viewWindowBtn = [[WMDragView alloc] initWithFrame:CGRectMake(BSLogWindowSereenWidth-40, BSLogWindowSereenHeight/2.0-20, 40, 40)];
    }
    
    viewWindowBtn.layer.cornerRadius = 20.0;
    viewWindowBtn.layer.masksToBounds = YES;
    viewWindowBtn.dragEnable = YES;
    viewWindowBtn.isKeepBounds = YES;
    __weak typeof(self) weakSelf = self;
    viewWindowBtn.clickDragViewBlock = ^(WMDragView *dragView) {
        [weakSelf btnShowClick];
    };
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(btnShowLongClick:)];
    longPressGR.minimumPressDuration = 1.5;
    [viewWindowBtn addGestureRecognizer:longPressGR];
    
    if (!btnShow) {
        btnShow = [[UIButton alloc] initWithFrame:viewWindowBtn.bounds];
    }
    
    btnShow.backgroundColor = [UIColor orangeColor];
    [btnShow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnShow.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [btnShow setTitle:@"日志" forState:UIControlStateNormal];
    btnShow.userInteractionEnabled = NO;
    [viewWindowBtn addSubview:btnShow];
    [window addSubview:viewWindowBtn];
    
    self.frame = CGRectMake(0, 0, 0, 0);
    self.layer.masksToBounds = YES;
    
    // string
    self.logsArrM = [NSMutableArray array];
}

//悬浮按钮被点击
- (void)btnShowClick{
    CGRect rect = self.frame;
    if (rect.size.width != 0) {
        //有
        self.frame = CGRectMake(0, 0, 0, 0);
    }else{
        self.frame = CGRectMake(0, 20, BSLogWindowSereenWidth, BSLogWindowSereenHeight/2.0+BSLogWindowNAVTOP);
    }
}
//悬浮按钮被长按
- (void)btnShowLongClick:(UILongPressGestureRecognizer *)gr{
    if (gr.state==UIGestureRecognizerStateBegan) {
        //长按手势回调
        [BSLogWindow clear];
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(0, 20, BSLogWindowSereenWidth, BSLogWindowSereenHeight/2.0+BSLogWindowNAVTOP)];
    if (self) {
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addObserver:self forKeyPath:@"rootViewController" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
            [self setUpUI];
        }
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
    
    [self.logsArrM enumerateObjectsUsingBlock:^(BSLogModel *log, NSUInteger idx, BOOL * _Nonnull stop) {
        if (log.strLog.length == 0) {
            return;
        }
        
        NSMutableAttributedString* logString = [[NSMutableAttributedString alloc] initWithString:log.strLog];
        UIColor* logColor = (idx == self.logsArrM.count - 1 || idx == self.logsArrM.count - 2) ? [UIColor yellowColor] : [UIColor whiteColor]; // yellow if new, white if more than 0.1 second ago
        [logString addAttribute:NSForegroundColorAttributeName value:logColor range:NSMakeRange(0, logString.length)];
        
        [attributedString appendAttributedString:logString];
    }];
    
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

//通过c语言中dup2函数映射到pipe端口，监听端口读取打印的文字显示在界面上。
- (void)redirectSTD:(int)fd{
 
    NSPipe * pipe = [NSPipe pipe];
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading];
    int pipeFileHandle = [[pipe fileHandleForWriting] fileDescriptor];
    dup2(pipeFileHandle, fd);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle];
    [pipeReadHandle readInBackgroundAndNotifyForModes:@[NSRunLoopCommonModes]];

}
- (void)redirectNotificationHandle:(NSNotification *)nf{
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
     NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        printf("%s", [str UTF8String]);
        [BSLogWindow printLog:str];
    if(self.printBlock){
        self.printBlock(str);
    }

    [[nf object] readInBackgroundAndNotifyForModes:@[NSRunLoopCommonModes]];
}

+ (void)BSLog:(NSString *)str{
    [BSLogWindow printLog:str];
    BSLogWindow *bslogWindow = [BSLogWindow sharedInstance];
    if(bslogWindow.printBlock){
        bslogWindow.printBlock(str);
    }
}

+ (void)BSLog:(NSString *)str type:(BSLogType)type{
    if (type == BSLogTypeScreen) {
        [self BSLog:str];
    }else if (type == BSLogTypeConsole){
        NSLog(@"%@",str);
    }else{
        NSLog(@"%@",str);
        [self BSLog:str];
    }
}

/**
 返回打印的内容
 */
- (void)printReturnStr:(NSString *)str{
    if (self.printBlock) {
        self.printBlock(str);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == [UIApplication sharedApplication].keyWindow && [keyPath isEqualToString:@"rootViewController"]) {
        [self setUpUI];
    }
}
@end













