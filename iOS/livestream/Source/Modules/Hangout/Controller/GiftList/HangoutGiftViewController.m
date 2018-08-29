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
#import "SelectNumButton.h"
#import "SelectForGiftView.h"

#import "LSImageViewLoader.h"
#import "LSGiftManager.h"

@interface HangoutGiftViewController () <JTSegmentControlDelegate, LSPZPagingScrollViewDelegate, LSCheckButtonDelegate,LSButtonBarDelegete ,SelectForGiftViewDelegate, HangoutNormalGiftViewDelegate, CeleBrationGiftViewDelegate>
@property (nonatomic, weak) IBOutlet UIView *segmentView;
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

// 箭头视图
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

// 礼物列表头部视图
@property (weak, nonatomic) IBOutlet UIView *giftTypeView;
// 礼物列表底部视图
@property (weak, nonatomic) IBOutlet UIView *giftBottomView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftBottomViewHeight;
// 选择发送对象view
@property (weak, nonatomic) IBOutlet UIView *selectView;

// 吧台礼物列表
@property (strong, nonatomic) NSArray<LSGiftManagerItem *> *buyforList;
// 连击礼物及大礼物列表
@property (strong, nonatomic) NSArray<LSGiftManagerItem *> *normalList;
// 庆祝礼物列表
@property (strong, nonatomic) NSArray<LSGiftManagerItem *> *celebrationList;

// 多功能按钮
@property (strong) SelectNumButton* buttonBar;
/*
 *  多功能按钮约束
 */
@property (strong) MASConstraint *buttonBarBottom;
@property (nonatomic, assign) int buttonBarHeight;

// 顶部分类栏
@property (nonatomic, strong) JTSegmentControl *segment;

@property (nonatomic, strong) NSArray *views;
@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) NSArray<JTSegmentItem *> *sliderFixArray;
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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewTwoY;
@end

@implementation HangoutGiftViewController

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
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
    
    // 初始化选中连击礼物Item
    self.selectComboItem = [[LSGiftManagerItem alloc] init];
    
    // 初始化当前连击时间
    self.comboDate = [NSDate date];
    
    // 初始化礼物管理器
    self.giftManager = [LSGiftManager manager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 填充固定分栏
    NSMutableArray<JTSegmentItem *> *array = [NSMutableArray array];
    JTSegmentItem *item = nil;
    item = [[JTSegmentItem alloc] initWithImage:nil selectedImage:nil title:NSLocalizedStringFromSelf(@"Bar counter")];
    [array addObject:item];
    item = [[JTSegmentItem alloc] initWithImage:nil selectedImage:nil title:NSLocalizedStringFromSelf(@"Gift store")];
    [array addObject:item];
    item = [[JTSegmentItem alloc] initWithImage:nil selectedImage:nil title:NSLocalizedStringFromSelf(@"Celebration")];
    [array addObject:item];
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
    
    self.giftBottomView.layer.masksToBounds = YES;
    self.giftBottomView.clipsToBounds = YES;
    
    self.selectView.layer.cornerRadius = 5;
    
    // 初始化分栏
    [self setupSegment];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 加载默认页
    [self reloadData];
    
    self.nameLabel.hidden = YES;
    
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height * 0.5;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.hidden = YES;
    
    self.allImageViewOne.layer.cornerRadius = self.allImageViewOne.frame.size.height * 0.5;
    self.allImageViewOne.layer.masksToBounds = YES;
    self.allImageViewOne.hidden = YES;
    
    self.allImageViewTwo.layer.cornerRadius = self.allImageViewTwo.frame.size.height * 0.5;
    self.allImageViewTwo.layer.masksToBounds = YES;
    self.allImageViewTwo.hidden = YES;
    
    self.allImageViewThree.layer.cornerRadius = self.allImageViewThree.frame.size.height * 0.5;
    self.allImageViewThree.layer.masksToBounds = YES;
    self.allImageViewThree.hidden = YES;
    
    // 设置选择发送礼物控件
    [self setupButtonBar];
    
    [self showSelectForGiftView];
    
    // 请求礼物列表
    [self requrstHangoutGiftList];
}

#pragma mark - Set/Get
- (void)setChatAnchorArray:(NSMutableArray<LSUserInfoModel *> *)chatAnchorArray {
    _chatAnchorArray = chatAnchorArray;
    
    // 如果选择发送为All 更新所有选择发送队列
    if (self.anchorIdArray.count > 1) {
        for (LSUserInfoModel *model in _chatAnchorArray) {
            [self.anchorIdArray addObject:model.userId];
        }
        [self showSelectForGiftView];
    } else if (self.anchorIdArray.count == 1) {
        BOOL isHave = NO;
        NSString *anchorId = self.anchorIdArray.firstObject;
        for (LSUserInfoModel *model in _chatAnchorArray) {
            if ([model.userId isEqualToString:anchorId]) {
                isHave = YES;
            }
        }
        if (!isHave) {
            [self showSelectForGiftView];
        }
    }
    
    // 如果选择发送控件为空或者当前直播间没人 更新显示队列第一个选择对象
    if (self.nameLabel.isHidden || !chatAnchorArray.count) {
        [self showSelectForGiftView];
    }
}

// 显示选择发送控件数据
- (void)showSelectForGiftView {
    if (self.chatAnchorArray.count > 0) {
        
        switch (self.chatAnchorArray.count) {
            case 1:{
                LSUserInfoModel *model = self.chatAnchorArray.firstObject;
                NSMutableArray *urls = [NSMutableArray arrayWithObject:model.photoUrl];
                [self showOneSelectView:urls nickName:model.nickName];
                [self.anchorIdArray removeAllObjects];
                [self.anchorIdArray addObject:model.userId];
            }break;
                
            case 2:{
                LSUserInfoModel *oneModel = self.chatAnchorArray[0];
                LSUserInfoModel *twoModel = self.chatAnchorArray[1];
                NSMutableArray *urls = [NSMutableArray arrayWithObjects:oneModel.photoUrl, twoModel.photoUrl, nil];
                [self.anchorIdArray removeAllObjects];
                [self.anchorIdArray addObject:oneModel.userId];
                [self.anchorIdArray addObject:twoModel.userId];
                [self showMoreSelectView:urls nickName:@"All"];
            }break;
                
            default:{
                LSUserInfoModel *oneModel = self.chatAnchorArray[0];
                LSUserInfoModel *twoModel = self.chatAnchorArray[1];
                LSUserInfoModel *threeModel = self.chatAnchorArray[2];
                NSMutableArray *urls = [NSMutableArray arrayWithObjects:oneModel.photoUrl, twoModel.photoUrl, threeModel.photoUrl, nil];
                [self.anchorIdArray removeAllObjects];
                [self.anchorIdArray addObject:oneModel.userId];
                [self.anchorIdArray addObject:twoModel.userId];
                [self.anchorIdArray addObject:threeModel.userId];
                [self showMoreSelectView:urls nickName:@"All"];
            }break;
        }
    } else {
        self.headImageView.hidden = YES;
        self.nameLabel.hidden = YES;
    }
}

// 显示一个选中样式
- (void)showOneSelectView:(NSMutableArray *)urls nickName:(NSString *)nickName {
    self.nameLabel.hidden = NO;
    self.headImageView.hidden = NO;
    
    self.allImageViewOne.hidden = YES;
    self.allImageViewTwo.hidden = YES;
    self.allImageViewThree.hidden = YES;
    
    self.nameLabel.text = nickName;
    [[LSImageViewLoader loader] refreshCachedImage:self.headImageView options:SDWebImageRefreshCached imageUrl:urls.firstObject placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
}

// 显示多个选中样式
- (void)showMoreSelectView:(NSMutableArray *)urls nickName:(NSString *)nickName {
    self.headViewTwoY.constant = -5;
    BOOL isSubter = YES;
    if (urls.count > 2) {
        isSubter = NO;
        self.headViewTwoY.constant = 0;
    }
    self.nameLabel.hidden = NO;
    self.allImageViewOne.hidden = isSubter;
    self.allImageViewTwo.hidden = NO;
    self.allImageViewThree.hidden = NO;
    
    self.headImageView.hidden = YES;
    
    self.nameLabel.text = nickName;
    [[LSImageViewLoader loader] refreshCachedImage:self.allImageViewTwo options:SDWebImageRefreshCached imageUrl:urls.firstObject placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    [[LSImageViewLoader loader] refreshCachedImage:self.allImageViewThree options:SDWebImageRefreshCached imageUrl:urls[1] placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    if (!isSubter) {
        [[LSImageViewLoader loader] refreshCachedImage:self.allImageViewOne options:SDWebImageRefreshCached imageUrl:urls[2] placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    }
}

- (void)setupSegment {
    // 创建分栏控件
    CGRect frame = CGRectMake(0, 0, self.segmentView.frame.size.width, self.segmentView.frame.size.height);
    self.segment = [[JTSegmentControl alloc] init];
    self.segment.frame = frame;
    self.segment.sliderViewColor = COLOR_WITH_16BAND_RGB(0x05c775);
    self.segment.font = [UIFont systemFontOfSize:12];
    self.segment.selectedFont = [UIFont systemFontOfSize:12];
    self.segment.itemTextColor = [UIColor blackColor];
    self.segment.itemBackgroundColor = [UIColor clearColor];
    self.segment.itemSelectedTextColor = COLOR_WITH_16BAND_RGB(0x05c775);
    self.segment.itemSelectedBackgroundColor = [UIColor clearColor];
    self.segment.bounces = YES;
    self.segment.autoAdjustWidth = YES;
    //    self.segment.itemWidthCustom = 100;
    self.segment.delegate = self;
    
    [self.segmentView addSubview:self.segment];
}

#pragma mark - 数据逻辑
- (void)reloadData {
    self.curIndex = 0;
    // 填充固定分栏内容
    NSMutableArray *sliderArray = [NSMutableArray arrayWithArray:self.sliderFixArray];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewFixArray];
    
    self.segment.items = sliderArray;
    [self.segment setupViewOpen];
    
    // 选中默认分页界面
    self.views = viewControllers;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
    
    if (self.curIndex > 1) {
        self.giftBottomViewHeight.constant = 0;
    } else {
        self.giftBottomViewHeight.constant = 43;
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

#pragma mark - 初始化选择发送按钮控件
- (void)setupButtonBar {
    self.buttonBar = [[SelectNumButton alloc] init];
    [self.view addSubview:self.buttonBar];
    [self.buttonBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        make.left.equalTo(self.selectView.mas_left);
        make.right.equalTo(self.selectView.mas_right);
        self.buttonBarBottom = make.bottom.equalTo(self.selectView.mas_bottom);
    }];
    self.buttonBar.isVertical = YES;
    self.buttonBar.clipsToBounds = YES;
    self.buttonBar.delegate = self;
    
    self.selectBtn.selectedChangeDelegate = self;
}

#pragma mark - 多功能按钮管理
- (void)setupButtonBar:(NSArray *)audienceArray {
    
    [self.buttonBar removeAllButton];
    
    NSMutableArray *chatNameArray = [[NSMutableArray alloc] init];
    [chatNameArray addObjectsFromArray:audienceArray];

    NSMutableArray *items = [NSMutableArray array];
    
    // 头像url数组
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    // 如果主播人数多于2 创建All按钮
    if (chatNameArray.count > 1) {
        for (LSUserInfoModel *model in chatNameArray) {
            [urls addObject:model.photoUrl];
        }
        SelectForGiftView *view = [[SelectForGiftView alloc] initWithFrame:CGRectZero];
        view.delegate = self;
        SelecterModel *model = [[SelecterModel alloc] init];
        model.anchorId = nil;
        model.anchorName = @"All";
        model.urls = urls;
        [view showViewUpdate:model];
        [view sizeToFit];
        [items addObject:view];
        
    } else if (chatNameArray.count == 0) {
        SelectForGiftView *view = [[SelectForGiftView alloc] initWithFrame:CGRectZero];
        view.delegate = self;
        SelecterModel *model = [[SelecterModel alloc] init];
        model.anchorId = nil;
        model.anchorName = nil;
        model.urls = urls;
        [view showViewUpdate:model];
        [view sizeToFit];
        [items addObject:view];
    }
    
    // 遍历创建每个主播at控件
    for (int i = 0; i < chatNameArray.count; i++) {
        NSMutableArray *urls = [[NSMutableArray alloc] init];
        LSUserInfoModel *model = chatNameArray[i];
        [urls addObject:model.photoUrl];
        SelectForGiftView *view = [[SelectForGiftView alloc] initWithFrame:CGRectZero];
        view.delegate = self;
        SelecterModel *selecterModel = [[SelecterModel alloc] init];
        selecterModel.anchorId = model.userId;
        selecterModel.anchorName = model.nickName;
        selecterModel.urls = urls;
        [view showViewUpdate:selecterModel];
        [view sizeToFit];
        [items addObject:view];
    }
    self.buttonBar.items = items;
    [self.buttonBar reloadData:YES];
    self.buttonBarHeight = 33 * (int)items.count;
}

#pragma mark - SelectForGiftViewDelegate
- (void)selectTheSender:(SelecterModel *)model {
    // 清空选中发送给礼物的人队列
    [self.anchorIdArray removeAllObjects];
    // 选中没人
    if (!model.anchorName.length && !model.anchorId.length) {
        self.headImageView.hidden = YES;
        self.nameLabel.hidden = YES;
    }
    
    // 选中单人
    if (model.anchorName.length > 0 && model.anchorId.length > 0) {
        [self showOneSelectView:model.urls nickName:model.anchorName];
        // 添加发送给礼物的人
        [self.anchorIdArray addObject:model.anchorId];
    }
    
    // 选中All
    if (model.anchorName.length > 0 && !model.anchorId.length) {
        [self showMoreSelectView:model.urls nickName:model.anchorName];
        
        // 添加发送给礼物的所有人
        for (LSUserInfoModel *model in self.chatAnchorArray) {
            [self.anchorIdArray addObject:model.userId];
        }
    }
    [self hiddenButtonBar];
}


#pragma mark - LSCheckButtonDelegate
- (void)selectedChanged:(id)sender {
    
    if (sender == self.selectBtn) {
        if (self.selectBtn.selected) {
            [self setupButtonBar:self.chatAnchorArray];
            [self showButtonBar];
        } else {
            [self hiddenButtonBar];
        }
    }
}

#pragma mark - 分栏委托(JTSegmentControlDelegate)
- (void)didSelectedWithSegement:(JTSegmentControl * _Nonnull)segement index:(NSInteger)index {
    if( self.curIndex != index ) {
        self.curIndex = index;
        [self.pagingScrollView displayPagingViewAtIndex:index animated:YES];
        if (index > 1) {
            self.giftBottomViewHeight.constant = 0;
        } else {
            self.giftBottomViewHeight.constant = 43;
        }
        [self hiddenButtonBar];
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
        [self.segment moveTo:index animated:YES];
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

#pragma mark - CeleBrationGiftViewDelegate
- (void)celeBrationCollectionDidSelectItem:(LSGiftManagerItem *)item giftView:(CeleBrationGiftView *)giftView {
    // 重置连击id
    self.clickId = 0;
    
    // 主控制器发送礼物
    if ([self.giftDelegate respondsToSelector:@selector(sendGiftForAnchor:giftItem:clickId:)]) {
        [self.giftDelegate sendGiftForAnchor:self.anchorIdArray giftItem:item clickId:self.clickId];
    }
}

#pragma mark - 界面显示/隐藏
/** 显示聊天选择框 **/
- (void)showButtonBar {
    [self.buttonBarBottom uninstall];
    self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, -M_PI);
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.buttonBarHeight));
        self.buttonBarBottom = make.bottom.equalTo(self.selectView.mas_top).offset(-2);
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
        self.buttonBarBottom = make.bottom.equalTo(self.selectView.mas_bottom);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.buttonBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.selectBtn.selected = NO;
    }];
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

@end
