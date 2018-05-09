//
//  AudienceCell.h
//  livestream
//
//  Created by randy on 2017/8/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudienModel.h"

@interface AudienceCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UIImageView *showIcon;
+ (NSString *)cellIdentifier;

- (void)updateHeadImageWith:(AudienModel *)audienModel isVip:(BOOL)isVip;

- (void)setCornerRadius:(CGFloat)radius;

@end
