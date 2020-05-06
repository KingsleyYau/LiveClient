//
//  LSVIPLiveGiftListCell.m
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSVIPLiveGiftListCell.h"

#import "LSGiftManager.h"
#import "LSImageViewLoader.h"

@interface LSVIPLiveGiftListCell ()

@property (nonatomic, strong) LSGiftManager *loadManager;
@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@end


@implementation LSVIPLiveGiftListCell

+ (NSString *)cellIdentifier {
    return @"LSVIPLiveGiftListCell";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.loadManager = [LSGiftManager manager];
    self.imageLoader = [LSImageViewLoader loader];
    
    self.giftCountView.layer.cornerRadius = self.giftCountView.frame.size.height / 2;
    self.giftCountView.layer.masksToBounds = YES;
    self.shadowView.hidden = YES;
}

- (void)reloadSelectedItem {
    if (self.selectCell) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = COLOR_WITH_16BAND_RGB(0xf7cd3a).CGColor;
    } else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = COLOR_WITH_16BAND_RGB(0xf7cd3a).CGColor;
    }
}

- (void)reset:(LSGiftManagerItem *)item {
    // TODO:还原控件
    self.selectCell = NO;
    
    self.giftBigImageView.hidden = YES;
    self.giftCountView.hidden = YES;
    self.giftBgView.alpha = 1;
    
    self.shadowView.hidden = YES;
    self.shadowView.layer.cornerRadius = self.shadowView.frame.size.height / 2;
    self.shadowView.layer.masksToBounds = YES;
}

- (void)updateItem:(LSGiftManagerItem *)item liveRoom:(LiveRoom *)liveRoom type:(NSString *)type {
    // 重置控件状态
    [self reset:item];
    
    // 直播间样式
    switch (liveRoom.roomType) {
        case LiveRoomType_Public:{
            self.giftCreditLabel.textColor = COLOR_WITH_16BAND_RGB(0xfedc4b);
            [self.giftBgView setImage:[UIImage imageNamed:@"Live_Public_Top_GiftBg"]];
        }break;
            
        default:{
            self.giftCreditLabel.textColor = COLOR_WITH_16BAND_RGB(0xFF6D00);
            [self.giftBgView setImage:[UIImage imageNamed:@"VIPLive_GiftBG"]];
        }break;
    }
    
    // 大礼物
    if (item.infoItem.type == GIFTTYPE_Heigh) {
        self.giftBigImageView.hidden = NO;
    } else {
        self.giftBigImageView.hidden = YES;
    }
    // 礼物图片
    [self.imageLoader loadImageWithImageView:self.giftImageView
                                     options:0
                                    imageUrl:item.infoItem.middleImgUrl
                            placeholderImage:
     [UIImage imageNamed:@"Live_Gift_Nomal"] finishHandler:nil];
    
    if ([type isEqualToString:@"Free"]) {
        // 背包礼物
        
        // 大礼物
        self.giftBigImageView.hidden = YES;
        // 礼物价格
        self.giftCreditLabel.text = type;
        // 显示礼物数量
        self.giftCountView.hidden = NO;
        
        if (item.backpackTotal < 1) {
            self.shadowView.hidden = NO;
            self.giftCountView.hidden = YES;
        } else if (item.backpackTotal > 99) {
            self.giftCountLabel.text = [NSString stringWithFormat:@"99+"];
        } else {
            self.giftCountLabel.text = [NSString stringWithFormat:@"%d", (int)item.backpackTotal];
        }
        
    } else {
        // 普通礼物
        // 礼物价格
        NSString * creditStr = @"credits";
        if (item.infoItem.credit == 1.0f ||
            item.infoItem.credit == 0.1f ||
            item.infoItem.credit == 0.01f)
        {
            creditStr = @"credit";
        }
        
        NSString *crediteNum = [NSString stringWithFormat:@"%@ %@", @(item.infoItem.credit),creditStr];
        if (item.infoItem.credit <= 0 || item.roomInfoItem.isFree) {
            crediteNum = @"Free";
        }
        self.giftCreditLabel.text = crediteNum;
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
