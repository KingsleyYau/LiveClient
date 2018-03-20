//
//  LiveChannelCollectionViewCell.h
//  livestream
//
//  Created by test on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

@interface LiveChannelCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet LSUITapImageView *roomTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *onlineImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *roomTpyePublic;
@property (weak, nonatomic) IBOutlet UIImageView *interestLeft;
@property (weak, nonatomic) IBOutlet UIImageView *interestRight;

/**
 *  头像下载器
 */
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
+ (NSString *)cellIdentifier;

@end
