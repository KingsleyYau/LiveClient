//
//  MeLevelView.m
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MeLevelView.h"

@implementation MeLevelView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    WKWebViewConfiguration *myConfiguration = [[WKWebViewConfiguration alloc] init];
    
    
    myConfiguration.preferences.minimumFontSize = 10;
    
    myConfiguration.preferences.javaScriptEnabled = YES;
    
    self = [super initWithFrame:frame configuration:myConfiguration];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}


@end
