//
//  LSAddCartSuccessView.m
//  livestream
//
//  Created by Calvin on 2019/10/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSAddCartSuccessView.h"
#import "LSShadowView.h"
@interface LSAddCartSuccessView ()

@end

@implementation LSAddCartSuccessView

- (instancetype)initWithFrame:(CGRect)frame {
     self = [super initWithFrame:frame];
     if (self) {
         self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSAddCartSuccessView" owner:self options:0].firstObject;
         self.frame = frame;
     }
     return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tipContentView.layer.cornerRadius = 4;
    self.tipContentView.layer.masksToBounds = YES;
    
    self.tipCheckoutBtn.layer.cornerRadius = 4;
    self.tipCheckoutBtn.layer.masksToBounds = YES;
    [[LSShadowView new]showShadowAddView:self.tipCheckoutBtn];
}

- (IBAction)tipCheckoutBtnDid:(id)sender {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(addCartSuccessViewDidCheckoutBtn)]) {
        [self.delegate addCartSuccessViewDidCheckoutBtn];
    }
}

- (IBAction)exitBtnDid:(id)sender {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(addCartSuccessViewDidContiuneBtn)]) {
        [self.delegate addCartSuccessViewDidContiuneBtn];
    }
}

- (IBAction)cancelBtnDid:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)bgViewTap:(id)sender {
    [self removeFromSuperview];
}

@end
