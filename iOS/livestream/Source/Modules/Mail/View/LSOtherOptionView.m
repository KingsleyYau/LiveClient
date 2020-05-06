//
//  LSOtherOptionView.m
//  livestream
//
//  Created by test on 2020/4/15.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSOtherOptionView.h"

@implementation LSOtherOptionView

+ (LSOtherOptionView *)ohterOptionWithDelegate:(id<LSOtherOptionViewDelegate>)delegate {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    LSOtherOptionView* view = [nibs objectAtIndex:0];
    view.delegate = delegate;
    view.declineSendMailBtn.layer.cornerRadius = view.declineSendMailBtn.frame.size.height * 0.5f;
    view.declineSendMailBtn.layer.masksToBounds = YES;
    view.declineSendMailBtn.layer.borderWidth = 1;
    view.declineSendMailBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x999999).CGColor;
    
    view.decelineBtn.layer.cornerRadius = view.decelineBtn.frame.size.height * 0.5f;
    view.decelineBtn.layer.masksToBounds = YES;
    view.decelineBtn.layer.borderWidth = 1;
    view.decelineBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x999999).CGColor;
    
    view.sendMailBtn.layer.cornerRadius = view.sendMailBtn.frame.size.height * 0.5f;
    view.sendMailBtn.layer.masksToBounds = YES;
    view.sendMailBtn.layer.borderWidth = 1;
    view.sendMailBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x999999).CGColor;

    return view;
}


- (IBAction)declineAndSendMailAction:(UIButton *)sender {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(lsOtherOptionView:declineAndSendMail:)]) {
        [self.delegate lsOtherOptionView:self declineAndSendMail:sender];
    }
}
- (IBAction)declineAction:(UIButton *)sender {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(lsOtherOptionView:decline:)]) {
        [self.delegate lsOtherOptionView:self decline:sender];
    }
    
}
- (IBAction)sendMailAction:(UIButton *)sender {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(lsOtherOptionView:sendMail:)]) {
        [self.delegate lsOtherOptionView:self sendMail:sender];
    }
}

@end
