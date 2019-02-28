//
//  LSHangoutFriendCollectionViewCell.h
//  livestream
//
//  Created by test on 2019/1/21.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

@interface LSHangoutFriendCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (weak, nonatomic) IBOutlet UILabel *anchorName;
@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onlineWidth;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellWidth;
@end
