//
//  StreamFileItemLayout.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/12.
//  Copyright © 2020年 lance. All rights reserved.
//

#import "StreamFileItemLayout.h"

@interface StreamFileItemLayout ()

/** x边距 */
@property (assign, nonatomic) CGFloat paddingX;
/** y边距 */
@property (assign, nonatomic) CGFloat paddingY;
/** 大小 */
@property (assign, nonatomic) CGFloat itemSize;
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

@implementation StreamFileItemLayout
- (instancetype)init {
    if (self = [super init]) {
        // 页数当前页的初始化
        self.currentPage = 0;
    }

    return self;
}

// 每次布局发生变动都会进入,设置页面当前页不能放在这,切换可能会出现页面的角标不正确
- (void)prepareLayout {
    [super prepareLayout];

    // 初始化参数
    self.itemSize = self.collectionView.frame.size.width / 2;

    self.lineItemCount = 0;
    self.lineCount = 0;

    self.itemCount = [self.collectionView numberOfItemsInSection:0];
}

- (CGSize)collectionViewContentSize {
    CGFloat superViewWidth = self.collectionView.frame.size.width;
    CGFloat superViewHeight = self.collectionView.frame.size.height;
    
    // 计算列数
    self.lineItemCount = superViewWidth / self.itemSize;

    // 计算总行数
    if (self.lineItemCount > 0) {
        self.lineCount = (self.itemCount % self.lineItemCount == 0) ? (self.itemCount / self.lineItemCount) : (self.itemCount / self.lineItemCount) + 1;
    }

    CGSize size = CGSizeMake(superViewWidth, self.lineCount * self.itemSize);
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
    
    // 计算行index
    NSInteger line = 0;
    if (self.lineItemCount != 0) {
        line =  indexPath.row / self.lineItemCount;
    }

    // 计算列index
    NSInteger column = 0;
    if (self.lineItemCount != 0) {
        column = indexPath.row % self.lineItemCount;
    }

    // 计算起始X坐标和高度
    CGFloat y = line * (self.itemSize);

    // 计算起始Y坐标和高度
    CGFloat x = column * self.itemSize;
    
    // 计算frame
    attributes.frame = CGRectMake(x, y, self.itemSize, self.itemSize);

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
