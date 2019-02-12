//
//  QNChatEmotionChooseCollectionViewLayout.m
//  dating
//
//  Created by Max on 16/6/2.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatEmotionChooseCollectionViewLayout.h"

@interface QNChatEmotionChooseCollectionViewLayout ()

@property (assign, nonatomic) CGFloat paddingX;
@property (assign, nonatomic) CGFloat paddingY;

@property (assign, nonatomic) CGFloat itemSize;
@property (assign, nonatomic) CGFloat itemSpace;
//@property (assign, nonatomic) CGFloat itemSpaceReal;
@property (assign, nonatomic) CGFloat lineSpace;
//@property (assign, nonatomic) CGFloat lineSpaceReal;
@property (assign, nonatomic) NSInteger itemCount;

@property (assign, nonatomic) NSInteger lineItemCount;
@property (assign, nonatomic) NSInteger lineCount;
@property (assign, nonatomic) NSInteger pageLineCount;
@property (assign, nonatomic) NSInteger pageCount;

@end

@implementation QNChatEmotionChooseCollectionViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    // 算法为固定表情大小, 按照宽度计算个数
    
    // 初始化参数
    self.paddingX = 0;
    self.paddingY = 0;
    
    self.itemSize = 35;
    self.itemSpace = 10;
//    self.itemSpaceReal = 0;
    self.lineSpace = 10;
//    self.lineSpaceReal = 0;
    
    self.lineItemCount = 0;
    self.lineCount = 0;
    self.pageLineCount = 0;
    self.pageCount = 0;
    
    self.itemCount = [self.collectionView numberOfItemsInSection:0];
}

- (CGSize)collectionViewContentSize {
//    NSLog(@"collectionViewContentSize( self.collectionView.frame.size.width : %f, self.collectionView.frame.size.width : %f )", self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    
//    // 计算列分隔
//    if( self.lineItemCount != 0 ) {
//        // 计算分隔
//        self.itemSpace = 1.0 * (self.collectionView.frame.size.width - (self.itemSize * self.lineItemCount)) / (self.lineItemCount + 1);
//    }
    
    // 计算列数
    if( (self.itemSize + self.itemSpace) != 0 ) {
        self.lineItemCount = ((self.collectionView.frame.size.width - self.itemSize) / (self.itemSize + self.itemSpace)) + 1;
    }
    
    // 计算边距
    self.paddingX = self.collectionView.frame.size.width - (self.lineItemCount * (self.itemSize + self.itemSpace));
    if( self.paddingX < self.itemSpace * 2 ) {
        // 左右边距小于间隔
        self.paddingX = self.itemSpace;
        
        // 重新计算列数
        if( (self.itemSize + self.itemSpace) != 0 ) {
            self.lineItemCount = ((self.collectionView.frame.size.width - (2 * self.paddingX) - self.itemSize) / (self.itemSize + self.itemSpace)) + 1;
        }
        
        // 重新计算边距
        self.paddingX = self.collectionView.frame.size.width - (self.lineItemCount * (self.itemSize + self.itemSpace));

    }
    self.paddingX = self.paddingX / 2;
    
    // 计算总行数
    if( self.lineItemCount > 0 ) {
        self.lineCount = (self.itemCount % self.lineItemCount == 0)?(self.itemCount / self.lineItemCount):(self.itemCount / self.lineItemCount) + 1;
    }
    
//    // 计算行分隔
//    if( self.pageLineCount != 0 ) {
//        self.lineSpace = (self.collectionView.frame.size.height - (self.itemSize * self.pageLineCount)) / (self.pageLineCount + 1);
//    }
    
    // 计算每页行数
    if( (self.itemSize + self.lineSpace) != 0) {
        self.pageLineCount = ((self.collectionView.frame.size.height - self.itemSize) / (self.itemSize + self.lineSpace)) + 1;
    }
    
    self.paddingY = self.collectionView.frame.size.height - (self.pageLineCount * (self.itemSize + self.lineSpace));
    if( self.paddingY < self.lineSpace * 2 ) {
        // 上下边距小于间隔
        self.paddingY = self.lineSpace;
        
        // 重新计算每页行数
        if( (self.itemSize + self.lineSpace) != 0) {
            self.pageLineCount = ((self.collectionView.frame.size.height - (2 * self.paddingY) - self.itemSize) / (self.itemSize + self.lineSpace)) + 1;
        }
        
        // 重新计算边距
        self.paddingY = self.collectionView.frame.size.height - (self.pageLineCount * (self.itemSize + self.lineSpace));
    }
    self.paddingY = self.paddingY / 2;
    
    // 计算页数
    if( self.pageLineCount != 0 ) {
        self.pageCount = (self.lineCount / self.pageLineCount);
        if( self.lineCount % self.pageLineCount != 0 ) {
            self.pageCount++;
        }
    }
    
    CGSize size = CGSizeMake(self.pageCount * self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    return size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {   
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.itemCount; i ++) {
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
    if( (self.pageLineCount * self.lineItemCount) != 0 ) {
        page = indexPath.row / (self.pageLineCount * self.lineItemCount);

        if( self.pageLineCount * self.lineItemCount ) {
            pageItems = indexPath.row % (self.pageLineCount * self.lineItemCount);
        }
    }
    
    // 计算行index
    NSInteger line = 0;
    if( self.lineItemCount != 0 ) {
        line = pageItems / self.lineItemCount;
    }
    
    // 计算列index
    NSInteger column = 0;
    if( self.lineItemCount != 0 ) {
       column = pageItems % self.lineItemCount;
    }
    
    // 计算起始X坐标和高度
    CGFloat x = self.paddingX + page * (self.collectionView.frame.size.width) + column * (self.itemSize + self.itemSpace);
    // 计算起始Y坐标和高度
    CGFloat y = self.paddingY + line * (self.itemSize + self.lineSpace);
    // 计算frame
    attributes.frame = CGRectMake(x, y, self.itemSize, self.itemSize);
    
    return attributes;
}

@end
