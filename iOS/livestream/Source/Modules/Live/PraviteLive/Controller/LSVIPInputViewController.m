//
//  LSVIPInputViewController.m
//  livestream
//
//  Created by Calvin on 2019/8/29.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSVIPInputViewController.h"

#import "LSExpertPhizCollectionView.h"
#import "LSNormalPhizCollectionView.h"
#import "DialogTip.h"

#import "LiveModule.h"
#import "LiveRoomCreditRebateManager.h"
#import "LSChatEmotionManager.h"
#import "LiveUrlHandler.h"
#import "HomeVouchersManager.h"

#import "LSGiftManagerItem.h"
#import "LSChatEmotion.h"

#import "GetLeftCreditRequest.h"

#define PlaceholderFont [UIFont boldSystemFontOfSize:14]
#define MaxInputCount 70
#define INPUTMESSAGEVIEW_MAX_HEIGHT 44.0 * 2

#define MSGVIEWBOTTOM 130
#define MSGVIEWHEIGHT (SCREEN_HEIGHT/2 - MSGVIEWBOTTOM)


@interface LSVIPInputViewController () <UITextViewDelegate, LSCheckButtonDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate,
                                        IMLiveRoomManagerDelegate, LSVIPLiveViewControllerDelegate, LSNormalPhizCollectionViewDelegate, LSPhizPageViewDelegate, LSExpertPhizCollectionViewDelegate, UIGestureRecognizerDelegate, LSGiftManagerDelegate, LiveRoomCreditRebateManagerDelegate, LSVIPGiftPageViewControllerDelegate, LSTopGiftViewDelegate, LSLiveTextViewDelegate>

/** 键盘弹出 **/
@property (nonatomic, assign) BOOL isKeyboradShow;

/** 大礼物播放队列 **/
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

/** 表情选择器键盘 **/
@property (nonatomic, strong) LSPhizPageView *chatEmotionKeyboardView;

/** 普通表情 */
@property (nonatomic, strong) LSNormalPhizCollectionView *chatNomalEmotionView;

/** 高亲密度表情 */
@property (nonatomic, strong) LSExpertPhizCollectionView *chatAdvancedEmotionView;

#pragma mark - 管理器
// IM管理器
@property (nonatomic, strong) LSImManager *imManager;
// 表情管理类
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 礼物下载管理器
@property (nonatomic, strong) LSGiftManager *giftManager;
// 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;
// 3秒toast控件
@property (nonatomic, strong) DialogTip *dialogTipView;

// 进入直播间时间
@property (strong) NSDate *roomInDate;

//缓存输入框内容
@property (nonatomic, copy) NSAttributedString *emotionAttributedString;

@property (nonatomic, strong) UIButton *closeInputBtn;
@end

@implementation LSVIPInputViewController

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"LSVIPInputViewController::initCustomParam()");

    // 隐藏导航栏
    self.isShowNavBar = NO;
    // 禁止导航栏后退手势
    self.canPopWithGesture = NO;

    // 直播间展现管理器
    self.liveVC = [[LSVIPLiveViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.liveVC];
    self.liveVC.liveDelegate = self;

    // 礼物管理器
    self.giftVC = [[LSVIPGiftPageViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.giftVC];
    self.giftVC.vcDelegate = self;

    // 初始化toast控件
    self.dialogTipView = [DialogTip dialogTip];

    // 初始化Im管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    // 初始化余额管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    [self.creditRebateManager addDelegate:self];

    // 初始化登录管理器
    self.loginManager = [LSLoginManager manager];
    // 初始化接口管理器
    self.sessionManager = [LSSessionRequestManager manager];
    // 初始化表情管理器
    self.emotionManager = [LSChatEmotionManager emotionManager];

    self.msgSuperTabelTop = 0;

    self.liveVC.msgSuperViewBottom.constant = MSGVIEWBOTTOM;
}

- (void)dealloc {
    NSLog(@"LSVIPInputViewController::dealloc()");

    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];

    [self.creditRebateManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化直播间界面管理器
    self.liveVC.liveRoom = self.liveRoom;
    // 初始化直播间界面样式
    self.liveVC.roomStyleItem = self.roomStyleItem;
    // 初始化礼物列表界面管理器
    self.giftVC.liveRoom = self.liveRoom;
    self.giftVC.roomStyleItem = self.roomStyleItem;
    // 初始化进入房间时间
    self.roomInDate = [NSDate date];

    // 初始化公共界面
    [self.view addSubview:self.liveVC.view];

    [self.liveVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    [self.view sendSubviewToBack:self.liveVC.view];
    [self.view bringSubviewToFront:self.liveVC.msgSuperView];
    [self.view bringSubviewToFront:self.liveVC.previewVideoView];

    // 初始化礼物列表界面
    [self.chooseGiftListView addSubview:self.giftVC.view];
    self.chooseGiftListView.hidden = YES;

    self.inputBGView.layer.cornerRadius = self.inputBGView.tx_height / 2;
    self.inputBGView.layer.masksToBounds = YES;

    self.inviteBtn.layer.cornerRadius = self.inviteBtn.tx_height / 2;
    self.inviteBtn.layer.masksToBounds = YES;

    self.chooseTopGiftView.layer.cornerRadius = 8;
    self.chooseTopGiftView.layer.masksToBounds = YES;

    self.inputTextView.placeholder = NSLocalizedStringFromSelf(@"INPUT_MSG");
    self.inputTextView.font = PlaceholderFont;
    self.inputTextView.delegate = self;
    self.inputTextView.liveTextViewDelegate = self;

    // 私密直播间
    if (self.roomStyleItem.emotionImage && self.roomStyleItem.emotionSelectImage) {
        self.emotionBtn.adjustsImageWhenHighlighted = NO;
        [self.emotionBtn setImage:self.roomStyleItem.emotionImage forState:UIControlStateNormal];
        [self.emotionBtn setImage:self.roomStyleItem.emotionSelectImage forState:UIControlStateSelected];
        self.emotionBtn.selectedChangeDelegate = self;
        // inputView约束
        self.inputViewRight.constant = 5;
        self.sendBtnWidth.constant = 64;
        self.inviteBtnWidth.constant = 0;
        // inputMessageView约束
        self.popBtnWidth.constant = 0;
        self.emotionBtnWidth.constant = 41;
        self.inputTextViewRight.constant = 14;
        self.inviteFreeImage.hidden = YES;
    }

    // 公开直播间
    if (self.roomStyleItem.popBtnImage && self.roomStyleItem.popBtnSelectImage) {
        self.popBtn.adjustsImageWhenHighlighted = NO;
        [self.popBtn setImage:self.roomStyleItem.popBtnImage forState:UIControlStateNormal];
        [self.popBtn setImage:self.roomStyleItem.popBtnSelectImage forState:UIControlStateSelected];
        self.popBtn.selectedChangeDelegate = self;
        // inputView约束
        self.inputViewRight.constant = 10;
        self.sendBtnWidth.constant = 0;

        self.inviteFreeImage.hidden = ![[HomeVouchersManager manager] isShowInviteFree:self.liveRoom.userId];
        // 男士无私密权限或者为节目直播间 不显示邀请按钮
        if (self.liveRoom.priv.isHasOneOnOneAuth && !self.liveRoom.liveShowType) {
            self.inviteBtnWidth.constant = SCREEN_WIDTH / 2 - 10;
        } else {
            self.inviteFreeImage.hidden = YES;
            self.inviteBtnWidth.constant = 0;
        }

        // inputMessageView约束
        self.popBtnWidth.constant = 44;
        self.emotionBtnWidth.constant = 0;
        self.inputTextViewRight.constant = 7;
    }

    // 初始化表情控件
    [self setupEmotionInputView];

    self.topGiftView.delegate = self;
    self.topGiftView.liveRoom = self.liveRoom;
    [self.topGiftView getGiftData];

    self.chooseTopGiftView.backgroundColor = self.roomStyleItem.chooseTopGiftViewBgColor;
    [self.topGiftViewBtn setImage:self.roomStyleItem.topGiftViewBtnImage forState:UIControlStateNormal];

    self.closeInputBtn = [[UIButton alloc] init];
    [self.closeInputBtn addTarget:self action:@selector(closeInputBtnDid:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 请求账户余额
    [self getLeftCreditRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 关闭输入
    [self closeAllInputView];

    // 清除提示
    [self.dialogTipView removeShow];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    // 添加手势
    [self addSingleTap];

    [self.giftVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.chooseGiftListView);
        make.width.equalTo(self.chooseGiftListView);
        make.bottom.equalTo(self.chooseGiftListView);
        make.height.equalTo(@(self.giftVC.viewHeight));
    }];
    // 使约束生效
    [self.giftVC.view layoutSubviews];
    self.chooseGiftListViewHeight.constant = self.giftVC.viewHeight;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    // 去除手势
    [self removeSingleTap];

    // 切换界面收起礼物列表 隐藏连击按钮
    if (self.chooseGiftListViewTop.constant != 0) {
        [self closeChooseGiftListView];
    }
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化输入框
    [self setupInputMessageView];
}

#pragma mark - 选择按钮回调
- (void)selectedChanged:(id)sender {
    if (sender == self.emotionBtn) {
        [self.closeInputBtn removeFromSuperview];
        [self.view endEditing:YES];
        UIButton *emotionBtn = (UIButton *)sender;
        if (emotionBtn.selected) {
            // 弹出底部emotion的键盘
            [self showEmotionView];
        } else {
            // 切换成系统的的键盘
            [self showKeyboardView];
        }
    } else if (sender == self.popBtn) {
        if (self.popBtn.selected) {
            self.inputTextView.placeholder = NSLocalizedStringFromSelf(@"POP_MSG");
            // 调用修改view color方法 触发drawRect
            [self.inputTextView setBackgroundColor:[UIColor clearColor]];
        } else {
            self.inputTextView.placeholder = NSLocalizedStringFromSelf(@"INPUT_MSG");
            // 调用修改view color方法 触发drawRect
            [self.inputTextView setBackgroundColor:COLOR_WITH_16BAND_RGB_ALPHA(0x00000000)];
        }
    }
}

#pragma mark - 文本和表情输入控件管理
- (void)setupInputMessageView {

    [self showInputMessageView];
}

- (void)showInputMessageView {
    self.inputMessageView.hidden = YES;
}

- (void)hideInputMessageView {
    self.inputMessageView.hidden = NO;
}

#pragma mark - 初始化表情输入控件
- (void)setupEmotionInputView {
    // 普通表情
    if (self.chatNomalEmotionView == nil) {
        self.chatNomalEmotionView = [LSNormalPhizCollectionView emotionChooseView:self];
        self.chatNomalEmotionView.delegate = self;
        self.chatNomalEmotionView.stanListItem = self.emotionManager.stanListItem;
        self.chatNomalEmotionView.tipView.hidden = NO;
        self.chatNomalEmotionView.tipLabel.text = self.emotionManager.stanListItem.errMsg;
        [self.chatNomalEmotionView reloadData];
    }

    // 高亲密度表情
    if (self.chatAdvancedEmotionView == nil) {
        self.chatAdvancedEmotionView = [LSExpertPhizCollectionView friendlyEmotionView:self];
        self.chatAdvancedEmotionView.delegate = self;
        self.chatAdvancedEmotionView.advanListItem = self.emotionManager.advanListItem;
        self.chatAdvancedEmotionView.tipLabel.text = self.emotionManager.advanListItem.errMsg;
        [self.chatAdvancedEmotionView reloadData];
    }

    // 表情选择器
    if (self.chatEmotionKeyboardView == nil) {
        self.chatEmotionKeyboardView = [LSPhizPageView LSPageChooseKeyboardView:self];
        self.chatEmotionKeyboardView.delegate = self;
        self.chatEmotionKeyboardView.hidden = YES;
        [self.view addSubview:self.chatEmotionKeyboardView];
        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.inputMessageView.mas_width);
            make.height.equalTo(@219);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(5);
        }];

        NSMutableArray *array = [NSMutableArray array];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"VIPLive_Phiz"];
        [button setImage:image forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
        [array addObject:button];

        button = [UIButton buttonWithType:UIButtonTypeCustom];
        image = [UIImage imageNamed:@"VIPLive_VIPPhiz"];
        [button setImage:image forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
        [array addObject:button];

        self.chatEmotionKeyboardView.buttons = array;
    }
    // 请求表情列表
    [self getLiveRoomEmotionList];
}

#pragma mark - 显示直播间可发送表情
- (void)getLiveRoomEmotionList {
    for (NSNumber *i in self.liveRoom.imLiveRoom.emoTypeList) {
        if ([i intValue] == 1) {
            self.chatAdvancedEmotionView.isCanSend = YES;
        } else {
            self.chatNomalEmotionView.tipView.hidden = YES;
        }
    }
}

#pragma mark - 请求账号余额
- (void)getLeftCreditRequest {
    GetLeftCreditRequest *request = [[GetLeftCreditRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, LSLeftCreditItemObject *_Nonnull item) {
        NSLog(@"LSVIPInputViewController::getLeftCreditRequest( [获取账号余额请求结果], %@, errnum : %ld, errmsg : %@, credit : %f, coupon : %d, postStamp : %f, livechatCount : %d )", BOOL2SUCCESS(success), (long)errnum, errmsg, item.credit, item.coupon, item.postStamp, item.liveChatCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.creditRebateManager setCredit:item.credit];
            } else {
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 推荐礼物点击回调
- (void)topGiftViewDidSelectItem:(LSGiftManagerItem *)item {
    //TODO 直接调用 self.giftVC的发送方法
    [self.giftVC didSendGiftAction:nil item:item];
}

#pragma mark - LSVIPLiveViewControllerDelegate
- (void)onReEnterRoom:(LSVIPLiveViewController *)vc {
    if ([self.playDelegate respondsToSelector:@selector(onReEnterRoom:)]) {
        [self.playDelegate onReEnterRoom:self];
    }
}

- (void)noCreditPushTo:(LSVIPLiveViewController *)vc {
    if ([self.playDelegate respondsToSelector:@selector(pushToAddCredit:)]) {
        [self.playDelegate pushToAddCredit:self];
    }
}

- (void)showHangoutTipView:(LSVIPLiveViewController *)vc {
    // 公开直播间弹出hangout提示控件
    if ([self.playDelegate respondsToSelector:@selector(showPubilcHangoutTipView:)]) {
        [self.playDelegate showPubilcHangoutTipView:self];
    }
}

- (void)closeAllInputView:(LSVIPLiveViewController *)vc {
    // 关闭所有输出设备
    [self closeAllInputView];
    if ([self.playDelegate respondsToSelector:@selector(didRemoveGiftListInfo:)]) {
        [self.playDelegate didRemoveGiftListInfo:self];
    }
}

- (void)pushStoreVC:(LSVIPLiveViewController *)vc {
    if ([self.playDelegate respondsToSelector:@selector(pushStoreVC:)]) {
        [self.playDelegate pushStoreVC:self];
    }
}

#pragma mark - IM回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"LSVIPInputViewController::onLogin( [IM登录], errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LSVIPInputViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LSVIPInputViewController::onSendGift( [发送直播间礼物消息], errmsg : %@, credit : %f, rebateCredit : %f )", errmsg, credit, rebateCredit);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (credit > 0) {
                [self.creditRebateManager setCredit:credit];

                self.liveRoom.imLiveRoom.rebateInfo.curCredit = rebateCredit;
            }
        }
    });
}

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LSVIPInputViewController::onSendToast( [发送直播间弹幕消息, %@], errmsg : %@, credit : %f, rebateCredit : %f )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errmsg, credit, rebateCredit);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (credit > 0) {
                self.liveRoom.imLiveRoom.rebateInfo.curCredit = rebateCredit;
            }
        } else if (errType == LCC_ERR_NO_CREDIT) {
        }
    });
}

- (void)onRecvRebateInfoNotice:(NSString *_Nonnull)roomId rebateInfo:(RebateInfoObject *_Nonnull)rebateInfo {
    NSLog(@"LSVIPInputViewController::onRecvRebateInfoNotice( [接收返点通知], roomId : %@", roomId);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置余额及返点信息管理器
        IMRebateItem *imRebateItem = [[IMRebateItem alloc] init];
        imRebateItem.curCredit = rebateInfo.curCredit;
        imRebateItem.curTime = rebateInfo.curTime;
        imRebateItem.preCredit = rebateInfo.preCredit;
        imRebateItem.preTime = rebateInfo.preTime;

        // 更新本地返点信息
        self.liveRoom.imLiveRoom.rebateInfo = rebateInfo;

    });
}

- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"LSVIPInputViewController::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    dispatch_async(dispatch_get_main_queue(), ^{
                       // 更新blanceview等级

                   });
}

- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *_Nonnull)loveLevelItem {
    NSLog(@"LSVIPInputViewController::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知],  loveLevel : %d, anchorId: %@, anchorName: %@ )", loveLevelItem.loveLevel, loveLevelItem.anchorId, loveLevelItem.anchorName);
    dispatch_async(dispatch_get_main_queue(), ^{
        //本地写死3级
        if (loveLevelItem.loveLevel >= 3) {
            self.chatAdvancedEmotionView.isCanSend = YES;
        }
    });
}

#pragma mark - 界面事件
- (IBAction)tapInputView:(id)sender {
    [self.inputTextView becomeFirstResponder];
}

- (IBAction)topGiftViewBtnDid:(UIButton *)sender {

    // 隐藏底部
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.chooseTopGiftView.alpha = 0;
                     }];

    // 显示礼物列表
    [self showChooseGiftListView];
}

- (IBAction)sendBtnDid:(UIButton *)sender {

    [self keyboardDidSendBtn];
}

- (IBAction)inviteBtnDid:(id)sender {

    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorName:self.liveRoom.userName anchorId:self.liveRoom.userId roomType:LiveRoomType_Private];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)closeInputBtnDid:(id)sender {
    [self.closeInputBtn removeFromSuperview];
    [self singleTapAction];
}

#pragma mark - 显示礼物列表
- (void)showChooseGiftListView {
    [self.view addSubview:self.closeInputBtn];
    [self.closeInputBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.chooseGiftListView.hidden = NO;
    self.giftVC.isShowView = YES;
    self.chooseTopGiftView.hidden = YES;
    if (!self.topGiftView.isShowGiftData) {
        [self.topGiftView getGiftData];
    }

    [self.view layoutIfNeeded];
    self.chooseGiftListViewTop.constant = -self.chooseGiftListViewHeight.constant;
    [UIView animateWithDuration:0.25
        animations:^{
            [self.view layoutIfNeeded];
        }
        completion:^(BOOL finished) {
            [self.view bringSubviewToFront:self.chooseGiftListView];
        }];
}

- (void)closeChooseGiftListView {
    // TODO:收起礼物列表
    [self.view layoutIfNeeded];
    self.chooseTopGiftView.hidden = NO;
    self.chooseGiftListViewTop.constant = 0;
    [UIView animateWithDuration:0.25
        animations:^{
            [self.view layoutIfNeeded];
            self.chooseTopGiftView.alpha = 1;
        }
        completion:^(BOOL finished) {
            self.chooseGiftListView.hidden = YES;
            [self showBottomView];
        }];
}

- (void)showKeyboardView {
    // TODO:显示系统键盘
    self.inputTextView.inputView = nil;
    [self.inputTextView becomeFirstResponder];
}

/** 显示表情选择 **/
- (void)showEmotionView {
    // 关闭系统键盘
    [self.inputTextView resignFirstResponder];
    // 添加关闭inputView按钮
    [self.view addSubview:self.closeInputBtn];
    [self.closeInputBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputMessageView.mas_top);
    }];
   
    [self.view bringSubviewToFront:self.inputMessageView];
    
    if (self.inputMessageViewBottom.constant != -self.chatEmotionKeyboardView.frame.size.height) {
        self.chatEmotionKeyboardView.hidden = NO;

        if (IS_IPHONE_X) {
            CGFloat height = self.chatEmotionKeyboardView.frame.size.height + 35;
            [self moveInputBarWithKeyboardHeight:height withDuration:0.25];
        } else {
            // 未显示则显示
            [self moveInputBarWithKeyboardHeight:self.chatEmotionKeyboardView.frame.size.height withDuration:0.25];
        }

        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputMessageView.mas_bottom);
        }];
    }
    [self.chatEmotionKeyboardView reloadData];
}

- (void)closeAllInputView {
    // 关闭表情输入
    if (self.emotionBtn.selected == YES) {
        if (self.inputTextView.isFirstResponder) {
            [self.inputTextView resignFirstResponder];
        }
        self.emotionBtn.selected = NO;
        [self moveInputBarWithKeyboardHeight:0 withDuration:0.25];
        [self showInputMessageView];
        self.chatEmotionKeyboardView.hidden = YES;
    } else {
        // 关闭键盘输入
        [self.inputTextView resignFirstResponder];
    }
}

- (void)hiddenBottomView {
    // 隐藏底部输入框
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.inputMessageView.transform = CGAffineTransformMakeTranslation(0, 54);
                     }];
}

- (void)showBottomView {
    // 显示底部输入框
    [UIView animateWithDuration:0.2
                          delay:0.25
                        options:0
                     animations:^{
                         self.inputMessageView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

// 显示3秒toas提示控件
- (void)showDialogTipView:(NSString *)tipText {
    [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:tipText];
}

#pragma mark - 礼物列表界面回调(LSVIPGiftPageViewControllerDelegate)
- (void)showCreditView:(NSString *)tip {
    [self.liveVC showAddCreditsView:tip];
}

- (void)didUpBtnHidenGiftList:(LSVIPGiftPageViewController *)vc {
    [self closeChooseGiftListView];
}

- (void)didShowGiftListInfo:(LSVIPGiftPageViewController *)vc {
    if ([self.playDelegate respondsToSelector:@selector(didShowGiftListInfo:)]) {
        [self.playDelegate didShowGiftListInfo:self];
    }
}

#pragma mark - 手势事件 (单击屏幕)
- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        self.singleTap.delegate = self;
        [self.liveVC.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.liveVC.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
        self.singleTap.delegate = nil;
    }
}

- (void)singleTapAction {
    // 单击关闭输入
    [self closeAllInputView];

    // 如果已经展开礼物列表
    if (self.chooseGiftListView.frame.origin.y < SCREEN_HEIGHT) {
        // 收起礼物列表
        [self closeChooseGiftListView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint pt = [touch locationInView:self.view];
    if (!CGRectContainsPoint([self.chooseGiftListView frame], pt)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 普通表情选择回调 (LSNormalPhizCollectionViewDelegate)
- (void)liveStandardEmotionView:(LSNormalPhizCollectionView *)liveStandardEmotionView didSelectNomalItem:(NSInteger)item {
    LSChatEmotion *emotion = [self.emotionManager.stanEmotionList objectAtIndex:item];

    if (self.inputTextView.text.length <= MaxInputCount) {
        // 插入表情描述到输入框
        [self.inputTextView insertEmotion:emotion];
    }
}

#pragma mark - 高亲密度表情选择回调 (LSExpertPhizCollectionViewDelegate)
- (void)liveAdvancedEmotionView:(LSExpertPhizCollectionView *)liveAdvancedEmotionView didSelectNomalItem:(NSInteger)item {

    LSChatEmotion *emotion = [self.emotionManager.advanEmotionList objectAtIndex:item];

    if (self.inputTextView.text.length <= MaxInputCount) {
        // 插入表情描述到输入框
        [self.inputTextView insertEmotion:emotion];
    }
}

#pragma mark - 表情、礼物键盘选择回调 (LSPhizPageViewDelegate)
- (NSUInteger)pagingViewCount:(LSPhizPageView *)pageChooseKeyboardView {
    return 2;
}

- (Class)pageChooseKeyboardView:(LSPhizPageView *)pageChooseKeyboardView classForIndex:(NSUInteger)index {
    Class cls = nil;

    if (pageChooseKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
            // 普通表情
            cls = [LSNormalPhizCollectionView class];
        } else if (index == 1) {
            // 高亲密度表情
            cls = [LSExpertPhizCollectionView class];
        }

    } else {
    }
    return cls;
}

- (UIView *)pageChooseKeyboardView:(LSPhizPageView *)pageChooseKeyboardView pageViewForIndex:(NSUInteger)index {
    UIView *view = nil;

    if (pageChooseKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
            view = self.chatNomalEmotionView;
            view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);
        } else if (index == 1) {
            view = self.chatAdvancedEmotionView;
            view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);
        }
    } else {
        //        if (index == 0) {
        //            view = self.presentView;
        //        } else if (index == 1) {
        //            view = self.backpackView;
        //        }
    }
    return view;
}

- (void)pageChooseKeyboardView:(LSPhizPageView *)pageChooseKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    if (pageChooseKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
            // 普通表情
            [self.chatNomalEmotionView reloadData];

        } else if (index == 1) {
            // 高级表情
            [self.chatAdvancedEmotionView reloadData];
        }
    } else {
        if (index == 0) {
        } else if (index == 1) {
        }
    }
}

- (void)pageChooseKeyboardView:(LSPhizPageView *)pageChooseKeyboardView didShowPageViewForDisplay:(NSUInteger)index {
    if (pageChooseKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
        } else if (index == 1) {
        }
    } else {
        if (index == 0) {
        } else if (index == 1) {
        }
    }
}

- (void)pageChooseKeyboardViewDidSendBtn {
    [self keyboardDidSendBtn];
}
#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    BOOL bFlag = NO;

    if (height != 0) {
        // 添加关闭inputView按钮
        [self.view addSubview:self.closeInputBtn];
        [self.closeInputBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [self.view bringSubviewToFront:self.inputMessageView];
        // 弹出键盘
        if (IS_IPHONE_X) {
            self.inputMessageViewBottom.constant = -height + 35;
            self.liveVC.msgSuperViewBottom.constant = self.inputBGView.tx_height + height - 30;
        } else {
            self.inputMessageViewBottom.constant = -height;
            self.liveVC.msgSuperViewBottom.constant = self.inputBGView.tx_height + height;
        }

        self.liveVC.msgSuperViewH.constant = MSGVIEWHEIGHT / 2;

        if (!self.liveVC.isMsgPushDown) {
            NSInteger height = MSGVIEWHEIGHT - self.liveVC.msgTableViewTop.constant;
            if (height < self.liveVC.msgSuperViewH.constant) {
                self.liveVC.msgTableViewTop.constant = self.liveVC.msgSuperViewH.constant - height;
            } else {
                self.liveVC.msgTableViewTop.constant = 0;
            }
        }

        bFlag = YES;

    } else {
        [self.closeInputBtn removeFromSuperview];
        self.chatEmotionKeyboardView.hidden = YES;

        // 收起键盘
        self.inputMessageViewBottom.constant = -5;

        self.liveVC.msgSuperViewBottom.constant = MSGVIEWBOTTOM;
        self.liveVC.msgSuperViewH.constant = MSGVIEWHEIGHT;

        if (self.inputTextView.text.length > 0) {
            self.bottomMsgLabel.attributedText = self.inputTextView.attributedText;
            self.bottomMsgLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        } else {
            self.bottomMsgLabel.font = [UIFont systemFontOfSize:14];
            self.bottomMsgLabel.textColor = COLOR_WITH_16BAND_RGB(0x383838);
            self.bottomMsgLabel.text = NSLocalizedStringFromSelf(@"BOTTOM_MSG");
        }

        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(5);
        }];
    }
    if (self.liveVC.isMsgPushDown) {
        self.liveVC.msgTableViewTop.constant = self.liveVC.msgSuperViewH.constant;
    } else {
        if (self.liveVC.topInterval < self.liveVC.msgSuperViewH.constant) {
            self.liveVC.msgTableViewTop.constant = self.liveVC.msgSuperViewH.constant - self.liveVC.topInterval;
        } else {
            self.liveVC.msgTableViewTop.constant = 0;
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
    // 从表情键盘切换成系统键盘,保存普通表情的富文本属性
    self.emotionAttributedString = self.inputTextView.attributedText;
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];

    // 改变控件状态
    [self hideInputMessageView];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // 动画收起键盘
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];

    if (self.emotionBtn.selected != YES) {
        // 改变控件状态
        [self showInputMessageView];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (!self.liveVC.isMsgPushDown) {
        [self.liveVC chatListScrollToEnd];
    }
}

#pragma mark - 文本输入回调 (UITextViewDelegate)
- (void)textViewDidChange:(UITextView *)textView {
    // 超过字符限制
    NSString *toBeString = textView.text;
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (position) {
        if (toBeString.length > MaxInputCount) {
            // 取出之前保存的属性
            textView.attributedText = self.emotionAttributedString;

        } else {
            // 记录当前的富文本属性
            self.emotionAttributedString = textView.attributedText;
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // 增加手势
    [self addSingleTap];
    // 切换所有按钮到系统键盘状态
    self.emotionBtn.selected = NO;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL result = YES;

    if ([text containEmoji]) {
        // 系统表情，不允许输入
        result = NO;
    } else if ([text isEqualToString:@"\n"]) {
        // 输入回车，即按下send，不允许输入
        [self keyboardDidSendBtn];
        result = NO;
    } else {
        // 判断是否超过字符限制
        NSInteger strLength = textView.text.length - range.length + text.length;
        if (strLength > MaxInputCount && text.length >= range.length) {
            // 判断是否删除字符
            if ('\000' != [text UTF8String][0] && ![text isEqualToString:@"\b"]) {
                // 非删除字符，不允许输入
                result = NO;
            }
        }
    }
    return result;
}

#pragma mark - 输入栏高度改变回调
- (void)textViewChangeHeight:(LSLiveTextView *)textView height:(CGFloat)height {
    if (height < INPUTMESSAGEVIEW_MAX_HEIGHT) {
        self.inputMessageViewHeight.constant = height + 10;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.inputTextView setNeedsDisplay];
    });
}

- (void)keyboardDidSendBtn {

        // 有输入内容才处理
        if (self.inputTextView.text.length > 0) {
            // TODO:点击发送按钮
            NSDate *now = [NSDate date];
            NSTimeInterval betweenTime = [now timeIntervalSinceDate:self.roomInDate];
            
            if (betweenTime >= 1) {
                NSString *str = [self.inputTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                if (str.length > 0) {
                    [self.liveVC sendMsg:self.inputTextView.text isLounder:self.popBtn.selected];
                    self.inputTextView.text = @"";
                    self.bottomMsgLabel.font = [UIFont systemFontOfSize:14];
                    self.bottomMsgLabel.textColor = COLOR_WITH_16BAND_RGB(0x383838);
                    self.bottomMsgLabel.text = NSLocalizedStringFromSelf(@"BOTTOM_MSG");
                    // 点击send关闭键盘
                    [self closeAllInputView];
                }
            } else {
                [self showDialogTipView:NSLocalizedStringFromSelf(@"SPEAK_TOO_FAST")];
                
            }
            self.roomInDate = now;
        }
}
@end
