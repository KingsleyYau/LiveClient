//
//  PushInviteViewController.m
//  livestream
//
//  Created by Max on 2017/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PushInviteViewController.h"
#import "LSTimer.h"
#import "LSAnchorImManager.h"
#import "UserInfoManager.h"
#import "LSImageViewLoader.h"
#import "LiveModule.h"
#import "LiveService.h"
#import "LSAnchorRequestManager.h"
#import "LiveGobalManager.h"
#import "DialogTip.h"
#import "LiveUrlHandler.h"
#import "LSLoginManager.h"
@interface PushInviteViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) UserInfoManager *userInfoManager;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (strong) LSTimer *removeTimer;
@end

typedef void(^AcceptInviteHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, ZBHttpRoomType roomType);

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

    // TODO:Google Analyze - ShowInvitation
    [[LiveModule module].analyticsManager reportActionEvent:ShowInvitation eventCategory:EventCategoryGobal];
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
    NSLog(@"PushInviteViewController::acceptAction( url : %@ )", self.url);
    
    [self pushLiveRoom];
}

- (void)pushLiveRoom
{
    if ([LiveGobalManager manager].liveRoom) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedStringFromSelf(@"Alert_Msg") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"SURE", nil), nil];
        [alertView show];
    }
    else
    {
        // 停止定时器
        [self.removeTimer stopTimer];
        
        // 跳转接收邀请界面
        [[LiveService service] openUrlByLive:self.url];
        // TODO:Google Analyze - ClickInvitation
        [[LiveModule module].analyticsManager reportActionEvent:ClickInvitation eventCategory:EventCategoryGobal];
        // 移除界面
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

- (IBAction)cancelAction:(id)sender {
    NSLog(@"PushInviteViewController::cancelAction( url : %@ )", self.url);
    // 停止定时器
    [self.removeTimer stopTimer];
    // 拒绝邀请
    [self rejectInviteRequest];
    // 移除界面
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        // 停止定时器
        [self.removeTimer stopTimer];
        // 移除界面
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
    else
    {
        // 停止定时器
        [self.removeTimer stopTimer];
        
        // 接收立即私密邀请
        [self sendAcceptInstanceInvite:self.inviteId finshHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, ZBHttpRoomType roomType) {
            if (success) {
                // 重组url
                self.url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:roomId userId:self.userId roomType:LiveRoomType_Private];
                // 发送通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LivePushInviteNotification" object:self.url];
            } else {
                [[DialogTip dialogTip]showDialogTip:ZBAppDelegate.window tipText:errmsg];
            }
        }];
        // 移除界面
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

#pragma mark - 业务逻辑
- (void)sendAcceptInstanceInvite:(NSString *)inviteid finshHandler:(AcceptInviteHandler)finshHandler {
    [[LSAnchorRequestManager manager] anchorAcceptInstanceInvite:inviteid finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, ZBHttpRoomType roomType) {
        NSLog(@"PushInviteViewController::sendAcceptInstanceInvite:( [主播接收立即私密邀请] success : %@, errnum : %d, errmsg : %@, roomid : %@, roomType : %d)",(success == YES) ? @"成功":@"失败", errnum, errmsg, roomId, roomType);
        dispatch_async(dispatch_get_main_queue(), ^{
            finshHandler(success, errnum, errmsg, roomId, roomType);
        });
    }];
}

- (void)rejectInviteRequest {
    // 拒绝邀请
    [[LSAnchorRequestManager manager] anchorRejectInstanceInvite:self.inviteId rejectReason:@"" finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
         NSLog(@"PushInviteViewController::anchorRejectInstanceInvite( [拒绝邀请, %@] )", BOOL2SUCCESS(success));
    }];
}

- (void)updataUserInfo:(NSString *)userId {
    // TODO:更新用户信息
    WeakObject(self, weakSelf);
    [self.userInfoManager getFansBaseInfo:userId
                        finishHandler:^(AudienModel *_Nonnull item) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                weakSelf.tipsLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PUSH_INVITE_TIP"), item.nickName];
                                [weakSelf.imageViewLoader refreshCachedImage:weakSelf.ladyImageView options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
                            });
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

