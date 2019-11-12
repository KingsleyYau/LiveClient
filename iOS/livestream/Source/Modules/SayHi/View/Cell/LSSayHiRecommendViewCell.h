//
//  LSSayHiRecommendViewCell.h
//  livestream
//
//  Created by test on 2019/4/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSSayHiRecommendViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *anchorPhoto;
@property (weak, nonatomic) IBOutlet UIButton *onlineImageView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *anchorName;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
@property (weak, nonatomic) IBOutlet UIView *statusView;
+ (NSString *)cellIdentifier;
+ (CGFloat)cellWidth;
@end

NS_ASSUME_NONNULL_END
