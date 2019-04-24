//
//  GiftPageViewController.m
//  livestream
//
//  Created by Max on 2018/5/29.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "GiftPageViewController.h"
#import "GiftCollectionViewController.h"

#import "PresentSendView.h"
#import "CountTimeButton.h"
#import "SelectNumButton.h"

#import "GiftItemCollectionViewCell.h"

#import "LiveModule.h"

#import "DialogTip.h"

#import "LiveRoomCreditRebateManager.h"
#import "SendGiftTheQueueManager.h"
#import "LSLoginManager.h"
#import "LSGiftManager.h"
#import "LSImManager.h"

@interface GiftPageViewController () <JTSegmentControlDelegate, LSPZPagingScrollViewDelegate, LSCheckButtonDelegate, LiveRoomCreditRebateManagerDelegate, GiftCollectionViewControllerDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate, SendGiftTheQueueManagerDelegate>

@property (nonatomic, weak) IBOutlet UIView *segmentView;
@property (nonatomic, strong) JTSegmentControl *segment;
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

@property (nonatomic, weak) IBOutlet CountTimeButton *comboBtn;
@property (nonatomic, weak) IBOutlet PresentSendView *sendView;
@property (nonatomic, strong) SelectNumButton *buttonBar;

@property (nonatomic, strong) MASConstraint *buttonBarBottom;
@property (nonatomic, assign) NSInteger buttonBarHeight;

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, strong) NSArray<JTSegmentItem *> *sliderArray;
@property (nonatomic, strong) NSArray<GiftCollectionViewController *> *vcArray;

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

@end

@implementation GiftPageViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    self.isShowNavBar = NO;
    
    self.curIndex = 0;
    self.buttonBarHeight = 0;

    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    [self.creditRebateManager addDelegate:self];

    self.sendGiftTheQueueManager = [[SendGiftTheQueueManager alloc] init];
    self.sendGiftTheQueueManager.delegate = self;
    
    self.loginManager = [LSLoginManager manager];
    
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
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
    
    [self.comboBtn stopCountDown];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 初始化提示
    self.dialogTipView = [DialogTip dialogTip];

    // 初始化分栏
    [self setupSegment];
    // 初始化内容
    [self setupPageScrollView];
    // 初始初始化多功能按钮
    [self setupGiftNumberBar];
    // 初始化底部
    [self setupBottomView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 加载默认页
    [self reloadData];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.comboBtn stopCountDown];
}

- (void)setupSegment {
    // TODO:初始化分栏控件
    self.segment = [[JTSegmentControl alloc] init];
    self.segment.backgroundColor = [UIColor clearColor];
    self.segment.sliderViewColor = [UIColor clearColor];
    self.segment.font = [UIFont systemFontOfSize:13];
    self.segment.selectedFont = [UIFont systemFontOfSize:13];
    self.segment.itemTextColor = COLOR_WITH_16BAND_RGB_ALPHA(0x59ffffff);
    self.segment.itemSelectedTextColor = COLOR_WITH_16BAND_RGB(0xf7cd3a);
    self.segment.itemBackgroundColor = COLOR_WITH_16BAND_RGB(0x000000);
    self.segment.itemSelectedBackgroundColor = [UIColor clearColor];
    
    self.segment.bounces = YES;
    self.segment.autoAdjustWidth = NO;
    self.segment.delegate = self;

    [self.segmentView addSubview:self.segment];
    [self.segment mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.segmentView);
        make.top.equalTo(self.segmentView);
        make.width.equalTo(self.segmentView);
        make.height.equalTo(self.segmentView);
    }];
    
    NSMutableArray<JTSegmentItem *> *array = [NSMutableArray array];
    JTSegmentItem *item = nil;
    item = [[JTSegmentItem alloc] initWithImage:[UIImage imageNamed:@"Live_GiftList_Normal"] selectedImage:[UIImage imageNamed:@"Live_GiftList_Select"] title:NSLocalizedStringFromSelf(@"STORE")];
    [array addObject:item];
    item = [[JTSegmentItem alloc] initWithImage:[UIImage imageNamed:@"Live_Backlist_Normal"] selectedImage:[UIImage imageNamed:@"Live_Backlist_Select"] title:NSLocalizedStringFromSelf(@"BACKPACK")];
    [array addObject:item];
    self.sliderArray = array;
}

- (void)setupPageScrollView {
    // TODO:初始化分页
    NSMutableArray *array = [NSMutableArray array];

    GiftCollectionViewController *vc = [[GiftCollectionViewController alloc] initWithNibName:nil bundle:nil];
    vc.vcDelegate = self;
    vc.type = GiftListTypeNormal;
    vc.liveRoom = self.liveRoom;
    [array addObject:vc];

    vc = [[GiftCollectionViewController alloc] initWithNibName:nil bundle:nil];
    vc.vcDelegate = self;
    vc.type = GiftListTypeBackpack;
    vc.liveRoom = self.liveRoom;
    [array addObject:vc];

    self.vcArray = array;
}

- (void)setupGiftNumberBar {
    // TODO:初始化多功能按钮
    self.buttonBar = [[SelectNumButton alloc] init];
    [self.view addSubview:self.buttonBar];
    [self.buttonBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        make.left.equalTo(self.sendView.selectBtn.mas_left);
        make.right.equalTo(self.sendView.selectBtn.mas_right);
        self.buttonBarBottom = make.bottom.equalTo(self.sendView.mas_bottom);
    }];
    
    self.buttonBar.isVertical = YES;
    self.buttonBar.clipsToBounds = YES;
    
    [self setupButtonBar:@[@1]];
}

- (void)setupBottomView {
    // TODO:初始化底部控件
    
    // 普通发送按钮
    self.sendView.selectBtn.selectedChangeDelegate = self;
    [self.sendView.sendBtn addTarget:self action:@selector(sendGiftAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view bringSubviewToFront:self.sendView];
    
    // 连击按钮
    self.comboBtn.titleLabel.numberOfLines = 0;
    self.comboBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.comboBtn.titleName = @"30 \n combo";
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_Cambo_Nomal"] forState:UIControlStateNormal];
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_Cambo_Hight"] forState:UIControlStateHighlighted];
    [self.comboBtn addTarget:self action:@selector(comboGiftAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 发送按钮
- (void)sendViewNotUserEnabled {
    // TODO:按钮禁用
    [self.sendView.sendBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
    [self.sendView.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendView.containerView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xbfbfbf).CGColor;
    self.sendView.sendBtn.userInteractionEnabled = NO;
}

- (void)sendViewCanUserEnabled {
    // TODO:按钮可用
    [self.sendView.sendBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xf7cd3a)];
    [self.sendView.sendBtn setTitleColor:COLOR_WITH_16BAND_RGB(0x383838) forState:UIControlStateNormal];
    self.sendView.containerView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xf7cd3a).CGColor;
    self.sendView.sendBtn.userInteractionEnabled = YES;
}

#pragma mark - 提示对话框
- (void)showDialogTipView:(NSString *)tipText {
    // TODO:显示提示
    [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:tipText];
}

#pragma mark - 多功能按钮
- (void)setupButtonBar:(NSArray *)sendNumList {
    UIImage *whiteImage = [LSUIImageFactory createImageWithColor:[UIColor whiteColor] imageRect:CGRectMake(0, 0, 1, 1)];
    UIImage *blueImage = [LSUIImageFactory createImageWithColor:COLOR_WITH_16BAND_RGB(0xf7cd3a) imageRect:CGRectMake(0, 0, 1, 1)];

    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < sendNumList.count; i++) {
        NSString *title = [NSString stringWithFormat:@"%@", sendNumList[i]];
        UIButton *numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [numberButton setTitle:title forState:UIControlStateNormal];
        [numberButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [numberButton setBackgroundImage:whiteImage forState:UIControlStateNormal];
        [numberButton setBackgroundImage:blueImage forState:UIControlStateSelected];
        [numberButton addTarget:self action:@selector(numberButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            self.sendView.selectNumLabel.text = title;
            [numberButton setSelected:YES];
        } else {
            [numberButton setSelected:NO];
        }
        [items addObject:numberButton];
    }
    self.buttonBar.items = items;
    [self.buttonBar reloadData:YES];
    self.buttonBarHeight = 45 * (int)sendNumList.count;
}

- (void)showButtonBar {
    // 删除底部约束
    [self.buttonBarBottom uninstall];
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.buttonBarHeight));
        self.buttonBarBottom = make.bottom.equalTo(self.sendView.mas_top).offset(-2);
    }];
    [UIView animateWithDuration:0.3
        animations:^{
            [self.view layoutIfNeeded];
            self.buttonBar.alpha = 1;

        }
        completion:^(BOOL finished) {
            self.sendView.selectBtn.selected = YES;
        }];
}

- (void)hideButtonBar {
    // 删除底部约束
    [self.buttonBarBottom uninstall];

    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        self.buttonBarBottom = make.bottom.equalTo(self.sendView.mas_bottom);
    }];
    [UIView animateWithDuration:0.3
        animations:^{
            [self.view layoutIfNeeded];
            self.buttonBar.alpha = 0;

        }
        completion:^(BOOL finished) {
            self.sendView.selectBtn.selected = NO;
        }];
}

- (void)numberButtonAction:(id)sender {
    UIButton *btn = sender;
    [btn setSelected:YES];

    if (self.buttonBar.items.count > 1) {
        for (UIButton *button in self.buttonBar.items) {
            if (btn != button) {
                [button setSelected:NO];
            }
        }
    }

    self.sendView.selectNumLabel.text = btn.titleLabel.text;
    [self hideButtonBar];
}

#pragma mark - 多功能按钮委托(LSCheckButtonDelegate)
- (void)selectedChanged:(id)sender {
    if (sender == self.sendView.selectBtn) {
        if (self.sendView.selectBtn.selected) {
            [self showButtonBar];
        } else {
            [self hideButtonBar];
        }
    }
}

#pragma mark - 显示买点弹框
- (void)showAddCreditsView:(NSString *)tip {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:tip preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *addAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"ADD_CREDITS", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
        if ([self.vcDelegate respondsToSelector:@selector(didCreditAction:)]) {
            [self.vcDelegate didCreditAction:self];
        }
    }];
    [alertVC addAction:cancelAC];
    [alertVC addAction:addAC];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - 数据逻辑
- (void)reloadData {
    // TODO:刷新礼物列表界面
    self.segment.items = self.sliderArray;
    [self.segment setupViewOpen];

    // 选中默认分页界面
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
}

- (void)selectItem:(LSGiftManagerItem *)item {
    // TODO:选择指定礼物
    GiftCollectionViewController *vc = [self.vcArray objectAtIndex:0];
    [vc selectItem:item];
}

- (void)reset {
    // TODO:重置界面
    [self resetBottomBar];
}

- (void)resetBottomBar {
    [self resetGiftClickParam];
    [self hideButtonBar];
}

#pragma mark - 私有Get/Set
- (NSInteger)viewHeight {
    return ceil(self.view.frame.size.width / 2.0 + 90 + 10 + 5);
}

#pragma mark - 发送数据逻辑
- (BOOL)sendGiftItemWithType {
    // TODO:根据当前礼物列表类型控发送礼物
    BOOL bFlag = NO;
    GiftCollectionViewController *vc = [self.vcArray objectAtIndex:self.curIndex];
    switch (vc.type) {
        case GiftListTypeNormal: {
            // 普通礼物
            bFlag = [self sendNormalGift:vc.selectGiftItem];
        } break;
        case GiftListTypeBackpack: {
            // 背包礼物
            bFlag = [self sendBackpackGift:vc.selectGiftItem];
            
        } break;
        default:
            break;
    }
    return bFlag;
}

- (BOOL)sendNormalGift:(LSGiftManagerItem *)item {
    // TODO:发送普通礼物
    BOOL bFlag = NO;
    
    // 个人信用点和返点
    double userCredit = self.creditRebateManager.mCredit + self.liveRoom.imLiveRoom.rebateInfo.curCredit;
    NSLog(@"GiftPageViewController::sendNormalGift( [发送普通礼物], giftId : %@, mCredit : %f, curCredit : %f, userCredit : %f )", item.giftId, self.creditRebateManager.mCredit, self.liveRoom.imLiveRoom.rebateInfo.curCredit, userCredit);

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

- (BOOL)sendBackpackGift:(LSGiftManagerItem *)item {
    // TODO:发送背包礼物
    NSLog(@"GiftPageViewController::sendBackpackGift( [发送背包礼物], giftId : %@, backpackTotal : %d )", item.giftId, (int)item.backpackTotal);
    
    BOOL bFlag = NO;
    if (item.backpackTotal > 0) {
        if( item.backpackTotal >= self.giftNum ) {
            item.backpackTotal -= self.giftNum;
            
            // 发送礼物
            [self sendLSGiftManagerItem:item isBack:YES];
            
            GiftCollectionViewController *vc = [self.vcArray objectAtIndex:self.curIndex];
            if (item.backpackTotal == 0) {
                // 礼物已经送完
                // 重置连击
                [self resetGiftClickParam];
                
                // 已经发送所有礼物, 清空选中礼物
                vc.selectedIndexPath = -1;
                
            } else {
                bFlag = YES;
            }
            [vc reloadData];
        }
    }
    
    return bFlag;
}

- (void)sendLSGiftManagerItem:(LSGiftManagerItem *)item isBack:(BOOL)isBack {
    // TODO:发送直播间礼物
    NSLog(@"GiftPageViewController::sendLSGiftManagerItem( "
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
    self.endNum = [self.sendView.selectNumLabel.text intValue];
    self.giftNum = [self.sendView.selectNumLabel.text intValue];
    self.totalGiftNum = [self.sendView.selectNumLabel.text intValue];
    self.giftClickId = -1;
    
    // 隐藏连击按钮
    self.comboBtn.hidden = YES;
    // 显示发送按钮
    self.sendView.hidden = NO;
    // 停止连击按钮
    [self.comboBtn stopCountDown];
}

- (void)updateGiftClickParam {
    self.starNum = self.totalGiftNum + 1;
    self.endNum = self.totalGiftNum + [self.sendView.selectNumLabel.text intValue];
    self.giftNum = [self.sendView.selectNumLabel.text intValue];
    self.totalGiftNum += self.giftNum;
}

#pragma mark - 点击事件
- (IBAction)balanceAction:(id)sender {
    // TODO:点击余额

    if ([self.vcDelegate respondsToSelector:@selector(didBalanceAction:)]) {
        [self.vcDelegate didBalanceAction:self];
    }
}

- (void)sendGiftAction:(id)sender {
    // TODO:点击发送礼物

    // 还原连击属性
    [self resetGiftClickParam];
    // 隐藏礼物数量控件
    [self hideButtonBar];

    BOOL bFlag = NO;
    GiftCollectionViewController *vc = [self.vcArray objectAtIndex:self.curIndex];
    if (vc.selectGiftItem.infoItem.type == GIFTTYPE_COMMON) {
        if (vc.selectGiftItem.infoItem.multiClick) {
            // 生成连击ID
            [self createGiftClickId];
            // 隐藏发送按钮
            self.sendView.hidden = YES;
            // 显示连击按钮
            self.comboBtn.hidden = NO;
            // 模拟点击连击按钮
            [self comboGiftAction:self.comboBtn];
            // 标记已经处理为连击礼物
            bFlag = YES;
        }
    }

    if (!bFlag) {
        // 发送当前选择的礼物
        [self sendGiftItemWithType];
    }
}

- (void)comboGiftAction:(id)sender {
    // TODO:点击连击礼物
    CountTimeButton *button = (CountTimeButton *)sender;

    // 停止计时
    [button stopCountDown];
    // 重新开始
    [button startCountDownWithSecond:30];

    // 连击按钮倒计时改变回调
    WeakObject(self, weakSelf);
    [sender countDownChanging:^NSAttributedString *(CountTimeButton *countDownButton, NSInteger second) {
        countDownButton.titleLabel.numberOfLines = 0;
        return [weakSelf appendComboButtonTitle:[NSString stringWithFormat:@"%ld", (long)second]];
    }];

    // 连击按钮倒计时结束回调
    [sender countDownFinished:^NSAttributedString *(CountTimeButton *countDownButton, NSInteger second) {
        if (second <= 0.0) {
            // 重置连击参数
            [weakSelf resetGiftClickParam];
        }

        return [weakSelf appendComboButtonTitle:@"30"];
    }];

    // 发送当前选择的礼物
    if( [self sendGiftItemWithType] ) {
        // 更新连击礼物参数
        [self updateGiftClickParam];
    } else {
        // 停止连击
        [self resetGiftClickParam];
    }

}

#pragma mark - 礼物管理器委托(LSGiftManagerDelegate)
- (void)giftDownloadManagerBigGiftChange:(LSGiftManagerItem *)LSGiftManagerItem index:(NSInteger)index {
    // 礼物下载状态改变, 刷新列表
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

#pragma mark - 分栏委托(JTSegmentControlDelegate)
- (void)didSelectedWithSegement:(JTSegmentControl *_Nonnull)segement index:(NSInteger)index {
    if (self.curIndex != index) {
        self.curIndex = index;
        // 还原底部控件
        [self resetBottomBar];
        // 根据选中控件改变礼物数量控件
        GiftCollectionViewController *vc = [self.vcArray objectAtIndex:self.curIndex];
        [self setupButtonBar:vc.selectGiftItem.infoItem.sendNumList];
        // 刷新分页
        [self.pagingScrollView displayPagingViewAtIndex:index animated:YES];
    }
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
    GiftCollectionViewController *vc = [self.vcArray objectAtIndex:index];
    UIView *view = vc.view;
    if (view != nil) {
        [view removeFromSuperview];
    }
    [pageView removeAllSubviews];

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
    [vc reloadData];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    if (self.curIndex != index) {
        self.curIndex = index;
        // 还原底部控件
        [self resetBottomBar];
        // 根据选中控件改变礼物数量控件
        GiftCollectionViewController *vc = [self.vcArray objectAtIndex:self.curIndex];
        [self setupButtonBar:vc.selectGiftItem.infoItem.sendNumList];
        // 刷新分栏
        [self.segment moveTo:index animated:YES];
    }
}

#pragma mark - 分页委托(LSPZPagingScrollViewDelegate)
- (void)didChangeGiftItem:(GiftCollectionViewController *)vc item:(LSGiftManagerItem *)item {
    [self resetBottomBar];
    [self setupButtonBar:item.infoItem.sendNumList];

    // 判断点击的礼物是否可以发送
    if ([item canSend:self.liveRoom.imLiveRoom.loveLevel userLevel:self.liveRoom.imLiveRoom.manLevel]) {
        // 发送按钮可用
        [self sendViewCanUserEnabled];
    } else {
        // 发送按钮不可用
        [self sendViewNotUserEnabled];

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

- (void)didChangeGiftList:(GiftCollectionViewController *)vc {
    if ([self.vcDelegate respondsToSelector:@selector(didChangeGiftList:)]) {
        [self.vcDelegate didChangeGiftList:self];
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
    NSLog(@"GiftPageViewController::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.liveRoom.imLiveRoom.manLevel = level;
    });
}

- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *  _Nonnull)loveLevelItem {
    NSLog(@"GiftPageViewController::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d, anchorId: %@, anchorName: %@ )", loveLevelItem.loveLevel, loveLevelItem.anchorId, loveLevelItem.anchorName);
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

