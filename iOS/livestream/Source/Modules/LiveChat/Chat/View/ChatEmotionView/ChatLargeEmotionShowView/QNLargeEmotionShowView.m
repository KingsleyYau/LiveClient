//
//  QNLargeEmotionShowView.m
//  dating
//
//  Created by test on 16/9/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNLargeEmotionShowView.h"

@interface QNLargeEmotionShowView()<GIFImageViewDelegate>

@end

@implementation QNLargeEmotionShowView
+ (instancetype)largeEmotionShowView {
    QNLargeEmotionShowView *largeEmotionshowView = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"QNLargeEmotionShowView" owner:self options:nil].firstObject;
    largeEmotionshowView.animationArray = nil;
    
    largeEmotionshowView.imageView.delegate = largeEmotionshowView;
    
    return largeEmotionshowView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

/*
- (void)reset {
    self.defaultImage = [UIImage imageNamed:@"LS_Chat_LargeEmotionDefault"];
    [self stop];
}

- (void)play {
    [self.imageView setImage:self.defaultImage];

    if (self.animationArray.count > 0 ) {
        self.loadingImageView.hidden = YES;
        
        UIImage* image = [self.animationArray objectAtIndex:0];
        [self.imageView setImage:image];
        self.imageView.animationImages = self.animationArray;
        self.imageView.animationDuration = 1.0f * self.animationArray.count / 6;
        self.imageView.animationRepeatCount = 0;
        
        if( ![self.imageView isAnimating] ) {
            [self.imageView startAnimating];
        }
        
    } else {
        self.imageView.animationImages = nil;
        [self stop];
        
        self.loadingImageView.hidden = NO;
        [self.activityView startAnimating];
    }
}

- (void)stop {
    [self.imageView stopAnimating];
    [self.imageView setImage:self.defaultImage];
}
*/

- (void)playGif:(NSString *)emotionPath
{
     [self getGif:self.animationArray path:emotionPath];
}

//根据数组播放GIF
- (void)getGif:(NSArray * )imgs path:(NSString *)path
{
    if (path.length > 0) {
        [self.imageView stopGIF];
        
        UIImage * defaultImg = self.defaultImage?self.defaultImage:[UIImage imageNamed:@"LS_Chat_LargeEmotionDefault"];
        [self.imageView setImage:imgs.count > 0?[imgs firstObject]:defaultImg];
        

        //生成完整GIF路径
        path = [NSString stringWithFormat:@"%@.gif",path];
        //判断本地是否有GIF，没有则创建
        if ([self locationGIF:path].length > 0) {
            self.imageView.gifPath = [self locationGIF:path];
        }
        else
        {
            self.loadingImageView.hidden = NO;
            if (!imgs) {
                return;
            }
            self.imageView.gifPath = [QNGIFImageView createGIFPath:path imageArray:imgs];
        }
        
        self.loadingImageView.hidden = NO;
        [self.imageView startGIF];
    }
}

//获取本地GIF路径
- (NSString *)locationGIF:(NSString *)gifPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:gifPath]) {
        return gifPath;
    }
    else {
        return @"";
    }
    return @"";
}

//gif动画开始播放
- (void)gifWillPlay
{
    //隐藏load状态
   self.loadingImageView.hidden = YES;
}

@end
