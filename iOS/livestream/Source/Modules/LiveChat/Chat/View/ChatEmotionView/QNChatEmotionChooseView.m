//
//  QNChatEmotionChooseView.m
//  dating
//
//  Created by Max on 16/5/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatEmotionChooseView.h"
#import "QNChatEmotionChooseCollectionViewCell.h"
#import "QNChatSmallEmotionCollectionViewCell.h"
#import "ChatEmotionCreditsCollectionViewLayout.h"

typedef enum : NSUInteger {
    EmotionTypeNomal,
    EmotionTypeSmall,
} EmotionType;


@implementation QNChatEmotionChooseView

+ (instancetype)emotionChooseView:(id)owner {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"QNChatEmotionChooseView" owner:owner options:nil];
    QNChatEmotionChooseView* view = [nibs objectAtIndex:0];
        
    UINib *nib = [UINib nibWithNibName:@"QNChatEmotionChooseCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[QNChatEmotionChooseCollectionViewCell cellIdentifier]];
    view.emotionCollectionView.tag = EmotionTypeNomal;


    UINib *smallNib = [UINib nibWithNibName:@"QNChatSmallEmotionCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [view.smallEmotionCollectionView registerNib:smallNib forCellWithReuseIdentifier:[QNChatSmallEmotionCollectionViewCell cellIdentifier]];
    view.smallEmotionCollectionView.tag = EmotionTypeSmall;
    view.smallEmotionCollectionView.scrollEnabled = NO;
//    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
//    flow.sectionInset = UIEdgeInsetsMake(10, 5, 0,5);
//    flow.minimumLineSpacing = 0;
//    flow.minimumInteritemSpacing = 10;
//    CGFloat item = [UIScreen mainScreen].bounds.size.width / 5.0f - 10;
//    flow.itemSize = CGSizeMake(item, item);
//    
//    view.smallEmotionCollectionView.collectionViewLayout = flow;
    
    view.pageView.numberOfPages = 0;
    view.pageView.currentPage = 0;
    
    return view;
}

- (void)reloadData {
//    self.pageView.numberOfPages = 0;
//    self.pageView.currentPage = 0;
    [self.emotionCollectionView reloadData];
    [self.smallEmotionCollectionView reloadData];
//    self.emotionCollectionView.collectionViewLayout.collectionViewContentSize = CGSizeMake(self.frame.size.width, self.emotionCollectionView.contentSize.height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (collectionView.tag == EmotionTypeNomal) {
        count = self.emotions.count;
    }else if (collectionView.tag == EmotionTypeSmall) {
        count = self.smallEmotions.count;
    }
    
    return count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView.tag == EmotionTypeNomal) {
        QNChatEmotionChooseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[QNChatEmotionChooseCollectionViewCell cellIdentifier] forIndexPath:indexPath];
        QNChatEmotion* item = [self.emotions objectAtIndex:indexPath.item];
        cell.imageView.image = item.image;
        return cell;
    }else if (collectionView.tag == EmotionTypeSmall) {
        QNChatSmallEmotionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[QNChatSmallEmotionCollectionViewCell cellIdentifier] forIndexPath:indexPath];
        QNChatSmallGradeEmotion *smallGradeItem = [self.smallEmotions objectAtIndex:indexPath.item];
        if( smallGradeItem.image ) {
               cell.imageView.image = smallGradeItem.image;
        } else {
             cell.imageView.image = [UIImage imageNamed:@"LS_Chat_LargeEmotionDefault"];
        }
        
        // 刷新页数 小高表布局
        QNChatEmotionCreditsCollectionViewLayout *layout = (QNChatEmotionCreditsCollectionViewLayout *)self.smallEmotionCollectionView.collectionViewLayout;
       self.layout = (QNChatEmotionCreditsCollectionViewLayout *)self.smallEmotionCollectionView.collectionViewLayout;
        if( self.pageView.numberOfPages != layout.pageCount ) {
            self.pageView.numberOfPages = layout.pageCount;
        }
        

        return cell;
    }
    

    return [[UICollectionViewCell alloc] init];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == EmotionTypeNomal) {
        if( self.delegate != nil && [self.delegate respondsToSelector:@selector(chatEmotionChooseView:didSelectNomalItem:)] ) {
            [self.delegate chatEmotionChooseView:self didSelectNomalItem:indexPath.item];
        }
    }else if (collectionView.tag == EmotionTypeSmall) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(chatEmotionChooseView:didSelectSmallItem:)]) {
            QNChatSmallGradeEmotion *smallGradeItem = [self.smallEmotions objectAtIndex:indexPath.item];
            [self.delegate chatEmotionChooseView:self didSelectSmallItem:smallGradeItem];
        }
    }

}

/* 
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
