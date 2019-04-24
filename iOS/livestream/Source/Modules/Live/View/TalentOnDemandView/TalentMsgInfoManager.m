//
//  TalentMsgInfoManager.m
//  testApp
//
//  Created by Calvin on 2018/5/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "TalentMsgInfoManager.h"
#import "LSImageViewLoader.h"
@implementation TalentMsgInfoManager

+ (NSMutableAttributedString *)showImageString:(NSString *)name AndTitle:(NSString *)str andTitleFont:(UIFont*)font inMaxWidth:(CGFloat)width giftImage:(NSString *)url isShowGift:(BOOL)isShow
{
    if ([TalentMsgInfoManager isOverTheScreen:str titleFont:font inMaxWidth:width]) {
        str = [TalentMsgInfoManager showImageString:name andTitle:str andTitleFont:font inMaxWidth:width];
    }
 
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    if (isShow) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [[LSImageViewLoader loader] loadImageWithImageView:imageView options:0 imageUrl:url placeholderImage:
         [UIImage imageNamed:@"Live_Publish_Btn_Gift"] finishHandler:nil];
        
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = imageView.image;
        attch.bounds = CGRectMake(10, -5, 20, 20);
        
        NSAttributedString *attachmentAttrStr = [NSAttributedString attributedStringWithAttachment:attch];
        // 将转换成属性字符串插入到目标字符串
        [attrStr insertAttributedString:attachmentAttrStr atIndex:str.length];
    }
    return attrStr;
}

+(NSMutableAttributedString *)showTitleString:(NSString *)title Andunderline:(NSString *)str
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:title];
    [attrStr setAttributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}
                     range:[title rangeOfString:str]];
    return attrStr;
}

+ (NSMutableAttributedString *)showUnderlineString:(NSString *)name AndTitle:(NSString *)str andTitleFont:(UIFont*)font inMaxWidth:(CGFloat)width
{
    if ([TalentMsgInfoManager isOverTheScreen:str titleFont:font inMaxWidth:width]) {
        str = [TalentMsgInfoManager showString:name andTitle:str andTitleFont:font inMaxWidth:width];
    }
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attrStr setAttributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}
                     range:[str rangeOfString:@"Details"]];
    return attrStr;
}

+ (NSString *)showImageString:(NSString *)name andTitle:(NSString *)str andTitleFont:(UIFont*)font inMaxWidth:(CGFloat)width {
    
    NSString * newName = name;
    for (int i = 1; i < name.length; i++) {
        newName = [newName substringToIndex:name.length- i];
        str = [NSString stringWithFormat:@"This show requires a \"%@\"",newName];
        if ([TalentMsgInfoManager isOverTheScreen:str titleFont:font inMaxWidth:width]) {
            continue;
        }
        else
        {
            NSMutableString * num = [[NSMutableString alloc]initWithString:newName];
            [num replaceCharactersInRange:NSMakeRange(newName.length-3, 3)  withString:@"..."];
            str = [NSString stringWithFormat:@"This show requires a \"%@\"",num];
            break;
        }
    }
    return str;
}

+ (NSString *)showString:(NSString *)name andTitle:(NSString *)str andTitleFont:(UIFont*)font inMaxWidth:(CGFloat)width {
    
    NSString * newName = name;
    for (int i = 1; i < name.length; i++) {
        newName = [newName substringToIndex:name.length- i];
        str = [NSString stringWithFormat:@"You will use 0.3 credits to buy \"%@\". Details",newName];
        if ([TalentMsgInfoManager isOverTheScreen:str titleFont:font inMaxWidth:width]) {
            continue;
        }
        else
        {
            NSMutableString * num = [[NSMutableString alloc]initWithString:newName];
            [num replaceCharactersInRange:NSMakeRange(newName.length-3, 3)  withString:@"..."];
            str = [NSString stringWithFormat:@"You will use 0.3 credits to buy \"%@\". Details",num];
            break;
        }
    }
    return str;
}

+ (BOOL)isOverTheScreen:(NSString *)str titleFont:(UIFont *)font inMaxWidth:(CGFloat)width{

    CGSize size = [str sizeWithAttributes:@{NSFontAttributeName:font}];
    BOOL isOver = NO;
    if (size.width > width) {
        isOver = YES;
    }else
    {
        isOver = NO;
    }
    return isOver;
}


@end
