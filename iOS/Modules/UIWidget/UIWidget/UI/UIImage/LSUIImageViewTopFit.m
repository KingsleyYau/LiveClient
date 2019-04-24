//
//  UIImageViewTopFit.m
//  UIWidget
//
//  Created by Max on 16/6/23.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "LSUIImageViewTopFit.h"

@implementation LSUIImageViewTopFit

- (void)setImage:(UIImage *)image {
    UIImage *scaleImage = image;

    // 改变填充方式, 等比全显示
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (image != nil) {
        // 计算高宽比
        float viewScaleSize = self.frame.size.height / self.frame.size.width;
        float imageScaleSize = image.size.height / image.size.width;

        if (image.size.height > image.size.width) {
            // 高大于宽(纵向图片)
            if (viewScaleSize < imageScaleSize) {
                // view的[高宽比]小于image[高宽比]
                CGRect clippedRect;
                // 裁剪图片
                if (image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight) {
                    clippedRect = CGRectMake(0, 0, image.size.width * viewScaleSize, image.size.width);
                } else {
                    clippedRect = CGRectMake(0, 0, image.size.width, image.size.width * viewScaleSize);
                }
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
                scaleImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:image.imageOrientation];
                CGImageRelease(imageRef);

            } else {
                // view的[高宽比]大于image[高宽比]
                // 改变填充方式, 填满
                self.contentMode = UIViewContentModeScaleAspectFill;
            }


        } else {
            // 高小于宽(横向图片)
            if (viewScaleSize < imageScaleSize) {
                // 如果图片是等比例
                if (imageScaleSize == 1) {
                    self.contentMode = UIViewContentModeScaleAspectFit;
                    scaleImage = [self imageCompressFitSizeScale:image targetSize:self.frame.size];

                }else {
                    // view的[高宽比]小于image[高宽比]
                    CGRect clippedRect;
                    // 裁剪图片
                    if (image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight) {
                        clippedRect = CGRectMake(0, 0, image.size.width * viewScaleSize, image.size.width);
                    } else {
                        clippedRect = CGRectMake(0, 0, image.size.width, image.size.width * viewScaleSize);
                    }
                    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
                    scaleImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:image.imageOrientation];
                    CGImageRelease(imageRef);
                }
            } else {
                self.contentMode = UIViewContentModeScaleAspectFill;
            }
        }
    }

    [super setImage:scaleImage];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

// 从顶部开始缩放图片
- (UIImage *) imageCompressFitSizeScale:(UIImage *)sourceImage targetSize:(CGSize)size{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }
        
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            if (scaledHeight > targetHeight) {
                thumbnailPoint.y = 0;
            }else {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            }
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(size, 0, 1);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end
