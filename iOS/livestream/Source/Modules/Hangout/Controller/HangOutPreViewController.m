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
#import "LiveRoomCreditRebateManager.h"
#import "LSSendinvitationHangoutRequest.h"
#import "LSCancelInviteHangoutRequest.h"
#import "LSGetHangoutStatusRequest.h"
#import "LSGetHangoutInvitStatusRequest.h"
#import "LSUpQNInviteIdRequest.h"
#import "LSSessionRequestManager.h"

#import "HangOutViewController.h"
#import "HangOutPreAnchorPhotoCell.h"
#import "LSAddCreditsViewController.h"

// 180秒后显示超时
#define INVITE_TIMEOUT 180

@interface HangOutPreViewController ()<IMManagerDelegate, IMLiveRoomManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

typedef enum {
    HANGOUT_PERIOD_NONE = 0,
    HANGOUT_PERIOD_GETSTATUS,
    HANGOUT_PERIOD_ENTERNEW,
    HANGOUT_PERIOD_INVITING,
    HANGOUT_PERIOD_ENTERING,
    HANGOUT_PERIOD_RETRY,
    HANGOUT_PERIOD_ERROR,
    HANGOUT_PERIOD_NOCREDIT,
    HANGOUT_PERIOD_HAVEROOM,
}HANGOUT_PERIOD_TYPE;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIButton *retryButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewWidth;

@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;

@property (weak, nonatomic) IBOutlet UIButton *goMyRoomBtn;

@property (weak, nonatomic) IBOutlet UIButton *startNewRoomBtn;

@property (nonatomic, strong) NSMutableArray<IMLivingAnchorItemObject *> *anchorArray;

@property (nonatomic, strong) LiveRoom *liveRoom;

@property (nonatomic, strong) LSLoginManager *loginManager;

@property (nonatomic, strong) LSImManager *imManager;

@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

// 总超时倒数
@property (strong) LSTimer *handleTimer;
// 总超时剩余时间
@property (nonatomic, assign) int exitLeftSecond;

/**
 邀请id
 */
@property (nonatomic, copy) NSString *inviteId;

/**
 hangout状态队列
 */
@property (nonatomic, strong) NSArray<LSHangoutStatusItemObject *> *status;

/**
 过渡页状态
 */
@property (nonatomic, assign) HANGOUT_PERIOD_TYPE preType;

/**
 被邀请主播
 */
@property (nonatomic, strong) IMLivingAnchorItemObject *inviteAnchor;

@property (nonatomic, strong) HangOutViewController *hangoutVC;

@end

@implementation HangOutPreViewController

- (void)dealloc {
    NSLog(@"HangOutPreViewController::dealloc()");
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.isShowNavBar = NO;
    // 禁止导航栏后退手势
    self.canPopWithGesture = NO;
    
    self.loginManager = [LSLoginManager manager];
    
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    self.imageLoader = [LSImageViewLoader loader];
    
    self.liveRoom = [[LiveRoom alloc] init];
    self.anchorArray = [[NSMutableArray alloc] init];
    self.status = [[NSArray alloc] init];
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.preType = HANGOUT_PERIOD_NONE;
    
    self.exitLeftSecond = INVITE_TIMEOUT;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 禁止锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // 过渡页提示语
    NSString *tip;
    if (self.hangoutAnchorName.length > 0 && ![self.hangoutAnchorName isEqualToString:@""]) {
        tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_ANCHOR"),self.hangoutAnchorName];
    } else {
        tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_ANCHOR"),self.inviteAnchorName];
    }
    // 重置界面
    [self resetView:YES tip:tip];
    
    UINib *cellNib = [UINib nibWithNibName:@"HangOutPreAnchorPhotoCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:[HangOutPreAnchorPhotoCell cellIdentifier]];
    
    self.retryButton.layer.cornerRadius = self.retryButton.frame.size.height / 2;
    self.retryButton.layer.masksToBounds = YES;
    
    self.addCreditBtn.layer.cornerRadius = self.addCreditBtn.frame.size.height / 2;
    self.addCreditBtn.layer.masksToBounds = YES;
    
    self.goMyRoomBtn.layer.cornerRadius = self.goMyRoomBtn.frame.size.height / 2;
    self.goMyRoomBtn.layer.masksToBounds = YES;
    
    self.startNewRoomBtn.layer.cornerRadius = self.startNewRoomBtn.frame.size.height / 2;
    self.startNewRoomBtn.layer.masksToBounds = YES;
    
    // 刷新过渡页主播头像
    if (self.hangoutAnchorId.length > 0 && ![self.hangoutAnchorId isEqualToString:@""]) {
        IMLivingAnchorItemObject *item = [[IMLivingAnchorItemObject alloc] init];
        item.anchorId = self.hangoutAnchorId;
        item.nickName = self.hangoutAnchorName;
        [self.anchorArray addObject:item];
    }
    if (self.inviteAnchorId.length > 0 && ![self.inviteAnchorId isEqualToString:@""]) {
        IMLivingAnchorItemObject *item = [[IMLivingAnchorItemObject alloc] init];
        item.anchorId = self.inviteAnchorId;
        item.nickName = self.inviteAnchorName;
        [self.anchorArray addObject:item];
    }
    self.collectionViewWidth.constant = self.anchorArray.count * 100;
    [self.collectionView reloadData];
    
    if (self.roomId.length > 0 && self.roomId != nil) {
        // 进入房间
        [self enterHangoutRoom:self.roomId isCreateOnly:NO];
    } else {
        // 请求数据
        [self getHangoutStatus];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.viewDidAppearEver) {
        [self startHandleTimer];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopHandleTimer];
}

#pragma mark - 数据请求
- (void)getHangoutStatus {
    self.preType = HANGOUT_PERIOD_GETSTATUS;
    // TODO:获取当前会员hangout直播状态
    WeakObject(self, weakSelf);
    LSGetHangoutStatusRequest *request = [[LSGetHangoutStatusRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSHangoutStatusItemObject *> *list) {
        NSLog(@"HangOutPreViewController::getHangoutStatus ([获取当前会员hangout直播状态] success : %@, errnum : %d, errmsg : %@,)", BOOL2SUCCESS(success), errnum, errmsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.exitLeftSecond > 0) {
                if (errnum == HTTP_LCC_ERR_EXIST_HANGOUT) {
                    
                    weakSelf.status = list;
                    LSHangoutStatusItemObject *obj = weakSelf.status.firstObject;
                    
                    NSLog(@"HangOutPreViewController::HangoutStatus (roomid : %@, anchorListCount : %lu)",obj.liveRoomId,(unsigned long)obj.anchorList.count);
                    
                    if (obj.anchorList.count > 0) {
                        [weakSelf showHttpErrorType:errnum tip:errmsg];
                    } else {
                        [weakSelf enterHangoutRoom:weakSelf.roomId isCreateOnly:YES];
                    }
                } else {
                    [weakSelf enterHangoutRoom:weakSelf.roomId isCreateOnly:YES];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)enterHangoutRoom:(NSString *)roomId isCreateOnly:(BOOL)isCreateOnly {
    // TODO:观众新建/进入多人互动直播间
    self.preType = HANGOUT_PERIOD_ENTERING;
    if (!roomId.length) {
        roomId = @"";
        self.preType = HANGOUT_PERIOD_ENTERNEW;
    }
    WeakObject(self, weakSelf);
    BOOL bFlag = [self.imManager enterHangoutRoom:roomId isCreateOnly:isCreateOnly finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString * _Nonnull errMsg, IMHangoutRoomItemObject * _Nonnull item) {
        NSLog(@"HangOutPreViewController::enterHangoutRoom( [观众新建/进入多人互动直播间] success : %@, errType : %d, errMsg : %@, roomId : %@ isCreateOnly : %d )", BOOL2SUCCESS(success), errType, errMsg, item.roomId, isCreateOnly);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.exitLeftSecond > 0) {
                if (success) {
                    // 创建多人互动直播间成功
                    if (item.roomType == ROOMTYPE_HANGOUTROOM) {
                        weakSelf.liveRoom.roomType = LiveRoomType_Hang_Out;
                    }
                    weakSelf.liveRoom.hangoutLiveRoom = item;
                    // 更新本地信用点
                    [[LiveRoomCreditRebateManager creditRebateManager] setCredit:item.credit];
                    
                    // 如果房间没有主播则邀请主播 有则判断主播状态
                    if (item.otherAnchorList.count > 0) {
                        IMLivingAnchorItemObject *obj = item.otherAnchorList.firstObject;
                        switch (obj.anchorStatus) {
                            case LIVEANCHORSTATUS_INVITECONFIRM:
                            case LIVEANCHORSTATUS_KNOCKCONFIRM:
                            case LIVEANCHORSTATUS_RECIPROCALENTER:
                            case LIVEANCHORSTATUS_ONLINE:{
                                [weakSelf stopHandleTimer];
                                
                                HangOutViewController *vc = [[HangOutViewController alloc] initWithNibName:nil bundle:nil];
                                // 主播队列
                                for (IMLivingAnchorItemObject *obj in item.otherAnchorList) {
                                    [vc anchorArrayAddObject:obj];
                                }
                                // 礼物队列
                                for (IMRecvGiftItemObject *obj in item.buyforList) {
                                    [vc roomGiftListAddObject:obj];
                                }
                                vc.liveRoom = weakSelf.liveRoom;
                                vc.inviteAnchorId = weakSelf.inviteAnchorId;
                                vc.inviteAnchorName = weakSelf.inviteAnchorName;
                                [weakSelf.navigationController pushViewController:vc animated:YES];
                            }break;
                                
                            default:{
                            }break;
                        }
                    } else {
                        if (item.roomId.length > 0) {
                            weakSelf.roomId = item.roomId;
                            [weakSelf sendHangoutInvite:NO];
                        }
                    }
                } else {
                    // 创建失败
                    [weakSelf showErrorType:errType tip:errMsg];
                }
            }
        });
    }];
    if (!bFlag) {
        [self showErrorType:LCC_ERR_CONNECTFAIL tip:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
    }
}

- (void)sendHangoutInvite:(BOOL)isCreateOnly {
    // TODO:发起多人互动邀请
    self.preType = HANGOUT_PERIOD_INVITING;
    WeakObject(self, weakSelf);
    LSSendinvitationHangoutRequest *request = [[LSSendinvitationHangoutRequest alloc] init];
    request.roomId = self.roomId;
    request.anchorId = self.inviteAnchorId;
    request.recommendId = nil;
    request.isCreateOnly = isCreateOnly;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, NSString * _Nonnull inviteId, int expire) {
        NSLog(@"HangOutPreViewController::sendHangoutInvite( [发起多人互动邀请 %@] errnum : %d, errmsg : %@,"
              "roomId : %@, inviteId : %@, erpire : %d isCreateOnly : %d )", BOOL2SUCCESS(success), errnum, errmsg, roomId, inviteId, expire, isCreateOnly);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.exitLeftSecond > 0) {
                if (success) {
                    weakSelf.inviteId = inviteId;
                    [weakSelf upQNInviteId:inviteId roomId:roomId];
                } else {
                    [weakSelf showHttpErrorType:errnum tip:errmsg];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)upQNInviteId:(NSString *)inviteId roomId:(NSString *)roomId {
    LSUpQnInviteIdRequest *request = [[LSUpQnInviteIdRequest alloc] init];
    request.manId = [LSLoginManager manager].loginItem.userId;
    request.anchorId = self.inviteAnchorId;
    request.inviteId = inviteId;
    request.roomId = roomId;
    request.inviteType = LSBUBBLINGINVITETYPE_HANGOUT;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        
    };
    [self.sessionManager sendRequest:request];
}

- (void)sendCancelHangoutInvit {
    // TODO:取消多人互动邀请
    LSCancelInviteHangoutRequest *request = [[LSCancelInviteHangoutRequest alloc] init];
    request.inviteId = self.inviteId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        NSLog(@"HangOutPreViewController::LSCancelInviteHangoutRequest( [取消多人互动邀请 %@] errnum : %d,"
              "errmsg : %@ )",success == YES ? @"成功":@"失败", errnum, errmsg);
    };
    [self.sessionManager sendRequest:request];
}

- (void)getHangoutInviteStatu {
    // TODO:查询Hangout邀请状态
    WeakObject(self, weakSelf);
    if (self.inviteId.length > 0 && self.preType == HANGOUT_PERIOD_INVITING) {
        LSGetHangoutInvitStatusRequest *request = [[LSGetHangoutInvitStatusRequest alloc] init];
        request.inviteId = self.inviteId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, HangoutInviteStatus status, NSString *_Nonnull roomId, int expire) {
            NSLog(@"HangOutPreViewController::getHangoutInviteStatu( [查询多人互动邀请状态] success : %@, errnum : %d, errmsg : %@,"
                  "status : %d, roomId : %@, expire : %d )",
                  BOOL2SUCCESS(success), errnum, errmsg, status, roomId, expire);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    if ([weakSelf.roomId isEqualToString:roomId]) {
                        weakSelf.inviteAnchor = [[IMLivingAnchorItemObject alloc] init];
                        weakSelf.inviteAnchor.anchorId = weakSelf.inviteAnchorId;
                        weakSelf.inviteAnchor.nickName = weakSelf.inviteAnchorName;
                        weakSelf.inviteAnchor.anchorStatus = LIVEANCHORSTATUS_UNKNOW;
                        weakSelf.inviteAnchor.inviteId = weakSelf.inviteId;
                        weakSelf.inviteAnchor.leftSeconds = 0;
                        weakSelf.inviteAnchor.loveLevel = 0;
                        
                        switch (status) {
                            // 同意 直接进入直播间
                            case IMREPLYINVITETYPE_AGREE: {
                                HangOutViewController *vc = [[HangOutViewController alloc] initWithNibName:nil bundle:nil];
                                [vc anchorArrayAddObject:weakSelf.inviteAnchor];
                                weakSelf.liveRoom.roomId = roomId;
                                vc.liveRoom = weakSelf.liveRoom;
                                vc.inviteAnchorId = weakSelf.inviteAnchorId;
                                vc.inviteAnchorName = weakSelf.inviteAnchorName;
                                self.hangoutVC = vc;
                                [weakSelf.navigationController pushViewController:vc animated:YES];
                                
                            } break;
                                
                            // 拒绝/超时
                            case IMREPLYINVITETYPE_REJECT:
                            case IMREPLYINVITETYPEE_OUTTIME:{
                                NSString *errmsg = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_REJECT"),weakSelf.inviteAnchorName];
                                [weakSelf showErrorType:0 tip:errmsg];
                            }break;
                                
                            // 没钱
                            case IMREPLYINVITETYPE_NOCREDIT:{
                                [weakSelf showErrorType:LCC_ERR_NO_CREDIT tip:NSLocalizedStringFromSelf(@"NO_CREDIT")];
                            }break;
                                
                            // 主播忙
                            case IMREPLYINVITETYPE_BUSY:{
                                [weakSelf showErrorType:0 tip:NSLocalizedStringFromSelf(@"INVITE_BUSY")];
                            }break;
                                
                            default:{
                            }break;
                        }
                    }
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
}

#pragma mark - IM通知
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"HangOutPreViewController::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"HangOutViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onRecvDealInviteHangoutNotice:(IMRecvDealInviteItemObject *)item {
    NSLog(@"HangOutPreViewController::onRecvDealInviteHangoutNotice( [接收主播回复观众多人互动邀请通知] invteId : %@, roomId : %@,"
          "anchorId : %@, type : %d)", item.inviteId, item.roomId, item.anchorId, item.type);
    BOOL isEquelAnchorId = NO;
    if (self.hangoutAnchorId.length > 0 && ![self.hangoutAnchorId isEqualToString:@""]) {
        isEquelAnchorId = [item.anchorId isEqualToString:self.hangoutAnchorId];
    } else {
        isEquelAnchorId = [item.anchorId isEqualToString:self.inviteAnchorId];
    }
    BOOL isEquelRoomId = [item.roomId isEqualToString:self.roomId];
    if (isEquelAnchorId && isEquelRoomId) {
        self.inviteAnchor = [[IMLivingAnchorItemObject alloc] init];
        self.inviteAnchor.anchorId = item.anchorId;
        self.inviteAnchor.nickName = item.nickName;
        self.inviteAnchor.photoUrl = item.photoUrl;
        self.inviteAnchor.anchorStatus = LIVEANCHORSTATUS_UNKNOW;
        self.inviteAnchor.inviteId = item.inviteId;
        self.inviteAnchor.leftSeconds = 0;
        self.inviteAnchor.loveLevel = 0;
        
        WeakObject(self, weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.exitLeftSecond > 0) {
                [weakSelf stopHandleTimer];
                
                switch (item.type) {
                        // 同意 直接进入直播间
                    case IMREPLYINVITETYPE_AGREE:{
                        HangOutViewController *vc = [[HangOutViewController alloc] initWithNibName:nil bundle:nil];
                        [vc anchorArrayAddObject:self.inviteAnchor];
                        weakSelf.liveRoom.roomId = item.roomId;
                        vc.liveRoom = weakSelf.liveRoom;
                        vc.inviteAnchorId = weakSelf.inviteAnchorId;
                        vc.inviteAnchorName = weakSelf.inviteAnchorName;
                        self.hangoutVC = vc;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    }break;
                        
                        // 拒绝/超时
                    case IMREPLYINVITETYPE_REJECT:
                    case IMREPLYINVITETYPEE_OUTTIME:{
                        NSString *errmsg = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_REJECT"),item.nickName];
                        [weakSelf showErrorType:0 tip:errmsg];
                    }break;
                        
                        // 没钱
                    case IMREPLYINVITETYPE_NOCREDIT:{
                        [weakSelf showErrorType:LCC_ERR_NO_CREDIT tip:NSLocalizedStringFromSelf(@"NO_CREDIT")];
                    }break;
                        
                        // 主播忙
                    case IMREPLYINVITETYPE_BUSY:{
                        [weakSelf showErrorType:0 tip:NSLocalizedStringFromSelf(@"INVITE_BUSY")];
                    }break;
                        
                    default:{
                    }break;
                }
            }
        });
    }
}

- (void)onRecvEnterHangoutRoomNotice:(IMRecvEnterRoomItemObject *)item {
    NSLog(@"HangOutPreViewController::onRecvEnterHangoutRoomNotice( [接收观众/主播进入多人互动直播间] roomId : %@, userId : %@,"
          "nickName : %@ )",item.roomId, item.userId, item.nickName);
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!item.isAnchor && [self.loginManager.loginItem.userId isEqualToString:item.userId]) {
            weakSelf.liveRoom.roomId = item.roomId;
            weakSelf.liveRoom.userId = item.userId;
            weakSelf.liveRoom.userName = item.nickName;
            weakSelf.liveRoom.photoUrl = item.photoUrl;
            weakSelf.liveRoom.publishUrlArray = item.pullUrl;
        }
    });
}

- (void)onRecvAnchorCountDownEnterHangoutRoomNotice:(NSString *)roomId anchorId:(NSString *)anchorId leftSecond:(int)leftSecond {
    BOOL isEqualUserId = [anchorId isEqualToString:self.inviteAnchor.anchorId];
    BOOL isEqualRoomId = [roomId isEqualToString:self.roomId];
    
    if (isEqualUserId && isEqualRoomId) {
        NSLog(@"HangOutPreViewController::onRecvAnchorCountDownEnterHangoutRoomNotice( [接收进入多人互动直播间倒数] roomId : %@, anchorId : %@ leftSecond : %d )",roomId, anchorId, leftSecond);
        WeakObject(self, weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.inviteAnchor.anchorStatus = LIVEANCHORSTATUS_RECIPROCALENTER;
            weakSelf.inviteAnchor.leftSeconds = leftSecond;
            
            if (weakSelf.hangoutVC) {
                [weakSelf.hangoutVC upDateChildView:anchorId];
            }
        });
    }
}

- (void)resetView:(BOOL)isLoading tip:(NSString *)tip {
    self.tipLabel.text = tip;
    self.addCreditBtn.hidden = YES;
    self.retryButton.hidden = YES;
    self.goMyRoomBtn.hidden = YES;
    self.startNewRoomBtn.hidden = YES;
    if (isLoading) {
        self.loadingView.hidden = NO;
        [self.loadingView startAnimating];
    } else {
        self.loadingView.hidden = YES;
        [self.loadingView stopAnimating];
    }
}

- (void)showRetryBtnTip:(NSString *)tip {
    self.preType = HANGOUT_PERIOD_RETRY;
    self.tipLabel.text = tip;
    self.addCreditBtn.hidden = YES;
    self.retryButton.hidden = NO;
    self.goMyRoomBtn.hidden = YES;
    self.startNewRoomBtn.hidden = YES;
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimating];
}

- (void)showAddCreditBtnTip:(NSString *)tip {
    self.preType = HANGOUT_PERIOD_NOCREDIT;
    self.tipLabel.text = tip;
    self.addCreditBtn.hidden = NO;
    self.retryButton.hidden = YES;
    self.goMyRoomBtn.hidden = YES;
    self.startNewRoomBtn.hidden = YES;
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimating];
}

- (void)showHaveMyHangoutRoomTip:(NSString *)tip {
    self.preType = HANGOUT_PERIOD_HAVEROOM;
    self.tipLabel.text = tip;
    self.addCreditBtn.hidden = YES;
    self.retryButton.hidden = YES;
    self.goMyRoomBtn.hidden = NO;
    self.startNewRoomBtn.hidden = NO;
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimating];
}

- (void)showErrorType:(LCC_ERR_TYPE)type tip:(NSString *)errorMsg {
    [self stopHandleTimer];
    
    self.preType = HANGOUT_PERIOD_ERROR;
    switch (type) {
        case LCC_ERR_CONNECTFAIL:{
            [self showRetryBtnTip:errorMsg];
        }break;
            
        case LCC_ERR_NO_CREDIT:{
            [self showAddCreditBtnTip:errorMsg];
        }break;
            
        default:{
            [self resetView:NO tip:errorMsg];
        }break;
    }
}

- (void)showHttpErrorType:(HTTP_LCC_ERR_TYPE)type tip:(NSString *)errorMsg {
    [self stopHandleTimer];
    
    self.preType = HANGOUT_PERIOD_ERROR;
    switch (type) {
        case HTTP_LCC_ERR_CONNECTFAIL:{
            [self showRetryBtnTip:errorMsg];
        }break;
            
        case HTTP_LCC_ERR_NO_CREDIT:{
            [self showAddCreditBtnTip:errorMsg];
        }break;
            
        case HTTP_LCC_ERR_EXIST_HANGOUT:{
            [self showHaveMyHangoutRoomTip:errorMsg];
        }break;
        
        default:{
            [self resetView:NO tip:errorMsg];
        }break;
    }
}

#pragma mark - 总超时控制
- (void)handleCountDown {
    WeakObject(self, weakSelf);
    self.exitLeftSecond--;
    if (self.exitLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒数完成, 提示超时
            [weakSelf stopHandleTimer];
            
            NSString *tip;
            if (weakSelf.hangoutAnchorName.length > 0 && ![weakSelf.hangoutAnchorName isEqualToString:@""]) {
                tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_REJECT"),weakSelf.hangoutAnchorName];
            } else {
                tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_REJECT"),weakSelf.inviteAnchorName];
            }
            [weakSelf showErrorType:0 tip:tip];
        });
    }
}

- (void)startHandleTimer {
    NSLog(@"HangOutPreViewController::startHandleTimer()");
    
    WeakObject(self, weakSelf);
    [self.handleTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf handleCountDown];
    }];
}

- (void)stopHandleTimer {
    NSLog(@"HangOutPreViewController::stopHandleTimer()");
    
    [self.handleTimer stopTimer];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.anchorArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IMLivingAnchorItemObject *item = self.anchorArray[indexPath.row];
    HangOutPreAnchorPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HangOutPreAnchorPhotoCell cellIdentifier] forIndexPath:indexPath];
    [cell setupCellDate:item];
    return cell;
}

#pragma mark - 界面事件
- (IBAction)retryAction:(id)sender {
    [self stopHandleTimer];
    [self startHandleTimer];
    
    NSString *tip;
    if (self.hangoutAnchorName.length > 0 && ![self.hangoutAnchorName isEqualToString:@""]) {
        tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_ANCHOR"),self.hangoutAnchorName];
    } else {
        tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_ANCHOR"),self.inviteAnchorName];
    }
    [self resetView:YES tip:tip];
    self.roomId = @"";
    [self enterHangoutRoom:self.roomId isCreateOnly:YES];
}

- (IBAction)closeAction:(id)sender {
    [self stopHandleTimer];
    
    if (self.inviteId.length > 0 && self.preType == HANGOUT_PERIOD_INVITING) {
        [self sendCancelHangoutInvit];
    }
    if (self.roomId.length > 0) {
        [[LSImManager manager] leaveHangoutRoom:self.roomId finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg) {
            NSLog(@"HangOutPreViewController::leaveHangoutRoom - closeAction[退出旧的多人互动直播间 %@]",BOOL2SUCCESS(success));
        }];
    }
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:YES completion:nil];
}

- (IBAction)addCreditsAction:(id)sender {
    [self stopHandleTimer];
    
    LSAddCreditsViewController * vc = [[LSAddCreditsViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goMyRoomAction:(id)sender {
    [self stopHandleTimer];
    [self startHandleTimer];
    
    [self.anchorArray removeAllObjects];
    LSHangoutStatusItemObject *obj = self.status.firstObject;
    self.roomId = obj.liveRoomId;
    
    NSString *tip;
    for (int index = 0; index < obj.anchorList.count; index++) {
        LSFriendsInfoItemObject *item = obj.anchorList[index];
        IMLivingAnchorItemObject *anchor = [[IMLivingAnchorItemObject alloc] init];
        anchor.anchorId = item.anchorId;
        anchor.nickName = item.nickName;
        [self.anchorArray addObject:anchor];
    
        NSLog(@"HangOutPreViewController::goMyRoomAction (anchorIndex : %d, anchorID : %@)",index, item.anchorId);
        
        if (index == 0) {
            // 重置邀请主播ID 防止进入直播间发起错误邀请
            self.inviteAnchorId = item.anchorId;
            
            tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_ANCHOR"),item.nickName];
            // 重新赋值邀请名称
            if (self.hangoutAnchorName.length > 0 && ![self.hangoutAnchorName isEqualToString:@""]) {
                self.hangoutAnchorName = item.nickName;
            } else {
                self.inviteAnchorName = item.nickName;
            }
        }
    }
    
    self.collectionViewWidth.constant = self.anchorArray.count * 100;
    [self.collectionView reloadData];
    [self resetView:YES tip:tip];
    
    [self enterHangoutRoom:self.roomId isCreateOnly:NO];
}

- (IBAction)startNewRoomAction:(id)sender {
    [self stopHandleTimer];
    [self startHandleTimer];
    
    NSString *tip;
    if (self.hangoutAnchorName.length > 0 && ![self.hangoutAnchorName isEqualToString:@""]) {
        tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_ANCHOR"),self.hangoutAnchorName];
    } else {
        tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_ANCHOR"),self.inviteAnchorName];
    }
    [self resetView:YES tip:tip];
    
    [self enterHangoutRoom:self.roomId isCreateOnly:YES];
}

@end
