//
//  LSPurchaseCreditsView.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/9.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPurchaseCreditsView.h"
#import "LSImageViewLoader.h"
#import "LiveGobalManager.h"

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
    
    self.bigTitleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bigTitleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    self.bigTitleLabel.layer.shadowOpacity = 0.5;
    
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

- (void)setupCreditView:(NSString *)url {
    LSImageViewLoader *loader = [[LSImageViewLoader alloc] init];
    [loader loadImageWithImageView:self.headImageView options:0 imageUrl:url placeholderImage:LADYDEFAULTIMG finishHandler:nil];
}

- (void)setupCreditTipIsAccept:(BOOL)isAccept name:(NSString *)name credit:(double)credit {
    self.creditLabel.text = [NSString stringWithFormat:@"%.2f",credit];
    
    if (isAccept) {
        self.titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ON_CREDIT_ACCEPT_SCHEDULE"),name];
        self.tipLabel.text = NSLocalizedStringFromSelf(@"ON_CREDIT_ACCEPT_TIP");
    } else {
        self.titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"mUZ-QF-KyS.text"),name];
        self.tipLabel.text = NSLocalizedStringFromSelf(@"3KF-AJ-tOs.text");
    }
}

- (void)showLSCreditViewInView:(UIView *)view {
    [[LiveGobalManager manager] showPopupView:self withVc:nil];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.leading.trailing.equalTo(view);
        }];
    }
}

- (void)removeShowCreditView {
    [self removeFromSuperview];
    [[LiveGobalManager manager] removeLiveRoomPopup];
}

- (IBAction)purchaseBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(purchaseDidAction)]) {
        [self.delegate purchaseDidAction];
    }
}

- (IBAction)laterBtnDid:(id)sender {
    [self removeShowCreditView];
}


@end
