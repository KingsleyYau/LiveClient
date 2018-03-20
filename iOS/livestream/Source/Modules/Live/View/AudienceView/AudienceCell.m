//
//  AudienceCell.m
//  livestream
//
//  Created by randy on 2017/8/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AudienceCell.h"
#import "LSImageViewLoader.h"

@interface AudienceCell ()
@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@end

@implementation AudienceCell

+ (NSString *)cellIdentifier {
    return @"AudienceCell";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.imageLoader = [LSImageViewLoader loader];
    }
    return self;
}

- (void)updateHeadImageWith:(AudienModel *)audienModel isVip:(BOOL)isVip {
    
    if (isVip) {
        self.headImageView.layer.cornerRadius = 12;
    } else {
        self.headImageView.layer.cornerRadius = 12.5;
    }
    self.headImageView.layer.masksToBounds = YES;
    
    if (!audienModel.photoUrl.length) {
        [self.headImageView setImage:audienModel.image];
    } else {
        [self.imageLoader stop];
        [self.imageLoader refreshCachedImage:self.headImageView options:SDWebImageRefreshCached imageUrl:audienModel.photoUrl
                            placeholderImage:audienModel.image];
    }
}

- (void)setCornerRadius:(CGFloat)radius{
    
    self.headImageView.layer.cornerRadius = radius;
}



- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
