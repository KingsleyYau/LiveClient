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

@interface PresentView()<UIScrollViewDelegate,KKCheckButtonDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageViewTopOffset;

@property (nonatomic, weak) UIButton *btnOne;

@property (nonatomic, weak) UIButton *btnTwenty;

@property (nonatomic, weak) UIButton *btnFifty;

/**
 *  多功能按钮约束
 */
@property (strong) MASConstraint* buttonBarBottom;

@end


@implementation PresentView

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
    }
    return self;
}

- (void)reloadData {
    
  
}


- (void)setGiftIdArray:(NSArray *)giftIdArray{
    
    _giftIdArray = giftIdArray;
    [self.collectionView reloadData];
}

- (void)scrollPageControlAction:(UIPageControl *)sender {
    
    CGSize viewSize = self.collectionView.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [self.collectionView scrollRectToVisible:rect animated:YES];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftIdArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    GiftItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    NSString *giftId = self.giftIdArray[indexPath.row];
    LiveRoomGiftItemObject *item = [[LiveGiftDownloadManager giftDownloadManager]backGiftItemWithGiftID:giftId];
    
    [cell updataCellViewItem:item];
    
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
        
        for (GiftItemCollectionViewCell *cell in collectionView.visibleCells) {
            
            if ([cell isEqual:(GiftItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]]) {
                continue;
            }
            cell.selectCell = NO;
            self.isCellSelect = NO;
            [cell reloadStyle];
        }
        
        GiftItemCollectionViewCell* cell = (GiftItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.selectCell == NO) {
            
            cell.selectCell = YES;
            self.isCellSelect = YES;
            [self selectOneNum:cell];
            
        }else {
            cell.selectCell = NO;
            self.isCellSelect = NO;
        }
        [cell reloadStyle];
    }
    
    
    NSString *giftId = self.giftIdArray[indexPath.row];
    self.selectCellItem = [[LiveGiftDownloadManager giftDownloadManager]backGiftItemWithGiftID:giftId];
    
    if (self.presentDelegate && [self.presentDelegate respondsToSelector:@selector(presentViewdidSelectItemWithSelf:atIndexPath:)]) {
        [self.presentDelegate presentViewdidSelectItemWithSelf:self atIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    for (GiftItemCollectionViewCell *cell in collectionView.visibleCells) {
        cell.selectCell = NO;
        [cell reloadStyle];
    }
    
}

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

#pragma mark - 发送按钮
- (void)sendTheGift:(id)sender{
    
    if (self.presentDelegate  && [self.presentDelegate respondsToSelector:@selector(presentViewSendBtnClick:)]){
        
        [self.presentDelegate presentViewSendBtnClick:self];
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
    
    UIButton* btnFifty = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFifty setTitle:@"50" forState:UIControlStateNormal];
    [btnFifty setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnFifty setBackgroundImage:whiteImage forState:UIControlStateNormal];
    [btnFifty setBackgroundImage:blueImage forState:UIControlStateSelected];
    [btnFifty addTarget:self action:@selector(selectFiftyNum:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnFifty setSelected:NO];
    self.btnFifty = btnFifty;
    [items addObject:self.btnFifty];
    
    
    UIButton* btnTwenty = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTwenty setTitle:@"20" forState:UIControlStateNormal];
    [btnTwenty setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnTwenty setBackgroundImage:whiteImage forState:UIControlStateNormal];
    [btnTwenty setBackgroundImage:blueImage forState:UIControlStateSelected];
    [btnTwenty addTarget:self action:@selector(selectTwentyNum:) forControlEvents:UIControlEventTouchUpInside];
    [btnTwenty setSelected:NO];
    self.btnTwenty = btnTwenty;
    [items addObject:self.btnTwenty];
    
    UIButton* btnOne = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnOne setTitle:@"1" forState:UIControlStateNormal];
    [btnOne setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnOne setBackgroundImage:whiteImage forState:UIControlStateNormal];
    [btnOne setBackgroundImage:blueImage forState:UIControlStateSelected];
    [btnOne addTarget:self action:@selector(selectOneNum:) forControlEvents:UIControlEventTouchUpInside];
    [btnOne setSelected:YES];
    self.btnOne = btnOne;
    [items addObject:self.btnOne];
    
    self.buttonBar.items = items;
    [self.buttonBar reloadData:YES];
}


- (void)selectOneNum:(id)sender{
    
    [self.btnOne setSelected:YES];
    [self.btnTwenty setSelected:NO];
    [self.btnFifty setSelected:NO];
    
    self.sendView.selectNumLabel.text = self.btnOne.titleLabel.text;
    
    [self hideButtonBar];
}

- (void)selectTwentyNum:(id)sender{
 
    [self.btnTwenty setSelected:YES];
    [self.btnOne setSelected:NO];
    [self.btnFifty setSelected:NO];
    
    self.sendView.selectNumLabel.text = self.btnTwenty.titleLabel.text;
    
    [self hideButtonBar];
}

- (void)selectFiftyNum:(id)sender{
    
    [self.btnFifty setSelected:YES];
    [self.btnTwenty setSelected:NO];
    [self.btnOne setSelected:NO];
    
    self.sendView.selectNumLabel.text = self.btnFifty.titleLabel.text;
    
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
