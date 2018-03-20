//
//  BigGiftAnimationView.m
//  livestream
//
//  Created by randy on 17/6/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BigGiftAnimationView.h"

@interface BigGiftAnimationView()

@end

@implementation BigGiftAnimationView
static BigGiftAnimationView *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedObject{
    dispatch_once(&onceToken, ^(void){
        if (sharedInstance == nil) {
            sharedInstance = [[BigGiftAnimationView alloc] init];
        }
        
    });
    return sharedInstance;
}


@end
