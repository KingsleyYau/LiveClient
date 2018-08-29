//
//  DialogChoose.m
//  livestream
//
//  Created by Max on 2017/9/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DialogChoose.h"
#import "LiveBundle.h"

@interface DialogChoose ()
@property (weak) UIView* view;
@property (weak) UIButton *backBtn;
@property (strong) void(^cancelBlock)();
@property (strong) void(^actionBlock)();
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noBtnTop;

@end

@implementation DialogChoose
+ (DialogChoose *)dialog {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    DialogChoose* view = [nibs objectAtIndex:0];
    
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.tag = DialogTag;
    view.checkBox.onAnimationType = BEMAnimationTypeBounce;
    view.checkBox.offAnimationType = BEMAnimationTypeBounce;
    view.checkBox.boxType = BEMBoxTypeSquare;
    view.checkBox.tintColor = [UIColor lightGrayColor];
    view.checkBox.onTintColor = Color(29, 239, 232, 1.0);//[UIColor greenColor];
    view.checkBox.onFillColor = Color(29, 239, 232, 1.0);//[UIColor greenColor];
    view.checkBox.onCheckColor = [UIColor whiteColor];
    view.checkBox.animationDuration = 0.3;
    
    view.okButton.layer.cornerRadius = 10;
    view.cancelButton.layer.cornerRadius = 10;
    
    return view;
}

- (void)hiddenCheckView {
    self.checkBox.hidden = YES;
    self.checkLabel.hidden = YES;
    self.noBtnTop.constant = -16;
}

- (void)showDialog:(UIView *)view cancelBlock:(void(^)())cancelBlock actionBlock:(void(^)())actionBlock {
    self.cancelBlock = cancelBlock;
    self.actionBlock = actionBlock;
    
//    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//    [window addSubview:self];
//    [window bringSubviewToFront:self];
//
//    self.view = view;
//    self.view.userInteractionEnabled = NO;
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setBackgroundColor:COLOR_WITH_16BAND_RGB_ALPHA(0x66000000)];
    self.backBtn = btn;
    [view addSubview:self.backBtn];
    [view bringSubviewToFront:self.backBtn];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(view.mas_width).offset(-60);
            make.centerY.equalTo(view.mas_centerY);
            make.centerX.equalTo(view);
        }];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
        
        [self sizeToFit];
    }
}

- (IBAction)cancelCancel:(id)sender {
    if( self.cancelBlock ) {
        self.cancelBlock();
    }
    [self.backBtn removeFromSuperview];
    [self removeFromSuperview];
//    self.view.userInteractionEnabled = YES;
}

- (IBAction)actionOK:(id)sender {
    if( self.actionBlock ) {
        self.actionBlock();
    }
    [self.backBtn removeFromSuperview];
    [self removeFromSuperview];
//    self.view.userInteractionEnabled = YES;
}

@end
