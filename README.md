 # BSLogWindow
1. 一 个用来打印信息到屏幕的小工具，方便测试调试。
2. NSLog输出到控制台同时输出到屏幕
 # 用法
 1. pod 'BSLogWindow'
 2. 代码示例
 ```
 #import "BSLogWindow.h"
 
 #define ShowLogWindow 1
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
     self.window = [UIWindow new];
     self.window.rootViewController = [ViewController new];
     [self.window makeKeyAndVisible];
 
     #if DEBUG && ShowLogWindow
     BSLogWindow *logWindow = [BSLogWindow sharedInstance];
     [logWindow setHidden:NO];
     logWindow.printBlock = ^(NSString *str) {
     //NSLog(@"str = %@",str);
     };
     #endif
 
     return YES;
 }
 ```

