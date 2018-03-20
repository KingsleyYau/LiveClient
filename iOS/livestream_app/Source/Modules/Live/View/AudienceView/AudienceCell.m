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
        self.headImageView.layer.cornerRadius = 13;
    } else {
        self.headImageView.layer.cornerRadius = 12.5;
    }
    self.headImageView.layer.masksToBounds = YES;
    
    [self.imageLoader stop];
    [self.imageLoader refreshCachedImage:self.headImageView options:SDWebImageRefreshCached imageUrl:audienModel.photoUrl
                        placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
    
    NSLog(@"AudienceCell::updateHeadImageWith( photoUrl : %@ )", audienModel.photoUrl);
}

- (void)setCornerRadius:(CGFloat)radius{
    
    self.headImageView.layer.cornerRadius = radius;
}



- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
