//
//  BigGiftAnimationView.m
//  livestream
//
//  Created by randy on 17/6/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BigGiftAnimationView.h"

@interface BigGiftAnimationView()


@property (nonatomic, strong)UIImage *carWebPImage;

@end

@implementation BigGiftAnimationView
static BigGiftAnimationView *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedObject{
    dispatch_once(&onceToken, ^(void){
        if (sharedInstance == nil) {
            sharedInstance = [[BigGiftAnimationView alloc] init];
            [sharedInstance carWebPImage];
        }
        
    });
    return sharedInstance;
}

+(void)attemptDealloc{
    onceToken = 0;
    sharedInstance = nil;
}


- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.carGiftView = [[YYAnimatedImageView alloc]init];
        CGFloat lh = 453 / (360 / SCREEN_WIDTH);
        CGFloat ly = (SCREEN_HEIGHT - lh) * 0.5;
        self.carGiftView.frame = CGRectMake(0, ly, SCREEN_WIDTH, lh);
        
    }
    return self;
}

- (void)starAnimation{
    
    NSLog(@"Bool%d",YYImageWebPAvailable());
    
    YYImage *image = [YYImage imageNamed:@"gift"];
    self.carGiftView.image = image;
    [self addSubview:self.carGiftView];
}

- (UIImage *)carWebPImage{
    
    if (!_carWebPImage) {
        
        _carWebPImage = [YYImage imageNamed:@"gift"];
    }
    return _carWebPImage;
}

@end
