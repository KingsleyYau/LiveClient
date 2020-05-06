//
//  LSTableView.m
//  UIWidget
//
//  Created by Randy_Fan on 2020/3/12.
//  Copyright © 2020 drcom. All rights reserved.
//

#import "LSTableView.h"

@implementation LSTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBarkModelBackgroundColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setBarkModelBackgroundColor];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self setBarkModelBackgroundColor];
}

- (void)setBarkModelBackgroundColor {
    if ([self backgroundColorIsEqualWhite:self.backgroundColor]) {
        if (@available(iOS 13.0, *)) {
            self.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            self.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (BOOL)backgroundColorIsEqualWhite:(UIColor *)backgroundColor {
    if (CGColorEqualToColor(backgroundColor.CGColor, [UIColor whiteColor].CGColor)) {
        return YES;
    } else {
        return NO;
    }
}

@end
