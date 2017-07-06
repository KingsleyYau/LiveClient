//
//  BigGiftAnimationView.h
//  livestream
//
//  Created by randy on 17/6/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BigGiftAnimationView : UIView

@property (nonatomic, strong)YYAnimatedImageView *carGiftView;

@property (nonatomic, strong)NSArray *webpPaths;

+ (instancetype)sharedObject;

+(void)attemptDealloc;

- (void)starAnimationWithGiftID:(NSString *)giftID;

@end
