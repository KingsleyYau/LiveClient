//
//  JDAlertView.m
//  livestream
//
//  Created by Calvin on 17/10/13.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "JDAlertView.h"

@interface JDAlertView ()
@property (strong) void(^noBlock)();
@property (strong) void(^yesBlock)();
@end

@implementation JDAlertView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.alertView.layer.cornerRadius = 10;
    self.alertView.layer.masksToBounds = YES;
    
    self.yesBtn.layer.cornerRadius = 5;
    self.yesBtn.layer.masksToBounds = YES;
    
    self.noBtn.layer.cornerRadius = 5;
    self.noBtn.layer.masksToBounds = YES;
}

- (instancetype)initWithMessage:(NSString *)message noButtonTitle:(NSString *)noMsg yesButtonTitle:(NSString *)yesMsg onBlock:(void(^)())onBlock yesBlock:(void(^)())yesBlock
{
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"JDAlertView" owner:self options:0].firstObject;
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        self.messageLabel.text = message;
        
        [self.yesBtn setTitle:yesMsg forState:UIControlStateNormal];
        [self.noBtn setTitle:noMsg forState:UIControlStateNormal];
        
        self.noBlock = onBlock;
        self.yesBlock = yesBlock;
        
        CGSize viewH = [message boundingRectWithSize:CGSizeMake(self.messageLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:self.messageLabel.font} context:nil].size;
        
        if (viewH.height > self.messageLabel.frame.size.height) {
            CGFloat h = viewH.height - self.messageLabel.frame.size.height;
            CGRect viewRect = self.alertView.frame;
            viewRect.size.height = viewRect.size.height + h + 20;
            self.alertView.frame = viewRect;
            
        }
        
    }
    return self;
}

- (void)show
{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

- (IBAction)closeBtnDid:(UIButton *)sender {
    
    [self removeFromSuperview];
}

- (IBAction)yesBtnDid:(UIButton *)sender {
    
    if (self.yesBlock) {
        self.yesBlock();
    }
    [self removeFromSuperview];
}

- (IBAction)noBtnDid:(UIButton *)sender {

    if (self.noBlock) {
        self.noBlock();
    }
    [self removeFromSuperview];
}

- (IBAction)bgTap:(UITapGestureRecognizer *)sender {
   [self removeFromSuperview];
}

@end
