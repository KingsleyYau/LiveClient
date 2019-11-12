//
//  LSStoreListCell.m
//  livestream
//
//  Created by Calvin on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSStoreListCell.h"
#import "LSShadowView.h"

@interface LSStoreListCell ()
@property (nonatomic, copy) NSString * giftId;
@end

@implementation LSStoreListCell

+ (NSString *)cellIdentifier {
    return @"LSStoreListCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.bgView.layer.cornerRadius = 3;
    self.bgView.layer.masksToBounds = YES;
    
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
    
    self.layer.borderWidth = 0.3;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.imageViewLoader = [LSImageViewLoader loader];
}

- (void)uploadUI:(LSFlowerGiftItemObject *)item {
    
    self.giftId = item.giftId;
    [self.imageViewLoader loadHDListImageWithImageView:self.imageView
                                               options:0
                                              imageUrl:item.giftImg
                                      placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"]
                                         finishHandler:nil];
    
    self.titleLabel.text = item.giftName;
    
    self.stroeNewIcon.hidden = !item.isNew;
    
    self.discountLabel.hidden = YES;
 
    switch (item.priceShowType) {
        case LSPRICESHOWTYPE_WEEKDAY://平日价
        {
              self.priceLabel.text = [NSString stringWithFormat:@"$%0.2f",item.giftWeekdayPrice];
        }break;
        case LSPRICESHOWTYPE_HOLIDAY://节日价
        {
            self.priceLabel.text = [NSString stringWithFormat:@"$%0.2f",item.giftPrice];
        }break;
        case LSPRICESHOWTYPE_DISCOUNT://优惠价
        {
            self.priceLabel.text = [NSString stringWithFormat:@"$%0.2f",item.giftDiscountPrice];
            self.discountLabel.hidden = NO;
            NSString * str = [NSString stringWithFormat:@"$%0.2f",item.giftWeekdayPrice];
             NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:str];
                    [attributeStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x999999) range:NSMakeRange(0, str.length)];
                    [attributeStr addAttribute:NSStrikethroughStyleAttributeName value:
            @(NSUnderlineStyleSingle) range:NSMakeRange(0, str.length)];
            self.discountLabel.attributedText = attributeStr;
        }break;
        default:
            break;
    }
    
    if (self.discountLabel.hidden) {
        self.priceLabelW.constant = self.addBtn.tx_x - 10;
    }else {
        CGFloat w = [self.priceLabel.text sizeWithAttributes:@{NSFontAttributeName:self.priceLabel.font}].width;
        if (w > self.addBtn.tx_x - 10) {
            self.priceLabelW.constant = self.addBtn.tx_x - 10;
        }else {
            self.priceLabelW.constant = w;
            self.discountLabelW.constant = self.addBtn.tx_x - w - 10;
        }
    }
}

- (IBAction)addBtnDid:(UIButton *)sender {
    if ([self.cellDelegate respondsToSelector:@selector(stroeListCellAddCartBtnDid:forImageView:)]) {
        [self.cellDelegate stroeListCellAddCartBtnDid:self.giftId forImageView:self.imageView];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageViewLoader stop];
    [self.imageView sd_cancelCurrentImageLoad];
    self.imageView.image = nil;
}

@end
