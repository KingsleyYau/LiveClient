//
//  LSSayHiRecommendViewCell.m
//  livestream
//
//  Created by test on 2019/4/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiRecommendViewCell.h"

@implementation LSSayHiRecommendViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (!self.imageViewLoader) {
        self.imageViewLoader = [LSImageViewLoader loader];
    }
    self.layer.cornerRadius = 3.0f;
    self.layer.masksToBounds = YES;
    
    self.statusView.layer.cornerRadius = self.statusView.frame.size.height * 0.5f;
    self.statusView.layer.masksToBounds = YES;
    
    self.onlineImageView.layer.cornerRadius = self.onlineImageView.frame.size.height * 0.5f;
    self.onlineImageView.layer.masksToBounds = YES;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[ (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x25000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x00252525).CGColor ];
    gradientLayer.locations = @[ @0, @0.75, @1.0 ];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(0, 0.0);
    gradientLayer.frame = CGRectMake(0, 0, [LSSayHiRecommendViewCell cellWidth], self.shadowView.bounds.size.height);
    [self.shadowView.layer addSublayer:gradientLayer];
}

+ (NSString *)cellIdentifier {
    return @"LSSayHiRecommendViewCell";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {

    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


+ (CGFloat)cellWidth {
    CGFloat w = (screenSize.width - 45) / 2.0;
    return w;
}
@end
