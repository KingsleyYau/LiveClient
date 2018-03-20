//
//  PremiumMembershipView.m
//  dating
//
//  Created by Calvin on 17/4/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "PremiumMembershipView.h"

#define AlertViewW 270

@interface PremiumMembershipView ()
@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) UIView * lineView;
@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) UIButton * button;
@end

@implementation PremiumMembershipView

 
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.bgView = [[UIView alloc]initWithFrame:frame];
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0;
        [self addSubview:self.bgView];
        
        self.textView = [[UITextView alloc]init];
        self.textView.textContainerInset = UIEdgeInsetsMake(15, 15, 15, 15);
        self.textView.font = [UIFont systemFontOfSize:13];
        self.textView.editable = NO;
        self.textView.scrollEnabled = NO;
        [self addSubview:self.textView];
        
        self.lineView = [[UIView alloc]init];
        self.lineView.backgroundColor = [UIColor lightGrayColor];
        [self.textView addSubview:self.lineView];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setTitle:@"OK" forState:UIControlStateNormal];
        [self.button setTitleColor:COLOR_WITH_16BAND_RGB(0x0066FF) forState:UIControlStateNormal];
        [self.button addTarget:self action:@selector(buttonDid) forControlEvents:UIControlEventTouchUpInside];
        [self.textView addSubview:self.button];
        
    }
    return self;
}

- (void)showMembershipView:(NSString *)message
{
    NSString * title = @"";
    NSRange range = [message rangeOfString: @"</h[0-9]>" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        message = [message stringByReplacingOccurrencesOfString:[message substringWithRange:range] withString:@""];
        NSString * str = [message substringToIndex:range.location];
        NSRange range = [str rangeOfString: @"<h[0-9]>" options:NSRegularExpressionSearch];
        NSArray * array = [str componentsSeparatedByString:[str substringWithRange:range]];
        title = [array lastObject];
        message = [message stringByReplacingOccurrencesOfString:[str substringWithRange:range] withString:@""];
    }

    message = [message stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.7;
    }];

    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:message];
    [richText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:[message rangeOfString:title]];
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[message rangeOfString:title]];
    [richText addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x797979) range:NSMakeRange(title.length, message.length - title.length)];
    self.textView.attributedText = richText;
    
    self.textView.frame = CGRectMake(screenSize.width/2 - AlertViewW/2, screenSize.height/2 - [self messageH:message]/2, AlertViewW, [self messageH:message]);
    self.textView.layer.cornerRadius = 4;
    self.textView.layer.masksToBounds = YES;
    
    self.lineView.frame = CGRectMake(0, self.textView.frame.size.height - 50, AlertViewW, 0.5);
    
    self.button.frame = CGRectMake(0, self.lineView.frame.origin.y, AlertViewW, self.textView.frame.size.height - self.lineView.frame.origin.y);
}

- (void)hideMembershipView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0;
        self.textView.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)buttonDid
{
    [self hideMembershipView];
}

- (CGFloat)messageH:(NSString *)message
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:self.textView.font, NSFontAttributeName, nil];
    
    CGRect rect= [message boundingRectWithSize:CGSizeMake(AlertViewW - 15, MAXFLOAT)
                                            options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                         attributes:dict context:nil];
    return rect.size.height + 80;
}

@end
