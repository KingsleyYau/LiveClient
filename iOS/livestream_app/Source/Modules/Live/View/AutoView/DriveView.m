//
//  DriveView.m
//  livestream
//
//  Created by randy on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DriveView.h"
#import "LiveBundle.h"
#import "LSImageViewLoader.h"

@implementation DriveView

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {

        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];

        self.joinBackGroundView.layer.cornerRadius = 8;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
        self.joinBackGroundView.layer.cornerRadius = 8;
    }
    return self;
}

// 更新数据源
- (void)audienceComeInLiveRoom:(AudienceModel *)model {

    self.userJoinLabel.text = model.nickname;
    
    [self.driveImageView sd_setImageWithURL:[NSURL URLWithString:model.riderurl] placeholderImage:[UIImage imageNamed:@"live_room_car"] options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        if ([self.delegate respondsToSelector:@selector(canPlayDirve:audienceModel:ifError:)]) {
            [self.delegate canPlayDirve:self audienceModel:model ifError:error];
        }
    }];
}

@end
