//
//  GiftStatisticsViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/4/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "GiftStatisticsViewCell.h"
#import "LSImageViewLoader.h"

@interface GiftStatisticsViewCell ()
@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@end

@implementation GiftStatisticsViewCell

+ (NSString *)cellIdentifier {
    return @"GiftStatisticsViewCell";
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

    self.backGroundView.layer.cornerRadius = self.backGroundView.frame.size.height * 0.5;
    self.backGroundView.layer.masksToBounds = YES;

    self.giftNumView.layer.cornerRadius = self.giftNumView.frame.size.height * 0.5;
    self.giftNumView.layer.masksToBounds = YES;
}

- (void)updataCellViewItem:(LSGiftManagerItem *)item num:(int)num {
    [self.imageLoader loadImageWithImageView:self.giftImageView
                                     options:0
                                    imageUrl:item.infoItem.smallImgUrl
                            placeholderImage:[UIImage imageNamed:@"Live_Publish_Btn_Gift"]
                               finishHandler:nil];
    if (num < 2) {
        self.giftNumView.hidden = YES;
    } else {
        self.giftNumView.hidden = NO;
    }
    if (num > 99) {
        self.giftNumLabel.text = [NSString stringWithFormat:@"..."];
    } else {
        self.giftNumLabel.text = [NSString stringWithFormat:@"%d", num];
    }
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.giftImageView sd_cancelCurrentImageLoad];
    self.giftImageView.image = nil;
}

@end
