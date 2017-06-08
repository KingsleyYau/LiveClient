//
//  UIImage+UIImage_ResourcePath.m
//  DrPalm
//
//  Created by fgx_lion on 12-5-18.
//  Copyright (c) 2012年 DrCOM. All rights reserved.
//

#import "UIImage+ResourcePath.h"

typedef enum {
    SHOW_IMAGE_TYPE_UNDEFINE,
    SHOW_IMAGE_TYPE_NORMAL,
    SHOW_IMAGE_TYPE_2X,
}SHOW_IMAGE_TYPE;

@implementation UIImage (ResourcePath)
//+ (NSString*)changeNameWithScreen:(NSString*)name
//{
//    // 计算屏幕分辨率, 取得 image 类型
//    static SHOW_IMAGE_TYPE imageType = SHOW_IMAGE_TYPE_UNDEFINE;
//    if (SHOW_IMAGE_TYPE_UNDEFINE == imageType){
//        CGRect rect = [[UIScreen mainScreen] bounds];
//        CGFloat scale_screen = [UIScreen mainScreen].scale;
//        CGFloat screenHeight = rect.size.height * scale_screen;
//        if (960.0f == screenHeight){
//            imageType = SHOW_IMAGE_TYPE_2X;
//        }
//        else {
//            imageType = SHOW_IMAGE_TYPE_NORMAL;
//        }
//    }
//    
//    // 根据屏幕分辨率，改变文件名
//    NSString *sign = nil;
//    if (imageType == SHOW_IMAGE_TYPE_2X) {
//        sign = @"@2x.";
//    }
//    
//    // 更改文件名
//    NSMutableString *transName = [NSMutableString stringWithString:name];
//    if (imageType != SHOW_IMAGE_TYPE_NORMAL) {
//        NSRange range = [transName rangeOfString:@"." options:NSBackwardsSearch];
//        [transName replaceCharactersInRange:range withString:sign];
//    }
//    return transName;
//}

+ (UIImage*)imageNamedWithData:(NSString *)name
{
    return [UIImage imageWithContentsOfFile:name];
}
@end
