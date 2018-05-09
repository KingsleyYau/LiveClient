//
//  HangOutViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangOutViewController.h"
#import "HangOutLiverViewController.h"
#import "HangOutUserViewController.h"

#import "LSImManager.h"
#import "LSLoginManager.h"
#import "LSSessionRequestManager.h"
#import "LiveGiftDownloadManager.h"
#import "LSChatEmotionManager.h"
#import "LiveStreamSession.h"
#import "UserInfoManager.h"
#import "LiveRoomCreditRebateManager.h"

#import "AllGiftItem.h"
#import "AudienModel.h"

#import "SelectNumButton.h"
#import "DialogTip.h"

#import "LSSendinvitationHangoutRequest.h"
#import "LSCancelInviteHangoutRequest.h"
#import "LSGetCanHangoutAnchorListRequest.h"

@interface HangOutViewController ()<IMManagerDelegate, IMLiveRoomManagerDelegate, HangOutLiverViewControllerDelegate,
                                    LiveSendBarViewDelegate, LSCheckButtonDelegate>

// 管理空闲主播窗口队列
@property (nonatomic, strong) NSMutableArray *hangoutArray;

// 管理正在使用的主播窗口字典
@property (nonatomic, strong) NSMutableDictionary *hangoutDic;

// 当前直播间主播队列
@property (nonatomic, strong) NSMutableArray *anchorArray;

// 男士视屏窗口
@property (nonatomic, strong) HangOutUserViewController *userVC;

// 点击邀请按钮的主播窗口
@property (nonatomic, strong) HangOutLiverViewController *liverVC;

// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;

// IM管理器
@property (nonatomic, strong) LSImManager *imManager;

// 请求管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

// 礼物列表下载管理器
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;

// 表情列表管理器
@property (nonatomic, strong) LSChatEmotionManager *chatEmotionManager;

// 个人信息管理器
@property (nonatomic, strong) UserInfoManager *infoManager;

// 信用点管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditManager;

// 多功能按钮
@property (strong) SelectNumButton* buttonBar;
/*
 *  多功能按钮约束
 */
@property (strong) MASConstraint *buttonBarBottom;
@property (nonatomic, assign) int buttonBarHeight;

// 聊天框被选中名字
@property (nonatomic, copy) NSString *selectName;

// 3秒提示框
@property (nonatomic, strong) DialogTip *dialogTipView;

@end

@implementation HangOutViewController

- (void)dealloc {
    NSLog(@"HangOutViewController:dealloc()");
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [self.hangoutArray removeAllObjects];
    [self.hangoutDic removeAllObjects];
}

- (void)initCustomParam {
    [super initCustomParam];
    
    // 初始化控制器队列
    self.hangoutArray = [[NSMutableArray alloc] init];
    
    // 初始化代理管理器
    self.hangoutDic = [[NSMutableDictionary alloc] init];
    
    // 初始化主播队列
    self.anchorArray = [[NSMutableArray alloc] init];
    
    // 初始化点击邀请按钮的主播窗口
    self.liverVC = [[HangOutLiverViewController alloc] init];
    
    // 初始化登录管理器
    self.loginManager = [LSLoginManager manager];
    
    // 初始化im管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    // 初始化请求管理器
    self.sessionManager = [LSSessionRequestManager manager];
    
    // 初始化礼物下载管理器
    self.giftDownloadManager = [LiveGiftDownloadManager manager];
    
    // 初始化表情管理器
    self.chatEmotionManager = [LSChatEmotionManager emotionManager];
    
    // 初始化用户信息管理器
    self.infoManager = [UserInfoManager manager];
    
    // 初始化信用点管理器
    self.creditManager = [LiveRoomCreditRebateManager creditRebateManager];
    
    // 3秒提示框
    self.dialogTipView = [DialogTip dialogTip];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupChildViewVC];
    
    [self setupInputMessageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [self.dialogTipView removeShow];
}

- (void)setupChildViewVC {
    
    CGFloat length = [UIScreen mainScreen].bounds.size.width / 2;
    for (int i = 0; i < 3; i++) {
        HangOutLiverViewController *liverVC = [[HangOutLiverViewController alloc] init];
        liverVC.index = i;
        liverVC.inviteDelegate = self;
        [self addChildViewController:liverVC];
        [self.videoBottomView addSubview:liverVC.view];
        
        [liverVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            if (i == 0 || i == 1) {
                make.top.equalTo(@(0));
            } else {
                make.top.equalTo(@(length));
            }
            
            if (i == 0 || i == 2) {
                make.left.equalTo(@(0));
            } else {
                make.left.equalTo(@(length));
            }
            
            make.width.height.equalTo(@(length));
        }];
        
        [self.hangoutArray addObject:liverVC];
    }
    
    self.userVC = [[HangOutUserViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.userVC];
    [self.videoBottomView addSubview:self.userVC.view];
    [self.userVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(length));
        make.left.equalTo(@(length));
        make.width.height.equalTo(@(length));
    }];
}

#pragma mark - 文本和表情输入控件管理
- (void)setupInputMessageView {
    self.liveSendBarView.delegate = self;
    if ([LSDevice iPhoneXStyle]) {
        self.inputMessageViewBottom.constant = -35;
    }
    self.inputMessageView.layer.shadowColor = Color(0, 0, 0, 0.7).CGColor;
    self.inputMessageView.layer.shadowOffset = CGSizeMake(0, -0.5);
    self.inputMessageView.layer.shadowOpacity = 0.5;
    self.inputMessageView.layer.shadowRadius = 1.0f;
    [self showInputMessageView];
    
    // 聊天输入框
    self.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0xb296df);
    self.liveSendBarView.inputTextField.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
    // 隐藏表情按钮
    self.liveSendBarView.emotionBtnWidth.constant = 0;
}

- (void)showInputMessageView {
    self.chatBtn.hidden = NO;
    self.giftBtn.hidden = NO;
    
    self.liveSendBarView.hidden = YES;
}

- (void)hideInputMessageView {
    self.chatBtn.hidden = YES;
    self.giftBtn.hidden = YES;
    
    self.liveSendBarView.hidden = NO;
}

#pragma mark - 初始化多功能按钮
- (void)setupButtonBar {
    self.buttonBar = [[SelectNumButton alloc] init];
    [self.view addSubview:self.buttonBar];
    [self.buttonBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        make.left.equalTo(self.chatAudienceView.mas_left);
        make.right.equalTo(self.chatAudienceView.mas_right);
        self.buttonBarBottom = make.bottom.equalTo(self.chatAudienceView.mas_bottom);
    }];
    self.buttonBar.isVertical = YES;
    self.buttonBar.clipsToBounds = YES;
    
    self.selectBtn.selectedChangeDelegate = self;
}

#pragma mark - 多功能按钮管理
- (void)setupButtonBar:(NSArray *)audienceArray {
    
    [self.buttonBar removeAllButton];
    
    UIImage *normalImage = [LSUIImageFactory createImageWithColor:Color(41, 122, 243, 0.81) imageRect:CGRectMake(0, 0, 1, 1)];
    
    NSMutableArray *chatNameArray = [[NSMutableArray alloc] init];
    [chatNameArray addObjectsFromArray:audienceArray];
    
    AudienModel *item = [[AudienModel alloc] init];
    item.nickName = NSLocalizedStringFromSelf(@"CHAT_AUDIENCE_ALL");
    [chatNameArray insertObject:item atIndex:0];
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < chatNameArray.count; i++) {
        
        AudienModel *model = chatNameArray[i];
        
        NSString *title = [NSString stringWithFormat:@"      %@",model.nickName];
        UIButton *firstNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [firstNumBtn setTitle:title forState:UIControlStateNormal];
        [firstNumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        firstNumBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        firstNumBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [firstNumBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [firstNumBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
        [firstNumBtn addTarget:self action:@selector(selectFirstNum:) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:firstNumBtn];
    }
    self.buttonBar.items = items;
    [self.buttonBar reloadData:YES];
    self.buttonBarHeight = 22 * (int)chatNameArray.count;
}

- (void)selectFirstNum:(id)sender {
    UIButton *btn = sender;
    NSString *name = [btn.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.audienceNameLabel.text = [NSString stringWithFormat:@"@ %@",name];
    self.selectName = self.audienceNameLabel.text;
    [self hiddenButtonBar];
}

#pragma mark - LSCheckButtonDelegate
- (void)selectedChanged:(id)sender {
    
    if (sender == self.selectBtn) {
        if (self.selectBtn.selected) {
            [self setupButtonBar:self.anchorArray];
            [self showButtonBar];
        } else {
            [self hiddenButtonBar];
        }
    }
}

#pragma mark - HangOutLiverViewControllerDelegate
- (void)inviteAnchorJoinHangOut:(HangOutLiverViewController *)liverVC {
    self.liverVC = liverVC;
    LSHangoutAnchorItemObject *obj = [[LSHangoutAnchorItemObject alloc] init];
    obj.anchorId = @"harrytest";
    obj.nickName = @"harry";
    [self.liverVC sendHangoutInvite:obj];
}

- (void)invitationHangoutRequest:(BOOL)success errMsg:(NSString *)errMsg liverVC:(HangOutLiverViewController *)liverVC {
    if (success) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (HangOutLiverViewController *vc in self.hangoutArray) {
            if (vc.index == liverVC.index) {
                @synchronized(self.hangoutDic) {
                    [self.hangoutDic setObject:liverVC forKey:liverVC.liveRoom.userId];
                }
            } else {
                [array addObject:vc];
            }
        }
        @synchronized(self.hangoutArray) {
            self.hangoutArray = array;
        }
    } else {
        [self showdiaLog:errMsg];
    }
}

- (void)cancelInviteHangoutRequest:(BOOL)success errMsg:(NSString *)errMsg liverVC:(HangOutLiverViewController *)liverVC {
    if (success) {
        [self resetAnchorWindow:liverVC userId:liverVC.liveRoom.userId];
    } else {
        [self showdiaLog:errMsg];
    }
}

- (void)inviteHangoutNotAgreeNotice:(HangOutLiverViewController *)liverVC {
    // 释放绑定的控制器
    [self resetAnchorWindow:liverVC userId:liverVC.liveRoom.userId];
}

- (void)leaveHangoutRoomNotice:(HangOutLiverViewController *)liverVC {
    // 释放绑定的控制器
    [self resetAnchorWindow:liverVC userId:liverVC.liveRoom.userId];
}

- (void)loadVideoOvertime:(HangOutLiverViewController *)liverVC {
    // 释放绑定的控制器
    [self resetAnchorWindow:liverVC userId:liverVC.liveRoom.userId];
}

- (void)resetAnchorWindow:(HangOutLiverViewController *)vc userId:(NSString *)userId {
    @synchronized(self.hangoutArray) {
        [self.hangoutArray addObject:vc];
        // 窗口排序
        [self.hangoutArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            HangOutLiverViewController * oneVC = obj1;
            HangOutLiverViewController * twoVC = obj2;
            return [@(oneVC.index) compare:@(twoVC.index)];
        }];
    }
    @synchronized(self.hangoutDic) {
        [self.hangoutDic removeObjectForKey:userId];
    }
    NSLog(@"排序好了");
}

#pragma mark - HTTP请求
- (void)sendGetCanHangOutAnchorList {
    LSGetCanHangoutAnchorListRequest *request = [[LSGetCanHangoutAnchorListRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LSHangoutAnchorItemObject *> * _Nullable array) {
        
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - LiveSendBarViewDelegate
- (void)sendBarLouserAction:(LiveSendBarView *)sendBarView isSelected:(BOOL)isSelected {
}

- (void)sendBarEmotionAction:(LiveSendBarView *)sendBarView isSelected:(BOOL)isSelected {
    // 表情/软键盘切换
}

- (void)sendBarSendAction:(LiveSendBarView *)sendBarView {
    // 发送聊天
//    NSString *str =  [self.liveSendBarView.inputTextField.fullText stringByReplacingOccurrencesOfString:@" " withString:@""];
//    if ([self.liveVC sendMsg:self.liveSendBarView.inputTextField.fullText] || !str.length) {
//        self.liveSendBarView.inputTextField.fullText = nil;
//    }
}

#pragma mark - 界面事件
- (IBAction)chatBtnAction:(id)sender {
    if ([self.liveSendBarView.inputTextField canBecomeFirstResponder]) {
        [self.liveSendBarView.inputTextField becomeFirstResponder];
    }
}

- (IBAction)giftBtnAction:(id)sender {
    
}

#pragma mark - 界面显示/隐藏
/** 显示聊天选择框 **/
- (void)showButtonBar {
    [self.buttonBarBottom uninstall];
    self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, -M_PI);
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.buttonBarHeight));
        self.buttonBarBottom = make.bottom.equalTo(self.chatAudienceView.mas_top).offset(-2);
    }];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.buttonBar.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         self.selectBtn.selected = YES;
                     }];
}

/** 收起聊天选择框 **/
- (void)hiddenButtonBar {
    [self.buttonBarBottom uninstall];
    self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, M_PI);
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        self.buttonBarBottom = make.bottom.equalTo(self.chatAudienceView.mas_bottom);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.buttonBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.selectBtn.selected = NO;
    }];
}

- (void)showdiaLog:(NSString *)tip {
    [self.dialogTipView showDialogTip:self.view tipText:tip];
}

#pragma mark - IM通知
- (void)onRecvHangoutGiftNotice:(IMRecvHangoutGiftItemObject *)item {
    NSLog(@"HangOutViewController::onRecvHangoutGiftNotice( [接收多人互动直播间礼物通知] roomId : %@, fromId : %@, toUid : %@,"
          "giftId : %@ )",item.roomId, item.fromId, item.toUid, item.giftId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.liveRoom.roomId isEqualToString:item.roomId]) {
            // 判断本地是否有该礼物 无则下载
            BOOL bHave = [self.giftDownloadManager judgeTheGiftidIsHere:item.giftId];
            if (bHave) {
                AllGiftItem *giftItem = [self.giftDownloadManager backGiftItemWithGiftID:item.giftId];
                switch (giftItem.infoItem.type) {
                    case GIFTTYPE_CELEBRATE:{ // 庆祝礼物 当前VC播放
                    }break;
                        
                    default:{
                        // toUid有值发送给指定对象 无则发送给全部
                        if (item.toUid.length) {
                            HangOutLiverViewController *vc = [self.hangoutDic objectForKey:item.toUid];
                            if (vc) {
                                [vc onSendGiftNoticePlay:item];
                            }
                            
                        } else {
                            if (self.hangoutDic.count) {
                                NSArray *keys = [self.hangoutDic allKeys];
                                for (int i = 0; i < keys.count; i++) {
                                    NSString *key = keys[i];
                                    HangOutLiverViewController *vc = [self.hangoutDic objectForKey:key];
                                    if (vc) {
                                        [vc onSendGiftNoticePlay:item];
                                    }
                                }
                            }
                        }
                    }break;
                }
            } else {
                // 获取礼物详情
                [self.giftDownloadManager requestListnotGiftID:item.giftId];
            }
        }
    });
    
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    if (height != 0) {
        
        // 弹出键盘
//        self.liveVC.msgSuperViewTop.constant =  - height + 5; 聊天列表
        self.inputMessageViewBottom.constant = - height;
        
    } else {
        // 收起键盘
        if ([LSDevice iPhoneXStyle]) {
            self.inputMessageViewBottom.constant = -35;
        } else {
            self.inputMessageViewBottom.constant = 0;
        }
//        self.liveVC.msgSuperViewTop.constant = 5;
        
        if (self.liveSendBarView.inputTextField.fullText.length) {
            [self.chatBtn setTitle:self.liveSendBarView.inputTextField.fullText forState:UIControlStateNormal];
        } else {
            [self.chatBtn setTitle:NSLocalizedStringFromSelf(@"INPUT_PLACEHOLDER") forState:UIControlStateNormal];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
    
    // 改变控件状态
    [self hideInputMessageView];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // 动画收起键盘
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    
    if( self.liveSendBarView.emotionBtn.selected != YES ) {
        // 改变控件状态
        [self showInputMessageView];
    }
}


@end
