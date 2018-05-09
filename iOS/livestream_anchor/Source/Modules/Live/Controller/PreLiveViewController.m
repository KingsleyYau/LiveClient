//
//  PreLiveViewController.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PreLiveViewController.h"

#import "PublicViewController.h"
#import "PublicVipViewController.h"
#import "PrivateViewController.h"
#import "PrivateVipViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "LiveFinshViewController.h"
#import "AnchorPersonalViewController.h"

#import "LiveModule.h"
#import "LSAnchorImManager.h"
#import "LSImageViewLoader.h"
#import "LiveGobalManager.h"
#import "LiveBundle.h"
#import "UserInfoManager.h"
#import "PreInviteToHandler.h"
#import "PreRoomInHandler.h"
#import "PreAcceptHandler.h"
#import "CheckPrivacyManager.h"
#import "PreShowRoomInHandler.h"

// 10秒后显示退出按钮
#define CANCEL_BUTTON_TIMEOUT 10

@interface PreLiveViewController () <ZBIMLiveRoomManagerDelegate, ZBIMManagerDelegate, LiveGobalManagerDelegate,
                                    PreInviteToHandlerDelegate, CheckPrivacyManagerDelegate>
// IM管理器
@property (nonatomic, strong) LSAnchorImManager *imManager;

#pragma mark - 倒数控制
// 开播前倒数
@property (strong) LSTimer *showRoomTimer;

#pragma mark - 总超时控制
// 总超时倒数
@property (strong) LSTimer *handleTimer;
// 显示退出按钮时间
@property (nonatomic, assign) int showExitBtnLeftSecond;

@property (nonatomic, assign) NSInteger timeCount;

#pragma mark - 头像逻辑
@property (atomic, strong) LSImageViewLoader *imageViewLoader;

@property (nonatomic, strong) CheckPrivacyManager *checkManager;

@property (nonatomic, strong) UIViewController *vc;

@property (nonatomic, strong) PreInviteToHandler *inviteHandler;
@property (nonatomic, strong) PreRoomInHandler *roominHandler;
@property (nonatomic, strong) PreAcceptHandler *acceptHandler;
@property (nonatomic, strong) PreShowRoomInHandler *showRoomInHandler;

@property (nonatomic, strong) LSAnchorProgramItemObject *programItem;

@end

@implementation PreLiveViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PreLiveViewController::initCustomParam()");

    // 初始化管理器
    self.imManager = [LSAnchorImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    // 初始化权限检测管理器
    self.checkManager = [[CheckPrivacyManager alloc] init];
    self.checkManager.checkDelegate = self;
    
    // 初始化后台管理器
    [[LiveGobalManager manager] addDelegate:self];

    self.imageViewLoader = [LSImageViewLoader loader];
    
    // 初始化计时器
    self.handleTimer = [[LSTimer alloc] init];
    self.showRoomTimer = [[LSTimer alloc] init];

}

- (void)dealloc {
    NSLog(@"PreLiveViewController::dealloc()");

    [[LiveGobalManager manager] removeDelegate:self];
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [self.inviteHandler unInit];
    
    // 赋值到全局变量, 用于前台计时
    [LiveGobalManager manager].liveRoom = nil;
    [LiveGobalManager manager].player = nil;
    [LiveGobalManager manager].publisher = nil;
    
    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化handler
    self.inviteHandler = [[PreInviteToHandler alloc] init];
    self.inviteHandler.inviteDelegate = self;
    
    self.roominHandler = [[PreRoomInHandler alloc] init];
    
    self.acceptHandler = [[PreAcceptHandler alloc] init];
    
    self.showRoomInHandler = [[PreShowRoomInHandler alloc] init];
    
    // 重置参数
    [self reset];

    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    // 更新用户头像名字
    if (self.liveRoom.photoUrl) {
        [self.imageViewLoader refreshCachedImage:self.ladyImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
    }
    if (self.liveRoom.userName) {
        self.ladyNameLabel.text = self.liveRoom.userName;
    }
    
    WeakObject(self, weakSelf);
    [[UserInfoManager manager] getFansBaseInfo:self.liveRoom.userId finishHandler:^(AudienModel * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.liveRoom.photoUrl = item.photoUrl;
            weakSelf.liveRoom.userName = item.nickName;
            // 刷新男士名字头像
            weakSelf.ladyNameLabel.text = item.nickName;
            [weakSelf.imageViewLoader refreshCachedImage:self.ladyImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
        });
    }];
    
    // 显示loadingView
    [self showTipLoadingView];
    
    
    // 清除浮窗
    [[LiveModule module].notificationVC.view removeFromSuperview];
    [[LiveModule module].notificationVC removeFromParentViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    // 开始计时
    [self startHandleTimer];
    
    // 先检测是否开启摄像头/麦克风权限
    [self.checkManager checkPrivacyIsOpen:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                // 发起请求
                [self startRequest:self.status];
            }
        });
    }];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 停止计时
    [self stopAllTimer];
    [self.showRoomTimer stopTimer];
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化主播头像
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.frame.size.width / 2;
    self.ladyImageView.layer.masksToBounds = YES;
}

- (void)showTipLoadingView {
    self.loadingViewTop.constant = 20;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
}

- (void)hiddenTipLoadingView {
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimating];
}

#pragma mark - 数据逻辑
- (void)startRequest:(PreLiveStatus)status {
    switch (status) {
        case PreLiveStatus_Inviting:{
            self.statusLabel.text = DEBUG_STRING([NSString stringWithFormat:@"请求私密邀请..."]);
            BOOL bFlag = [self.inviteHandler instantInviteWithUserid:self.liveRoom.userId finshHandler:^(BOOL success, ZBLCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull inviteid, NSString * _Nonnull roomid) {
                if (success) {
                    
                    self.inviteId = inviteid;
                    if (roomid.length) {
                        self.liveRoom.roomId = roomid;
                        // 进入直播间
                        [self enterRoom:self.liveRoom.roomId];
                    } else {
                        [self showTip:NSLocalizedStringFromSelf(@"INVITING_VIEWR_START")];
                    }
                } else {
                    self.statusLabel.text = DEBUG_STRING(@"请求私密邀请失败");
                    [self handleError:errnum errMsg:errmsg];
                }
            }];
            if (!bFlag) {
                [self handleError:ZBLCC_ERR_CONNECTFAIL errMsg:nil];
            }
        }break;
            
        case PreLiveStatus_Enter:{
            NSString *str = [NSString stringWithFormat:@"请求进入指定直播间(roomId : %@)...", self.liveRoom.roomId];
            self.statusLabel.text = DEBUG_STRING(str);
            NSLog(@"PreLiveViewController::startRequest( [PreLiveStatus_Enter roomID : %@] )",self.liveRoom.roomId);
            [self enterRoom:self.liveRoom.roomId];
        }break;
        
        case PreLiveStatus_Accept:{
            self.statusLabel.text = DEBUG_STRING(@"正在接受私密邀请");
            [self.acceptHandler acceptInviteWithId:self.inviteId finshHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, ZBHttpRoomType roomType) {
                if (success) {
                    self.liveRoom.roomId = roomId;
                    NSLog(@"PreLiveViewController::startRequest( [PreLiveStatus_Accept roomID : %@] )",self.liveRoom.roomId);
                    [self enterRoom:self.liveRoom.roomId];
                } else {
                    self.statusLabel.text = DEBUG_STRING(@"接受私密邀请失败");
                    [self httpHandelError:errnum errmsg:errmsg];
                }
            }];
        }break;
        case PreLiveStatus_Show:{
            [self.showRoomInHandler getShowRoomInfo:self.liveShowId finshHandler:^(BOOL success, LSAnchorProgramItemObject * _Nonnull item, NSString * _Nonnull roomId, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
                if (success) {
                    self.cancelButton.hidden = NO;
                    self.programItem = item;
                    NSLog(@"PreLiveViewController::startRequest( [getShowRoomInfo roomID : %@] )",roomId);
//                    [self changeShowLeftTime:item.leftSecToStart roomId:roomId];
                    [self changeShowLeftTime:60 roomId:roomId];
                } else {
                    self.statusLabel.text = DEBUG_STRING(@"获取节目信息失败");
                    [self httpHandelError:errnum errmsg:errmsg];
   
                }
            }];
        }break;
        
        default:{
        }break;
    }
}

- (void)handleError:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    // TODO:错误处理
    [self.statusLabel setText:DEBUG_STRING(@"出错啦")];
    
    self.status = PreLiveStatus_Error;
    
    // 隐藏菊花
    [self hiddenTipLoadingView];
    // 清空邀请
    self.inviteId = nil;

    [self stopAllTimer];

    switch (errType) {
        case ZBLCC_ERR_CONNECTFAIL: {
            // TODO:1.请求超时/网络失败
            if (self.liveRoom.roomId.length) {
                [self showRetry];
            }
            [self.tipsLabel setText:NSLocalizedStringFromSelf(@"CONNECTION_SERVER_FAILED")];
        } break;
            
        case ZBLCC_ERR_INVITE_TIME_OUT:
        case ZBLCC_ERR_INVITE_REJECT: {
            [self.tipsLabel setText:NSLocalizedStringFromSelf(@"VIEWER_NOT_REPLY")];
        } break;
            
        default: {
            [self.tipsLabel setText:errMsg];
        } break;
    }
}

- (void)httpHandelError:(ZBHTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    // TODO:错误处理
    [self.statusLabel setText:DEBUG_STRING(@"出错啦")];
    
    self.status = PreLiveStatus_Error;
    
    // 隐藏菊花
    [self hiddenTipLoadingView];
    
    [self stopAllTimer];
    
    [self.showRoomTimer stopTimer];
    
    switch (errnum) {
        case ZBHTTP_LCC_ERR_CONNECTFAIL: {
            // TODO:1.请求超时/网络失败
            [self showRetry];
            [self.tipsLabel setText:NSLocalizedStringFromSelf(@"CONNECTION_SERVER_FAILED")];
        } break;
            
        default: {
            [self.tipsLabel setText:errmsg];
        } break;
    }
}

- (void)showTip:(NSString *)tipMsg {
    
    [self.statusLabel setText:DEBUG_STRING(@"等待用户确认...")];
    // 隐藏菊花
    [self hiddenTipLoadingView];
    
    [self.tipsLabel setText:tipMsg];
}

- (void)reset {
    // TODO:重置参数
    // 10秒后显示退出按钮
    self.showExitBtnLeftSecond = CANCEL_BUTTON_TIMEOUT;
    // 还原状态提示
    self.tipsLabel.text = @"";
    self.statusLabel.text = @"";
    // 显示菊花
    self.loadingViewTop.constant = 20;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    // 隐藏退出按钮
    self.cancelButton.hidden = YES;

    // 隐藏按钮
    self.retryButtonHeight.constant = 0;
    self.retryButtonTop.constant = 0;
    self.closeButtonHeight.constant = 0;
    self.closeButtonTop.constant = 0;
}

- (void)stopAllTimer {
    [self stopHandleTimer];
    self.cancelButton.hidden = NO;
}

#pragma mark - 界面事件
- (void)enterRoom:(NSString *)roomId {
    BOOL bFlag = [self.roominHandler sendRoomIn:roomId finshHandler:^(BOOL success, ZBLCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBImLiveRoomObject * _Nonnull item) {
        self.statusLabel.text = [NSString stringWithFormat:DEBUG_STRING(@"请求进入指定直播间%@"),(success == YES) ? @"成功" : @"失败"];
        if (success) {
            if ([self.liveRoom.roomId isEqualToString:item.roomId]) {
                self.liveRoom.roomType = [[LSAnchorImManager manager] roomTypeToLiveRoomType:item.roomType];
                self.liveRoom.imLiveRoom = item;
                // 视频流url
                self.liveRoom.playUrlArray = item.pullUrl;
                self.liveRoom.publishUrlArray = item.pushUrl;
                
                // 直接进入直播间
                [self enterPrivateVipRoom];
            }else if (item.liveShowType == IMANCHORPUBLICROOMTYPE_PROGRAM && item.roomId.length > 0) {
                PublicVipViewController *vc = [[PublicVipViewController alloc] initWithNibName:nil bundle:nil];
                LiveRoom *room = [[LiveRoom alloc] init];
                room.userId = item.anchorId;
                room.roomId = item.roomId;
                room.roomType = [[LSAnchorImManager manager] roomTypeToLiveRoomType:item.roomType];
                room.playUrlArray = item.pullUrl;
                room.publishUrlArray = item.pushUrl;
                room.leftSeconds = item.leftSeconds;
                room.maxFansiNum = item.maxFansiNum;
                room.imLiveRoom = item;
                vc.liveRoom = room;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            [self handleError:errnum errMsg:errmsg];
        }
    }];
    if (!bFlag) {
        [self handleError:ZBLCC_ERR_CONNECTFAIL errMsg:nil];
    }
}

- (void)enterPrivateVipRoom {
    // TODO:进入豪华私密直播间界面
    PrivateViewController *vc = [[PrivateViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showRetry {
    // TODO:显示重试按钮
    self.retryButtonTop.constant = 20;
    self.retryButtonHeight.constant = 35;
    [self hiddenTipLoadingView];
}

#pragma mark - 点击事件
- (IBAction)cancelClick:(id)sender {
    // TODO:点击关闭界面
    if (self.status == PreLiveStatus_Inviting) {
        self.tipsLabel.text = NSLocalizedStringFromSelf(@"INVITING_TO_CANCEL");
        [self.inviteHandler cancelInviteWithId:self.inviteId finshHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
            if (errnum != ZBHTTP_LCC_ERR_CANCEL_FAIL_INVITE) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                self.tipsLabel.text = NSLocalizedStringFromSelf(@"FAILED_TO_CANCEL");
            }
        }];
    } else if (self.status == PreLiveStatus_Show){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"CLOSE_LIVE_SHOW") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"Close") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    // 清空邀请
    self.inviteId = nil;
    self.liveRoom.roomId = nil;
}

- (IBAction)closeClick:(id)sender {

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    // 清空邀请
    self.inviteId = nil;
    self.liveRoom.roomId = nil;
}

- (IBAction)retry:(id)sender {
    // 重置参数
    [self reset];

    // 开始计时
    [self stopHandleTimer];
    [self startHandleTimer];

    // 重新请求
    if (self.liveRoom.roomId.length) {
        self.status = PreLiveStatus_Enter;
    } else {
        if (self.inviteId.length) {
            self.status = PreLiveStatus_Accept;
        }
    }
    [self startRequest:self.status];
}

#pragma mark - CheckPrivacyManagerDelegate
- (void)cancelPrivacy {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PreInviteToHandlerDelegate
- (void)instantInviteReply:(InstantInviteItem *)item {
    NSLog(@"PreLiveViewController::[接受立即私密邀请回复回调]");
    if (item.replyType == ZBREPLYTYPE_AGREE) {
        self.liveRoom.roomId = item.roomId;
        NSLog(@"PreLiveViewController::instantInviteReply( [roomID : %@] )",self.liveRoom.roomId);
        // 进入直播间
        [self enterRoom:self.liveRoom.roomId];
    } else {
        [self handleError:ZBLCC_ERR_INVITE_REJECT errMsg:nil];
    }
}

- (void)inviteIsTimeOut {
    NSLog(@"PreLiveViewController::[主播发送立即私密邀请超时]");
    [self handleError:ZBLCC_ERR_INVITE_TIME_OUT errMsg:nil];
}

- (void)getInviteInfoWithId:(NSString *)inviteid imInviteIdItem:(ZBImInviteIdItemObject *)item errType:(ZBLCC_ERR_TYPE)errType errmsg:(NSString *)errmsg {
    NSLog(@"PreLiveViewController::[获取指定立即私密邀请信息回调]");
    if ([self.inviteId isEqualToString:inviteid]) {
        if (errType == ZBLCC_ERR_SUCCESS) {
            
            switch (item.replyType) {
                case ZBIMREPLYTYPE_UNCONFIRM:{ // 待确认
                }break;
                case ZBIMREPLYTYPE_AGREE:{ // 已同意
                    // 进入直播间
                    self.liveRoom.roomId = item.roomId;
                    NSLog(@"PreLiveViewController::getInviteInfoWithId( [roomID : %@] )",self.liveRoom.roomId);
                    [self enterRoom:self.liveRoom.roomId];
                }break;
                default:{ // 其他情况
                    [self handleError:ZBLCC_ERR_INVITE_REJECT errMsg:nil];
                }break;
            }
        
        } else {
            [self handleError:errType errMsg:errmsg];
        }
    }
}

#pragma mark - 倒数开始演出
- (void)changeShowLeftTime:(int)leftSeconds roomId:(NSString *)roomId{
    if (leftSeconds == 0) {
        [self enterRoom:roomId];
    }else {
        self.timeCount = leftSeconds;
        WeakObject(self, weakSelf);
        [self.showRoomTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf changeTimeLabel:roomId];
            });
        }];
    }

}

- (void)changeTimeLabel:(NSString *)roomId {
 
    NSInteger minutes = (self.timeCount + 59) / 60;
    NSInteger min = self.timeCount / 60;
    NSInteger sec = self.timeCount % 60;
    NSString *str = [NSString stringWithFormat:@"%ld.%ld",min,sec];

    
    //    NSString *str = [NSString stringWithFormat:@"%lds", (long)self.timeCount];
//    NSAttributedString *countStr = [self parseMessage:str font:[UIFont systemFontOfSize:18] color:[UIColor whiteColor]];
//    NSMutableAttributedString *timeStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"ENTER_LIVE_SHOW")];
//    [timeStr appendAttributedString:countStr];
//    self.tipsLabel.attributedText = timeStr;
    NSString *timeCountTips = [NSString stringWithFormat:@"Your show \"%@\" is starting in %ld minutes.Please do not leave this page.",self.programItem.showTitle,minutes];
    self.tipsLabel.text = timeCountTips;
    self.timeCount -= 1;
    
    if (self.timeCount < 0) {
        // 关闭
        [self.showRoomTimer stopTimer];
    
        self.timeCount = 0;
        // 自动进入
        [self enterRoom:roomId];
    }
}

#pragma mark - 字符串拼接
- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    return attributeString;
}



#pragma mark - 显示关闭按钮倒数控制
- (void)handleCountDown {
    self.showExitBtnLeftSecond--;
    if (self.showExitBtnLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopHandleTimer];
            // 允许显示退出按钮
            self.cancelButton.hidden = NO;
        });
    }
}

- (void)startHandleTimer {
    WeakObject(self, weakSelf);
    [self.handleTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf handleCountDown];
    }];
}

- (void)stopHandleTimer {
    [self.handleTimer stopTimer];
}

@end
