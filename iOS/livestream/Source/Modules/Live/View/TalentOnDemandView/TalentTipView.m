//
//  TalentTipView.m
//  livestream
//
//  Created by Calvin on 17/9/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TalentTipView.h"
#import "LiveBundle.h"

@interface TalentTipView ()

@end

@implementation TalentTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [[LiveBundle mainBundle] loadNibNamed:@"TalentTipView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;

    self.cancelBtn.layer.cornerRadius = 5;
    self.cancelBtn.layer.masksToBounds = YES;

    self.requstBtn.layer.cornerRadius = 5;
    self.requstBtn.layer.masksToBounds = YES;
}

- (void)setTalentName:(NSString *)name {
    NSString *message = [NSString stringWithFormat:@"%@%@", self.talentLabel.text, name];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:message];
    [attr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x5D0E86) range:[message rangeOfString:name]];
    self.talentLabel.attributedText = attr;
}

- (void)setPriceNum:(NSString *)price {
    NSString *message = [NSString stringWithFormat:@"%@ %@", self.priceLabel.text, price];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.priceLabel.text
                                                                                attributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    NSAttributedString *atbPrice = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",price]];
    [attrStr appendAttributedString:atbPrice];
    [attrStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0xF7CD3A) range:[message rangeOfString:price]];
    self.priceLabel.attributedText = attrStr;
}

- (IBAction)cancelBtnDid:(UIButton *)sender {
}

- (IBAction)requstBtnDid:(UIButton *)sender {
}

- (IBAction)closeBtnDid:(UIButton *)sender {
}
@end
