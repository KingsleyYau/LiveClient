//
//  LSHangoutListHeadView.m
//  livestream
//
//  Created by test on 2019/1/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSHangoutListHeadView.h"
#import "LSConfigManager.h"

@interface LSHangoutListHeadView()<LSCheckButtonDelegate>
@end

@implementation LSHangoutListHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSHangoutListHeadView" owner:self options:nil].firstObject;
        self.frame = frame;

        self.getItBtn.layer.cornerRadius = 18.0f;
        self.getItBtn.layer.masksToBounds = YES;
        
        self.notShowLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToSelect)];
        [self.notShowLabel addGestureRecognizer:tap];
        
        self.notShowBtn.layer.borderWidth = 1;
        self.notShowBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.notShowBtn setImage:[UIImage imageNamed:@"HangoutList_banner_select"] forState:UIControlStateSelected];
        [self.notShowBtn setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        
        
        self.showMoreBtn.selectedChangeDelegate = self;
        
        
        self.showMoreBtn.layer.cornerRadius = 4;
        self.showMoreBtn.layer.masksToBounds = YES;
        [self addBorderForView:self.showMoreBtn color:COLOR_WITH_16BAND_RGB(0xFF6028) borderWidth:2];
        [self.showMoreBtn setImage:[UIImage imageNamed:@"HangoutList_banner_hide"] forState:UIControlStateSelected];
        [self.showMoreBtn setImage:[UIImage imageNamed:@"HangoutList_banner_show"] forState:UIControlStateNormal];
        
        NSString *creditPriceStr = [NSString stringWithFormat:@"%.1f",[LSConfigManager manager].item.hangoutCreditPrice];
        self.creditTips.text = [NSString stringWithFormat:@"Hang-out is billed at %@ credits per minute per broadcaster.",creditPriceStr];
        NSMutableAttributedString *attrbuteStr = [[NSMutableAttributedString alloc] initWithString:self.creditTips.text];
        NSRange tapRange = [self.creditTips.text rangeOfString:creditPriceStr];
        [attrbuteStr addAttributes:@{
                                     NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                     } range:tapRange];

        self.creditTips.attributedText = attrbuteStr;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.showMoreBtn.layer.cornerRadius = 4.0f;
    self.showMoreBtn.layer.masksToBounds = YES;
    self.getItBtn.layer.cornerRadius = 18.0f;
    self.getItBtn.layer.masksToBounds = YES;
    
}
- (IBAction)clickAction:(id)sender {
    if ([self.hangoutHeadDelegate respondsToSelector:@selector(LSHangoutListHeadViewDidShowMore:)]) {
        [self.hangoutHeadDelegate LSHangoutListHeadViewDidShowMore:self];
    }
}

- (void)selectedChanged:(id)sender {
    UIButton *showMoreBtn = (UIButton *)sender;
    if (showMoreBtn.selected == YES) {
        
        // 弹出底部emotion的键盘
        if ([self.hangoutHeadDelegate respondsToSelector:@selector(LSHangoutListHeadViewDidShowMore:)]) {
            [self.hangoutHeadDelegate LSHangoutListHeadViewDidShowMore:self];
        }
        
    } else {
        
        
        if ([self.hangoutHeadDelegate respondsToSelector:@selector(LSHangoutListHeadViewDidHideMore:)]) {
            [self.hangoutHeadDelegate LSHangoutListHeadViewDidHideMore:self];
        }
    }
}
- (IBAction)getTipNotShow:(id)sender {
    if ([self.hangoutHeadDelegate respondsToSelector:@selector(LSHangoutListHeadViewDidGetTips:)]) {
        [self.hangoutHeadDelegate LSHangoutListHeadViewDidGetTips:self];
    }
}
- (IBAction)tipDidNotShowAgainClickAction:(UIButton *)sender {
    if ([sender isSelected]) {
        [sender setSelected:NO];
    } else {
        [sender setSelected:YES];
    }
    
}


- (void)tapToSelect {
    [self tipDidNotShowAgainClickAction:self.notShowBtn];
}


// 添加左右下边框
- (UIView *)addBorderForView:(UIView *)originalView color:(UIColor *)color borderWidth:(CGFloat)borderWidth {
    // 左
    CALayer *layer1 = [CALayer layer];
    layer1.frame = CGRectMake(0, 0, borderWidth, originalView.frame.size.height);
    layer1.backgroundColor = color.CGColor;
    [originalView.layer addSublayer:layer1];
    
    // 右
    CALayer *layer3 = [CALayer layer];
    layer3.frame = CGRectMake(originalView.frame.size.width - borderWidth, 0, borderWidth, originalView.frame.size.height);
    layer3.backgroundColor = color.CGColor;
    [originalView.layer addSublayer:layer3];
    
    // 底部
    CALayer *layer2 = [CALayer layer];
    layer2.frame = CGRectMake(0, originalView.frame.size.height - borderWidth, originalView.frame.size.width, borderWidth);
    layer2.backgroundColor = color.CGColor;
    [originalView.layer addSublayer:layer2];
    
    return originalView;
}


@end
