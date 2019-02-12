//
//  GiftItemCollectionViewCell.m
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "GiftItemCollectionViewCell.h"
#import "LSGiftManager.h"
#import "LSImageViewLoader.h"

@interface GiftItemCollectionViewCell ()

@property (nonatomic, strong) LSGiftManager *loadManager;
@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@end

@implementation GiftItemCollectionViewCell
+ (NSString *)cellIdentifier {
    return @"GiftItemCollectionViewIdentifier";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    [self.loadingView startAnimating];

    self.loadManager = [LSGiftManager manager];
    self.imageLoader = [LSImageViewLoader loader];
    
    self.giftCountView.layer.cornerRadius = self.giftCountView.frame.size.height / 2;
    self.giftCountView.layer.masksToBounds = YES;

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
    self.giftCountLabel.hidden = YES;
    self.giftLockImageView.hidden = YES;
    
    self.loadingView.hidden = YES;
    self.giftCreditLabel.hidden = YES;
}

- (void)updateItem:(LSGiftManagerItem *)item manLevel:(NSInteger)manLevel lovelLevel:(NSInteger)lovelLevel type:(GiftListType)type {
    // 重置控件状态
    [self reset:item];
    
    // 能否发送状态
    BOOL bCanSend = [item canSend:lovelLevel userLevel:manLevel];
    // 锁
    self.giftLockImageView.hidden = bCanSend;
    
    // 大礼物
    if (item.infoItem.type == GIFTTYPE_Heigh) {
        self.giftBigImageView.hidden = NO;
        if (item.isDownloading) {
            // 下载中
            self.loadingView.hidden = NO;
        }
    }
    // 礼物图片
    [self.imageLoader loadImageWithImageView:self.giftImageView
                                     options:0
                                    imageUrl:item.infoItem.middleImgUrl
                            placeholderImage:
     [UIImage imageNamed:@"Live_Gift_Nomal"]];
    
    // 礼物名字
    self.giftNameLabel.text = item.infoItem.name;
    
    // 根据类型处理控件
    switch (type) {
        case GiftListTypeNormal: {
            // 普通礼物
            
            // 礼物价格
            self.giftCreditLabel.hidden = NO;
            self.giftCreditLabel.text = [NSString stringWithFormat:@"%@ Credits", @(item.infoItem.credit)];
            
        } break;
        case GiftListTypeBackpack: {
            // 背包礼物
            
            // 大礼物
            self.giftBigImageView.hidden = YES;
            // 礼物价格
            self.giftCreditLabel.hidden = YES;
            // 能发送, 显示礼物数量
            self.giftCountView.hidden = !bCanSend;
            self.giftCountLabel.hidden = !bCanSend;
            if (item.backpackTotal > 99) {
                self.giftCountLabel.text = [NSString stringWithFormat:@"99+"];
            } else {
                self.giftCountLabel.text = [NSString stringWithFormat:@"%d", (int)item.backpackTotal];
            }
            
        } break;
        default:
            break;
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
