//
//  UIScreen+DPI.m
//  UIWidget
//
//  Created by KingsleyYau on 13-12-17.
//  Copyright (c) 2013年 drcom. All rights reserved.
//

#import "UIScreen+DPI.h"

@implementation UIScreen(DPI)
+ (CGFloat)deviceDPI {
    float scale = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    float dpi = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        dpi = 132 * scale;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        dpi = 163 * scale;
    } else {
        dpi = 160 * scale;  
    }
    return dpi;
}
@end
