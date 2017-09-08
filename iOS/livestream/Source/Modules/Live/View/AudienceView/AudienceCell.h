//
//  AudienceCell.h
//  livestream
//
//  Created by randy on 2017/8/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudienceCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

+ (NSString *)cellIdentifier;

- (void)updateHeadImageWith:(UIImage *)headModel;

- (void)setCornerRadius:(CGFloat)radius;

@end
