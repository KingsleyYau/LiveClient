//
//  UITapImageView.h
//  huotun
//
//  Created by HEYANG on 16/4/21.
//  Copyright © 2016年 YUEMAO. All rights reserved.
//

// 功能：为图片添加点击事件，block中封装的是事件的内容

#import <UIKit/UIKit.h>

@interface UITapImageView : UIImageView

- (void)addTapBlock:(void(^)(id obj))tapAction;

//-(void)setImageWithUrl:(NSURL *)imgUrl placeholderImage:(UIImage *)placeholderImage tapBlock:(void(^)(id obj))tapAction;
@end
