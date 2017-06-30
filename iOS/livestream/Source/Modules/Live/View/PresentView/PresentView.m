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


@interface PresentView()<UIScrollViewDelegate>



@end


@implementation PresentView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        [self addSubview:containerView];
        
        UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
        self.collectionView.delegate = self;
        
        self.pageView.numberOfPages = 0;
        self.pageView.currentPage = 0;
        [self.pageView addTarget:self action:@selector(scrollPageControlAction:)forControlEvents:UIControlEventValueChanged]; // 设置监听事件
        
        self.comboBtn.titleLabel.numberOfLines = 0;
        self.comboBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.comboBtn.layer.cornerRadius = self.comboBtn.frame.size.width * 0.5f;
        self.comboBtn.layer.masksToBounds = YES;
        
        self.collectionViewHeight.constant = SCREEN_WIDTH * 0.5;
    }
    return self;
}

- (void)reloadData {
    
  
}

- (void)scrollPageControlAction:(UIPageControl *)sender {
    
    CGSize viewSize = self.collectionView.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [self.collectionView scrollRectToVisible:rect animated:YES];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 40;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    GiftItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    // 刷新页数 小高表布局
    GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
    if( self.pageView.numberOfPages != layout.pageCount ) {
        self.pageView.numberOfPages = layout.pageCount;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    for (GiftItemCollectionViewCell *cell in collectionView.visibleCells) {
        
        if ([cell isEqual:(GiftItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]]) {
            continue;
        }
        cell.selectCell = NO;
        [cell reloadStyle];
    }
    
    GiftItemCollectionViewCell* cell = (GiftItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.selectCell == NO) {
        cell.selectCell = YES;
    }else {
        cell.selectCell = NO;
    }
    [cell reloadStyle];

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


@end
