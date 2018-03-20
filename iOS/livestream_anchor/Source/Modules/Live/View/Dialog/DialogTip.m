//
//  DialogTip.m
//  livestream
//
//  Created by randy on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DialogTip.h"
#import "LiveBundle.h"

@interface DialogTip ()
@property (weak) UIView *view;
@end

@implementation DialogTip

+ (DialogTip *)dialogTip {

    static DialogTip *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
        view = [nibs objectAtIndex:0];
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = YES;
        view.tag = DialogTag;
        view.isShow = NO;
    });
    return view;
}

- (void)showDialogTip:(UIView *)view tipText:(NSString *)tip {
    if (self.isShow) {
        [self removeShow];
    }

//    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//    self.view = view;
    self.tipsLabel.text = tip;
    //    self.view.userInteractionEnabled = NO;
    [view addSubview:self];
    [view bringSubviewToFront:self];

    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(view.mas_width).offset(-DESGIN_TRANSFORM_3X(100));
        make.centerY.equalTo(view.mas_centerY);
        make.centerX.equalTo(view);
    }];

    self.isShow = YES;

    [self sizeToFit];
    [self performSelector:@selector(removeShow) withObject:nil afterDelay:3.0];
}

- (void)removeShow {
    self.isShow = NO;
    [self removeFromSuperview];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //    self.view.userInteractionEnabled = YES;
}

@end
