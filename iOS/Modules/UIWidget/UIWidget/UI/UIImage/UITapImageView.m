//
//  UITapImageView.h
//  huotun
//
//  Created by HEYANG on 16/4/21.
//  Copyright © 2016年 YUEMAO. All rights reserved.
//

#import "UITapImageView.h"

@interface  UITapImageView ()

@property (nonatomic, copy) void(^tapAction)(id);

@end

@implementation UITapImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)tap{
    if (self.tapAction) {
        self.tapAction(self);
    }
}
- (void)addTapBlock:(void(^)(id obj))tapAction{
    self.tapAction = tapAction;
    // hy:先判断当前是否有交互事件，如果没有的话。。。所有gesture的交互事件都会被添加进gestureRecognizers中
    if (![self gestureRecognizers]) {
        self.userInteractionEnabled = YES;
        // hy:添加单击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
}

//// 这个后期需要更新一下这个方法，因为这个方法和SDWebImage高度耦合了。思路：可以通过block将sd_setImage公开出去
//-(void)setImageWithUrl:(NSURL *)imgUrl placeholderImage:(UIImage *)placeholderImage tapBlock:(void(^)(id obj))tapAction{
//    [self sd_setImageWithURL:imgUrl placeholderImage:placeholderImage];
//    [self addTapBlock:tapAction];
//}

@end
