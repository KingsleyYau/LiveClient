//
//  LSVIPGiftPageViewController.m
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSVIPGiftPageViewController.h"
#import "LSPZPagingScrollView.h"
#import "LiveHeaderScrollview.h"

#import "LiveModule.h"

#import "DialogTip.h"

#import "LiveRoomCreditRebateManager.h"
#import "SendGiftTheQueueManager.h"
#import "LSLoginManager.h"
#import "LSGiftManager.h"
#import "LSImManager.h"
#import "LSTimer.h"

#import "LSGiftTypeView.h"

#define COMBOTIME 3

@interface LSVIPGiftPageViewController ()
<JTSegmentControlDelegate, LSPZPagingScrollViewDelegate, LSCheckButtonDelegate, LiveRoomCreditRebateManagerDelegate, LSGiftCollectionViewDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate, SendGiftTheQueueManagerDelegate,LSGiftTypeViewDelegate>

@property (nonatomic, weak) IBOutlet LSGiftTypeView *segmentView;
 
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *loading;

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, strong) NSArray<JTSegmentItem *> *sliderArray;
@property (nonatomic, strong) NSArray *vcArray;

#pragma mark - 连击属性
// 连击发送礼物数量
@property (nonatomic, assign) int giftNum;
// 连击发送礼物总数量
@property (nonatomic, assign) int totalGiftNum;
// 连击起始下标
@property (nonatomic, assign) int starNum;
// 连击结束下标
@property (nonatomic, assign) int endNum;
// 连击Id
@property (nonatomic, assign) int giftClickId;

// 普通提示
@property (nonatomic, strong) DialogTip *dialogTipView;

// 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;
// 送礼队列管理类
@property (nonatomic, strong) SendGiftTheQueueManager *sendGiftTheQueueManager;
// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;
// IM管理器
@property (nonatomic, strong) LSImManager *imManager;
// 连击定时器
@property (nonatomic, strong) LSTimer *comboTimer;
// 连击剩余事件
@property (nonatomic, assign) NSInteger comboTime;
// 上一个发送的礼物
@property (nonatomic, strong) LSGiftManagerItem *lastItem;

@property (nonatomic, assign) BOOL isRequastSuccess;
@end

@implementation LSVIPGiftPageViewController

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.isShowNavBar = NO;
    
    self.curIndex = 0;
    
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    [self.creditRebateManager addDelegate:self];
    
    self.sendGiftTheQueueManager = [[SendGiftTheQueueManager alloc] init];
    self.sendGiftTheQueueManager.delegate = self;
    
    self.loginManager = [LSLoginManager manager];
    
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    self.comboTimer = [[LSTimer alloc] init];
    
    self.comboTime = COMBOTIME;
    
    self.lastItem = [[LSGiftManagerItem alloc] init];
}

- (void)dealloc {
    if (self.dialogTipView) {
        [self.dialogTipView removeFromSuperview];
    }
    
    [self.sendGiftTheQueueManager unInit];
    [self.sendGiftTheQueueManager removeAllSendGift];
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [self.creditRebateManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 初始化提示
    self.dialogTipView = [DialogTip dialogTip];
    
    self.segmentView.delegate = self;
    
    // 初始化分栏
    [self setupSegment];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 加载默认页
    [self reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setIsShowView:(BOOL)isShowView {
    _isShowView = isShowView;
    if (isShowView) {
        if (!self.isRequastSuccess) {
            [self setupSegment];
        }
    }
}

- (void)extracted:(NSMutableArray *)typeListArray {
    WeakObject(self, weakSelf);
    self.curIndex = 0;
    [[LSGiftManager manager] getPraviteRoomBackpackGiftList:self.liveRoom.roomId finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (giftList.count > 0) {
                LSGiftTypeItemObject * freeItem = [[LSGiftTypeItemObject alloc]init];
                freeItem.typeId = @"Free";
                freeItem.typeName = @"Free ";
                [typeListArray addObject:freeItem];
                
                weakSelf.curIndex = 1;
            }
            
            LSGiftTypeItemObject * allItem = [[LSGiftTypeItemObject alloc]init];
            allItem.typeId = @"All";
            allItem.typeName = @"All";
            [typeListArray addObject:allItem];
            
            
            NSInteger roomType = 0;
            if (weakSelf.liveRoom.roomType ==LiveRoomType_Public || weakSelf.liveRoom.roomType == LiveRoomType_Public_VIP) {
                roomType = 1;
            }else {
                roomType = 2;
            }
            
            [[LSGiftManager manager] getGiftTypeList:roomType finshHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSGiftTypeItemObject *> *array) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (array.count > 0) {
                        if (typeListArray.count == 2) {
                            weakSelf.curIndex = 2;
                        }else {
                            weakSelf.curIndex = 1;
                        }
                        [typeListArray addObjectsFromArray:array];
                        
                    }
                    weakSelf.isRequastSuccess = success;
                    // 初始化内容
                    [weakSelf setupPageScrollView:typeListArray];
                    weakSelf.loading.hidden = YES;
                    weakSelf.segmentView.items = typeListArray;
                    [weakSelf.segmentView.collectionView reloadData];
                    [weakSelf.segmentView selectTypeRow:weakSelf.curIndex isAnimated:NO];
                    [weakSelf.pagingScrollView displayPagingViewAtIndex:weakSelf.curIndex animated:NO];
                });
            }];
            
        });
    }];
}

- (void)setupSegment {
    // TODO:初始化分栏控件
    
    NSMutableArray * images = [NSMutableArray array];
    for (int i = 1; i <= 7; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"Prelive_Loading%d",i]];
        [images addObject:image];
    }
    self.loading.animationImages = images;
    self.loading.animationDuration = 0.6;
    [self.loading startAnimating];
    
    NSMutableArray * typeListArray = [NSMutableArray array];
    [self extracted:typeListArray];
}

- (void)setupPageScrollView:(NSArray*)items {
    // TODO:初始化分页
    NSMutableArray *array = [NSMutableArray array];
    
    for (LSGiftTypeItemObject * item in items) {
        LSGiftCollectionView *vc = [[LSGiftCollectionView alloc] init];
        vc.delegate = self;
        vc.liveRoom = self.liveRoom;
        vc.giftTypeId = item.typeId;
        [array addObject:vc];
    }
    
    self.vcArray = array;
    
    [self reloadData];
}

#pragma mark - GfitTypeViewDelegate
- (void)giftTypeViewSelectIndexRow:(NSInteger)row {

    [self.pagingScrollView displayPagingViewAtIndex:row animated:NO];
}

#pragma mark - 界面按钮
- (IBAction)upBtnDid:(UIButton *)sender {
    
    if ([self.vcDelegate respondsToSelector:@selector(didUpBtnHidenGiftList:)]) {
        [self.vcDelegate didUpBtnHidenGiftList:self];
    }
}

- (IBAction)infoBtnDid:(UIButton *)sender {
    if ([self.vcDelegate respondsToSelector:@selector(didShowGiftListInfo:)]) {
        [self.vcDelegate didShowGiftListInfo:self];
    }
}

#pragma mark - 提示对话框
- (void)showDialogTipView:(NSString *)tipText {
    // TODO:显示提示
    [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:tipText];
}

// 弹出不可发送提示
- (BOOL)showSendGiftDialogView:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item {
    
    switch ([item canSend:self.liveRoom.imLiveRoom.loveLevel userLevel:self.liveRoom.imLiveRoom.manLevel]) {
        case GiftSendType_Not_LoveLevel:{
            NSString *tips = [NSString stringWithFormat:@"%@%d%@", NSLocalizedStringFromSelf(@"NO_TENOUGH_LOVE"), item.infoItem.loveLevel, NSLocalizedStringFromSelf(@"OR_HIGHER")];
            [self showDialogTipView:tips];
            return NO;
        }break;
            
        case GiftSendType_Not_UserLevel:{
            NSString *tips = [NSString stringWithFormat:@"%@%d%@", NSLocalizedStringFromSelf(@"NO_TENOUGH_LEVEL"), item.infoItem.level, NSLocalizedStringFromSelf(@"OR_HIGHER")];
            [self showDialogTipView:tips];
            return NO;
        }break;
            
        default:{
        }break;
    }
    
    if ([view.giftTypeId isEqualToString:@"Free"]) {
        if (item.backpackTotal < 1) {
            [self showDialogTipView:NSLocalizedStringFromSelf(@"NO_GIFT_NUMBER")];
            return NO;
        }
    }
    return YES;
}

#pragma mark - 显示买点弹框
- (void)showAddCreditsView:(NSString *)tip {
    if ([self.vcDelegate respondsToSelector:@selector(showCreditView:)]) {
        [self.vcDelegate showCreditView:tip];
    }
}

#pragma mark - 数据逻辑
- (void)reloadData {
    // TODO:刷新礼物列表界面
  
    // 选中默认分页界面
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
}

- (void)selectItem:(LSGiftManagerItem *)item {
    // TODO:选择指定礼物
    LSGiftCollectionView *view = [self.vcArray objectAtIndex:0];
    [view selectItem:item];
}

#pragma mark - 私有Get/Set
- (NSInteger)viewHeight {
    return ceil(self.view.frame.size.width / 2.0 + 90 + 10 + 5);
}

#pragma mark - 点击发送礼物事件
- (void)didSendGiftAction:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item {
    if ([self showSendGiftDialogView:view item:item]) {
        // 还原连击属性(如果连击时间大于3秒或者上一个连击礼物不一样)
        if (self.comboTime >= COMBOTIME || ![self.lastItem.infoItem.giftId isEqualToString:item.infoItem.giftId]) {
            [self resetGiftClickParam];
            self.lastItem = item;
        }
        
        BOOL bFlag = NO;
        if (item.infoItem.type == GIFTTYPE_COMMON) {
            if (item.infoItem.multiClick) {
                // 连击间隔大于30秒 生成新连击ID
                if (self.comboTime >= COMBOTIME || ![self.lastItem.infoItem.giftId isEqualToString:item.infoItem.giftId]) {
                    [self createGiftClickId];
                }
                [self sendComboGiftItem:view item:item];
                // 标记已经处理为连击礼物
                bFlag = YES;
            }
        }
        if (!bFlag) {
            // 发送当前选择的礼物
            [self sendGiftItemWithType:view item:item];
        }
    }
}

#pragma mark - 发送连击礼物事件
- (void)sendComboGiftItem:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item {
    if (self.comboTime < COMBOTIME) {
        self.comboTime = COMBOTIME;
    }
    
    WeakObject(self, weakSelf);
    [self.comboTimer startTimer:dispatch_get_main_queue() timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        weakSelf.comboTime--;
        if (weakSelf.comboTime <= 0) {
            // 停止定时器 重置连击参数
            [weakSelf.comboTimer stopTimer];
            [weakSelf resetGiftClickParam];
            weakSelf.comboTime = COMBOTIME;
        }
    }];
    
    // 发送当前选择的礼物
    if([self sendGiftItemWithType:view item:item]) {
        // 更新连击礼物参数
        [self updateGiftClickParam];
    } else {
        // 停止连击
        [self resetGiftClickParam];
    }
}

#pragma mark - 发送数据逻辑
- (BOOL)sendGiftItemWithType:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item {
    // TODO:根据当前礼物列表类型控发送礼物
    BOOL bFlag = NO;
    if ([view.giftTypeId isEqualToString:@"Free"]) {
        // 背包礼物
        bFlag = [self sendBackpackGift:view item:item];
    } else {
        // 普通礼物
        bFlag = [self sendNormalGift:item];
    }
    return bFlag;
}

- (BOOL)sendNormalGift:(LSGiftManagerItem *)item {
    // TODO:发送普通礼物
    BOOL bFlag = NO;
    
    // 个人信用点和返点
    double userCredit = self.creditRebateManager.mCredit + self.liveRoom.imLiveRoom.rebateInfo.curCredit;
    NSLog(@"LSVIPGiftPageViewController::sendNormalGift( [发送普通礼物], giftId : %@, mCredit : %f, curCredit : %f, userCredit : %f )", item.giftId, self.creditRebateManager.mCredit, self.liveRoom.imLiveRoom.rebateInfo.curCredit, userCredit);
    
    // 判断本地信用点是否够送礼
    if (userCredit - item.infoItem.credit >= 0) {
        [self sendLSGiftManagerItem:item isBack:NO];
        bFlag = YES;
        
    } else {
        [self showAddCreditsView:NSLocalizedStringFromSelf(@"SENDGIFT_ERR_ADD_CREDIT")];
        
        // 钱不够,清队列
        [self.sendGiftTheQueueManager removeAllSendGift];
        
        bFlag = NO;
    }
    
    return bFlag;
}

- (BOOL)sendBackpackGift:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item {
    // TODO:发送背包礼物
    NSLog(@"LSVIPGiftPageViewController::sendBackpackGift( [发送背包礼物], giftId : %@, backpackTotal : %d )", item.giftId, (int)item.backpackTotal);
    
    BOOL bFlag = NO;
    if (item.backpackTotal > 0) {
        if( item.backpackTotal >= self.giftNum ) {
            item.backpackTotal -= self.giftNum;
            
            // 发送礼物
            [self sendLSGiftManagerItem:item isBack:YES];
            
            if (item.backpackTotal == 0) {
                // 礼物已经送完
                // 重置连击
                [self resetGiftClickParam];
                
                // 已经发送所有礼物, 清空选中礼物
                view.selectedIndexPath = -1;
                
            } else {
                bFlag = YES;
            }
            [view reloadData];
        }
    }
    
    return bFlag;
}

- (void)sendLSGiftManagerItem:(LSGiftManagerItem *)item isBack:(BOOL)isBack {
    // TODO:发送直播间礼物
    NSLog(@"LSVIPGiftPageViewController::sendLSGiftManagerItem( "
          "[发送礼物], "
          "roomId : %@, giftId : %@, giftNum : %d, starNum : %d, endNum : %d  giftClickId : %d, backpackTotal : %d )",
          self.liveRoom.imLiveRoom.roomId, item.giftId, self.giftNum, self.starNum, self.endNum, self.giftClickId, (int)item.backpackTotal);
    
    GiftItem *sendItem = [GiftItem itemRoomId:self.liveRoom.roomId
                                     nickName:self.loginManager.loginItem.nickName
                                  is_Backpack:isBack
                                      giftNum:self.giftNum
                                      starNum:self.starNum
                                       endNum:self.endNum
                                      clickID:self.giftClickId
                                     giftItem:item];
    
    // 发送礼物列表礼物
    [self.sendGiftTheQueueManager sendLiveRoomGiftRequestWithGiftItem:sendItem];
}

#pragma mark - 连击
- (void)createGiftClickId {
    // TODO:生成连击ID
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    long long totalMilliseconds = currentTime * 1000;
    self.giftClickId = totalMilliseconds % 10000;
}

- (void)resetGiftClickParam {
    // TODO:还原连击属性
    self.starNum = 1;
    self.endNum = 1;
    self.giftNum = 1;
    self.totalGiftNum = 1;
    self.giftClickId = -1;
}

- (void)updateGiftClickParam {
    self.starNum = self.totalGiftNum + 1;
    self.endNum = self.totalGiftNum + 1;
    self.giftNum = 1;
    self.totalGiftNum += self.giftNum;
}

#pragma mark - 礼物管理器委托(LSGiftManagerDelegate)
- (void)giftDownloadManagerBigGiftChange:(LSGiftManagerItem *)LSGiftManagerItem index:(NSInteger)index {
    // 礼物下载状态改变, 刷新列表
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}


#pragma mark - 分页委托(LSPZPagingScrollViewDelegate)
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    return self.vcArray.count;
}

- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)];
    return view;
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    LSGiftCollectionView *view = [self.vcArray objectAtIndex:index];
    
    [pageView addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pageView);
        make.left.equalTo(pageView);
        make.width.equalTo(pageView);
        make.bottom.equalTo(pageView);
    }];
    // 使约束生效
    [view layoutSubviews];
    
    // 刷新数据
    [view reloadData];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    
    if (self.isShowView) {
        NSInteger row = index;
        [self.segmentView selectTypeRow:row isAnimated:YES];
    }
}

#pragma mark - 分页委托(LSVIPGiftViewControllerDelegate)
- (void)didChangeGiftItem:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item {
    
    
    // 判断点击的礼物是否可以发送
    if ([item canSend:self.liveRoom.imLiveRoom.loveLevel userLevel:self.liveRoom.imLiveRoom.manLevel]) {
        // 发送按钮可用
        
    } else {
        // 发送按钮不可用
       
        
        // 弹出提示
        if (item.infoItem.level > self.liveRoom.imLiveRoom.manLevel) {
            NSString *tips = [NSString stringWithFormat:@"%@%d%@", NSLocalizedStringFromSelf(@"NO_TENOUGH_LEVEL"), item.infoItem.level, NSLocalizedStringFromSelf(@"OR_HIGHER")];
            [self showDialogTipView:tips];
        } else if (item.infoItem.loveLevel > self.liveRoom.imLiveRoom.loveLevel) {
            NSString *tips = [NSString stringWithFormat:@"%@%d%@", NSLocalizedStringFromSelf(@"NO_TENOUGH_LOVE"), item.infoItem.loveLevel, NSLocalizedStringFromSelf(@"OR_HIGHER")];
            [self showDialogTipView:tips];
        }
    }
}


- (void)didSendGiftItem:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item {
    // TODO:点击发送礼物
    
    // 判断礼物是否可发送
    if ([self showSendGiftDialogView:view item:item]) {
        [self didSendGiftAction:view item:item];
    }
}

#pragma mark - 富文本
#define ComboTitleFont [UIFont boldSystemFontOfSize:30]
- (NSMutableAttributedString *)appendComboButtonTitle:(NSString *)title {
    // TODO:连击按钮标题富文本
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:title
                                                                                        attributes:
                                                  @{NSFontAttributeName : ComboTitleFont,
                                                    NSForegroundColorAttributeName : [UIColor blackColor]}];
    [attributeString appendAttributedString:[self parseMessage:@" \n combo" font:[UIFont systemFontOfSize:18] color:[UIColor blackColor]]];
    
    return attributeString;
}

- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    // TODO:聊天富文本
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)];
    return attributeString;
}

#pragma mark - Im通知
- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"LSVIPGiftPageViewController::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.liveRoom.imLiveRoom.manLevel = level;
    });
}

- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *  _Nonnull)loveLevelItem {
    NSLog(@"LSVIPGiftPageViewController::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d, anchorId: %@, anchorName: %@ )", loveLevelItem.loveLevel, loveLevelItem.anchorId, loveLevelItem.anchorName);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.liveRoom.imLiveRoom.loveLevel = loveLevelItem.loveLevel;
    });
}

#pragma mark - SendGiftTheQueueManagerDelegate
- (void)sendGiftFailWithItem:(GiftItem *)item {
    // 发送大礼物失败
    NSString *tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"BIG_GIFT_SEND_FAIL"), item.giftItem.infoItem.name];
    [self showDialogTipView:tip];
}

- (void)sendGiftNoCredit:(GiftItem *)item {
    // 信用点不足礼物发送失败, 停止连击
    [self resetGiftClickParam];
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LiveViewController::onSendGift( [发送直播间礼物消息], errmsg : %@, credit : %f, rebateCredit : %f )", errmsg, credit, rebateCredit);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!success && errType == LCC_ERR_NO_CREDIT) {
            // 钱不够清队列
            [self.sendGiftTheQueueManager removeAllSendGift];
        }
    });
}
@end
