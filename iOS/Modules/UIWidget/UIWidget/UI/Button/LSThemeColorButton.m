//
//  LSThemeColorButton.m
//  UIWidget
//
//  Created by test on 2020/3/13.
//  Copyright © 2020 drcom. All rights reserved.
//

#import "LSThemeColorButton.h"

@implementation LSThemeColorButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDarkModelColor];
    }
    return self;
}



- (instancetype _Nonnull)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDarkModelColor];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setDarkModelColor];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setDarkModelColor];
}



- (void)setDarkModelColor {
    
    if (@available(iOS 13.0, *)) {
         self.backgroundColor = [UIColor systemBackgroundColor];
        self.titleLabel.textColor = [UIColor labelColor];
    }else {
        self.backgroundColor = [UIColor clearColor];
       self.titleLabel.textColor = [UIColor systemBlueColor];
    }
}

@end
