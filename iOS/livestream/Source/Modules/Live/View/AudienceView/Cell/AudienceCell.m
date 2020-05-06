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
        
    }
    return self;
}

- (void)updateHeadImageWith:(AudienModel *)audienModel isVip:(BOOL)isVip {
    
    if (isVip) {
        self.headImageView.layer.cornerRadius = 15.5;
    } else {
        self.headImageView.layer.cornerRadius = 16;
    }
    self.headImageView.layer.masksToBounds = YES;
    
    self.imageLoader = [LSImageViewLoader loader];
    [self.imageLoader loadImageFromCache:self.headImageView options:SDWebImageRefreshCached imageUrl:audienModel.photoUrl
                        placeholderImage:audienModel.image finishHandler:^(UIImage *image) {
    }];
    
    if (audienModel.isHasTicket) {
        self.showIcon.hidden = NO;
    }
    else
    {
        self.showIcon.hidden = YES;
    }
}

- (void)setCornerRadius:(CGFloat)radius{
    
    self.headImageView.layer.cornerRadius = radius;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.headImageView sd_cancelCurrentImageLoad];
    self.headImageView.image = nil;
    [self.layer removeAllAnimations];
}

- (void)audienceRoomInAnimation {
    //创建一个CABasicAnimation对象
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    self.contentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    animation.fromValue = @0.0f;
    animation.toValue = @1.0f;
    animation.duration = 0.5;
    animation.removedOnCompletion = YES;
    //把animation添加到图层的layer中
    [self.layer addAnimation:animation forKey:@"scale.large"];
}

- (void)audienceRoomOutAnimation {
    //创建一个CABasicAnimation对象
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    self.contentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    animation.fromValue = @1.0f;
    animation.toValue = @0.0f;
    animation.duration = 0.3;
    animation.removedOnCompletion = YES;
    //把animation添加到图层的layer中
    [self.layer addAnimation:animation forKey:@"scale.small"];

}

@end
