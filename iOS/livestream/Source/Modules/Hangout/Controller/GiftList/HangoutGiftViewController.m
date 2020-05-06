//
//  HangoutGiftViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/18.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangoutGiftViewController.h"
#import "HangoutNormalGiftView.h"
#import "CeleBrationGiftView.h"
#import "GSSortView.h"
#import "SelectAnchorSendCell.h"

#import "LSImageViewLoader.h"
#import "LSGiftManager.h"

@interface HangoutGiftViewController () <JTSegmentControlDelegate, LSPZPagingScrollViewDelegate, LSCheckButtonDelegate , HangoutNormalGiftViewDelegate, CeleBrationGiftViewDelegate, GSSortViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

// 礼物列表头部视图
@property (nonatomic, weak) IBOutlet UIView *giftTypeView;
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

// 发送主播提示文本
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
// 全选按钮
@property (weak, nonatomic) IBOutlet UIButton *checkAllBtn;
// 选择主播控件
@property (weak, nonatomic) IBOutlet LSCollectionView *selectAnchorSendView;
// 礼物选择视图
@property (weak, nonatomic) IBOutlet UIView *selectSendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectSendViewHeight;

// 充值按钮
@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;

@property (strong, nonatomic) GSSortView *sortView;

// 吧台礼物列表
@property (strong, nonatomic) NSArray<LSGiftManagerItem *> *buyforList;
// 连击礼物及大礼物列表
@property (strong, nonatomic) NSArray<LSGiftManagerItem *> *normalList;
// 庆祝礼物列表
@property (strong, nonatomic) NSArray<LSGiftManagerItem *> *celebrationList;

@property (nonatomic, strong) NSArray *views;
@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) NSArray *sliderFixArray;
@property (nonatomic, strong) NSArray<UIView *> *viewFixArray;

// 选择发送主播ID数组
@property (nonatomic, strong) NSMutableArray *anchorIdArray;
// 连击ID
@property (nonatomic, assign) int clickId;
// 当前连击时间
@property (strong) NSDate *comboDate;

// 选中连击礼物Item
@property (nonatomic, strong) LSGiftManagerItem *selectComboItem;

@property (nonatomic, strong) LSGiftManager *giftManager;

@property (nonatomic, assign) BOOL isCheckAll;

@property (nonatomic, strong) NSMutableArray *anchorNameArray;

@end

@implementation HangoutGiftViewController

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.isShowNavBar = NO;
    
    // 初始化分类ID
    self.curIndex = 0;
    
    // 初始化连击ID
    self.clickId = 0;
    
    // 初始化多人互动礼物队列
    self.buyforList = [[NSMutableArray alloc] init];
    self.normalList = [[NSMutableArray alloc] init];
    self.celebrationList = [[NSMutableArray alloc] init];
    
    // 初始化选择发送主播ID队列
    self.anchorIdArray = [[NSMutableArray alloc] init];
    
    // 发送显示名字队列
    self.anchorNameArray = [[NSMutableArray alloc] init];
    
    // 初始化选中连击礼物Item
    self.selectComboItem = [[LSGiftManagerItem alloc] init];
    
    // 初始化当前连击时间
    self.comboDate = [NSDate date];
    
    // 初始化礼物管理器
    self.giftManager = [LSGiftManager manager];
    
    self.isCheckAll = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 填充固定分栏
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:NSLocalizedStringFromSelf(@"Bar counter")];
    [array addObject:NSLocalizedStringFromSelf(@"Gift store")];
    [array addObject:NSLocalizedStringFromSelf(@"Celebration")];
    self.sliderFixArray = array;
    
    HangoutNormalGiftView *barView = [[HangoutNormalGiftView alloc] initWithFrame:self.view.frame];
    [barView showLoadingView];
    barView.delegate = self;
    
    HangoutNormalGiftView *storeView = [[HangoutNormalGiftView alloc] initWithFrame:self.view.frame];
    [storeView showLoadingView];
    storeView.delegate = self;
    
    CeleBrationGiftView *celeBrationView = [[CeleBrationGiftView alloc] initWithFrame:self.view.frame];
    [celeBrationView showLoadingView];
    celeBrationView.delegate = self;
    self.viewFixArray = [NSArray arrayWithObjects:barView, storeView, celeBrationView, nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"SelectAnchorSendCell" bundle:[LiveBundle mainBundle]];
    [self.selectAnchorSendView registerNib:cellNib forCellWithReuseIdentifier:[SelectAnchorSendCell cellIdentifier]];
//    self.selectAnchorSendView.allowsMultipleSelection = YES;
    self.selectAnchorSendView.delegate = self;
    self.selectAnchorSendView.dataSource = self;
    self.selectAnchorSendView.scrollEnabled = NO;
    self.selectAnchorSendView.showsVerticalScrollIndicator = NO;
    self.selectAnchorSendView.showsHorizontalScrollIndicator = NO;
    //    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    
    self.addCreditBtn.layer.cornerRadius = self.addCreditBtn.frame.size.height / 2;
    self.addCreditBtn.layer.masksToBounds = YES;
    
    self.selectSendView.layer.masksToBounds = YES;
    self.selectSendView.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 初始化分栏
    [self setupSortView];
    
    // 加载默认页
    [self reloadData];
    
    // 请求礼物列表
    [self requrstHangoutGiftList];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 42, self.view.frame.size.width, self.view.frame.size.height - 91);
    [self.view addSubview:effectView];
    [self.view sendSubviewToBack:effectView];
}

#pragma mark - Set/Get
- (void)setChatAnchorArray:(NSMutableArray<LSUserInfoModel *> *)chatAnchorArray {
    _chatAnchorArray = chatAnchorArray;
    [self.anchorIdArray removeAllObjects];
    [self.selectAnchorSendView reloadData];
}

// 创建分栏控件
- (void)setupSortView {
    CGRect frame = CGRectMake(0, 0, self.giftTypeView.frame.size.width, self.giftTypeView.frame.size.height);
    self.sortView = [[GSSortView alloc] initWithFrame:frame];
    self.sortView.delegate = self;
    self.sortView.backgroundColor = COLOR_WITH_16BAND_RGB(0x141414);
    self.sortView.itemFont = 14;
    self.sortView.itemBetween = 10;
    self.sortView.textColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.sortView.textSelectColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.sortView.lineHeight = 3;
    self.sortView.lineImage = [UIImage imageNamed:@"Home_hangoutBg"];
    
    [self.giftTypeView addSubview:self.sortView];
}

#pragma mark - 数据逻辑
- (void)reloadData {
    self.curIndex = 0;
    
    // 填充固定分栏内容
    self.sortView.barTitles = self.sliderFixArray;
    [self.sortView reloadData];
    
    // 选中默认分页界面
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewFixArray];
    self.views = viewControllers;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
    
    if (self.curIndex > 1) {
        self.selectSendViewHeight.constant = 0;
    } else {
        self.selectSendViewHeight.constant = 93;
    }
}

// 刷新礼物列表数据
- (void)reloadGiftList {
    for (int i = 0; i < 3; i++) {
        if (i == 0) {
            // 吧台礼物
            HangoutNormalGiftView *bufView = self.views[i];
            [bufView hiddenMaskView];
            bufView.giftArray = self.buyforList;
        } else if (i == 1) {
            // 普通礼物
            HangoutNormalGiftView *nomView = self.views[i];
            [nomView hiddenMaskView];
            nomView.giftArray = self.normalList;
        } else {
            // 庆祝礼物
            CeleBrationGiftView *celeView = self.views[i];
            [celeView hiddenMaskView];
            celeView.giftArray = self.celebrationList;
        }
    }
}

#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.chatAnchorArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSUserInfoModel *item = self.chatAnchorArray[indexPath.row];
    SelectAnchorSendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SelectAnchorSendCell cellIdentifier] forIndexPath:indexPath];
    [cell setupDate:item.photoUrl index:indexPath.row];
    
    BOOL isEqualId = NO;
    for (NSString *anchorId in self.anchorIdArray) {
        if ([anchorId isEqualToString:item.userId]) {
            isEqualId = YES;
            break;
        } else {
            isEqualId = NO;
        }
    }
    
    if (isEqualId) {
        if (![cell getIsSelect]) {
            [self.anchorIdArray removeObject:item.userId];
        }
    } else {
        if ([cell getIsSelect]) {
            [self.anchorIdArray addObject:item.userId];
        }
    }
    
    [self showSendLabelText];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LSUserInfoModel *item = self.chatAnchorArray[indexPath.item];
    SelectAnchorSendCell *cell = (SelectAnchorSendCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.isCheckAll) {
        [cell changeSelect:YES];
        // 动画素组
        CABasicAnimation *animation = [self opacityForeverAnimation:0.5 fromValue:1 toValue:0 repeatCount:2];
        [cell foreverAnimation:animation];
    } else {
        [cell changeSelect:![cell getIsSelect]];
    }
    
    BOOL isEqualId = NO;
    for (NSString *anchorId in self.anchorIdArray) {
        if ([anchorId isEqualToString:item.userId]) {
            isEqualId = YES;
            break;
        } else {
            isEqualId = NO;
        }
    }
    
    if (isEqualId) {
        if (![cell getIsSelect]) {
            [self.anchorIdArray removeObject:item.userId];
        }
    } else {
        if ([cell getIsSelect]) {
            [self.anchorIdArray addObject:item.userId];
        }
    }
    
    [self showSendLabelText];
}

- (void)showSendLabelText {
    [self.anchorNameArray removeAllObjects];
    if (self.anchorIdArray.count > 0) {
        
        for (LSUserInfoModel *model in self.chatAnchorArray) {
            for (NSString *anchorId in self.anchorIdArray) {
                if ([model.userId isEqualToString:anchorId]) {
                    [self.anchorNameArray addObject:model.nickName];
                    break;
                }
            }
        }
        
        NSString *send = [NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromSelf(@"SEND_TO"),self.anchorNameArray[0]];
        if (self.anchorNameArray.count == 2) {
            send = [NSString stringWithFormat:@"%@, %@",send,self.anchorNameArray[1]];
        } else if (self.anchorNameArray.count == 3) {
            send = [NSString stringWithFormat:@"%@, %@, %@",send,self.anchorNameArray[1],self.anchorNameArray[2]];
        }
        self.sendLabel.text = send;
        
    } else {
        self.sendLabel.text = [NSString stringWithFormat:@"%@...",NSLocalizedStringFromSelf(@"SEND_TO")];
    }
}

#pragma mark - 动画数组
- (CABasicAnimation *)opacityForeverAnimation:(float)time fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue repeatCount:(CGFloat)repeatCount {
    // 必须写opacity才行。
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    // 透明度。
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = repeatCount;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    // 没有的话是均匀的动画
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}

#pragma mark - GSSortViewDelegate
- (void)gsSortViewDidScroll:(NSInteger)index {
    if( self.curIndex != index ) {
        self.curIndex = index;
        [self.pagingScrollView displayPagingViewAtIndex:index animated:YES];
        if (index > 1) {
            self.selectSendViewHeight.constant = 0;
        } else {
            self.selectSendViewHeight.constant = 93;
        }
    }
}

#pragma mark - 分页委托(LSPZPagingScrollViewDelegate)
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    return self.views.count;
}

- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)];
    return view;
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    UIView *view = [self.views objectAtIndex:index];
    
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
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    if( self.curIndex != index ) {
        self.curIndex = index;
        [self.sortView scrollMarkLineAndSelectedItem:self.view.frame.size.width * index];
    }
}

#pragma mark - HangoutNormalGiftViewDelegate
- (void)hangoutNormalCollectionDidSelectItem:(LSGiftManagerItem *)item giftView:(HangoutNormalGiftView *)giftView {
    // 是否连击礼物
    BOOL isCombo = item.infoItem.type == GIFTTYPE_COMMON ? YES : NO;
    // 是否可连击
    BOOL isMultiClick = item.infoItem.multiClick;
    // 之前选中连击GiftItem与当前选中 Id是否一样
    BOOL isEqualGiftId = [self.selectComboItem.infoItem.giftId isEqualToString:item.infoItem.giftId];
    
    if (isCombo && isMultiClick) {
        // ID不一样
        if (!isEqualGiftId) {
            // 覆盖之前item
            self.selectComboItem = item;
            // 生成新连击ID
            [self getTheClickID];
            
        } else {
            // 如果发送间隔大于3秒 生成新连击ID
            if ([self getInterval] > 3) {
                // 生成新连击ID
                [self getTheClickID];
            }
        }
	}
    
    if (isCombo) {
        // 主控制器发送连击礼物
        if ([self.giftDelegate respondsToSelector:@selector(sendComboGiftForAnchor:giftItem:clickId:)]) {
            [self.giftDelegate sendComboGiftForAnchor:self.anchorIdArray giftItem:item clickId:self.clickId];
        }
        
        // 更新连击开始时间
        [self setNowComboDate];
    } else {
        // 重置连击id
        self.clickId = 0;
        
        // 主控制器发送礼物
        if ([self.giftDelegate respondsToSelector:@selector(sendGiftForAnchor:giftItem:clickId:)]) {
            [self.giftDelegate sendGiftForAnchor:self.anchorIdArray giftItem:item clickId:self.clickId];
        }
    }
}

// 更新连击时间
- (void)setNowComboDate {
    self.comboDate = [NSDate date];
}

// 获取连击间隔时间
- (NSTimeInterval)getInterval {
    NSDate *now = [NSDate date];
    NSTimeInterval betweenTime = [now timeIntervalSinceDate:self.comboDate];
    return betweenTime;
}

// TODO:生成连击ID
- (void)getTheClickID {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    long long totalMilliseconds = currentTime * 1000;
    self.clickId = totalMilliseconds % 10000;
}

- (void)hangoutNormalGiftRetry {
    [self requrstHangoutGiftList];
}

#pragma mark - CeleBrationGiftViewDelegate
- (void)celeBrationCollectionDidSelectItem:(LSGiftManagerItem *)item giftView:(CeleBrationGiftView *)giftView {
    // 重置连击id
    self.clickId = 0;
    
    // 主控制器发送礼物
    if ([self.giftDelegate respondsToSelector:@selector(sendGiftForAnchor:giftItem:clickId:)]) {
        [self.giftDelegate sendGiftForAnchor:self.anchorIdArray giftItem:item clickId:self.clickId];
    }
}

- (void)celeBrationGiftRetry {
    [self requrstHangoutGiftList];
}

#pragma mark - HTTP请求
- (void)requrstHangoutGiftList {
    [self.giftManager getHangoutGiftList:self.liveRoom.roomId finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *buyforList, NSArray<LSGiftManagerItem *> *normalList, NSArray<LSGiftManagerItem *> *celebrationList) {
        self.buyforList = buyforList;
        self.normalList = normalList;
        self.celebrationList = celebrationList;
        [self reloadGiftList];
    }];
}

#pragma mark - 界面事件
- (IBAction)coinAction:(id)sender {
    if ([self.giftDelegate respondsToSelector:@selector(showMyBalanceView:)]) {
        [self.giftDelegate showMyBalanceView:self];
    }
}

- (IBAction)switchAction:(id)sender {
    UISwitch *switchBtn = (UISwitch *)sender;
    if ([self.giftDelegate respondsToSelector:@selector(selectSecrettyState:)]) {
        [self.giftDelegate selectSecrettyState:switchBtn.isOn];
    }
}

- (IBAction)checkAllAction:(id)sender {
    self.isCheckAll = YES;
    if (self.chatAnchorArray.count > 0) {
        [self.anchorIdArray removeAllObjects];
        
        [self.selectAnchorSendView performBatchUpdates:^{
            for (int index = 0; index < self.chatAnchorArray.count; index++) {
                LSUserInfoModel *item = self.chatAnchorArray[index];
                [self.anchorIdArray addObject:item.userId];
            }
            for (int i = 0; i < self.anchorIdArray.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self collectionView:self.selectAnchorSendView didSelectItemAtIndexPath:indexPath];
            }
        } completion:^(BOOL finished) {
            self.isCheckAll = NO;
        }];
    }
}

@end
