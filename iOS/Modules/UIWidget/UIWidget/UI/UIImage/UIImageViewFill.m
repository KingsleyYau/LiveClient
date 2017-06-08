//
//  UIImageViewFill.m
//  UIWidget
//
//  Created by test on 16/6/29.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "UIImageViewFill.h"

@implementation UIImageViewFill




- (void)setImage:(UIImage *)image {
    UIImage *scaleImage = image;
    // 改变填充方式
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    if( image != nil ) {       
        float viewScaleSize = self.frame.size.height / self.frame.size.width;
        float imageScaleSize = image.size.height / image.size.width;
        if ( image.size.height > image.size.width ) {
            // 高大于宽(纵向图片)
            if( viewScaleSize < imageScaleSize ) {
                // view的[高宽比]小于image[高宽比]
                // 裁剪图片
                CGRect clippedRect;
                // 裁剪图片
                if( image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight ) {
                    clippedRect = CGRectMake(0, 0, image.size.width * viewScaleSize, image.size.width);
                } else {
                    clippedRect = CGRectMake(0, 0, image.size.width, image.size.width * viewScaleSize);
                }
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
                scaleImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:image.imageOrientation];
                CGImageRelease(imageRef);
                
            } else {
                // view的[高宽比]大于image[高宽比]
                // 拉伸图片
                // 改变填充方式, 填满
                self.contentMode = UIViewContentModeScaleAspectFill;
            }
        } else {
            // 高小于宽(横向图片)
            // 改变填充方式, 填满
            self.contentMode = UIViewContentModeScaleAspectFill;
//            if( viewScaleSize < imageScaleSize ) {
//                // view的[高宽比]小于image[高宽比]
//                // 裁剪图片
//                CGRect clippedRect = CGRectMake(0, 0, image.size.width, image.size.width * viewScaleSize);
//                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
//                scaleImage = [UIImage imageWithCGImage:imageRef];
//                CGImageRelease(imageRef);
//
//            } else {
//                // view的[高宽比]大于image[高宽比]
//                // 改变填充方式, 填满
//                self.contentMode = UIViewContentModeScaleAspectFill;
//
//            }
        }
    }
    [super setImage:scaleImage];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if( self.image ) {
        [self setImage:self.image];
    }
}

@end
