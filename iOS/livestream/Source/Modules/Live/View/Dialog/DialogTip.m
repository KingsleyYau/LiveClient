//
//  DialogTip.m
//  livestream
//
//  Created by randy on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DialogTip.h"
@interface DialogTip ()
@property (strong) UIView* view;
@end


@implementation DialogTip

+ (DialogTip *)dialogTip{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    DialogTip* view = [nibs objectAtIndex:0];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.isShow = NO;
    return view;
}


- (void)showDialogTip:(UIView *)view tipText:(NSString *)tip {
    self.view = view;
    self.tipsLabel.text = tip;
//    self.view.userInteractionEnabled = NO;
    UIWindow* window = AppDelegate().window;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(window.mas_width).offset(-DESGIN_TRANSFORM_3X(100));
        make.centerY.equalTo(window.mas_centerY);
        make.centerX.equalTo(window);
    }];
    
    [self sizeToFit];
    
    self.isShow = YES;
    
    [self performSelector:@selector(removeShow) withObject:nil afterDelay:3.0];
}

- (void)removeShow {
    self.isShow = NO;
    [self removeFromSuperview];
//    self.view.userInteractionEnabled = YES;
}

@end
