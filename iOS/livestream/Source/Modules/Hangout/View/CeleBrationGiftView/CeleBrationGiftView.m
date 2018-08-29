//
//  CeleBrationGiftView.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "CeleBrationGiftView.h"
#import "LiveModule.h"
#import "LSGiftManager.h"
#import "LiveRoomGiftModel.h"
#import "CeleBrationGiftViewCell.h"
#import "CeleBrationGiftLayout.h"

@interface CeleBrationGiftView ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageView;

@property (weak, nonatomic) IBOutlet UIView *maskView;

@property (weak, nonatomic) IBOutlet UIButton *retryButton;

@property (weak, nonatomic) IBOutlet UIButton *noyetButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (strong, nonatomic) LSGiftManager *loadManager;

@property (nonatomic, assign) NSInteger indextPathRow;

@end

@implementation CeleBrationGiftView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.loadManager = [LSGiftManager manager];
    
    NSBundle *bundle = [LiveBundle mainBundle];
    
    UINib *nib = [UINib nibWithNibName:@"CeleBrationGiftViewCell" bundle:bundle];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[CeleBrationGiftViewCell cellIdentifier]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.pageView.numberOfPages = 1;
    self.pageView.currentPage = 0;
    [self.pageView addTarget:self action:@selector(scrollPageControlAction:) forControlEvents:UIControlEventValueChanged]; // 设置监听事件
    
    // 隐藏提示界面
    self.maskView.hidden = YES;
    
    self.indextPathRow = -1;
}

- (void)scrollPageControlAction:(UIPageControl *)sender {
    
    CGSize viewSize = self.collectionView.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [self.collectionView scrollRectToVisible:rect animated:YES];
}

- (void)setGiftArray:(NSArray<LSGiftManagerItem *> *)giftArray {
    // TODO:更新礼物队列
    _giftArray = giftArray;
    
    [self.collectionView reloadData];
    
    if (giftArray.count < 1) {
        [self showNoGiftYetView];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CeleBrationGiftViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CeleBrationGiftViewCell cellIdentifier] forIndexPath:indexPath];
    
    LSGiftManagerItem *item = self.giftArray[indexPath.row];
    [cell updataCellViewItem:item];
    
    BOOL isIndexPath = NO;
    if (self.indextPathRow == indexPath.row || (self.indextPathRow == -1 && indexPath.row == 0)) {
        isIndexPath = YES;
    } else {
        isIndexPath = NO;
    }
    
    // 默认选中第一个
    if (isIndexPath) {
        cell.selectCell = YES;
        self.isCellSelect = YES;
        self.selectCellItem = [self.loadManager getGiftItemWithId:item.giftId];
    } else {
        cell.selectCell = NO;
    }
    
    [cell reloadStyle];
    
    // 刷新页数 小高表布局
    CeleBrationGiftLayout *layout = (CeleBrationGiftLayout *)self.collectionView.collectionViewLayout;
    if (self.pageView.numberOfPages != layout.pageCount) {
        self.pageView.numberOfPages = layout.pageCount;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.indextPathRow = indexPath.row;
    [self.collectionView reloadData];
    
    [UIView setAnimationsEnabled:NO];
    [collectionView performBatchUpdates:^{
        [collectionView reloadData];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
    
    LSGiftManagerItem *item = self.giftArray[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(celeBrationCollectionDidSelectItem:giftView:)]) {
        [self.delegate celeBrationCollectionDidSelectItem:item giftView:self];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // 刷新选择分页
    CeleBrationGiftLayout *layout = (CeleBrationGiftLayout *)self.collectionView.collectionViewLayout;
    if (self.pageView.currentPage != layout.currentPage) {
        self.pageView.currentPage = layout.currentPage;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 滑动隐藏选择按钮
}

#pragma mark - 界面显示/隐藏
- (void)showRetryView {
    self.maskView.hidden = NO;
    self.retryButton.hidden = NO;
    self.noyetButton.hidden = YES;
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimating];
}

- (void)showNoGiftYetView {
    self.maskView.hidden = NO;
    self.noyetButton.hidden = NO;
    self.retryButton.hidden = YES;
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimating];
}

- (void)showLoadingView {
    self.maskView.hidden = NO;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    self.retryButton.hidden = YES;
    self.noyetButton.hidden = YES;
}

- (void)hiddenMaskView {
    self.maskView.hidden = YES;
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimating];
    self.retryButton.hidden = YES;
    self.noyetButton.hidden = YES;
}

@end
