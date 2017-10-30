//
//  LSUIWidgetBundle.m
//  UIWidget
//
//  Created by Max on 2017/10/13.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSUIWidgetBundle.h"
#import <UIKit/UIKit.h>

static NSBundle *gMainBundle = nil;
@implementation LSUIWidgetBundle
+ (void)setBundle:(NSBundle *)bundle {
    gMainBundle = bundle;
}

+ (NSBundle *)mainBundle {
    return gMainBundle;
}

+ (NSBundle *)resourceBundle {
    NSBundle *bundle = gMainBundle;
    if( !gMainBundle ) {
        bundle = [super mainBundle];
    }
    bundle = [NSBundle bundleWithPath:[[bundle resourcePath] stringByAppendingPathComponent:@"LSUIWidgetBundle.bundle"]];
    return bundle;
}
@end
