//
//  LSHangoutFriendCollectionViewCell.m
//  livestream
//
//  Created by test on 2019/1/21.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSHangoutFriendCollectionViewCell.h"

@implementation LSHangoutFriendCollectionViewCell

+ (NSString *)cellIdentifier {
    return @"LSHangoutFriendCollectionViewCell";
}

+ (NSInteger)cellWidth {
    return 66;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.imageViewLoader = [LSImageViewLoader loader];
        self.imageView.layer.cornerRadius = 5;
        self.imageView.layer.masksToBounds = YES;
        self.onlineView.layer.cornerRadius = self.onlineView.frame.size.width / 2.0;
        self.onlineView.layer.masksToBounds = YES;
        self.onlineView.layer.borderWidth = 1.0f;
        self.onlineView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
    
    
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor, (__bridge id)[UIColor clearColor].CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(0, 0.0);
    gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.shadowView.bounds.size.height);
    [self.shadowView.layer addSublayer:gradientLayer];
}


- (void)layoutSubviews {
    
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.masksToBounds = YES;
    self.onlineView.layer.cornerRadius = self.onlineView.frame.size.width / 2.0;
    self.onlineView.layer.masksToBounds = YES;
    self.onlineView.layer.borderWidth = 1.0f;
    self.onlineView.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end
