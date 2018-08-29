//
//  PushShowViewController.m
//  livestream_anchor
//
//  Created by Calvin on 2018/5/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PushShowViewController.h"

#import "LiveModule.h"
#import "LiveService.h"
#import "LiveGobalManager.h"
#import "PreShowRoomInHandler.h"
#import "DialogTip.h"
@interface PushShowViewController ()
@property (nonatomic, strong) PreShowRoomInHandler *showRoomInHandler;
@end

@implementation PushShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 8;
    self.view.layer.masksToBounds = YES;
    
    self.showRoomInHandler = [[PreShowRoomInHandler alloc] init];
    
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
    
    if (self.isShowAcceptBtn) {
        self.AcceptBtnW.constant = 85;
    }
    else
    {
        self.AcceptBtnW.constant = 0;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender {

    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)acceptAction:(id)sender {
    NSLog(@"PushShowViewController::acceptAction: url:%@", self.url);
    
    if ([LiveGobalManager manager].liveRoom) {
//        [self.showRoomInHandler getShowRoomInfo:self.liveShowId finshHandler:^(BOOL success, LSAnchorProgramItemObject * _Nonnull item, NSString * _Nonnull roomId, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (success) {
//                NSDictionary * dic = @{@"url":self.url,@"roomId":roomId};
//                // 发送通知
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"LivePushInviteNotification" object:dic];
//
//                } else {
//                    [[DialogTip dialogTip]showDialogTip:ZBAppDelegate.window tipText:errmsg];
//                }
//            });
//        }];
//
//        // 移除界面
//        [self.view removeFromSuperview];
//        [self removeFromParentViewController];
    }
    else
    {
        // 跳转接收邀请界面
        [[LiveService service] openUrlByLive:self.url];
        // 移除界面
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

@end
