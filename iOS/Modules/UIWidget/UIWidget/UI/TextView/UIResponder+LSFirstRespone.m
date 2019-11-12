//
//  UIResponder+LSFirstRespone.m
//  UIWidget
//
//  Created by test on 2019/10/21.
//  Copyright © 2019 drcom. All rights reserved.
//

#import "UIResponder+LSFirstRespone.h"

static __weak id currentFirstResponder;
@implementation UIResponder (LSFirstRespone)
+ (id)lsKeyboardCurrentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(lsFindFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

- (void)lsFindFirstResponder:(id)sender {
    currentFirstResponder = self;
}
@end
