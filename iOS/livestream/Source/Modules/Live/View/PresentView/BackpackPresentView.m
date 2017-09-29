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
#import "DialogTip.h"

#define NotenoughLove @"This gift is only available for user level 5 or higher."
#define NotenoughLevel @"This gift is only available for intimacy 5 or higher."
#define NoListTip @"Your backpack is empty."
#define RequestFailTip @"Failed to load"

@interface BackpackPresentView() < UIScrollViewDelegate,KKCheckButtonDelegate >

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageViewTopOffset;

@property (nonatomic, assign) NSInteger indextPathRow;

@property (nonatomic, assign) int buttonBarHeight;
/**
 *  多功能按钮约束
 */
@property (strong) MASConstraint* buttonBarBottom;

@property (nonatomic, assign) BOOL isFirstCreate;

@end

@implementation BackpackPresentView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        [self addSubview:containerView];
        
//        [self setupButtonBar];
        
        UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
        self.collectionView.delegate = self;
        
        self.requestFailView.hidden = YES;
        
        self.pageView.numberOfPages = 0;
        self.pageView.currentPage = 0;
        [self.pageView addTarget:self action:@selector(scrollPageControlAction:)forControlEvents:UIControlEventValueChanged]; // 设置监听事件
        
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
        
        self.pageViewTopOffset.constant = DESGIN_TRANSFORM_3X(8);
        
        self.reloadBtn.layer.cornerRadius = 6;
        self.reloadBtn.layer.masksToBounds = YES;
        
        self.indextPathRow = -1;
        self.buttonBarHeight = 1;
        
        self.isFirstCreate = YES;
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    if ( self = [super initWithFrame:frame] ) {
        
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        [self addSubview:containerView];
        
//        [self setupButtonBar];
        
        UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
        self.collectionView.delegate = self;
        
        self.requestFailView.hidden = YES;
        
        self.pageView.numberOfPages = 0;
        self.pageView.currentPage = 0;
        [self.pageView addTarget:self action:@selector(scrollPageControlAction:)forControlEvents:UIControlEventValueChanged]; // 设置监听事件
        
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
        
        self.pageViewTopOffset.constant = DESGIN_TRANSFORM_3X(8);
        
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
    if (self.backpackDelegate && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewShowBalance:)]) {
        [self.backpackDelegate backpackPresentViewShowBalance:self];
    }
}

- (IBAction)reloadGiftList:(id)sender {
    
    if (self.backpackDelegate && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewReloadList:)]) {
        [self.backpackDelegate backpackPresentViewReloadList:self];
    }
}

- (void)showNoListView {
    self.requestFailView.hidden = NO;
    self.reloadBtn.hidden = YES;
    self.tipImageViewTop.constant = 80;
    self.failTipLabel.text = NoListTip;
}

- (void)showRequestFailView {
    self.requestFailView.hidden = NO;
    self.reloadBtn.hidden = NO;
    self.tipImageViewTop.constant = 60;
    self.failTipLabel.text = RequestFailTip;
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

#pragma mark UICollectionViewDelegate / UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftIdArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GiftItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: [GiftItemCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    // 更新cell数据
    RoomBackGiftItem *model = self.giftIdArray[indexPath.row];
    [cell backpackHiddenView];
    // 是否可发送
    BOOL canSend = [[LiveGiftListManager manager] giftCanSendInLiveRoom:model.allItem];
    
    [cell updataBackpackCellViewItem:model manLV:self.manLevel loveLV:self.loveLevel canSend:canSend];
    
    // 默认选中第一个
    BOOL isIndexPath = NO;
    if (self.indextPathRow == indexPath.row) {
        isIndexPath = YES;
        
    }else if ((self.indextPathRow == -1 && indexPath.row == 0) || self.indextPathRow == self.giftIdArray.count ){
        self.indextPathRow = 0;
        isIndexPath = YES;
    }
    
    // 默认第一个等级不够 发送按钮不可用
    if (isIndexPath) {
        cell.selectCell = YES;
        self.isCellSelect = YES;
        self.selectCellItem = model.allItem;
        
        if (self.isFirstCreate) {
            [self setupButtonBar:model.allItem.infoItem.sendNumList];
            self.isFirstCreate = NO;
        }
        
        if ( model.allItem.infoItem.loveLevel > self.loveLevel || model.allItem.infoItem.level > self.manLevel || !canSend ) {
            [self.sendView.sendBtn setBackgroundColor:[UIColor grayColor]];
            self.sendView.sendBtn.userInteractionEnabled = NO;
        } else {
            [self.sendView.sendBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xf7cd3a)];
            self.sendView.sendBtn.userInteractionEnabled = YES;
        }
    }
    
    [cell reloadStyle];
    
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
        
        
        RoomBackGiftItem *model = self.giftIdArray[indexPath.row];
        
        if (self.backpackDelegate && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewDidSelectItemWithSelf:numberList:atIndexPath:)]) {
            [self.backpackDelegate backpackPresentViewDidSelectItemWithSelf:self numberList:model.allItem.infoItem.sendNumList atIndexPath:indexPath];
        }
        
        if ( model.allItem.infoItem.loveLevel > self.loveLevel ) {
            [[DialogTip dialogTip] removeShow];
            [[DialogTip dialogTip] showDialogTip:self.superview tipText:NotenoughLove];
            
        } else if ( model.allItem.infoItem.level > self.manLevel ) {
            [[DialogTip dialogTip] removeShow];
            [[DialogTip dialogTip] showDialogTip:self.superview tipText:NotenoughLevel];
        }
    }
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
    
    if (self.backpackDelegate  && [self.backpackDelegate respondsToSelector:@selector(backpackPresentViewSendBtnClick:andSender:)]){
        
        [self.backpackDelegate backpackPresentViewSendBtnClick:self andSender:sender];
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
- (void)setupButtonBar:(NSArray *)sendNumList {
    
    self.buttonBar.hidden = NO;
    self.sendView.selectNumLabel.hidden = NO;
    self.sendView.arrowImageView.hidden = NO;
    
    UIImage *whiteImage = [[UIImage alloc]createImageWithColor:[UIColor whiteColor] imageRect:CGRectMake(0, 0, 1, 1)];
    UIImage *blueImage = [[UIImage alloc]createImageWithColor:COLOR_WITH_16BAND_RGB(0xf7cd3a) imageRect:CGRectMake(0, 0, 1, 1)];
    
    NSMutableArray* items = [NSMutableArray array];
    
    for (int i = 0; i < sendNumList.count; i++) {
        
        NSString *title = [NSString stringWithFormat:@"%@",sendNumList[i]];
        UIButton* firstNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
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
            self.buttonBarHeight = 42 * (int)sendNumList.count;
        }
    }
}


- (void)selectFirstNum:(id)sender{
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
        make.height.equalTo(@DESGIN_TRANSFORM_3X(self.buttonBarHeight));
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
