//
//  ChatEmotionCreditsCollectionViewCell.m
//  dating
//
//  Created by test on 16/9/9.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatEmotionCreditsCollectionViewCell.h"

@interface ChatEmotionCreditsCollectionViewCell()
@end

@implementation ChatEmotionCreditsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.creditPrice.layer.cornerRadius = 8.0f;
    self.creditPrice.layer.masksToBounds = YES;
    self.creditPrice.layer.borderWidth = 1.0f;
    self.creditPrice.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.largeEmotionImageView.userInteractionEnabled = YES;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlerLongPress:)];
    [self addGestureRecognizer:longPress];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.creditPrice sizeToFit];
}

+ (NSString *)cellIdentifier {
    return @"ChatEmotionCreditsCollectionViewCell";
}

- (void)handlerLongPress:(UILongPressGestureRecognizer *)gesture {
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[@"gesture"] = gesture;
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"longPressGesture" object:nil userInfo:dict];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatEmotionCreditsCollectionViewCellDidLongPress:gesture:)]) {
        [self.delegate ChatEmotionCreditsCollectionViewCellDidLongPress:self gesture:gesture];
    }

}

@end
