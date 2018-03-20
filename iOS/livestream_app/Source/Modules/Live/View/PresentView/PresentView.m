//
//  PresentView.m
//  UIWidget
//
//  Created by test on 2017/6/9.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "PresentView.h"
#import "GiftItemCollectionViewCell.h"
#import "GiftItemLayout.h"
#import "LiveGiftDownloadManager.h"
#import "LiveRoomGiftModel.h"
#import "RandomGiftModel.h"
#import "LiveBundle.h"

@interface PresentView () <UIScrollViewDelegate, LSCheckButtonDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageViewTopOffset;

@property (nonatomic, assign) NSInteger indextPathRow;

@property (nonatomic, strong) LiveGiftDownloadManager *loadManager;
/*
 *  多功能按钮约束
 */
@property (strong) MASConstraint *buttonBarBottom;

@property (nonatomic, assign) int buttonBarHeight;

@property (nonatomic, assign) BOOL isFirstCreate;

@end

@implementation PresentView

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        [self addSubview:containerView];

        self.loadManager = [LiveGiftDownloadManager manager];

        [self setupButtonBar:@[ @1 ]];

        UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:bundle];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
        self.collectionView.delegate = self;

        self.isPromoIndexArray = [[NSMutableArray alloc] init];

        self.requestFailView.hidden = YES;

        self.pageView.numberOfPages = 0;
        self.pageView.currentPage = 0;
        [self.pageView addTarget:self action:@selector(scrollPageControlAction:) forControlEvents:UIControlEventValueChanged]; // 设置监听事件

        self.comboBtn.titleLabel.numberOfLines = 0;
        self.comboBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.comboBtn.titleName = @"30 \n combo";
        [self.comboBtn addTarget:self action:@selector(comboGiftInSide:) forControlEvents:UIControlEventTouchUpInside];
        [self.comboBtn addTarget:self action:@selector(comboGiftInSide:) forControlEvents:UIControlEventTouchUpOutside];
        [self.comboBtn addTarget:self action:@selector(comboGiftDow:) forControlEvents:UIControlEventTouchDown];

        self.buttonBar = [[SelectNumButton alloc] init];
        [self addSubview:self.buttonBar];
        [self.buttonBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@0);
            make.left.equalTo(self.sendView.selectBtn.mas_left);
            make.right.equalTo(self.sendView.selectBtn.mas_right);
            self.buttonBarBottom = make.bottom.equalTo(self.sendView.mas_bottom);
        }];

        self.buttonBar.isVertical = YES;
        self.buttonBar.clipsToBounds = YES;

        self.sendView.selectBtn.selectedChangeDelegate = self;
        [self.sendView.sendBtn addTarget:self action:@selector(sendTheGift:) forControlEvents:UIControlEventTouchUpInside];
        [self bringSubviewToFront:self.sendView];

        self.failTipLabel.textColor = COLOR_WITH_16BAND_RGB_ALPHA(0xa3ffffff);

        self.pageViewTopOffset.constant = DESGIN_TRANSFORM_3X(5);

        self.reloadBtn.layer.cornerRadius = 6;
        self.reloadBtn.layer.masksToBounds = YES;

        self.indextPathRow = -1;
        self.buttonBarHeight = 1;

        self.isFirstCreate = YES;
    }
    return self;
}

#pragma mark - 按钮事件
- (IBAction)showMyBalance:(id)sender {
    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewShowBalance:)]) {
        [self.presentDelegate presentViewShowBalance:self];
    }
}

- (IBAction)reloadGiftList:(id)sender {
    self.isFirstCreate = YES;
    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewReloadList:)]) {
        [self.presentDelegate presentViewReloadList:self];
    }
}

- (void)showNoListView {
    self.requestFailView.hidden = NO;
    self.reloadBtn.hidden = YES;
    self.tipImageViewTop.constant = DESGIN_TRANSFORM_3X(55);
    self.failTipLabel.text = NSLocalizedStringFromSelf(@"NO_LIST_TIP");
    self.pageView.hidden = YES;
    [self setupButtonBar:@[ @"1" ]];
    [self sendViewNotUserEnabled];
}

- (void)showRequestFailView {
    self.requestFailView.hidden = NO;
    self.reloadBtn.hidden = NO;
    self.tipImageViewTop.constant = DESGIN_TRANSFORM_3X(32);
    self.failTipLabel.text = NSLocalizedStringFromSelf(@"REQUEST_FAIL_TIP");
    self.pageView.hidden = YES;
    [self setupButtonBar:@[ @"1" ]];
    [self sendViewNotUserEnabled];
}

- (void)showGiftListView {
    self.requestFailView.hidden = YES;
}

// 按钮不可用
- (void)sendViewNotUserEnabled {
    [self.sendView.sendBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
    [self.sendView.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendView.containerView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xbfbfbf).CGColor;
    self.sendView.sendBtn.userInteractionEnabled = NO;
}

// 按钮可用
- (void)sendViewCanUserEnabled {
    [self.sendView.sendBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xf7cd3a)];
    [self.sendView.sendBtn setTitleColor:COLOR_WITH_16BAND_RGB(0x383838) forState:UIControlStateNormal];
    self.sendView.containerView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xf7cd3a).CGColor;
    self.sendView.sendBtn.userInteractionEnabled = YES;
}

- (void)reloadData {

    [self.isPromoIndexArray removeAllObjects];
    [self.collectionView reloadData];
}

- (void)setGiftIdArray:(NSArray *)giftIdArray {

    [self.isPromoIndexArray removeAllObjects];
    _giftIdArray = giftIdArray;

    // 筛选可发送礼物 添加到随机礼物列表
    RandomGiftModel *randomModel = [[RandomGiftModel alloc] init];
    for (LiveRoomGiftModel *item in giftIdArray) {

        if (!(self.loveLevel < item.allItem.infoItem.loveLevel || self.manLevel < item.allItem.infoItem.level)) {
            RandomGiftModel *model = [[RandomGiftModel alloc] init];
            model.randomInteger = [giftIdArray indexOfObject:item];
            model.giftModel = item;
            randomModel = model;
            if (item.isPromo == YES) {
                [self.isPromoIndexArray addObject:model];
            }
        }
    }
    // 如果没有推荐礼物则随机显示可发送礼物
    if (self.isPromoIndexArray.count < 1) {
        [self.isPromoIndexArray addObject:randomModel];
    }
    
    [self.collectionView reloadData];

    // 防止cell有加载滑动动画
    [UIView setAnimationsEnabled:NO];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadData];
    }
        completion:^(BOOL finished) {
            [UIView setAnimationsEnabled:YES];
        }];
}

- (void)scrollPageControlAction:(UIPageControl *)sender {

    CGSize viewSize = self.collectionView.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [self.collectionView scrollRectToVisible:rect animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftIdArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.pageView.hidden) {
        self.pageView.hidden = NO;
    }

    GiftItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier] forIndexPath:indexPath];

    LiveRoomGiftModel *model = self.giftIdArray[indexPath.row];
    AllGiftItem *item = [self.loadManager backGiftItemWithGiftID:model.giftId];
    [cell updataCellViewItem:item manLV:self.manLevel loveLV:self.loveLevel];

    BOOL isIndexPath = NO;
    if (self.indextPathRow == indexPath.row) {
        isIndexPath = YES;

    } else if (self.indextPathRow == -1 && indexPath.row == 0) {
        self.indextPathRow = 0;
        isIndexPath = YES;
    }

    // 默认选中第一个
    if (isIndexPath) {
        cell.selectCell = YES;
        self.isCellSelect = YES;
        self.selectCellItem = [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:model.giftId];

        if (self.isFirstCreate) {
            [self setupButtonBar:self.selectCellItem.infoItem.sendNumList];
            self.isFirstCreate = NO;
        }

        if (model.allItem.infoItem.loveLevel > self.loveLevel || model.allItem.infoItem.level > self.manLevel) {
            // 发送按钮不可用
            [self sendViewNotUserEnabled];

        } else {
            // 发送按钮可用
            [self sendViewCanUserEnabled];
        }
    }

    [cell reloadStyle];

    // 刷新页数 小高表布局
    GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
    if (self.pageView.numberOfPages != layout.pageCount) {
        self.pageView.numberOfPages = layout.pageCount;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.buttonBar.frame.size.height) {

        [self hideButtonBar];

    } else {

        self.indextPathRow = indexPath.row;
        [self.collectionView reloadData];

        [UIView setAnimationsEnabled:NO];
        [collectionView performBatchUpdates:^{
            [collectionView reloadData];
        }
            completion:^(BOOL finished) {
                [UIView setAnimationsEnabled:YES];
            }];

        // 设置选中礼物cell的可选按钮
        LiveRoomGiftModel *model = self.giftIdArray[indexPath.row];
        if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewdidSelectItemWithSelf:numberList:atIndexPath:)]) {
            [self.presentDelegate presentViewdidSelectItemWithSelf:self numberList:self.selectCellItem.infoItem.sendNumList atIndexPath:indexPath];
        }

        // 用户等级或亲密度不够
        int loveLevel = model.allItem.infoItem.loveLevel;
        int manLevel = model.allItem.infoItem.level;
        if (manLevel > self.manLevel) {
            if ([self.presentDelegate respondsToSelector:@selector(presentViewdidSelectGiftLevel:loveLevel:)]) {
                [self.presentDelegate presentViewdidSelectGiftLevel:manLevel loveLevel:loveLevel];
            }
        } else if (loveLevel > self.loveLevel) {
            if ([self.presentDelegate respondsToSelector:@selector(presentViewdidSelectGiftLevel:loveLevel:)]) {
                [self.presentDelegate presentViewdidSelectGiftLevel:manLevel loveLevel:loveLevel];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    // 刷新选择分页
    GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
    if (self.pageView.currentPage != layout.currentPage) {
        self.pageView.currentPage = layout.currentPage;
    }
    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewDidScroll:currentPageNumber:)]) {
        GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
        [self.presentDelegate presentViewDidScroll:self currentPageNumber:layout.currentPage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.buttonBar.frame.size.height) {
        [self hideButtonBar];
    }
}

- (void)randomSelect:(NSInteger)integer {

    // 滑动到指定页面
    int num = (int)(integer / 8);
    self.collectionView.contentOffset = CGPointMake(num * SCREEN_WIDTH, 0);
    // 刷新分页控件
    self.pageView.currentPage = num;
    self.isFirstCreate = YES;
    self.indextPathRow = integer;
    [self.collectionView reloadData];
}

#pragma mark - 发送按钮
- (void)sendTheGift:(id)sender {

    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewSendBtnClick:andSender:)]) {

        [self.presentDelegate presentViewSendBtnClick:self andSender:sender];
    }
}

- (void)comboGiftInSide:(id)sender {

    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewComboBtnInside:andSender:)]) {

        [self.presentDelegate presentViewComboBtnInside:self andSender:sender];
    }
}

- (void)comboGiftDow:(id)sender {

    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewComboBtnDown:andSender:)]) {

        [self.presentDelegate presentViewComboBtnDown:self andSender:sender];
    }
}

#pragma mark - 多功能按钮管理
- (void)setupButtonBar:(NSArray *)sendNumList {
    UIImage *whiteImage = [LSUIImageFactory createImageWithColor:[UIColor whiteColor] imageRect:CGRectMake(0, 0, 1, 1)];
    UIImage *blueImage = [LSUIImageFactory createImageWithColor:COLOR_WITH_16BAND_RGB(0xf7cd3a) imageRect:CGRectMake(0, 0, 1, 1)];

    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < sendNumList.count; i++) {
        NSString *title = [NSString stringWithFormat:@"%@", sendNumList[i]];
        UIButton *firstNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [firstNumBtn setTitle:title forState:UIControlStateNormal];
        [firstNumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [firstNumBtn setBackgroundImage:whiteImage forState:UIControlStateNormal];
        [firstNumBtn setBackgroundImage:blueImage forState:UIControlStateSelected];
        [firstNumBtn addTarget:self action:@selector(selectFirstNum:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            self.sendView.selectNumLabel.text = title;
            [firstNumBtn setSelected:YES];
        } else {
            [firstNumBtn setSelected:NO];
        }
        [items addObject:firstNumBtn];
    }
    self.buttonBar.items = items;
    [self.buttonBar reloadData:YES];
    self.buttonBarHeight = 45 * (int)sendNumList.count;
}

- (void)selectFirstNum:(id)sender {
    UIButton *btn = sender;
    [sender setSelected:YES];

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

#pragma mark - LSCheckButtonDelegate
- (void)selectedChanged:(id)sender {

    if (sender == self.sendView.selectBtn) {
        if (self.sendView.selectBtn.selected) {
            [self showButtonBar];
        } else {
            [self hideButtonBar];
        }
    }
}

- (void)showButtonBar {
    [self.buttonBarBottom uninstall];

    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.buttonBarHeight));
        self.buttonBarBottom = make.bottom.equalTo(self.sendView.mas_top).offset(-2);
    }];
    [UIView animateWithDuration:0.3
        animations:^{
            [self layoutIfNeeded];
            self.buttonBar.alpha = 1;

        }
        completion:^(BOOL finished) {
            self.sendView.selectBtn.selected = YES;
        }];
}

- (void)hideButtonBar {
    [self.buttonBarBottom uninstall];

    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        self.buttonBarBottom = make.bottom.equalTo(self.sendView.mas_bottom);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
        self.buttonBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.sendView.selectBtn.selected = NO;
    }];
}

@end

