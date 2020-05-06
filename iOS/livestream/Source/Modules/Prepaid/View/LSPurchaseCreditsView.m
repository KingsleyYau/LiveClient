//
//  LSPurchaseCreditsView.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/9.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPurchaseCreditsView.h"
#import "LSImageViewLoader.h"

@interface LSPurchaseCreditsView()


@end

@implementation LSPurchaseCreditsView

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPurchaseCreditsView" owner:self options:0].firstObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.purchaseView.layer.masksToBounds = YES;
    self.purchaseView.layer.cornerRadius = 4;
    
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = self.headImageView.tx_height / 2;
    
    self.purchaseBtn.layer.masksToBounds = YES;
    self.purchaseBtn.layer.cornerRadius = self.purchaseBtn.tx_height / 2;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"LATER") attributes:@{
        NSFontAttributeName : [UIFont systemFontOfSize:14],
        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838),
        NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]
    }];
    self.laterBtn.titleLabel.attributedText = str;
}

- (void)setupCreditView:(NSString *)url name:(NSString *)name {
    LSImageViewLoader *loader = [[LSImageViewLoader alloc] init];
    [loader loadImageFromCache:self.headImageView options:0 imageUrl:url placeholderImage:LADYDEFAULTIMG finishHandler:nil];
    
    self.tipLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"mUZ-QF-KyS.text"),name];
}

- (IBAction)purchaseBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(purchaseDidAction)]) {
        [self.delegate purchaseDidAction];
    }
}

- (IBAction)laterBtnDid:(id)sender {
    self.hidden = YES;
}


@end
