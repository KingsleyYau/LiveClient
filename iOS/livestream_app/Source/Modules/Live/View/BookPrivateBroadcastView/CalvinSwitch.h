//
//  CalvinSwitch.h
//  testDemo
//
//  Created by Calvin on 17/9/25.
//  Copyright © 2017年 dating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalvinSwitch : UIControl

@property (nonatomic, assign, getter = isOn) BOOL on;

@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *thumbTintColor;
@property (nonatomic, assign) NSInteger switchKnobSize;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;

@property (nonatomic, strong) NSString *onText;
@property (nonatomic, strong) NSString *offText;

- (id)initWithFrame:(CGRect)frame onColor:(UIColor *)onColor offColor:(UIColor *)offColor font:(UIFont *)font ballSize:(NSInteger )ballSize;

@end
