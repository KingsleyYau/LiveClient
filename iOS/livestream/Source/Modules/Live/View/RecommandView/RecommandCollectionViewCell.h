//
//  RecommandCollectionViewCell.h
//  livestream
//
//  Created by Max on 2017/9/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageViewLoader.h"

@interface RecommandCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) ImageViewLoader *imageViewLoader;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellWidth;

@end
