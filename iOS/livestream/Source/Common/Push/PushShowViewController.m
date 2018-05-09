//
//  PushShowViewController.m
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PushShowViewController.h"
#import "LSImageViewLoader.h"
#import "UserInfoManager.h"
#import "LSTimer.h"
#import "LiveModule.h"
#import "LiveService.h"
@interface PushShowViewController ()
@property (nonatomic, strong) UserInfoManager *userInfoManager;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (strong) LSTimer *removeTimer;
@end

@implementation PushShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 8;
    self.view.layer.masksToBounds = YES;
    
    self.userInfoManager = [UserInfoManager manager];
    self.imageViewLoader = [LSImageViewLoader loader];
    
    self.removeTimer = [[LSTimer alloc] init];
    
    self.tipsLabel.text = self.tips;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    LiveModule *module = [LiveModule module];
    if( [[LiveModule module].delegate respondsToSelector:@selector(moduleOnNotificationDisappear:)] ) {
        [[LiveModule module].delegate moduleOnNotificationDisappear:module];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updataUserInfo:self.anchorId];
    [[LiveModule module].analyticsManager reportActionEvent:ShowShowStart eventCategory:EventCategoryShowCalendar];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.bounds.size.width * 0.5;
    self.ladyImageView.clipsToBounds = YES;
   
    // 定时4分钟移除
    [self timingRemoveView];
}

- (void)updataUserInfo:(NSString *)userId {

    WeakObject(self, weakSelf);
    [self.userInfoManager getUserInfo:userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.imageViewLoader refreshCachedImage:weakSelf.ladyImageView options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender {
    [self.removeTimer stopTimer];

    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)tipTap:(UITapGestureRecognizer *)sender {
    
    NSLog(@"PushShowViewController::acceptAction: url:%@",self.url);
    [self.removeTimer stopTimer];
    // 跳转接收邀请界面
    [[LiveService service] openUrlByLive:self.url];
    [[LiveModule module].analyticsManager reportActionEvent:ClickShowStart eventCategory:EventCategoryShowCalendar];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)timingRemoveView {
    WeakObject(self, weakSelf);
    [self.removeTimer startTimer:nil timeInterval:240.0 * NSEC_PER_SEC starNow:NO action:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf cancelAction:nil];
        });
    }];
}

@end
