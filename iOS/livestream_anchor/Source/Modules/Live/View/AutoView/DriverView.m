//
//  DriverView.m
//  livestream
//
//  Created by randy on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DriverView.h"
#import "LiveBundle.h"

@implementation DriverView

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {

        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];

        self.driveBackgroundView.layer.cornerRadius = self.driveBackgroundView.frame.size.height / 2;
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
        self.driveBackgroundView.layer.cornerRadius = self.driveBackgroundView.frame.size.height / 2;
    }
    return self;
}

- (void)setupViewColor:(RoomStyleItem *)item {
    
    self.userNameLabel.textColor = item.driverStrColor;
    self.joinLabel.textColor = item.driverStrColor;
    self.driveBackgroundView.backgroundColor = item.riderBgColor;
}

// 更新数据源
- (void)audienceComeInLiveRoom:(AudienModel *)model {

    self.userNameLabel.text = model.nickName;
    [self.userNameLabel sizeToFit];
    
    int selfWidth;
    if (self.userNameLabel.frame.size.width > 55) {
        selfWidth = 55 + 104;
    } else {
        selfWidth = self.userNameLabel.frame.size.width + 104;
    }
    
    [self.driveImageView sd_setImageWithURL:[NSURL URLWithString:model.mountUrl]
                           placeholderImage:[UIImage imageNamed:@"Live_Rider_Normal"]
                                    options:0
                                  completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                                      if (self.delegate && [self.delegate respondsToSelector:@selector(canPlayDirve:driverModel:offset:ifError:)]) {
                                          [self.delegate canPlayDirve:self driverModel:model offset:selfWidth ifError:error];
                                      }
                                  }];
}

@end
