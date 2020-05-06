//
//  HangOutPreAnchorPhotoCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/1/18.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "HangOutPreAnchorPhotoCell.h"
#import "LSImageViewLoader.h"
#import "LSUserInfoManager.h"

@interface HangOutPreAnchorPhotoCell ()

@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@end

@implementation HangOutPreAnchorPhotoCell

+ (NSString *)cellIdentifier {
    return @"HangOutPreAnchorPhotoCell";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageLoader = [LSImageViewLoader loader];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setupCellDate:(IMLivingAnchorItemObject *)item {
    self.nameLabel.text = item.nickName;
    // 请求主播个人信息
    if (item.photoUrl.length > 0) {
        [self.imageLoader loadImageFromCache:self.headImageView options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:LADYDEFAULTIMG finishHandler:nil];
    } else {
        WeakObject(self, weakSelf);
        self.headImageView.image = LADYDEFAULTIMG;
        [[LSUserInfoManager manager] getUserInfo:item.anchorId finishHandler:^(LSUserInfoModel * _Nonnull item) {
            [weakSelf.imageLoader loadImageFromCache:weakSelf.headImageView options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:LADYDEFAULTIMG finishHandler:nil];
        }];
    }
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.headImageView sd_cancelCurrentImageLoad];
    self.headImageView.image = nil;
}

@end
