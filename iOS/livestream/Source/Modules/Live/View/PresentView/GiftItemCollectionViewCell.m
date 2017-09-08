//
//  GiftItemCollectionViewCell.m
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "GiftItemCollectionViewCell.h"

@interface GiftItemCollectionViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftImageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftImageWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftImageBottomOffset;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftNameLableBottomOffset;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftCountBottomOffset;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigGiftLogoHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigGiftLogoWidth;

@property (weak, nonatomic) IBOutlet UIImageView *bigGiftLogo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *haveNumViewWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *haveNumViewHeight;


@end

@implementation GiftItemCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self updataMasonry];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectCell = NO;
    
    self.bigGiftLogo.hidden = NO;
    self.haveNumView.hidden = YES;
    
    [self updataMasonry];

}

- (void)updataMasonry{
    
    self.giftName.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(11)];
    self.giftCount.titleLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(10)];
    self.giftCountBottomOffset.constant = DESGIN_TRANSFORM_3X(4);
    self.giftNameLableBottomOffset.constant = 0;
    self.giftImageBottomOffset.constant = DESGIN_TRANSFORM_3X(3);
    self.giftImageWidth.constant = self.giftImageHeight.constant = DESGIN_TRANSFORM_3X(50);
    self.bigGiftLogoWidth.constant = self.bigGiftLogoHeight.constant = DESGIN_TRANSFORM_3X(12);
    self.haveNumViewWidth.constant = DESGIN_TRANSFORM_3X(26);
    self.haveNumViewHeight.constant = DESGIN_TRANSFORM_3X(26);
    self.haveNumView.layer.cornerRadius = DESGIN_TRANSFORM_3X(13);
    self.haveNumView.layer.masksToBounds = YES;
    self.haveNumLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(14)];
}

- (void)reloadStyle {
    if (self.selectCell) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor yellowColor].CGColor;
    }else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor yellowColor].CGColor;
    }
}

/** 背包隐藏view */
- (void)backpackHiddenView {
    
    self.giftCount.hidden = YES;
    self.bigGiftLogo.hidden = YES;
    self.haveNumView.hidden = NO;
}

- (void)updataCellViewItem:(AllGiftItem *)item{
    
    self.selectCell = NO;
    
    if (item.infoItem.type == GIFTTYPE_COMMON) {
        
        self.bigGiftLogo.hidden = YES;
    }else{
        
        self.bigGiftLogo.hidden = NO;
    }
    
    self.giftName.text = item.infoItem.name;
    
    [self.giftImageView sd_setImageWithURL:[NSURL URLWithString:item.infoItem.middleImgUrl]
                          placeholderImage:[UIImage imageNamed:@"Live_giftIcon_nomal"] options:0];
    
    [self.giftCount setTitle:[NSString stringWithFormat:@" %0.2f",item.infoItem.credit] forState:UIControlStateNormal];
    
}

- (void)updataBackpackCellViewItem:(BackpackGiftItem *)backItem{
    
    self.selectCell = NO;
    
    self.bigGiftLogo.hidden = YES;
    
//    self.giftName.text = backItem.item.name;
    
//    [self.giftImageView sd_setImageWithURL:[NSURL URLWithString:backItem.item.imgUrl]
//                          placeholderImage:[UIImage imageNamed:@"Live_giftIcon_nomal"] options:0];
    
    self.haveNumLabel.text = [NSString stringWithFormat:@"%d",backItem.giftNum];
}

+ (NSString *)cellIdentifier {
    return @"GiftItemCollectionViewIdentifier";
}
@end
