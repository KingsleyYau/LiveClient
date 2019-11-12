//
//  DeliveryStatusView.m
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "DeliveryStatusView.h"

@implementation DeliveryStatusView

+ (DeliveryStatusView *)deliveryStatusView {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    DeliveryStatusView* view = [nibs objectAtIndex:0];
    view.contentView.layer.cornerRadius = 4.0f;
    view.contentView.layer.masksToBounds = YES;
    [view setupUI];
    return view;
}


- (void)showDeliveryStatusView:(UIView *)view {
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(view);
        }];
    }
}


- (IBAction)closeAction:(id)sender {
    [self removeFromSuperview];

}

- (void)setupUI {
    if (screenSize.width < 375) {
        self.infoHeight.constant = 300;
    }
    self.pendingTips.attributedText = [self allString:self.pendingTips.text ChangeString:@"Pending" font:[UIFont boldSystemFontOfSize:16]];
    self.deliveryTips.attributedText = [self allString:self.deliveryTips.text ChangeString:@"Delivered" font:[UIFont boldSystemFontOfSize:16]];
    self.cancelTips.attributedText = [self allString:self.cancelTips.text ChangeString:@"Cancelled" font:[UIFont boldSystemFontOfSize:16]];
    self.shippedTips.attributedText = [self allString:self.shippedTips.text ChangeString:@"Shipped" font:[UIFont boldSystemFontOfSize:16]];

}


- (NSMutableAttributedString *)allString:(NSString *)allStr ChangeString:(NSString *)changeStr font:(UIFont* )font{
    
    NSString *str = [NSString stringWithFormat:@"%@", allStr];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    
    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, changeStr.length)];
    [string endEditing];
    

    
    return string;
    
}
@end
