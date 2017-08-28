//
//  PlayViewController.m
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PlayViewController.h"

#import "LiveViewController.h"
#import "PlayEndViewController.h"

#import "LiveStreamPlayer.h"

#import "FileCacheManager.h"

#import "CountTimeButton.h"

#import "GetLiveRoomGiftListByUserIdRequest.h"
#import "LiveRoomGiftItemObject.h"
#import "SendGiftItem.h"

#import "ChatTextLadyTableViewCell.h"
#import "ChatTextSelfTableViewCell.h"

#import "ChatFriendlyEmotionView.h"
#import "ChatEmotionChooseView.h"

#import "ChatEmotion.h"
#import "ChatMessageObject.h"
#import "ChatEmotionManager.h"

#import "SendGiftTheQueueManager.h"
#import "BackpackSendGiftManager.h"

#define ComboTitleFont [UIFont boldSystemFontOfSize:30]


@interface PlayViewController () <UITextFieldDelegate, KKCheckButtonDelegate,IMLiveRoomManagerDelegate,UIGestureRecognizerDelegate,
                                    PresentViewDelegate,IMLiveRoomManagerDelegate,LiveViewControllerDelegate, ChatEmotionChooseViewDelegate, ChatEmotionKeyboardViewDelegate,ChatFriendlyEmotionViewDelegate,ChatTextViewDelegate, GiftPresentViewDelegate,BackpackPresentViewDelegate>

/** 拉流地址 **/
@property (nonatomic, strong) NSString* url;

/** 推流组件 **/
@property (strong) LiveStreamPlayer* player;

/** 显示界面 **/
@property (strong) LiveViewController* liveVC;

/** 直播结束界面(观众) **/
@property (strong) PlayEndViewController* playEndVC;

/** IM管理器 **/
@property (nonatomic, strong) IMManager* imManager;

/** 登录管理器 **/
@property (nonatomic, strong) LoginManager* loginManager;

/** 首次点赞 **/
@property (nonatomic, assign) BOOL isFirstLike;

/** 键盘弹出 **/
@property (nonatomic, assign) BOOL isKeyboradShow;

/** 礼物列表首次点击 **/
@property (nonatomic, assign) BOOL isFirstClick;

/** 背包礼物首次点击 */
@property (nonatomic, assign) BOOL isBackpackFirstClick;

/** 是否是连击 **/
@property (nonatomic, assign) BOOL isMultiClick;

/** 是否正在连击中 **/
@property (nonatomic, assign) BOOL isComboing;

/** 点击Id **/
@property (nonatomic, assign) int clickId;

/** 记录点击Id **/
@property (nonatomic, assign) int recordClickId;

/** 礼物列表发送连击Button **/
@property (nonatomic, strong) CountTimeButton *comboBtn;

/** 大礼物播放队列 **/
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

/** 表情选择器键盘 **/
@property (nonatomic, strong) ChatEmotionKeyboardView *chatEmotionKeyboardView;

/** 普通表情 */
@property (nonatomic,strong)  ChatEmotionChooseView *chatNomalEmotionView;

/** 高亲密度表情 */
@property (nonatomic,strong)  ChatFriendlyEmotionView *chatFriendlyEmotionView;

/** 键盘弹出高度 */
@property (nonatomic,assign) CGFloat keyboardHeight;

/** 礼物列表选中cell */
@property (nonatomic, strong) LiveRoomGiftItemObject *selectCellItem;

/** inputView背景 */
@property (weak, nonatomic) IBOutlet UIImageView *inputShaowImageView;

/** 是否倒计时中 */
@property (nonatomic, assign) int countdownSender;

/** 当前送礼数、送礼总数、开始数、结束数 */
@property (nonatomic, assign) int giftNum;
@property (nonatomic, assign) int totalGiftNum;
@property (nonatomic, assign) int starNum;
@property (nonatomic, assign) int endNum;

/** 本地信用点 */
@property (nonatomic, assign) float creditNum;

/** 本地用户返点 */
@property (nonatomic, assign) float cur_creditNum;

/** 表情转义符解析器 **/
@property (nonatomic, strong) ChatMessageObject *chatMessageObject;

/** 送礼队列管理类 **/
@property (nonatomic, strong) SendGiftTheQueueManager *sendGiftTheQueueManager;

/** 表情管理类 **/
@property (nonatomic, strong) ChatEmotionManager *emotionManager;

/** 背包礼物管理类 */
@property (nonatomic, strong) BackpackSendGiftManager *backGiftManager;

/** 接口管理器 **/
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@end


@implementation PlayViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"PlayViewController::initCustomParam()");
    
//    self.url = @"rtmp://172.25.32.17/live/livestream";
//    self.url = @"rtmp://172.25.32.17/live/max";
    self.url = @"rtmp://172.25.32.17:1936/aac/max";
    
    self.liveVC = [[LiveViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.liveVC];
    self.liveVC.liveDelegate = self;
    
    self.chatMessageObject = [[ChatMessageObject alloc] init];
    
    // 添加直播间监听代理
    [[IMManager manager].client addDelegate:self];
    
    // 初始化管理器
    self.imManager = [IMManager manager];
    self.loginManager = [LoginManager manager];
    self.sessionManager = [SessionRequestManager manager];
    self.sendGiftTheQueueManager = [SendGiftTheQueueManager sendManager];
    self.emotionManager = [ChatEmotionManager emotionManager];
    self.backGiftManager = [BackpackSendGiftManager backpackGiftManager];
    
    // 初始化控制变量
    self.isFirstLike = NO; // 第一次点赞
    self.isKeyboradShow = NO; // 键盘是否弹出
    self.isMultiClick = NO; // 是否是连击
    self.isComboing = NO; // 是否正在连击
    
    // 记录连击ID初始化
    self.recordClickId = 0;
}

- (void)dealloc {
    NSLog(@"PlayViewController::dealloc()");
    
    // 添加直播间监听代理
    [[IMManager manager].client removeDelegate:self];
    
    [self.sendGiftTheQueueManager removeAllSendGift];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self.view addSubview:self.liveVC.view];
    [self.liveVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
    }];
    
    [self.liveVC.view removeConstraint:self.liveVC.msgTableViewBottom];
    [self.liveVC.tableSuperView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputMessageView.mas_top);
    }];
    
    // 初始化推流
    self.player = [LiveStreamPlayer instance];
    self.player.playView = self.liveVC.videoView;
    [self.view sendSubviewToBack:self.liveVC.view];
    
    // 初始化礼物列表界面
//    self.presentView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH * 0.5 + 55);
//    self.presentView.presentDelegate = self;
    
    self.chooseGiftListView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH * 0.5 + 99);
    
    // 初始化文本输入
    self.inputTextField.delegate = self;
    
    self.creditNum = 10000000;
    
    // 发送请求到服务器
    [self sendEnterRequest];
    [self sendGetGiftListRequest];

    // 加载主播头像
    [self.liveVC reloadLiverUserHeader:self.liveInfo.photoUrl];
    
    // 加载普通表情
    [self.emotionManager reloadEmotion];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 关闭输入
    [self closeAllInputView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    // 添加手势
    [self addSingleTap];
    
    // 开始播放
    [self play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    // 去除手势
    [self removeSingleTap];
    
    // 停止推流
    [self stop];
    
    // 移除所有送礼队列
    [self.sendGiftTheQueueManager removeAllSendGift];
    
    [self.presentView.comboBtn stop];
}

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化主播信息控件
    [self setupRoomView];
    
    // 初始化输入框
    [self setupInputMessageView];
    
    // 初始化表情列表
    [self setupEmotionInputView];
    
    // 初始化礼物列表
    [self setupGiftListView];
    
    // 初始化退出
    [self.liveVC.btnCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 主播信息控件管理
- (void)setupRoomView {
    self.liveVC.favourBtn.hidden = NO;
    [self.liveVC.favourBtn addTarget:self action:@selector(favourAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)favourAction:(id)sender {
    
}

#pragma mark - 文本和表情输入控件管理
- (void)setupInputMessageView {
    self.inputBackgroundView.layer.cornerRadius = self.inputBackgroundView.frame.size.height / 2;
    [self.btnLouder setImage:[UIImage imageNamed:@"Live_Input_Btn_Louder_Highlighted"] forState:UIControlStateSelected];
    
    [self.btnShare setImage:[UIImage imageNamed:@"Live_Publish_Btn_Share_Highlighted"] forState:UIControlStateHighlighted];
    
    self.btnSend.layer.cornerRadius = self.btnSend.frame.size.height / 2;
    UIEdgeInsets titleInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.btnSend setTitleEdgeInsets:titleInset];
    
    self.inputTextField.bottomLine.hidden = YES;
    self.inputTextField.font = PlaceholderFont;
    
    // 表情输入
    self.btnEmotion.adjustsImageWhenHighlighted = NO;
    self.btnEmotion.selectedChangeDelegate = self;
    [self.btnEmotion setImage:[UIImage imageNamed:@"Chat-EmotionGray"] forState:UIControlStateNormal];
    [self.btnEmotion setImage:[UIImage imageNamed:@"Chat-EmotionBlue"] forState:UIControlStateSelected];
    
    [self changePlaceholder:NO];
    
    [self showInputMessageView];
}

- (void)showInputMessageView {
    self.btnChat.hidden = NO;
    self.saysomeLabel.hidden = NO;
    self.btnShare.hidden = NO;
    self.btnShareWidth.constant = 40;
    self.btnGift.hidden = NO;
    self.btnGiftWidth.constant = 40;
    self.inputBackgroundView.hidden = YES;
    self.btnEmotion.hidden = YES;
    self.btnEmotionWidth.constant = 0;
    self.btnSend.hidden = YES;
    self.btnSendWidth.constant = 0;
}

- (void)hideInputMessageView {
    self.btnChat.hidden = YES;
    self.saysomeLabel.hidden = YES;
    self.btnShare.hidden = YES;
    self.btnShareWidth.constant = 0;
    self.btnGift.hidden = YES;
    self.btnGiftWidth.constant = 0;
    self.inputBackgroundView.hidden = NO;
    self.btnEmotion.hidden = NO;
    self.btnEmotionWidth.constant = 25;
    self.btnSend.hidden = NO;
    self.btnSendWidth.constant = 65;
}

- (void)changePlaceholder:(BOOL)louder {
    UIFont* font = PlaceholderFont;
    UIColor* color = [UIColor whiteColor];
    
    if( louder ) {
        // 切换成弹幕
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"INPUT_LOUDER_PLACEHOLDER")];
        [attributeString addAttributes:@{
                                         NSFontAttributeName : font,
                                         NSForegroundColorAttributeName:color
                                         }
                                 range:NSMakeRange(0, attributeString.length)
         ];
        self.inputTextField.attributedPlaceholder = attributeString;
        self.inputBackgroundColorView.backgroundColor = COLOR_WITH_16BAND_RGB(0xFFD205);
        [self.btnLouder setImage:[UIImage imageNamed:@"Live_Input_Btn_Louder_Selected"] forState:UIControlStateNormal];
        
    } else {
        // 切换成功普通
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"INPUT_PLACEHOLDER")];
        [attributeString addAttributes:@{
                                         NSFontAttributeName : font,
                                         NSForegroundColorAttributeName:color
                                         }
                                 range:NSMakeRange(0, attributeString.length)
         ];
        self.inputTextField.attributedPlaceholder = attributeString;
        self.inputBackgroundColorView.backgroundColor = COLOR_WITH_16BAND_RGB(0xFFFFFF);
        [self.btnLouder setImage:[UIImage imageNamed:@"Live_Input_Btn_Louder"] forState:UIControlStateNormal];
    }
}

#pragma mark - 初始化表情输入控件
- (void)setupEmotionInputView {
    
    // 普通表情
    if (self.chatNomalEmotionView == nil) {
        self.chatNomalEmotionView = [ChatEmotionChooseView emotionChooseView:self];
        self.chatNomalEmotionView.delegate = self;
        self.chatNomalEmotionView.emotions = self.emotionManager.emotionArray;
        [self.chatNomalEmotionView reloadData];
    }
    
    // 高亲密度表情
    if (self.chatFriendlyEmotionView == nil) {
        self.chatFriendlyEmotionView = [ChatFriendlyEmotionView friendlyEmotionView:self];
        self.chatFriendlyEmotionView.delegate = self;
        self.chatFriendlyEmotionView.emotions = self.emotionManager.emotionArray;
        [self.chatFriendlyEmotionView reloadData];
    }
    
    // 表情选择器
    if( self.chatEmotionKeyboardView == nil ) {
        self.chatEmotionKeyboardView = [ChatEmotionKeyboardView chatEmotionKeyboardView:self];
        self.chatEmotionKeyboardView.delegate = self;
        
        [self.view addSubview:self.chatEmotionKeyboardView];
        
        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.inputMessageView.mas_width);
            make.height.equalTo(@262);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.inputShaowImageView.mas_bottom).offset(0);
        }];
        
        NSMutableArray* array = [NSMutableArray array];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setTitle:@"Standard" forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
        [array addObject:button];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setTitle:@"Advanced" forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
        [array addObject:button];
        
        self.chatEmotionKeyboardView.buttons = array;
    }
}


#pragma mark - 初始化猎物列表选择控件
- (void)setupGiftListView {
    
    if ( self.presentView == nil ) {
        CGRect frame = CGRectMake(0, 0, 375, 272);
        self.presentView = [[PresentView alloc] initWithFrame:frame];
        self.presentView.presentDelegate = self;
    }
    
    if ( self.backpackView == nil ) {
        CGRect frame = CGRectMake(0, 0, 375, 272);
        self.backpackView = [[BackpackPresentView alloc] initWithFrame:frame];
        self.backpackView.backpackDelegate = self;
    }
    
    if( self.giftListView == nil ) {
        self.giftListView = [ChatEmotionKeyboardView chatEmotionKeyboardView:self];
        self.giftListView.delegate = self;
        self.giftListView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.5 + 99);
        [self.chooseGiftListView addSubview:self.giftListView];
    }

    NSMutableArray* array = [NSMutableArray array];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setTitle:@"Store" forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;
    [array addObject:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setTitle:@"Backpack" forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;
    [array addObject:button];
    
    self.giftListView.buttons = array;
}

#pragma mark - 直播间信息
- (void)setLiveInfo:(LiveRoomInfoItemObject *)liveInfo {
    _liveInfo = liveInfo;
    self.liveVC.roomId = _liveInfo.roomId;
}

#pragma mark - LiveViewControllerDelegate
- (void)sendRoomToastBackCoinsToPlay:(double)coins{
    
    self.presentView.coinsNumLabel.text = [NSString stringWithFormat:@"%.2f",coins];
    self.backpackView.coinsNumLabel.text = [NSString stringWithFormat:@"%.2f",coins];
}


#pragma mark - 数据逻辑
- (void)play {
//    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* recordFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.flv"];
    NSString* recordH264FilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.h264"];
    NSString* recordAACFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.aac"];
    
    // 开始转菊花
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFlag = [self.player playUrl:self.url recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止菊花
            if( bFlag ) {
                // 播放成功
                
            } else {
                // 播放失败
            }
        });
    });
}

- (void)stop {
    // 停止推流
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.player stop];
    });
}

- (void)sendEnterRequest {
    NSLog(@"PlayViewController::sendEnterRequest( [发送粉丝进入直播间请求, roomId : %@ )", self.liveInfo.roomId);
    
    [self.imManager sendFansRoomInWithRoomId:self.liveInfo.roomId];
}

- (void)sendExitRequest {
    NSLog(@"PlayViewController::sendExitRequest( [发送粉丝退出直播间请求, roomId : %@ )", self.liveInfo.roomId);
    
    [self.imManager sendFansRoomoutWithRoomId:self.liveInfo.roomId];
}

- (void)sendRoomGiftFormLiveItem:(LiveRoomGiftItemObject *)item andGiftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum {
    NSLog(@"PlayViewController::sendRoomGiftFormLiveItem( "
          "[发送礼物请求], "
          "roomId : %@, giftId : %@, giftNum : %d, starNum : %d, endNum : %d  multi_click_id : %d )",
          self.liveInfo.roomId, item.giftId, giftNum, starNum, endNum, self.clickId);
    
    SendGiftItem *sendGiftItem = [[SendGiftItem alloc] initWithGiftItem:item andGiftNum:giftNum starNum:starNum endNum:endNum clickID:self.clickId];
    
        if (self.recordClickId != self.clickId) {
            NSMutableArray *comboArray = [[NSMutableArray alloc] init];
            [comboArray addObject:sendGiftItem];
            
            // 添加一个礼物
            [self.sendGiftTheQueueManager setSendGiftWithKey:self.clickId forArray:comboArray];
            
            // 记录连击ID
            self.recordClickId = self.clickId;
            
        } else {
            NSMutableArray *mutableArray = [self.sendGiftTheQueueManager objectForKey:self.clickId];
            if ( mutableArray ) {
                [mutableArray addObject:sendGiftItem];
                [self.sendGiftTheQueueManager setSendGiftWithKey:self.clickId forArray:mutableArray];
                
            } else {
                NSMutableArray *comboArray = [[NSMutableArray alloc] init];
                [comboArray addObject:sendGiftItem];
                [self.sendGiftTheQueueManager setSendGiftWithKey:self.clickId forArray:comboArray];
            }
        }
        
        [self.sendGiftTheQueueManager addItemWithClickID:self.clickId giftNum:giftNum starNum:starNum endNum:endNum andGiftItem:item];
        
        NSLog(@"PlayViewController::sendRoomGiftFormLiveItem( sendGiftDictionary : %@ )",self.sendGiftTheQueueManager.sendGiftDictionary);
        
        /*** 礼物队列第一次发送送礼请求 ***/
        if (!self.isComboing) {
            
            // manager 发送礼物请求
            [self.sendGiftTheQueueManager sendLiveRoomGiftRequestWithGiftItem:sendGiftItem
                                                                       roomID:self.liveInfo.roomId multiClickID:self.clickId];
            self.isComboing = YES;
        }
    
    
    /*** 礼物本地播放  ***/
    if ( item.type == GIFTTYPE_COMMON ) {
        
        NSInteger starNumBer = starNum - 1;
        // 本地展示连击礼物
        GiftItem *giftItem = [GiftItem item:self.liveInfo.roomId fromID:self.loginManager.loginItem.userId nickName:self.loginManager.loginItem.nickName giftID:item.giftId giftNum:giftNum multi_click:item.multi_click starNum:starNumBer endNum:endNum clickID:self.clickId];
        [self.liveVC addCombo:giftItem];
        
    }else{
        
        // 本地播放大礼物动画
        for (int i = 0 ; i < giftNum; i++) {
            if (item.giftId) {
                [self.liveVC.bigGiftArray addObject:item.giftId];
            }
        }
        if (!self.liveVC.giftAnimationView) {
            [self.liveVC starBigAnimationWithGiftID:self.liveVC.bigGiftArray[0]];
        }
    }
    // 插入直播间送礼消息
    [self.liveVC addGiftMessageNickName:self.loginManager.loginItem.nickName giftID:item.giftId giftNum:giftNum];
}

- (void)sendGetGiftListRequest {
    NSLog(@"PlayViewController::sendGetGiftListRequest( "
          "[发送获取礼物列表请求], "
          "roomId : %@ "
          ")",
          self.liveInfo.roomId);
    
    GetLiveRoomGiftListByUserIdRequest *request = [[GetLiveRoomGiftListByUserIdRequest alloc] init];
    request.roomId = _liveInfo.roomId;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<NSString *> * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"PlayViewController::sendGetGiftListRequest( "
                  "[发送获取礼物列表请求结果], "
                  "roomId : %@, "
                  "success : %s, "
                  "errnum : %ld, "
                  "errmsg : %@ "
                  "array : %@ "
                  ")",
                  self.liveInfo.roomId,
                  success?"true":"false",
                  (long)errnum,
                  errmsg,
                  array
                  );
            
            if (success) {
                if (array && array.count != 0) {
                    self.presentView.giftIdArray = array;
                    self.backpackView.giftIdArray = array;
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)sendActionLikeRequest{
    NSLog(@"PlayViewController::sendActionLikeRequest( [发送点赞请求, roomId : %@ )", self.liveInfo.roomId);
    
    [self.imManager sendRoomFavWithRoomId:self.liveInfo.roomId];
}

#pragma mark - IM回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    
}


- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    
    // 移除所有送礼队列
    [self.sendGiftTheQueueManager removeAllSendGift];
}

- (void)onFansRoomIn:(BOOL)success reqId:(unsigned int)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl country:(NSString *)country videoUrls:(NSArray<NSString *> *)videoUrls fansNum:(int)fansNum contribute:(int)contribute fansList:(NSArray<RoomTopFanItemObject *> *)fansList {
    NSLog(@"PlayViewController::onFansRoomIn( [接收粉丝进入直播间回调], success : %s, errType : %d, errmsg : %@ )", success?"true":"false", errType, errmsg);

}

- (void)onRecvRoomCloseFans:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName fansNum:(int)fansNum {
    NSLog(@"PlayViewController::onRecvRoomCloseFans( [接收关闭直播间回调], roomId : %@, userId : %@, nickName : %@, fansNum : %d )", roomId, userId, nickName, fansNum);
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [roomId isEqualToString:self.liveInfo.roomId] ) {
            // 关闭输入
            [self closeAllInputView];
            
            // 显示直播结束界面
            [self showPlayEndViewWithLiverName:nickName andFansNum:fansNum];
        }
    });
}

- (void)onSendRoomFav:(BOOL)success reqId:(unsigned int)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"PlayViewController::onSendRoomFav( [发送点赞消息回调], success : %s, reqId : %d, errType : %d, errmsg : %@ )", success?"true":"false", reqId, errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if( success ) {
            [self.liveVC showLike];
        }
    });
}

- (void)onSendRoomGift:(BOOL)success reqId:(unsigned int)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg coins:(double)coins multi_click_id:(int)multi_click_id {
    NSLog(@"PlayViewController::onSendRoomGift( [发送礼物回调], success : %s, reqId : %d, errType : %d, errmsg : %@, coins : %f  multi_click_id: %d)", success?"true":"false", reqId, errType, errmsg, coins, multi_click_id);
    dispatch_sync(dispatch_get_main_queue(), ^{
        if( success ) {
            self.presentView.coinsNumLabel.text = [NSString stringWithFormat:@"%.2f",coins];
            self.backpackView.coinsNumLabel.text = [NSString stringWithFormat:@"%.2f",coins];
            self.creditNum = coins;
            
            NSMutableArray *comboArray = [self.sendGiftTheQueueManager objectForKey:multi_click_id];
            [comboArray removeObjectAtIndex:0];
            
            /*** 发送成功删除一个队列对象,是否为空 ***/
            if ( comboArray.count && comboArray != nil ) {
                
                [self.sendGiftTheQueueManager setSendGiftWithKey:multi_click_id forArray:comboArray];
                SendGiftItem *item = comboArray.firstObject;
                
                // manager 发送礼物请求
                [self.sendGiftTheQueueManager sendLiveRoomGiftRequestWithGiftItem:item roomID:self.liveInfo.roomId multiClickID:multi_click_id];
                
            }else {
                /*** 为空删除该礼物对象 ***/
                [self.sendGiftTheQueueManager removeSendGiftWithKey:multi_click_id];
                
                if (!self.sendGiftTheQueueManager.sendGiftDictionary.count) {
                    // 重置是否第一次送礼
                    self.isComboing = NO;
                    
                }else{
                    NSString *key = [self.sendGiftTheQueueManager getTheFirstKey];
                    NSMutableArray *giftArray = [self.sendGiftTheQueueManager objectForKey:[key intValue]];
                    SendGiftItem *item = giftArray.firstObject;
                    
                    // 发送礼物请求
                    [self.sendGiftTheQueueManager sendLiveRoomGiftRequestWithGiftItem:item roomID:self.liveInfo.roomId multiClickID:[key intValue]];
                }
            }
            
            NSLog(@"onSendRoomGift::sendGiftDictionary %@",self.sendGiftTheQueueManager.sendGiftDictionary);
        }
        else{
            
            if ( errType == 10025 ) {
                // 移除所有送礼队列
                [self.sendGiftTheQueueManager removeAllSendGift];
            }
        }
    });
}

#pragma mark - 界面事件
- (IBAction)chatAction:(id)sender {
    if ( [self.inputTextField canBecomeFirstResponder] ) {
        [self.inputTextField becomeFirstResponder];
    }
}

- (IBAction)shareAction:(id)sender {

}

- (IBAction)giftAction:(id)sender {
    
    // 请求礼物列表
    [self sendGetGiftListRequest];
    
    // 隐藏底部输入框
    [self hiddenBottomView];
    
    // 显示礼物列表
    [self showChooseGiftListView];
}

- (IBAction)sendAction:(id)sender {
    
    if( [self.liveVC sendMsg:self.inputTextField.text isLounder:self.btnLouder.selected] ) {
        self.inputTextField.text = nil;
        
        self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
        self.btnSend.userInteractionEnabled = NO;
    }
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self sendExitRequest];
}


#pragma mark - 界面显示/隐藏
/** 显示礼物列表 **/
- (void)showChooseGiftListView {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseGiftListView.transform = CGAffineTransformMakeTranslation(0, -self.chooseGiftListView.frame.size.height);
        [self.giftListView reloadData];
    } completion:^(BOOL finished) {
        self.liveVC.tableSuperView.hidden = YES;
        self.liveVC.msgTipsView.hidden = YES;
    }];
}

/** 收起礼物列表 **/
- (void)closeChooseGiftListView {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseGiftListView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        [self showBottomView];
        self.liveVC.tableSuperView.hidden = NO;
        if (self.liveVC.unReadMsgCount) {
            self.liveVC.msgTipsView.hidden = NO;
        }
        if ( self.presentView.buttonBar.height ) {
            [self.presentView hideButtonBar];
        }
        if ( self.backpackView.buttonBar.height ) {
            [self.backpackView hideButtonBar];
        }
    }];
}

/** 显示系统键盘 **/
- (void)showKeyboardView {
    
    self.inputTextField.inputView = nil;
    [self.inputTextField becomeFirstResponder];
}

/** 显示表情选择 **/
- (void)showEmotionView {
    
    // 关闭系统键盘
    [self.inputTextField resignFirstResponder];
    
    if( self.inputMessageViewBottom.constant != -self.chatEmotionKeyboardView.frame.size.height ) {
        // 未显示则显示
        [self moveInputBarWithKeyboardHeight:self.chatEmotionKeyboardView.frame.size.height withDuration:0.25];
    }
    [self.chatEmotionKeyboardView reloadData];
}

/** 关闭所有输入 **/
- (void)closeAllInputView {
    
    // 关闭表情输入
    if( self.btnEmotion.selected == YES ) {
        self.btnEmotion.selected = NO;
        [self moveInputBarWithKeyboardHeight:0 withDuration:0.25];
        [self showInputMessageView];
    }
    [self.inputTextField resignFirstResponder];
}

/** 隐藏底部输入框 **/
- (void)hiddenBottomView {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.inputMessageView.transform = CGAffineTransformMakeTranslation(0, 54);
    }];
}

/** 显示底部输入框 **/
- (void)showBottomView {
    
    [UIView animateWithDuration:0.2 delay:0.25 options:0 animations:^{
        self.inputMessageView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

#pragma mark - 礼物列表界面回调(PresentViewDelegate)
- (void)presentViewSendBtnClick:(PresentView *)presentView {
    // 标记已经点击
    self.isFirstClick = YES;
    
    if (self.presentView.buttonBar.height) {
        [self.presentView hideButtonBar];
    }
    
    if ( presentView.isCellSelect ) {
        
        // 判断本地信用点是否够送礼
        if (self.creditNum - presentView.selectCellItem.coins > 0) {
            
            /** 生成连击ID **/
            [self getTheClickID];
            
            if ( presentView.selectCellItem.type == GIFTTYPE_COMMON ) {
                
                if ( presentView.selectCellItem.multi_click ) {
                    self.presentView.sendView.hidden = YES;
                    presentView.comboBtn.hidden = NO;
                    // 标记是否是连击
    //                self.isMultiClick = YES;
                    // 连击礼物
                    [self.presentView.presentDelegate presentViewComboBtnInside:presentView andSender:presentView.comboBtn];
                    
                }else{
                    // 普通不连击礼物
    //                self.isMultiClick = NO;
                    _giftNum = [presentView.sendView.selectNumLabel.text intValue];
                    [self sendRoomGiftFormLiveItem:presentView.selectCellItem andGiftNum:_giftNum starNum:1 endNum:_giftNum];
                }
                
            } else {
                // 发送大礼物
    //            self.isMultiClick = NO;
                _giftNum = [presentView.sendView.selectNumLabel.text intValue];
                [self sendRoomGiftFormLiveItem:presentView.selectCellItem andGiftNum:_giftNum starNum:1 endNum:1];
            }
            
        }else{
            // 钱不够 清队列
//            [self.sendGiftTheQueueManager removeAllSendGift];
        }
    }
}

- (void)presentViewComboBtnInside:(PresentView *)presentView andSender:(id)sender {
    
    switch (self.imManager.isIMLogin) {
        case 1:
            // 是否第一次点击
            if (self.isFirstClick) {
                _starNum = 1;
                _endNum = [presentView.sendView.selectNumLabel.text intValue];
                _giftNum = [presentView.sendView.selectNumLabel.text intValue];
                _totalGiftNum = [presentView.sendView.selectNumLabel.text intValue];
                
                self.isFirstClick = NO;
                
            } else {
                _starNum = _totalGiftNum + 1;
                _endNum = _totalGiftNum + [presentView.sendView.selectNumLabel.text intValue];
                _giftNum = [presentView.sendView.selectNumLabel.text intValue];
                _totalGiftNum = _totalGiftNum + [presentView.sendView.selectNumLabel.text intValue];
            }
            
            // 发送连击礼物请求
            [self sendRoomGiftFormLiveItem:presentView.selectCellItem andGiftNum:_giftNum starNum:_starNum endNum:_endNum];
            
            break;
            
        case 0:
            
            self.isFirstClick = YES;
            
            break;
            
        default:
            break;
    }
    
    
    self.selectCellItem = presentView.selectCellItem;
    
    self.comboBtn = sender;
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_nomal"] forState:UIControlStateNormal];

    [sender stopCountDown];
    [sender startCountDownWithSecond:30];

    // 连击按钮倒计时改变回调
    __weak typeof(self) weakSelf = self;
    [sender countDownChanging:^NSAttributedString *(CountTimeButton *countDownButton,NSInteger second) {
        countDownButton.titleLabel.numberOfLines = 0;
        
        weakSelf.countdownSender = 1;
        
        return [weakSelf appendComboButtonTitle:[NSString stringWithFormat:@"%ld",(long)second]];
    }];

    // 连击按钮倒计时结束回调
    [sender countDownFinished:^NSAttributedString *(CountTimeButton *countDownButton, NSInteger second) {
        if (second <= 0.0) {
            weakSelf.comboBtn.hidden = YES;
            weakSelf.presentView.sendView.hidden = NO;
            
            weakSelf.countdownSender = 0;
            weakSelf.isFirstClick = YES;
            
            weakSelf.starNum = 0;
            weakSelf.endNum = 0;
            weakSelf.giftNum = 0;
            weakSelf.totalGiftNum = 0;
        }
        
        return [weakSelf appendComboButtonTitle:@"30"];
    }];
}

- (void)presentViewComboBtnDown:(PresentView *)presentView andSender:(id)sender {
    self.comboBtn = sender;
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_hight"] forState:UIControlStateHighlighted];
}

- (void)presentViewdidSelectItemWithSelf:(PresentView *)presentView atIndexPath:(NSIndexPath *)indexPath {
//    if ( [presentView.selectCellItem.giftId isEqualToString:_selectCellItem.giftId] && presentView.isCellSelect && _countdownSender && _isMultiClick) {
//        self.comboBtn.hidden = NO;
//        self.presentView.sendView.hidden = YES;
//    } else {
    
    if ( ![self.selectCellItem.giftId isEqualToString:presentView.selectCellItem.giftId] ) {
        self.comboBtn.hidden = YES;
        self.presentView.sendView.hidden = NO;
    }
    
//    }
}

- (void)presentViewDidScroll:(PresentView *)PresentViewView currentPageNumber:(NSInteger)page{
}

#pragma mark - 礼物背包界面回调(BackpackPresentViewDelegate)
- (void)backpackPresentViewSendBtnClick:(BackpackPresentView *)backpackView {

    self.isBackpackFirstClick = YES;
    if (self.backpackView.buttonBar.height) {
        [self.backpackView hideButtonBar];
    }
    if ( backpackView.isCellSelect ) {
        
        /** 生成连击ID **/
        [self getTheClickID];
        
        if ( backpackView.selectCellItem.type == GIFTTYPE_COMMON ) {
            
            if ( backpackView.selectCellItem.multi_click ) {
                
                backpackView.sendView.hidden = YES;
                backpackView.comboBtn.hidden = NO;
                // 连击礼物
                [self.backpackView.backpackDelegate backpackPresentViewComboBtnInside:backpackView andSender:backpackView.comboBtn];
            }else{
                
                _giftNum = [backpackView.sendView.selectNumLabel.text intValue];
                
            }
            
        }
        else {
            _giftNum = [backpackView.sendView.selectNumLabel.text intValue];
            // 发送大礼物
//            [self.backGiftManager sendBackpackGiftID:backpackView.selectCellItem.giftId giftNum:_giftNum statNum:1 endNum:1 finishHanld:^(BOOL success, NSMutableArray *backArray) {
//                
//                if (success) {
//                    self.backpackView.giftItemArray = backArray;
//                    
//                } else{
//                    self.backpackView.giftItemArray = backArray;
//                    
//                }
//            }];
        }
    }
}


- (void)backpackPresentViewComboBtnInside:(BackpackPresentView *)backpackView andSender:(id)sender {
    
    switch (self.imManager.isIMLogin) {
        case 1:
            // 是否第一次点击
            if (self.isBackpackFirstClick) {
                _starNum = 1;
                _endNum = [backpackView.sendView.selectNumLabel.text intValue];
                _giftNum = [backpackView.sendView.selectNumLabel.text intValue];
                _totalGiftNum = [backpackView.sendView.selectNumLabel.text intValue];
                
                self.isBackpackFirstClick = NO;
                
            } else {
                _starNum = _totalGiftNum + 1;
                _endNum = _totalGiftNum + [backpackView.sendView.selectNumLabel.text intValue];
                _giftNum = [backpackView.sendView.selectNumLabel.text intValue];
                _totalGiftNum = _totalGiftNum + [backpackView.sendView.selectNumLabel.text intValue];
            }
            
            // 发送连击礼物请求
//            [self sendRoomGiftFormLiveItem:backpackView.selectCellItem andGiftNum:_giftNum starNum:_starNum endNum:_endNum];
            
            break;
            
        case 0:
            
            self.isBackpackFirstClick = YES;
            
            break;
            
        default:
            break;
    }

    self.selectCellItem = backpackView.selectCellItem;
    
    self.comboBtn = sender;
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_nomal"] forState:UIControlStateNormal];
    
    [sender stopCountDown];
    [sender startCountDownWithSecond:30];
    
    // 连击按钮倒计时改变回调
    __weak typeof(self) weakSelf = self;
    [sender countDownChanging:^NSAttributedString *(CountTimeButton *countDownButton,NSInteger second) {
        countDownButton.titleLabel.numberOfLines = 0;
        
//        weakSelf.countdownSender = 1;
        
        return [weakSelf appendComboButtonTitle:[NSString stringWithFormat:@"%ld",(long)second]];
    }];
    
    // 连击按钮倒计时结束回调
    [sender countDownFinished:^NSAttributedString *(CountTimeButton *countDownButton, NSInteger second) {
        if (second <= 0.0) {
            weakSelf.comboBtn.hidden = YES;
            weakSelf.backpackView.sendView.hidden = NO;
            
//            weakSelf.countdownSender = 0;
            weakSelf.isFirstClick = YES;
            
            weakSelf.starNum = 0;
            weakSelf.endNum = 0;
            weakSelf.giftNum = 0;
            weakSelf.totalGiftNum = 0;
        }
        
        return [weakSelf appendComboButtonTitle:@"30"];
    }];

    
}


- (void)backpackPresentViewComboBtnDown:(BackpackPresentView *)backpackView andSender:(id)sender {
    self.comboBtn = sender;
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_hight"] forState:UIControlStateHighlighted];
}


- (void)backpackPresentViewDidSelectItemWithSelf:(BackpackPresentView *)backpackView atIndexPath:(NSIndexPath *)indexPath {
    
//    if ( [presentView.selectCellItem.giftId isEqualToString:_selectCellItem.giftId] && presentView.isCellSelect && _countdownSender && _isMultiClick) {
//        self.comboBtn.hidden = NO;
//        self.presentView.sendView.hidden = YES;
//    } else {
    
    if ( ![self.selectCellItem.giftId isEqualToString:backpackView.selectCellItem.giftId] ) {
        self.comboBtn.hidden = YES;
        self.backpackView.sendView.hidden = NO;
    }
    
//    }
}


- (void)backpackPresentViewDidScroll:(BackpackPresentView *)backpackView currentPageNumber:(NSInteger)page {
}


/** 生成连击ID **/
- (void)getTheClickID {
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    long long totalMilliseconds = currentTime * 1000;
    self.clickId = totalMilliseconds % 10000;
}

/** 拼接连击按钮标题 **/
- (NSMutableAttributedString *)appendComboButtonTitle:(NSString *)title {
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:title attributes:
                                                  @{NSFontAttributeName : ComboTitleFont,
                                                    NSForegroundColorAttributeName:[UIColor blackColor]}];
    [attributeString appendAttributedString:[self parseMessage:@" \n combo" font:[UIFont systemFontOfSize:18] color:[UIColor blackColor]]];
    
    return attributeString;
}


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



#pragma mark - 手势事件 (单击屏幕)
- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        self.singleTap.delegate = self;
        [self.liveVC.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if( self.singleTap ) {
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
        
    } else {
        // 如果没有打开键盘
        if (!_isKeyboradShow) {
            // 发送点赞请求
            [self sendActionLikeRequest];
            
            // 第一次点赞, 插入本地文本
            if (!_isFirstLike) {
                _isFirstLike = YES;
                [self.liveVC addLikeMessage:self.loginManager.loginItem.nickName];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint pt = [touch locationInView:self.view];
    if ( !CGRectContainsPoint([self.chooseGiftListView frame], pt) ) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 选择按钮回调
- (void)selectedChanged:(id)sender {
    if( sender == self.btnLouder ) {
        [self changePlaceholder:self.btnLouder.selected];
    }
    
    if ( sender == self.btnEmotion ) {
        
        [self.inputTextField endEditing:YES];
        UIButton *emotionBtn = (UIButton *)sender;
        if( emotionBtn.selected == YES ) {
            // 弹出底部emotion的键盘
            [self showEmotionView];
            
        } else {
            // 切换成系统的的键盘
            [self showKeyboardView];
        }
    }
}

#pragma mark - 文本输入回调 (UITextFieldDelegate)
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.btnEmotion.selected = NO;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    bool bFlag = YES;
    
    NSString *wholeString = textField.text;
    NSInteger wholeStringLength = wholeString.length - range.length + string.length;
    
    if (wholeStringLength > 0) {
        self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0x0CEDF5);
        self.btnSend.userInteractionEnabled = YES;
    }else{
        self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
        self.btnSend.userInteractionEnabled = NO;
    }
    
    if( wholeStringLength >= MaxInputCount ) {
        // 超过字符限制
        bFlag = NO;
    }
    
    return bFlag;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    bool bFlag = NO;
    
    if( self.inputTextField.text.length > 0 ) {
        if( [self.liveVC sendMsg:textField.text isLounder:self.btnLouder.selected] ) {
            self.inputTextField.text = nil;
            
            self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
            self.btnSend.userInteractionEnabled = NO;
        }
        
        bFlag = YES;
    }
    
    return bFlag;
}

#pragma mark - 普通表情选择回调 (ChatEmotionChooseViewDelegate)
- (void)chatEmotionChooseView:(ChatEmotionChooseView *)chatEmotionChooseView didSelectNomalItem:(NSInteger)item {
    if( self.inputTextField.text.length < 70 ) {
        // 插入表情描述到输入框
        ChatEmotion* emotion = [self.emotionManager.emotionArray objectAtIndex:item];
        [self.inputTextField insertEmotion:emotion];
        
//        [self.chatMessageObject chatMessageHaveEmotionWithString:self.inputTextField.text];
        self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0x0CEDF5);
        self.btnSend.userInteractionEnabled = YES;
    }
}

#pragma mark - 高亲密度表情选择回调 (ChatFriendlyEmotionViewDelegate)
- (void)chatFriendlyEmotionView:(ChatFriendlyEmotionView *)chatFriendlyEmotionView didSelectNomalItem:(NSInteger)item {
    if( self.inputTextField.text.length < 70 ) {
        // 插入表情描述到输入框
        ChatEmotion* emotion = [self.emotionManager.emotionArray objectAtIndex:item];
        [self.inputTextField insertEmotion:emotion];
        
//        [self.chatMessageObject chatMessageHaveEmotionWithString:self.inputTextField.text];
        self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0x0CEDF5);
        self.btnSend.userInteractionEnabled = YES;
    }
}

#pragma mark - 表情、礼物键盘选择回调 (ChatEmotionKeyboardViewDelegate)
- (NSUInteger)pagingViewCount:(ChatEmotionKeyboardView *)chatEmotionKeyboardView {
    return 2;
}

- (Class)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView classForIndex:(NSUInteger)index {
    
    Class cls = nil;
    
    if ( chatEmotionKeyboardView == self.chatEmotionKeyboardView ) {
        
        
        if ( index == 0 ) {
            
            // 普通表情
            cls = [ChatEmotionChooseView class];
            
        }else if ( index == 1 ) {
            // 高亲密度表情
            cls = [ChatFriendlyEmotionView class];
        }
        
    }
    else{
        
        if ( index == 0 ) {
            
            cls = [PresentView class];
            
            if (self.comboBtn) {
                self.comboBtn.countDownFinished(self.comboBtn , 0);
                [self.comboBtn stop];
                self.comboBtn.hidden = YES;
                self.comboBtn = nil;
            }
            
        }else if ( index == 1 ) {
            
            cls = [BackpackPresentView class];
            
            if (self.comboBtn) {
                self.comboBtn.countDownFinished(self.comboBtn , 0);
                [self.comboBtn stop];
                self.comboBtn.hidden = YES;
                self.comboBtn = nil;
            }
        }
    }
    return cls;
}

- (UIView *)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView pageViewForIndex:(NSUInteger)index {
    UIView* view = nil;
    
    if ( chatEmotionKeyboardView == self.chatEmotionKeyboardView ) {
        
        if ( index == 0 ) {
            
            // 普通礼物列表
            view = self.chatNomalEmotionView;
            view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);
            
        }else if ( index == 1 ) {
            // 背包礼物列表
            view = self.chatFriendlyEmotionView;
            view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);
        }
        
    }
    else{
        
        if ( index == 0 ) {
            
            view = self.presentView;
            
        }else if ( index == 1 ) {
            
            view = self.backpackView;
        }
    }
    
    return view;
}

- (void)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    
    if ( chatEmotionKeyboardView == self.chatEmotionKeyboardView ) {
        
        if ( index == 0 ) {
            
            // 普通表情
            [self.chatNomalEmotionView reloadData];
            
        }else if ( index == 1 ) {
            // 高级表情
            [self.chatFriendlyEmotionView reloadData];
        }
        
    }
    else{
        
        if ( index == 0 ) {
            
//            [self.presentView reloadData];
        }else if ( index == 1 ) {
            
//            [self.backpackView reloadData];
        }
    }
}

- (void)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView didShowPageViewForDisplay:(NSUInteger)index {
    
    if ( chatEmotionKeyboardView == self.chatEmotionKeyboardView ) {
        
        if ( index == 0 ) {
            
            
        }else if ( index == 1 ) {
            
        }
        
    }
    else{
        
        if ( index == 0 ) {
            
        }else if ( index == 1 ) {
            
        }
    }
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    BOOL bFlag = NO;
    
    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];
    
    if( height != 0 ) {
        // 弹出键盘
        self.inputMessageViewBottom.constant = -height;
        bFlag = YES;
        
    } else {
        // 收起键盘
        self.inputMessageViewBottom.constant = -5;
    }
    
    [UIView animateWithDuration:duration animations:^{
        // Make all constraint changes here, Called on parent view
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    self.keyboardHeight = keyboardRect.size.height;
    // 从表情键盘切换成系统键盘,保存普通表情的富文本属性
//    self.emotionAttributedString = self.inputTextField.attributedText;
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
    
    if( self.btnEmotion.selected != YES ) {
        // 改变控件状态
        [self showInputMessageView];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification{
    _isKeyboradShow = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification{
    _isKeyboradShow = NO;
}

#pragma mark - 结束直播界面
- (void)showPlayEndViewWithLiverName:(NSString *)nickName andFansNum:(int)fansNum {
    if( self.playEndVC == nil ) {
        // 只能出现一次
        self.playEndVC = [[PlayEndViewController alloc] initWithNibName:nil bundle:nil];
        
        self.playEndVC.liverNameLabel.text = nickName;
        self.playEndVC.viewverLabel.text = [NSString stringWithFormat:@"%d",fansNum];
        
        self.playEndVC.imageViewHeaderLoader = [ImageViewLoader loader];
        [self.playEndVC.imageViewHeaderLoader loadImageWithImageView:self.playEndVC.imageViewHeader options:0 imageUrl:self.liveInfo.photoUrl placeholderImage:[UIImage imageNamed:@""]];
        
        [self.view addSubview:self.playEndVC.view];
        [self.playEndVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
        [self addChildViewController:self.playEndVC];
        
        self.playEndVC.view.alpha = 0;
        NSTimeInterval duration = 0.5;
        [UIView animateWithDuration:duration animations:^{
            self.playEndVC.view.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

@end
