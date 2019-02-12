//
//  ChatHighGradeEmotion.m
//  dating
//
//  Created by Max on 16/10/13.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatHighGradeEmotion.h"

@implementation QNChatHighGradeEmotion

- (NSString *)priceText {
    return [NSString stringWithFormat:@"%.1f", self.emotionItemObject.price];
}

- (UIImage *)image {
    UIImage* image = nil;
    
    NSData *data = [NSData dataWithContentsOfFile:self.liveChatEmotionItemObject.imagePath];
    image = [UIImage imageWithData:data];
    
    return image;
}

@end
