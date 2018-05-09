//
//  TalentDialog.m
//  livestream_anchor
//
//  Created by Calvin on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "TalentDialog.h"
#import "DialogTip.h"
@interface TalentDialog ()
 
@property (strong) void (^declineBlock)();
@property (strong) void(^acceptBlock)();
@end

@implementation TalentDialog

+ (TalentDialog *)dialog {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    TalentDialog *view = [nibs objectAtIndex:0];
    
    view.tag = DialogTag;
    view.dialogView.layer.cornerRadius = 8;
    view.dialogView.layer.masksToBounds = YES;
    view.declineBtn.layer.cornerRadius = 4;
    view.acceptBtn.layer.cornerRadius = 4;
     return view;
}

- (void)setTalentName:(NSString *)name andRequestName:(NSString *)request
{
    NSString *requestStr = [NSString stringWithFormat:@"\"%@\"",request];
    NSString * str = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Talent_Msg"),name,requestStr];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[str rangeOfString:requestStr]];

    self.msgLabel.attributedText = attributedString;
}

- (void)showDialog:(UIView *)view declineBlock:(void(^)())declineBlock acceptBlock:(void(^)())acceptBlock {
    self.declineBlock = declineBlock;
    self.acceptBlock = acceptBlock;
 
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [view addSubview:self];
    
    //60s自动消失
    [self performSelector:@selector(hidenDialog) withObject:nil afterDelay:60];
}

- (IBAction)declineBtnDid:(UIButton *)sender {
    
    if( self.declineBlock ) {
        self.declineBlock();
    }
 
    [self removeFromSuperview];
}

- (IBAction)acceptBtnDid:(UIButton *)sender {
    
    if (!ZBAppDelegate.isNetwork) {
        [[DialogTip dialogTip]showDialogTip:ZBAppDelegate.window tipText:NSLocalizedStringFromSelf(@"Accepted_Failed")];
        return;
    }
    if( self.acceptBlock ) {
        self.acceptBlock();
    }
}

- (void)hidenDialog
{
     [self removeFromSuperview];
}

@end
