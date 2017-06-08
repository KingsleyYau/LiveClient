//
//  UIImageViewBottomFit.m
//  UIWidget
//
//  Created by test on 16/6/26.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "UIImageViewBottomFit.h"

@implementation UIImageViewBottomFit

- (void)setImage:(UIImage *)image {
    UIImage *scaleImage = image;
    
    if( image != nil ) {
        // 缩放图片
        float scaleSize = self.frame.size.width / image.size.width;
        
        // 高大于宽
        if( image.size.height >= image.size.width ) {
            // 改变填充方式, 底部平铺
            self.contentMode = UIViewContentModeBottom;
            UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width, image.size.height * scaleSize));
            [image drawInRect:CGRectMake(0, 0, self.frame.size.width, image.size.height * scaleSize)];
            scaleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
        } else {
            
            // 改变填充方式, 平铺
            UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width, self.frame.size.height));
            [image drawInRect:CGRectMake(0, 0, self.frame.size.width , self.frame.size.height)];
            scaleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.contentMode = UIViewContentModeScaleAspectFill;

            
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
