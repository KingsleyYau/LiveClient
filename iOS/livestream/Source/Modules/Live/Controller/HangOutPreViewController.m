//
//  HangOutPreViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangOutPreViewController.h"

#import "LSLoginManager.h"
#import "LSImManager.h"
#import "LSImageViewLoader.h"

#import "HangOutViewController.h"

@interface HangOutPreViewController ()

@property (nonatomic, strong) LiveRoom *liveRoom;

@property (nonatomic, strong) LSLoginManager *loginManager;

@property (nonatomic, strong) LSImManager *imManager;

@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@end

@implementation HangOutPreViewController

- (void)dealloc {
    NSLog(@"HangOutPreViewController::dealloc()");
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.loginManager = [LSLoginManager manager];
    
    self.imManager = [LSImManager manager];
    
    self.imageLoader = [LSImageViewLoader loader];
    
    self.liveRoom = [[LiveRoom alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetView];
    
    [self.imageLoader loadImageWithImageView:self.headImageView options:SDWebImageRefreshCached imageUrl:self.loginManager.loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
    
    [self startRequest];
    
    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)startRequest {
    BOOL bFlag = [self.imManager enterHangoutRoom:@"" finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString * _Nonnull errMsg, IMHangoutRoomItemObject * _Nonnull Item) {
        NSLog(@"HangOutPreViewController::enterHangoutRoom( [观众新建/进入多人互动直播间] success : %@, errType : %d, errMsg : %@, roomId : %@ )", success == YES ? @"成功" : @"失败", errType, errMsg, Item.roomId);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                // 创建多人互动直播间成功
                if (Item.roomType == ROOMTYPE_HANGOUTROOM) {
                    self.liveRoom.roomType = LiveRoomType_Hang_Out;
                }
                self.liveRoom.hangoutLiveRoom = Item;
                
                HangOutViewController *vc = [[HangOutViewController alloc] init];
                vc.liveRoom = self.liveRoom;
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                // 创建失败
                [self showErrorType:errType tip:errMsg];
            }
        });
    }];
    if (!bFlag) {
        [self showErrorType:LCC_ERR_CONNECTFAIL tip:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
    }
}

- (void)resetView {
    self.closeBtn.hidden = YES;
    self.tipLabel.hidden = YES;
    self.retryButton.hidden = YES;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
}

- (void)showRetryBtn {
    self.tipLabel.hidden = NO;
    self.retryButton.hidden = NO;
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimating];
}

- (void)showErrorType:(LCC_ERR_TYPE)type tip:(NSString *)errorMsg {

    self.tipLabel.text = errorMsg;
    self.closeBtn.hidden = NO;
    
    switch (type) {
        case LCC_ERR_CONNECTFAIL:{
            [self showRetryBtn];
        }break;
            
        default:{
            
        }break;
    }
}

#pragma mark - 界面事件
- (IBAction)retryAction:(id)sender {
    [self resetView];

    [self startRequest];
}

- (IBAction)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



@end
