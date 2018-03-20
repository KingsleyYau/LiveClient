//
//  GiftListCell.h
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
@interface GiftListCell : UICollectionViewCell
 
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLabel;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;


+ (NSString *)cellIdentifier;

- (NSString *)getTime:(NSInteger)time;
@end
