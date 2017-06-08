//
//  AnimationImageView.m
//  UIWidget
//
//  Created by test on 16/9/23.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "AnimationImageView.h"

@implementation AnimationImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)layoutSubviews {
    [super layoutSubviews];

}

- (void)imageAnimation {
    if (self.animationImageArray.count > 0) {
        NSMutableArray *imageArray = [NSMutableArray array];
            for (NSString *path  in self.animationImageArray) {
                NSData *data = [NSData dataWithContentsOfFile:path];
                UIImage *image= [UIImage imageWithData:data];
                //            UIImage *image = [UIImage imageWithContentsOfFile:path];
//                UIImage *image = [UIImage imageNamed:path];
                [imageArray addObject:image];
            }
        self.animationImages = imageArray;
        self.animationDuration = 2.0f;
        self.animationRepeatCount = MAXFLOAT;
        [self startAnimating];
        
        
    } else {
        [self stopAnimating];
        self.animationImages = [NSMutableArray array];
        
    }
}

@end
