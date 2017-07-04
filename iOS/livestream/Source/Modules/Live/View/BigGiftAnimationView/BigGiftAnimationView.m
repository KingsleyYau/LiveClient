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
        self.carGiftView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
    }
    return self;
}

- (void)starAnimationWithImageData:(NSData *)imageData {
    
    NSLog(@"Bool%d",YYImageWebPAvailable());
    
    YYImage *image = [YYImage imageWithData:imageData];
    self.carGiftView.contentMode = UIViewContentModeScaleAspectFit;
    self.carGiftView.image = image;
//    [self.carGiftView sizeToFit];
    [self addSubview:self.carGiftView];
}

- (UIImage *)carWebPImage{
    
    if (!_carWebPImage) {
        
        _carWebPImage = [YYImage imageNamed:@"gift"];
    }
    return _carWebPImage;
}

@end
