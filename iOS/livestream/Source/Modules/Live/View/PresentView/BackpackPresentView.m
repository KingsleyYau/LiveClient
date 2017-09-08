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
#import "UIImage+SolidColor.h"
#import "BackpackGiftItem.h"

@interface BackpackPresentView() < UIScrollViewDelegate,KKCheckButtonDelegate >

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageViewTopOffset;

@property (nonatomic, weak) UIButton *firstNumBtn;

@property (nonatomic, weak) UIButton *secondNumBtn;

@property (nonatomic, weak) UIButton *thirdNumBtn;

@property (nonatomic, assign) NSInteger indextPathRow;

/**
 *  多功能按钮约束
 */
@property (strong) MASConstraint* buttonBarBottom;

@end

@implementation BackpackPresentView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        [self addSubview:containerView];
        
        [self setupButtonBar];
        
        UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
        self.collectionView.delegate = self;
        
        self.pageView.numberOfPages = 0;
        self.pageView.currentPage = 0;
        [self.pageView addTarget:self action:@selector(scrollPageControlAction:)forControlEvents:UIControlEventValueChanged]; // 设置监听事件
        
        self.comboBtn.titleLabel.numberOfLines = 0;
        self.comboBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.comboBtn.titleName = @"30 \n combo";
        [self.comboBtn addTarget:self action:@selector(comboGiftInSide:) forControlEvents:UIControlEventTouchUpInside];
        [self.comboBtn addTarget:self action:@selector(comboGiftInSide:) forControlEvents:UIControlEventTouchUpOutside];
        [self.comboBtn addTarget:self action:@selector(comboGiftDow:) forControlEvents:UIControlEventTouchDown];
        
        self.collectionViewHeight.constant = SCREEN_WIDTH * 0.5;
        
        self.sendView.selectBtn.selectedChangeDelegate = self;
        [self.sendView.sendBtn addTarget:self action:@selector(sendTheGift:) forControlEvents:UIControlEventTouchUpInside];
        
        [self bringSubviewToFront:self.sendView];
        
        self.pageViewTopOffset.constant = DESGIN_TRANSFORM_3X(8);
        
        self.indextPathRow = -1;
        
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    if ( self = [super initWithFrame:frame] ) {
        
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        [self addSubview:containerView];
        
        [self setupButtonBar];
        
        UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
        self.collectionView.delegate = self;
        
        self.pageView.numberOfPages = 0;
        self.pageView.currentPage = 0;
        [self.pageView addTarget:self action:@selector(scrollPageControlAction:)forControlEvents:UIControlEventValueChanged]; // 设置监听事件
        
        self.comboBtn.titleLabel.numberOfLines = 0;
        self.comboBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.comboBtn.titleName = @"30 \n combo";
        [self.comboBtn addTarget:self action:@selector(comboGiftInSide:) forControlEvents:UIControlEventTouchUpInside];
        [self.comboBtn addTarget:self action:@selector(comboGiftInSide:) forControlEvents:UIControlEventTouchUpOutside];
        [self.comboBtn addTarget:self action:@selector(comboGiftDow:) forControlEvents:UIControlEventTouchDown];
        
        self.collectionViewHeight.constant = SCREEN_WIDTH * 0.5;
        
        self.sendView.selectBtn.selectedChangeDelegate = self;
        [self.sendView.sendBtn addTarget:self action:@selector(sendTheGift:) forControlEvents:UIControlEventTouchUpInside];
        
        [self bringSubviewToFront:self.sendView];
        
        self.pageViewTopOffset.constant = DESGIN_TRANSFORM_3X(8);
        
        self.indextPathRow = -1;
    }
    return self;
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
- (void)setGiftIdArray:(NSArray *)giftIdArray{
    
    _giftIdArray = giftIdArray;
    [self.collectionView reloadData];
}

- (void)setGiftItemArray:(NSMutableArray *)giftItemArray{
    
    _giftItemArray = giftItemArray;
    [self.collectionView reloadData];
}

#pragma mark UICollectionViewDelegate / UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftIdArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GiftItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: [GiftItemCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    NSString *giftId = self.giftIdArray[indexPath.row];
//    LiveRoomGiftItemObject *item = [[LiveGiftDownloadManager giftDownloadManager] backGiftItemWithGiftID:giftId];
//    
//    [cell updataCellViewItem:item];
    
    BOOL isIndexPath = NO;
    
    if (self.indextPathRow == indexPath.row) {
        isIndexPath = YES;
        
    }else if (self.indextPathRow == -1 && indexPath.row == 0){
        self.indextPathRow = 0;
        isIndexPath = YES;
    }
    
    if (isIndexPath) {
        cell.selectCell = YES;
        self.isCellSelect = YES;
        [self selectFirstNum:cell];
//        self.selectCellItem = item;
    }
    
    [cell reloadStyle];
    
    [cell backpackHiddenView];
    
    // 刷新页数 小高表布局
    GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
    if( self.pageView.numberOfPages != layout.pageCount ) {
        self.pageView.numberOfPages = layout.pageCount;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.buttonBar.height) {
        
        [self hideButtonBar];
        
    }else{
        
        self.indextPathRow = indexPath.row;
        [self.collectionView reloadData];
        
        [UIView setAnimationsEnabled: NO ];
        [collectionView performBatchUpdates:^{
            [collectionView reloadData];
        } completion:^( BOOL  finished) {
            [UIView setAnimationsEnabled: YES ];
        }];
    }
    
    NSString *giftId = self.giftIdArray[indexPath.row];
    [self didSelectItemWithGiftId:giftId];
    
    if (self.backpackDelegate && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewDidSelectItemWithSelf:atIndexPath:)]) {
        [self.backpackDelegate backpackPresentViewDidSelectItemWithSelf:self atIndexPath:indexPath];
    }
}


- (void)didSelectItemWithGiftId:(NSString *)giftId {
//    self.selectCellItem = [[LiveGiftDownloadManager giftDownloadManager]backGiftItemWithGiftID:giftId];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // 刷新选择分页
    GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
    if( self.pageView.currentPage != layout.currentPage ) {
        self.pageView.currentPage = layout.currentPage;
        
    }
    if (self.backpackDelegate && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewDidScroll:currentPageNumber:)]) {
        GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
        [self.backpackDelegate backpackPresentViewDidScroll:self currentPageNumber:layout.currentPage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.buttonBar.height) {
        [self hideButtonBar];
    }
}

#pragma mark - 发送按钮
- (void)sendTheGift:(id)sender{
    
    if (self.backpackDelegate  && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewSendBtnClick:)]){
        
        [self.backpackDelegate backpackPresentViewSendBtnClick:self];
    }
}

- (void)comboGiftInSide:(id)sender{
    
    if (self.backpackDelegate  && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewComboBtnInside:andSender:)]){
        
        [self.backpackDelegate backpackPresentViewComboBtnInside:self andSender:sender];
    }
}

- (void)comboGiftDow:(id)sender{
    
    if (self.backpackDelegate  && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewComboBtnDown:andSender:)]){
        
        [self.backpackDelegate backpackPresentViewComboBtnDown:self andSender:sender];
    }
}

#pragma mark - 多功能按钮管理
- (void)setupButtonBar {
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
    
    UIImage *whiteImage = [[UIImage alloc]createImageWithColor:[UIColor whiteColor] imageRect:CGRectMake(0, 0, 1, 1)];
    UIImage *blueImage = [[UIImage alloc]createImageWithColor:COLOR_WITH_16BAND_RGB(0x0deaf3) imageRect:CGRectMake(0, 0, 1, 1)];
    
    NSMutableArray* items = [NSMutableArray array];
    
    UIButton* thirdNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [thirdNumBtn setTitle:@"50" forState:UIControlStateNormal];
    [thirdNumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [thirdNumBtn setBackgroundImage:whiteImage forState:UIControlStateNormal];
    [thirdNumBtn setBackgroundImage:blueImage forState:UIControlStateSelected];
    [thirdNumBtn addTarget:self action:@selector(selectThirdNum:) forControlEvents:UIControlEventTouchUpInside];
    [thirdNumBtn setSelected:NO];
    self.thirdNumBtn = thirdNumBtn;
    [items addObject:self.thirdNumBtn];
    
    
    UIButton* secondNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [secondNumBtn setTitle:@"20" forState:UIControlStateNormal];
    [secondNumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [secondNumBtn setBackgroundImage:whiteImage forState:UIControlStateNormal];
    [secondNumBtn setBackgroundImage:blueImage forState:UIControlStateSelected];
    [secondNumBtn addTarget:self action:@selector(selectSecondNum:) forControlEvents:UIControlEventTouchUpInside];
    [secondNumBtn setSelected:NO];
    self.secondNumBtn = secondNumBtn;
    [items addObject:self.secondNumBtn];
    
    UIButton* firstNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [firstNumBtn setTitle:@"1" forState:UIControlStateNormal];
    [firstNumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [firstNumBtn setBackgroundImage:whiteImage forState:UIControlStateNormal];
    [firstNumBtn setBackgroundImage:blueImage forState:UIControlStateSelected];
    [firstNumBtn addTarget:self action:@selector(selectFirstNum:) forControlEvents:UIControlEventTouchUpInside];
    [firstNumBtn setSelected:YES];
    self.firstNumBtn = firstNumBtn;
    [items addObject:self.firstNumBtn];
    
    self.buttonBar.items = items;
    [self.buttonBar reloadData:YES];
}


- (void)selectFirstNum:(id)sender{
    
    [self.firstNumBtn setSelected:YES];
    [self.secondNumBtn setSelected:NO];
    [self.thirdNumBtn setSelected:NO];
    
    self.sendView.selectNumLabel.text = self.firstNumBtn.titleLabel.text;
    
    [self hideButtonBar];
}

- (void)selectSecondNum:(id)sender{
    
    [self.secondNumBtn setSelected:YES];
    [self.firstNumBtn setSelected:NO];
    [self.thirdNumBtn setSelected:NO];
    
    self.sendView.selectNumLabel.text = self.secondNumBtn.titleLabel.text;
    
    [self hideButtonBar];
}

- (void)selectThirdNum:(id)sender{
    
    [self.thirdNumBtn setSelected:YES];
    [self.secondNumBtn setSelected:NO];
    [self.firstNumBtn setSelected:NO];
    
    self.sendView.selectNumLabel.text = self.thirdNumBtn.titleLabel.text;
    
    [self hideButtonBar];
}


#pragma mark - KKCheckButtonDelegate
- (void)selectedChanged:(id)sender{
    
    if (sender == self.sendView.selectBtn) {
        if( self.sendView.selectBtn.selected ) {
            [self showButtonBar];
        } else {
            [self hideButtonBar];
        }
    }
}

- (void)showButtonBar {
    
    [self.buttonBarBottom uninstall];
    
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@DESGIN_TRANSFORM_3X(120));
        self.buttonBarBottom = make.bottom.equalTo(self.sendView.mas_top).offset(-2);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        // Make all constraint changes here, Called on parent view
        [self layoutIfNeeded];
        
        self.buttonBar.alpha = 1;
        
    } completion:^(BOOL finished) {
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
        // Make all constraint changes here, Called on parent view
        [self layoutIfNeeded];
        
        self.buttonBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.sendView.selectBtn.selected = NO;
    }];
}

@end
