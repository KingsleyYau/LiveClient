//
//  LSBLTextField.m
//  UIWidget
//
//  Created by Max on 2017/5/19.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSBLTextField.h"

//16进制颜色转换
#define COLOR_WITH_16BAND_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

@implementation LSBLTextField

- (void)awakeFromNib {
    [super awakeFromNib];

    self.clipsToBounds = NO;

    self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height + 2, self.frame.size.width, 1)];
    self.bottomLine.backgroundColor = [UIColor lightGrayColor];

    [self addSubview:self.bottomLine];

    [self addTarget:self action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.bottomLine.frame = CGRectMake(0, self.frame.size.height + 2, self.frame.size.width, 1);

    for (UIScrollView *view in self.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            CGPoint offset = view.contentOffset;
            if (offset.y != 0) {
                offset.y = 0;
                view.contentOffset = offset;
            }
            break;
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!textField.rightView) {
        self.bottomLine.backgroundColor = COLOR_WITH_16BAND_RGB(0x5d0e86);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!textField.rightView) {
        if (textField.text.length == 0) {
            self.bottomLine.backgroundColor = COLOR_WITH_16BAND_RGB(0x959595);
        }
    }

}

@end
