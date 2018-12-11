//
//  ViewController.m
//  BSLogWindow
//
//  Created by BaiShun on 2018/10/15.
//  Copyright © 2018 BaiShun. All rights reserved.
//

#import "ViewController.h"
#import "BSLogWindow.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    [BSLogWindow BSLog:[NSString stringWithFormat:@"Hello %@",@"BSLogWindow"] type:BSLogTypeAll];//控制台和屏幕都要打印
}

@end
