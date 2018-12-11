 # BSLogWindow
1.  是否遇到过这样一个问题，后台开发小伙伴总是问当前账号userid，token问题。总是问入参出参问题。那么这个工具用起来吧，让他们自己去看吧！
2. 一个方便脱机查看日志的工具
3. 可以控制打印到屏幕或者是控制台或者两者
4. 点击屏幕上日志按钮控制显示和隐藏屏幕日志信息
5. 长按日志按钮清空屏幕上日志信息

# 效果
![image](https://github.com/FreeBaiShun/BSLogWindow/blob/master/BSLogWindow.gif)

# 用法
 1. pod 'BSLogWindow'
 2. 代码示例
 ```
 //AppDelegate.m
 #ifdef DEBUG // 开发
 #define BSLogWindowShow 1
 
 #else // 生产
 #define BSLogWindowShow 0
 
 #endif
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 //BSLogWindow（控制显示）
 [BSLogWindow showWindow:BSLogWindowShow];
 return YES;
 }
 
 //打印数据
 [BSLogWindow BSLog:@"test" type:BSLogTypeAll];//控制台和屏幕都要打印
 [BSLogWindow BSLog:@"test" type:BSLogTypeConsole];//只在控制台打印
 [BSLogWindow BSLog:@"test" type:BSLogTypeScreen];//只在屏幕打印
 ```

