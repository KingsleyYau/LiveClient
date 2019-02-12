//
//  LSOutOfCreditsView.m
//  livestream
//
//  Created by test on 2018/12/17.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSOutOfPoststampView.h"
#import "TTTAttributedLabel.h"
#import "LSChatTextAttachment.h"
#import "LSShadowView.h"
#define AnimationTime 0.3
#define LATER @"LATER"
@interface LSOutOfPoststampView()<TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *tipView;
// 提示
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *laterLabel;
@end


@implementation LSOutOfPoststampView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

+ (LSOutOfPoststampView *)initWithActionViewDelegate:(id<LSOutOfPoststampViewDelegate>)delegate {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    LSOutOfPoststampView* view = [nibs objectAtIndex:0];
    view.tipView.layer.cornerRadius = 6.0f;
    view.tipView.layer.masksToBounds = YES;
    view.delegate = delegate;
    [view setupTapLabelStyle];
    
    return view;
}

- (IBAction)sendByCreditAction:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(lsOutOfPoststampView:didSelectAddCredit:)]) {
        [self.delegate lsOutOfPoststampView:self didSelectAddCredit:btn];
    }
    
}

- (void)setupTapLabelStyle {
    // 设置超链接属性
    NSDictionary *dic = @{
                          NSFontAttributeName : [UIFont systemFontOfSize:14],
                          NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838),
                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSUnderlineColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838),
                          };
    self.laterLabel.linkAttributes = dic;
    self.laterLabel.activeLinkAttributes = dic;
    self.laterLabel.delegate = self;
    
    // 设置文本属性
    NSMutableAttributedString *attrbuteStr = [[NSMutableAttributedString alloc] initWithString:self.laterLabel.text];

    
    // 设置超链接内容
    LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
    attachment.text = @"Later";
    attachment.url = [NSURL URLWithString:LATER];
    attachment.bounds = CGRectMake(0, 0, [UIFont systemFontOfSize:14].lineHeight, [UIFont systemFontOfSize:14].lineHeight);
    NSRange tapRange = [self.laterLabel.text rangeOfString:@"Later"];
    [attrbuteStr addAttributes:@{
                                 NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSAttachmentAttributeName : attachment,
                                 } range:tapRange];
    
    self.laterLabel.attributedText = attrbuteStr;
    
    [attrbuteStr enumerateAttributesInRange:NSMakeRange(0, attrbuteStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        LSChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
        if( attachment && attachment.url != nil ) {
            [self.laterLabel addLinkToURL:attachment.url withRange:range];
        }
    }];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if( [[url absoluteString] isEqualToString:LATER] ) {
        [self hideAnimation];
    }
}

- (void)outOfPoststampShowCreditView:(UIView *)view balanceCount:(NSString *)balanceCount{
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    self.addCreditBtn.layer.cornerRadius = 8;
    self.addCreditBtn.layer.masksToBounds = YES;
    
    LSShadowView * shadowView = [[LSShadowView alloc]init];
    [shadowView showShadowAddView:self.addCreditBtn];
    
    NSString *creditTips = [NSString stringWithFormat:@"Send by Credits(%@ credits)",balanceCount];
    [self.addCreditBtn setTitle:creditTips forState:UIControlStateNormal];
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view);
            make.bottom.equalTo(view);
            make.left.equalTo(view);
            make.right.equalTo(view);
        }];
        [UIView animateWithDuration:AnimationTime animations:^{
            self.tipView.alpha = 1;
            self.bgView.alpha = 1;
        }];
    }
}

//隐藏界面
- (void)hideAnimation {
    [UIView animateWithDuration:AnimationTime animations:^{
        self.bgView.alpha = 0;
        self.tipView.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
