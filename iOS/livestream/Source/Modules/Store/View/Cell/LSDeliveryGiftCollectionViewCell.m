//
//  LSDeliveryGiftCollectionViewCell.m
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSDeliveryGiftCollectionViewCell.h"

@implementation LSDeliveryGiftCollectionViewCell

+ (NSString *)cellIdentifier {
    return @"LSDeliveryGiftCollectionViewCell";
}

+ (NSInteger)cellWidth {
    return 67;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.imageViewLoader = [LSImageViewLoader loader];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.giftCount.layer.cornerRadius = self.giftCount.frame.size.width * 0.5f;
    self.giftCount.layer.masksToBounds = YES;
    self.giftImageView.layer.cornerRadius = 3.0f;
    self.giftImageView.layer.masksToBounds = YES;
}

@end
