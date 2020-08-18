//
//  LSTipsDialogView.m
//  livestream
//
//  Created by Albert on 2020/8/7.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSTipsDialogView.h"
#import "LiveBundle.h"

@interface LSTipsDialogView ()

@property (weak) UIView *view;

@property (nonatomic, assign) BOOL isShow;

@end

@implementation LSTipsDialogView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (LSTipsDialogView *)tipsDialogView {

    static LSTipsDialogView *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
        view = [nibs objectAtIndex:0];
        //view.layer.cornerRadius = 5;
        //view.layer.masksToBounds = YES;
        //view 阴影
        view.layer.shadowRadius = 5.f;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeZero;
        view.layer.shadowOpacity = 0.27;    //阴影的不透明度
        
        view.bgView.layer.masksToBounds = YES;
        view.bgView.layer.cornerRadius = 5.f;
        
        view.tag = 9;
        view.isShow = NO;
    });
    return view;
}

- (void)showDialogTip:(UIView *)view tipText:(NSString *)tip {
    if (self.isShow) {
        [self removeShow];
    }
    
    self.titleLabel.text = tip;
    [self.titleLabel setFont:[UIFont fontWithName:@"ArialMT" size:16]];
    
    [view addSubview:self];
    [view bringSubviewToFront:self];

    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view.mas_centerY);
            make.centerX.equalTo(view);
            make.width.equalTo(@261);
            make.height.equalTo(@94);
        }];
        
        self.isShow = YES;
        
        [self sizeToFit];
        [self performSelector:@selector(removeShow) withObject:nil afterDelay:3.0];
    }
}

- (void)removeShow {
    self.isShow = NO;
    [self removeFromSuperview];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
