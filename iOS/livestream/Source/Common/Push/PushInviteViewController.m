//
//  PushInviteViewController.m
//  livestream
//
//  Created by Max on 2017/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PushInviteViewController.h"

#import "LSImManager.h"
#import "LiveService.h"
#import "LSSessionRequestManager.h"

@interface PushInviteViewController ()

@end

@implementation PushInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 界面事件
- (IBAction)acceptAction:(id)sender {
    // 跳转接收邀请界面
    [[LiveService service] openUrlByLive:self.url];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)cancelAction:(id)sender {
    // 拒绝邀请
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
