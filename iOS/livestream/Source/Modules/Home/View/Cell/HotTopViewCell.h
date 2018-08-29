//
//  HotTopViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/7/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotTopViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
@property (weak, nonatomic) IBOutlet UILabel *unreadNumLabel;

- (void)setUnreadNum:(int)num;

+ (NSString *)cellIdentifier;

@end
