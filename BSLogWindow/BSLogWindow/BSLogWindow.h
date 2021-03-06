//
//  BSLogWindow.h
//  HAMLogOutputWindowDemo
//
//  Created by BaiShun on 2018/10/9.
//  Copyright © 2018年 Find the Lamp Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^PrintBLock)(NSString *str);
typedef NS_ENUM(NSUInteger, BSLogType) {
    BSLogTypeScreen,
    BSLogTypeConsole,
    BSLogTypeAll,
};

@interface BSLogWindow : UIView

@property (copy, nonatomic) PrintBLock printBlock;

/**
 显示window控制

 @param isShow 是否显示window
 */
+ (void)showWindow:(BOOL)isShow;

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
 输出文字到指定位置

 @param str 字串
 @param type 输出位置类型
 */
+ (void)BSLog:(NSString *)str type:(BSLogType)type;
@end





