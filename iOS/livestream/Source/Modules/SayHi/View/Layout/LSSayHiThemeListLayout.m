//
//  LSSayHiThemeListLayout.m
//  UIWidget
//
//  Created by test on 2017/6/13.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "LSSayHiThemeListLayout.h"

@interface LSSayHiThemeListLayout ()

/** x边距 */
@property (assign, nonatomic) CGFloat paddingX;
/** y边距 */
@property (assign, nonatomic) CGFloat paddingY;
/** 宽度 */
@property (assign, nonatomic) CGFloat itemWidth;
/** 高度 */
@property (assign, nonatomic) CGFloat itemHeight;
/** 间距 */
@property (assign, nonatomic) CGFloat itemSpace;
/** 行距 */
@property (assign, nonatomic) CGFloat lineSpace;
/** 总数 */
@property (assign, nonatomic) NSInteger itemCount;
/** 每行数组 */
@property (assign, nonatomic) NSInteger lineItemCount;
/** 总行数 */
@property (assign, nonatomic) NSInteger lineCount;
/** 每页行数 */
@property (assign, nonatomic) NSInteger pageLineCount;
/** 每页个数 */
@property (nonatomic, assign) NSInteger pageItemCount;

@end

@implementation LSSayHiThemeListLayout
- (instancetype)init {
    if (self = [super init]) {
        // 页数当前页的初始化
        self.currentPage = 0;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    
    return self;
}

// 每次布局发生变动都会进入,设置页面当前页不能放在这,切换可能会出现页面的角标不正确
- (void)prepareLayout {
    [super prepareLayout];
    
    // 初始化参数
    self.paddingX = 20;
    self.paddingY = 5;
    
    self.itemWidth = 0;
    self.itemHeight = 0;
    self.itemSpace = 10;
    self.lineSpace = 10;
    
    self.lineItemCount = 2;
    self.lineCount = 0;
    self.pageLineCount = 0;
    self.pageCount = 0;
    
    self.itemCount = [self.collectionView numberOfItemsInSection:0];
}

- (CGSize)collectionViewContentSize {
    CGFloat superViewWidth = self.collectionView.frame.size.width;
//    CGFloat superViewHeight = self.collectionView.frame.size.height;
    
    self.itemWidth = (superViewWidth - (self.paddingX * self.lineItemCount + self.itemSpace)) / self.lineItemCount;
    self.itemHeight = self.itemWidth * 0.6;
    
    // 计算总行数
    if (self.lineItemCount > 0) {
        self.lineCount = (self.itemCount % self.lineItemCount == 0) ? (self.itemCount / self.lineItemCount) : (self.itemCount / self.lineItemCount) + 1;
        
        self.pageLineCount = self.lineCount;
    }
    CGFloat contentHeight = self.lineCount * (self.itemHeight + self.lineSpace) - self.lineSpace + (self.paddingY * 2);
    CGSize size = CGSizeMake(superViewWidth, contentHeight);
    return size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.itemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    return attributes;
}

// 根据不同的indexPath，给出布局
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 计算页index
    NSInteger page = 0;
    NSInteger pageItems = 0;
    if ((self.pageLineCount * self.lineItemCount) != 0) {
        page = indexPath.row / (self.pageLineCount * self.lineItemCount);
        
        if (self.pageLineCount * self.lineItemCount) {
            pageItems = indexPath.row % (self.pageLineCount * self.lineItemCount * (page + 1));
        }
    }
    
    // 计算行index
    NSInteger line = 0;
    if (self.lineItemCount != 0) {
        line = pageItems / self.lineItemCount;
    }
    
    // 计算列index
    NSInteger column = 0;
    if (self.lineItemCount != 0) {
        column = pageItems % self.lineItemCount;
    }
    
    // 计算起始X坐标和高度
    CGFloat x = self.paddingX + column * (self.itemWidth + self.itemSpace);
    
    // 计算起始Y坐标和高度
    CGFloat y = self.paddingY + line * (self.itemHeight + self.lineSpace);
    // 计算frame
    attributes.frame = CGRectMake(x, y, self.itemWidth, self.itemHeight);
    
    return attributes;
}

// 当collectionview滚动时调用
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    // 获取偏移量
    CGPoint point = [super targetContentOffsetForProposedContentOffset:proposedContentOffset];
    CGFloat curretOffset = point.x;
    // 根据偏移量计算当前页数
    NSInteger currentPage = curretOffset / self.collectionView.frame.size.width;
    if( self.currentPage != currentPage ) {
        self.currentPage = currentPage;
    }
    
    return point;
}

@end
