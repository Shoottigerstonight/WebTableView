//
//  ViewController.m
//  WebTableView
//
//  Created by 侯云祥 on 2017/10/31.
//  Copyright © 2017年 今晚打老虎. All rights reserved.
//

#import "ViewController.h"
#import "WebTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
    bu.frame = CGRectMake(0, 100, 150, 50);
    [bu setTitle:@"进入到webview" forState:UIControlStateNormal];
    [bu setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:bu];
    [bu addTarget:self action:@selector(go) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)go
{
    [self presentViewController:[[WebTableViewController alloc] init] animated:YES completion:nil];
}

@end
