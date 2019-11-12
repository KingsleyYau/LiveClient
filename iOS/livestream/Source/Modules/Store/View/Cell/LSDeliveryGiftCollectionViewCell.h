//
//  LSDeliveryGiftCollectionViewCell.h
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSDeliveryGiftCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UIButton *giftCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftCountWidth;

@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellWidth;
@end

NS_ASSUME_NONNULL_END
