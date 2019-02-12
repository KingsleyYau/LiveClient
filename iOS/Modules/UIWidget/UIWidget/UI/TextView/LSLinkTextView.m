//
//  LinkTextView.m
//  UIWidget
//
//  Created by test on 2017/5/2.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSLinkTextView.h"

@implementation LSLinkTextView

/**
 UITextView文字超链接
 
 @param allStr 整个字符串
 @param changeStr 需要更改为超链接的部分字符
 @param changeStrColor 超链接字符颜色
 @param style 超链接字符的样式
 @return 返回的字符串
 */
+ (NSMutableAttributedString *)AllString:(NSString *)allStr ChangeString:(NSString *)changeStr ChangeStrColor:(UIColor *)changeStrColor StrStyle:(NSInteger)style font:(UIFont* )font{
    
    NSString *str = [NSString stringWithFormat:@"%@", allStr];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str]; // assume string exists
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    paragraphStyle.lineSpacing = 4;
    NSRange urlRange = [str rangeOfString:changeStr];
    [string addAttribute:NSLinkAttributeName
                   value:changeStr
                   range:urlRange];
    [string addAttribute:NSForegroundColorAttributeName
                   value:changeStrColor
                   range:urlRange];
    [string addAttribute:NSUnderlineStyleAttributeName
                   value:@(style)
                   range:urlRange];
    
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    
    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    [string endEditing];
    

    
    return string;
    
}


@end
