//
//  ViewController.m
//  VideoPlay
//
//  Created by 1 on 2017/1/18.
//  Copyright © 2017年 Yvan. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YvVideoPlayer.h"

@interface ViewController ()

@property (nonatomic, strong) YvVideoPlayer *player;
@end

@implementation ViewController

#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(10, 64, CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 300)];
    [self.view addSubview:containerView];
    self.player = [[YvVideoPlayer alloc]initWithContainerView:containerView];
    [self.player playWithVideoUrlString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
    
}
@end
