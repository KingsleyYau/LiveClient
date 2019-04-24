//
//  LSShadowView.m
//  livestream
//
//  Created by Calvin on 2019/1/5.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSShadowView.h"

@interface LSShadowView ()
@property (nonatomic, strong) UIView * shadowView;
@property (nonatomic, weak) UIView * radiusView;
@end

@implementation LSShadowView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.shadowColor = [UIColor blackColor];
        self.shadowOpacity = 0.3;
        self.shadowRadius = 3;
    }
    return self;
}

- (void)showShadowAddView:(UIView*)view {
    self.radiusView = view;
    [view.superview insertSubview:self belowSubview:view];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    self.layer.cornerRadius = view.layer.cornerRadius;
    self.layer.shadowColor = self.shadowColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = self.shadowOpacity;
    self.layer.shadowRadius = self.shadowRadius;
    
     [self.radiusView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.radiusView removeObserver:self forKeyPath:@"hidden"];
}

- (void)dealloc {
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UIView * view = (UIView *)object;
    if (view == self.radiusView && [@"hidden" isEqualToString:keyPath]) {
        self.hidden = view.hidden;
    }
}

@end
