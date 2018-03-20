//
//  BackpackPresentView.m
//  livestream
//
//  Created by randy on 2017/8/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BackpackPresentView.h"
#import "GiftItemCollectionViewCell.h"
#import "GiftItemLayout.h"
#import "LiveGiftDownloadManager.h"
#import "LiveBundle.h"

@interface BackpackPresentView () <UIScrollViewDelegate, LSCheckButtonDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageViewTopOffset;

@property (nonatomic, assign) NSInteger indextPathRow;

@property (nonatomic, assign) int buttonBarHeight;
/**
 *  多功能按钮约束
 */
@property (strong) MASConstraint *buttonBarBottom;

@property (nonatomic, assign) BOOL isFirstCreate;

@end

@implementation BackpackPresentView

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        [self addSubview:containerView];

        //        [self setupButtonBar];

        UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:bundle];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
        self.collectionView.delegate = self;

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
        self.buttonBar.hidden = YES;
        self.sendView.selectNumLabel.hidden = YES;
        self.sendView.arrowImageView.hidden = YES;
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
- (IBAction)reloadGiftList:(id)sender {

    if (self.backpackDelegate && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewReloadList:)]) {
        [self.backpackDelegate backpackPresentViewReloadList:self];
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

    [self.collectionView reloadData];
}

- (void)scrollPageControlAction:(UIPageControl *)sender {

    CGSize viewSize = self.collectionView.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [self.collectionView scrollRectToVisible:rect animated:YES];
}

#pragma mark 数据源
- (void)setGiftIdArray:(NSArray *)giftIdArray {

    _giftIdArray = giftIdArray;
    [self.collectionView reloadData];
}

#pragma mark UICollectionViewDelegate / UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftIdArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.pageView.hidden) {
        self.pageView.hidden = NO;
    }

    GiftItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier] forIndexPath:indexPath];

    // 更新cell数据
    RoomBackGiftItem *model = self.giftIdArray[indexPath.row];
    [cell updataBackpackCellViewItem:model];
    
    // 设置发送按钮可用
    if (!self.sendView.sendBtn.userInteractionEnabled) {
        [self sendViewCanUserEnabled];
    }
    
    AllGiftItem *item = [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:model.giftId];
    // 默认选中第一个
    BOOL isIndexPath = NO;
    if (self.indextPathRow == indexPath.row) {
        isIndexPath = YES;

    } else if ((self.indextPathRow == -1 && indexPath.row == 0) || self.indextPathRow == self.giftIdArray.count) {
        self.indextPathRow = 0;
        isIndexPath = YES;
    }
    
    if (isIndexPath) {
        cell.selectCell = YES;
        self.isCellSelect = YES;
        self.selectCellItem = item;

        if (self.isFirstCreate) {
            [self setupButtonBar:item.infoItem.sendNumList];
            self.isFirstCreate = NO;
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

        RoomBackGiftItem *model = self.giftIdArray[indexPath.row];
        AllGiftItem *item = [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:model.giftId];

        if ([self.backpackDelegate respondsToSelector:@selector(backpackPresentViewDidSelectItemWithSelf:numberList:atIndexPath:)]) {
            [self.backpackDelegate backpackPresentViewDidSelectItemWithSelf:self numberList:item.infoItem.sendNumList atIndexPath:indexPath];
        }
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    // 刷新选择分页
    GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
    if (self.pageView.currentPage != layout.currentPage) {
        self.pageView.currentPage = layout.currentPage;
    }
    if ([self.backpackDelegate respondsToSelector:@selector(backpackPresentViewDidScroll:currentPageNumber:)]) {
        GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
        [self.backpackDelegate backpackPresentViewDidScroll:self currentPageNumber:layout.currentPage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (self.buttonBar.frame.size.height) {
        [self hideButtonBar];
    }
}

#pragma mark - 发送按钮
- (void)sendTheGift:(id)sender {

    if ([self.backpackDelegate respondsToSelector:@selector(backpackPresentViewSendBtnClick:andSender:)]) {
        [self.backpackDelegate backpackPresentViewSendBtnClick:self andSender:sender];
    }
}

- (void)comboGiftInSide:(id)sender {

    if ([self.backpackDelegate respondsToSelector:@selector(backpackPresentViewComboBtnInside:andSender:)]) {
        [self.backpackDelegate backpackPresentViewComboBtnInside:self andSender:sender];
    }
}

- (void)comboGiftDow:(id)sender {

    if ([self.backpackDelegate respondsToSelector:@selector(backpackPresentViewComboBtnDown:andSender:)]) {
        [self.backpackDelegate backpackPresentViewComboBtnDown:self andSender:sender];
    }
}

#pragma mark - 多功能按钮管理
- (void)setupButtonBar:(NSArray *)sendNumList {

    self.buttonBar.hidden = NO;
    self.sendView.selectNumLabel.hidden = NO;
    self.sendView.arrowImageView.hidden = NO;

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

        if (i == sendNumList.count - 1) {
            self.buttonBar.items = items;
            [self.buttonBar reloadData:YES];
            self.buttonBarHeight = 45 * (int)sendNumList.count;
        }
    }
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
            // Make all constraint changes here, Called on parent view
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

    [UIView animateWithDuration:0.3
        animations:^{
            // Make all constraint changes here, Called on parent view
            [self layoutIfNeeded];

            self.buttonBar.alpha = 0;

        }
        completion:^(BOOL finished) {
            self.sendView.selectBtn.selected = NO;
        }];
}


@end
