//
//  GiftStatisticsViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/4/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGiftManager.h"

@interface GiftStatisticsViewCell : UICollectionViewCell

+ (NSString *)cellIdentifier;


@property (weak, nonatomic) IBOutlet UIView *backGroundView;

@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;

@property (weak, nonatomic) IBOutlet UIView *giftNumView;

@property (weak, nonatomic) IBOutlet UILabel *giftNumLabel;

- (void)updataCellViewItem:(LSGiftManagerItem *)item num:(int)num;

@end
