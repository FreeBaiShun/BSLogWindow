//
//  BSLogWindow.h
//  HAMLogOutputWindowDemo
//
//  Created by BaiShun on 2018/10/9.
//  Copyright © 2018年 Find the Lamp Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^PrintBLock)(NSString *str);

@interface BSLogWindow : UIView

@property (copy, nonatomic) PrintBLock printBlock;

+ (instancetype)sharedInstance;

/**
 在测试窗口输出 log，结尾会自动换行。测试窗口会自动向下滚动，最新的 log 显示为黄色，旧的 log 显示为白色。
 
 @param text 要输出的 log。
 */
+ (void)printLog:(NSString*)text;

/**
 清空测试窗口
 */
+ (void)clear;


/**
 设置隐藏
 */
- (void)setHiddenWindow;
@end





