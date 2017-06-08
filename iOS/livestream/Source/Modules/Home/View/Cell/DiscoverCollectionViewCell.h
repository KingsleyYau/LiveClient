//
//  DiscoverCollectionViewCell.h
//  livestream
//
//  Created by lance on 2017/5/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewLoader.h"
#import "UIImageViewFill.h"

@interface DiscoverCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageViewFill *imageCoverView;
@property (weak, nonatomic) IBOutlet UILabel *personName;
@property (weak, nonatomic) IBOutlet UILabel *personDetail;
@property (nonatomic, strong) ImageViewLoader* imageViewLoader;
+ (NSString *)cellIdentifier;
@end
