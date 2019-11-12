//
//  RecommendCollectionViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/6/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSRecommendAnchorItemObject.h"

NS_ASSUME_NONNULL_BEGIN

@class RecommendCollectionViewCell;
@protocol RecommendCollectionViewCellDelegate <NSObject>

- (void)recommendViewCellFollowToAnchor:(LSRecommendAnchorItemObject *)item;
- (void)recommendViewCellSayHiToAnchor:(LSRecommendAnchorItemObject *)item;

@end

@interface RecommendCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<RecommendCollectionViewCellDelegate> delegate;

+ (id)getUICollectionViewCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (void)updataReommendCell:(LSRecommendAnchorItemObject *)item;

+ (NSString *)cellIdentifier;

@end

NS_ASSUME_NONNULL_END
