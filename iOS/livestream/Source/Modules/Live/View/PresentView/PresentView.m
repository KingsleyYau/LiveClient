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
#import "UIImage+SolidColor.h"
#import "LiveRoomGiftModel.h"
#import "DialogTip.h"
#import "RandomGiftModel.h"

#define NotenoughLove @"This gift is only available for user level 5 or higher."
#define NotenoughLevel @"This gift is only available for intimacy 5 or higher."
#define NoListTip @"Your backpack is empty."
#define RequestFailTip @"Failed to load"

@interface PresentView() < UIScrollViewDelegate,KKCheckButtonDelegate >

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageViewTopOffset;

@property (nonatomic, assign) NSInteger indextPathRow;

@property (nonatomic, strong) LiveGiftDownloadManager *loadManager;
/*
 *  多功能按钮约束
 */
@property (strong) MASConstraint* buttonBarBottom;

@property (nonatomic, assign) int buttonBarHeight;

@property (nonatomic, assign) BOOL isFirstCreate;

@end


@implementation PresentView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        [self addSubview:containerView];
        
        self.loadManager = [LiveGiftDownloadManager manager];

        [self setupButtonBar:@[@1]];
        
        UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
        self.collectionView.delegate = self;
        
        self.canSendIndexArray = [[NSMutableArray alloc] init];
        
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
        
        self.loadManager = [LiveGiftDownloadManager manager];
        
        [self setupButtonBar:@[@1]];
        
        UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
        self.collectionView.delegate = self;
        
        self.canSendIndexArray = [[NSMutableArray alloc] init];
        
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
    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewShowBalance:)]) {
        [self.presentDelegate presentViewShowBalance:self];
    }
}

- (IBAction)reloadGiftList:(id)sender {
    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewReloadList:)]) {
        [self.presentDelegate presentViewReloadList:self];
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
    
    [self.canSendIndexArray removeAllObjects];
    [self.collectionView reloadData];
}


- (void)setGiftIdArray:(NSArray *)giftIdArray{
    
    [self.canSendIndexArray removeAllObjects];
    _giftIdArray = giftIdArray;
    
    // 筛选可发送礼物 添加到随机礼物列表
    for (LiveRoomGiftModel *item in giftIdArray) {
        
        if ( !(self.loveLevel < item.allItem.infoItem.loveLevel || self.manLevel < item.allItem.infoItem.level) ) {
            RandomGiftModel *model = [[RandomGiftModel alloc] init];
            model.randomInteger = [giftIdArray indexOfObject:item];
            model.giftModel = item;
            [self.canSendIndexArray addObject:model];
        }
    }
    
    [self.collectionView reloadData];
    
    // 防止cell有加载滑动动画
    [UIView setAnimationsEnabled: NO ];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadData];
    } completion:^( BOOL  finished) {
        [UIView setAnimationsEnabled: YES ];
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

    GiftItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    LiveRoomGiftModel *model = self.giftIdArray[indexPath.row];
    AllGiftItem* item = [self.loadManager backGiftItemWithGiftID:model.giftId];
    // 如果所有礼物列表没有该礼物 请求该礼物详情
    if (!item.infoItem.giftId) {
        [self.loadManager requestListnotGiftID:model.giftId];
    }
    
    [cell updataCellViewItem:item manLV:self.manLevel loveLV:self.loveLevel];
    
    BOOL isIndexPath = NO;
    if (self.indextPathRow == indexPath.row) {
        isIndexPath = YES;
        
    }else if (self.indextPathRow == -1 && indexPath.row == 0){
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
        
        if ( model.allItem.infoItem.loveLevel > self.loveLevel || model.allItem.infoItem.level > self.manLevel ) {
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
        
        // 设置选中礼物cell的可选按钮
        LiveRoomGiftModel *model= self.giftIdArray[indexPath.row];
        if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewdidSelectItemWithSelf:numberList:atIndexPath:)]) {
            [self.presentDelegate presentViewdidSelectItemWithSelf:self numberList:self.selectCellItem.infoItem.sendNumList atIndexPath:indexPath];
        }
        
        if ( model.allItem.infoItem.loveLevel > self.loveLevel ) {
            [[DialogTip dialogTip] removeShow];
            [self showDialogTipView:model.allItem andTip:NotenoughLove];
            
        } else if ( model.allItem.infoItem.level > self.manLevel ) {
            [[DialogTip dialogTip] removeShow];
            [self showDialogTipView:model.allItem andTip:NotenoughLevel];
        }
    }
}

- (void)showDialogTipView:(AllGiftItem *)item andTip:(NSString *)tip {
    
    [[DialogTip dialogTip] showDialogTip:self.superview tipText:tip];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // 刷新选择分页
    GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
    if( self.pageView.currentPage != layout.currentPage ) {
        self.pageView.currentPage = layout.currentPage;

    }
    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewDidScroll:currentPageNumber:)]) {
        GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
        [self.presentDelegate presentViewDidScroll:self currentPageNumber:layout.currentPage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.buttonBar.height) {
        [self hideButtonBar];
    }
}

- (void)randomSelect:(NSInteger)integer {
    self.indextPathRow = integer;
    [self.collectionView reloadData];
}


#pragma mark - 发送按钮
- (void)sendTheGift:(id)sender{
    
    if (self.presentDelegate  && [self.presentDelegate respondsToSelector:@selector(presentViewSendBtnClick:andSender:)]){
        
        [self.presentDelegate presentViewSendBtnClick:self andSender:sender];
    }
}

- (void)comboGiftInSide:(id)sender{
    
    if (self.presentDelegate  && [self.presentDelegate respondsToSelector:@selector(presentViewComboBtnInside:andSender:)]){
        
        [self.presentDelegate presentViewComboBtnInside:self andSender:sender];
    }
}

- (void)comboGiftDow:(id)sender{
    
    if (self.presentDelegate  && [self.presentDelegate respondsToSelector:@selector(presentViewComboBtnDown:andSender:)]){
        
        [self.presentDelegate presentViewComboBtnDown:self andSender:sender];
    }
}

#pragma mark - 多功能按钮管理
- (void)setupButtonBar:(NSArray *)sendNumList {
    
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
        [self layoutIfNeeded];
        self.buttonBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.sendView.selectBtn.selected = NO;
    }];
}

@end
