//
//  LSUITextFieldAlign.m
//  UIWidget
//
//  Created by Max on 2017/5/19.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSUITextFieldAlign.h"

@implementation LSUITextFieldAlign

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect leftRect = [super leftViewRectForBounds:bounds];
    leftRect.origin.x += 5;
    return leftRect;
}

@end
