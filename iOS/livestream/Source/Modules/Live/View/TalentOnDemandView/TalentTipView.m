//
//  TalentTipView.m
//  livestream
//
//  Created by Calvin on 17/9/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TalentTipView.h"

@interface TalentTipView ()

@end

@implementation TalentTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[NSBundle mainBundle] loadNibNamed:@"TalentTipView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    self.cancelBtn.layer.cornerRadius = 5;
    self.cancelBtn.layer.masksToBounds = YES;
    
    self.requstBtn.layer.cornerRadius = 5;
    self.requstBtn.layer.masksToBounds = YES;
}

- (void)setTalentName:(NSString *)name
{
    NSString * message = [NSString stringWithFormat:@"%@%@",self.talentLabel.text,name];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:message];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"5d0e86"] range:[message rangeOfString:name]];
    self.talentLabel.attributedText = attr;
}

- (void)setPriceNum:(NSString *)price
{
    NSString * message = [NSString stringWithFormat:@"%@%@",self.priceLabel.text,price];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:message];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"f7cd3a"] range:[message rangeOfString:price]];
    self.priceLabel.attributedText = attr;
}

- (IBAction)cancelBtnDid:(UIButton *)sender {
}

- (IBAction)requstBtnDid:(UIButton *)sender {
}

- (IBAction)closeBtnDid:(UIButton *)sender {
}
@end
