//
//  FollowCollectionViewCell.m
//  Hot
//
//  Created by lance on 2017/5/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewLoader.h"

@interface FollowCollectionViewCell : UICollectionViewCell


@property (nonatomic, weak) IBOutlet UIImageViewTopFit *imageViewContent;
@property (nonatomic, strong) ImageViewLoader* imageViewLoader;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
+ (NSString *)cellIdentifier;
@end
