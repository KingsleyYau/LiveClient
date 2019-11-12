//
//  LSCreditViewView.m
//  livestream
//
//  Created by Calvin on 2019/9/6.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSCreditView.h"
#import "LSShadowView.h"
@interface LSCreditView ()

@end

@implementation LSCreditView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSCreditView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.cornerRadius = 4;
    self.contentView.layer.masksToBounds = YES;
    
    self.addBtn.layer.cornerRadius = 6;
    self.addBtn.layer.masksToBounds = YES;
    
    LSShadowView * view = [[LSShadowView alloc]init];
    [view showShadowAddView:self.addBtn];
}

- (IBAction)tapBG:(UITapGestureRecognizer *)sender {
    self.hidden = YES;
}

- (IBAction)addBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(creditViewDidAddCredit)]) {
        [self.delegate creditViewDidAddCredit];
    }
    self.hidden = YES;
}

- (IBAction)closeBtnDid:(UIButton *)sender {
    self.hidden = YES;
}

@end
