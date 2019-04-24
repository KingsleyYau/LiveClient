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

- (void)updateUserBalanceCredit:(double)credit userInfo:(LSUserInfoModel *)userInfo {

    if (!self.nameLabel.text ||self.nameLabel.text.length <= 0) {
        NSString * name = userInfo.nickName;
        if (name.length > 20) {
            name = [name substringToIndex:17];
            name = [NSString stringWithFormat:@"%@...",name];
        }
        self.nameLabel.text = name;
    }

    if (!self.userIdLabel.text || self.userIdLabel.text.length <= 0) {
        self.userIdLabel.text = [NSString stringWithFormat:@"ID:%@",userInfo.userId];
    }
    
    [self.imageLoader loadImageFromCache:self.userHeadImageView options:SDWebImageRefreshCached imageUrl:userInfo.photoUrl
                        placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"] finishHandler:^(UIImage *image) {
                        }];
    
    NSString *imageName = [NSString stringWithFormat:@"User_leave_%d",[LSLoginManager manager].loginItem.level];
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
