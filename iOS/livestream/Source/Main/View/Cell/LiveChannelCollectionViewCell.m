//
//  LiveChannelCollectionViewCell.m
//  livestream
//
//  Created by test on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveChannelCollectionViewCell.h"

@implementation LiveChannelCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageViewLoader = [ImageViewLoader loader];
    self.onlineImageView.layer.cornerRadius = self.onlineImageView.frame.size.width * 0.5f;
    self.onlineImageView.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}

+ (NSString *)cellIdentifier {
    return @"LiveChannelCollectionViewCell";
}

@end
