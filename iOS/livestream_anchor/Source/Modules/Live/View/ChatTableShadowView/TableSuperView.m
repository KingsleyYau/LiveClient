//
//  TableSuperView.m
//  livestream
//
//  Created by randy on 2017/7/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TableSuperView.h"

@implementation TableSuperView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    NSArray *colors = [NSArray arrayWithObjects:
                       (id)[[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor,
                       (id)[[UIColor blackColor] CGColor],nil];
    [gradientLayer setColors:colors];
    gradientLayer.locations = @[@0,@0.2,@0.8];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 0.2);
    [gradientLayer setFrame:self.bounds];
    self.layer.mask = gradientLayer;
}

@end
