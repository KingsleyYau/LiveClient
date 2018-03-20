//
//  PushBookingViewController.m
//  livestream
//
//  Created by Max on 2017/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PushBookingViewController.h"
#import "LiveService.h"
#import "LiveModule.h"
#import "UserInfoManager.h"
#import "LSImageViewLoader.h"
#import "LSTimer.h"
#import "LiveGobalManager.h"
@interface PushBookingViewController ()
@property (nonatomic, strong) UserInfoManager *userInfoManager;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (strong) LSTimer *removeTimer;
@end

@implementation PushBookingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = NO;

    self.userInfoManager = [UserInfoManager manager];
    self.imageViewLoader = [LSImageViewLoader loader];

    self.removeTimer = [[LSTimer alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    LiveModule *module = [LiveModule module];
    if ([[LiveModule module].delegate respondsToSelector:@selector(moduleOnNotificationDisappear:)]) {
        [[LiveModule module].delegate moduleOnNotificationDisappear:module];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updataUserInfo:self.userId];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.bounds.size.width * 0.5;
    self.ladyImageView.clipsToBounds = YES;
    // TODO:Google Analyze - ShowBooking
    [[LiveModule module].analyticsManager reportActionEvent:ShowBooking eventCategory:EventCategoryGobal];
    // 开始移除定时器
    [self timingRemoveView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 停止定时器
    [self.removeTimer stopTimer];
}

#pragma mark - 界面事件
- (IBAction)acceptAction:(id)sender {
    NSLog(@"PushBookingViewController::acceptAction: url:%@", self.url);

    if ([LiveGobalManager manager].liveRoom) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Alert_Msg") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // 停止定时器
            [self.removeTimer stopTimer];
            // 移除界面
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SURE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 停止定时器
            [self.removeTimer stopTimer];
            // 发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LivePushBookingNotification" object:self.url];
            // 移除界面
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        // 停止定时器
        [self.removeTimer stopTimer];
        // 跳转预约倒计时
        [[LiveService service] openUrlByLive:self.url];
        // TODO:Google Analyze - ClickBooking
        [[LiveModule module].analyticsManager reportActionEvent:ClickBooking eventCategory:EventCategoryGobal];
        // 移除界面
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

- (IBAction)cancelAction:(id)sender {
    NSLog(@"PushBookingViewController::cancelAction( url : %@ )", self.url);
    // 停止定时器
    [self.removeTimer stopTimer];
    // 移除界面
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)updataUserInfo:(NSString *)userId {
    // TODO:更新用户信息
    WeakObject(self, weakSelf);
    [self.userInfoManager getFansBaseInfo:userId finishHandler:^(AudienModel * _Nonnull item) {
        weakSelf.tipsLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PUSH_BROADCAST_TIP"), item.nickName];
        [weakSelf.imageViewLoader refreshCachedImage:weakSelf.ladyImageView options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    }];
}

- (void)timingRemoveView {
    // TODO:定时移除通知
    WeakObject(self, weakSelf);
    [self.removeTimer startTimer:nil
                    timeInterval:180.0 * NSEC_PER_SEC
                         starNow:NO
                          action:^{
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [weakSelf cancelAction:nil];
                              });
                          }];
}

@end
