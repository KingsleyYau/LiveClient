//
//  PushInviteViewController.m
//  livestream
//
//  Created by Max on 2017/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PushInviteViewController.h"
#import "LSTimer.h"
#import "LSImManager.h"
#import "UserInfoManager.h"
#import "LSImageViewLoader.h"
#import "LiveModule.h"
#import "LiveService.h"
#import "LSSessionRequestManager.h"
#import "AcceptInstanceInviteRequest.h"
#import "LiveUrlHandler.h"
#import "LSAnalyticsManager.h"

@interface PushInviteViewController ()
@property (nonatomic, strong) UserInfoManager *userInfoManager;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (strong) LSTimer *removeTimer;
@end

@implementation PushInviteViewController

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
    if( [[LiveModule module].delegate respondsToSelector:@selector(moduleOnNotificationDisappear:)] ) {
        [[LiveModule module].delegate moduleOnNotificationDisappear:module];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updataUserInfo:self.anchorId];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.bounds.size.width * 0.5;
    self.ladyImageView.clipsToBounds = YES;
    [[LSAnalyticsManager manager] reportActionEvent:ShowInvitation eventCategory:EventCategoryGobal];
    // 定时3分钟移除
    [self timingRemoveView];
}

#pragma mark - 界面事件
- (IBAction)acceptAction:(id)sender {
    
    NSLog(@"PushInviteViewController::acceptAction: url:%@",self.url);
    [self.removeTimer stopTimer];
    // 跳转接收邀请界面
//    [[LiveService service] openUrlByLive:self.url];
    [[LiveModule module].service openUrl:self.url fromVC:AppDelegate().window.rootViewController];
    
    [[LSAnalyticsManager manager] reportActionEvent:ClickInvitation eventCategory:EventCategoryGobal];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)cancelAction:(id)sender {
    [self.removeTimer stopTimer];
    // 拒绝邀请
    [self rejectInviteRequest];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)rejectInviteRequest {
    AcceptInstanceInviteRequest *request = [[AcceptInstanceInviteRequest alloc] init];
    request.inviteId = self.inviteId;
    request.isConfirm = NO;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, AcceptInstanceInviteItemObject * _Nonnull item) {
        NSLog(@"PushInviteViewController::rejectInviteRequest : [拒绝应邀 %@]",BOOL2SUCCESS(success));
        if (success) {
        
        }
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

- (void)updataUserInfo:(NSString *)userId {
    WeakObject(self, weakSelf);
    [self.userInfoManager getUserInfo:userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.tipsLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PUSH_INVITE_TIP"),item.nickName];
            [weakSelf.imageViewLoader loadImageWithImageView:weakSelf.ladyImageView options:0 imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
        });
    }];
}

- (void)timingRemoveView {
    WeakObject(self, weakSelf);
    [self.removeTimer startTimer:nil timeInterval:180.0 * NSEC_PER_SEC starNow:NO action:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf cancelAction:nil];
        });
    }];
}

@end
