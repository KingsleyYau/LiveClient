//
//  CreditView.m
//  livestream
//
//  Created by randy on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "CreditView.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
#import "LiveBundle.h"
#import "LiveModule.h"

#define BalanceTip @"My Balance: "

@interface CreditView()

@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@end

@implementation CreditView

+ (CreditView *) creditView {
    
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    CreditView* view = [nibs objectAtIndex:0];
    view.rechargeBtn.layer.cornerRadius = 4;
    view.rechargeBtn.layer.masksToBounds = YES;
    view.userHeadImageView.layer.cornerRadius = 42;
    view.userHeadImageView.layer.masksToBounds = YES;
    view.imageLoader = [LSImageViewLoader loader];
    return view;
}

- (void)updateUserBalanceCredit:(double)credit headImage:(NSString *)imgUrl level:(int)lv {
    
    LSLoginManager *loginManager = [LSLoginManager manager];
    
    NSString * name = loginManager.loginItem.nickName;
    if (name.length > 20) {
        name = [name substringToIndex:17];
        name = [NSString stringWithFormat:@"%@...",name];
    }
    self.nameLabel.text = name;
    self.userIdLabel.text = [NSString stringWithFormat:@"ID:%@",loginManager.loginItem.userId];
    
    [self.imageLoader loadImageWithImageView:self.userHeadImageView options:0 imageUrl:imgUrl placeholderImage:[UIImage imageNamed:@"Man_Head_Nomal"]];
    
    NSString *imageName = [NSString stringWithFormat:@"User_leave_%d",lv];
    self.userLVImageView.image = [UIImage imageNamed:imageName];
    
    NSMutableAttributedString *attribuStr = [[NSMutableAttributedString alloc] init];
    [attribuStr appendAttributedString:[self parseMessage:BalanceTip font:[UIFont systemFontOfSize:12] color:[UIColor blackColor]]];
    NSString *str = [NSString stringWithFormat:@"%.2f credits",credit];
    [attribuStr appendAttributedString:[self parseMessage:str font:[UIFont systemFontOfSize:12] color:COLOR_WITH_16BAND_RGB(0xffd205)]];
    self.balanceLabel.attributedText = attribuStr;
}

- (void)userLevelUp:(int)level {
    NSString *imageName = [NSString stringWithFormat:@"User_leave_%d",level];
    self.userLVImageView.image = [UIImage imageNamed:imageName];
}

- (void)userCreditChange:(double)credit {
    NSMutableAttributedString *attribuStr = [[NSMutableAttributedString alloc] init];
    [attribuStr appendAttributedString:[self parseMessage:BalanceTip font:[UIFont systemFontOfSize:12] color:[UIColor blackColor]]];
    NSString *str = [NSString stringWithFormat:@"%.2f credits",credit];
    [attribuStr appendAttributedString:[self parseMessage:str font:[UIFont systemFontOfSize:12] color:COLOR_WITH_16BAND_RGB(0xffd205)]];
    self.balanceLabel.attributedText = attribuStr;
}

- (IBAction)userRecharge:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rechargeCreditAction:)]) {
        [self.delegate rechargeCreditAction:self];
    }
}

- (IBAction)closeAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(creditViewCloseAction:)]) {
        [self.delegate creditViewCloseAction:self];
    }
}


- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    return attributeString;
}


@end
