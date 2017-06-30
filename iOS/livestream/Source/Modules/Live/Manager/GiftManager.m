//
//  GiftManager.m
//  livestream
//
//  Created by randy on 17/6/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftManager.h"

@interface GiftManager()

@property (nonatomic, strong) GiftDownloaderManager *loaderManager;

@end

@implementation GiftManager

static  GiftManager* giftManager;

+ (instancetype)giftManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
       
        giftManager = [[GiftManager alloc]init];
        
        giftManager.giftArray = [[NSMutableArray alloc]init];
        giftManager.giftUrlArray = [[NSMutableArray alloc]init];
        giftManager.giftDic = [[NSMutableDictionary alloc]init];
        
    });
    
    return giftManager;
}

- (void)downloadGiftImage:(BOOL)isfirstLogin withImageUrl:(NSString *)url{
    
    self.loaderManager = [GiftDownloaderManager loadManager];
    
    [self.loaderManager downloadLiveGiftWithUrl:url];
}

- (UIImage *)imageGiftWithGiftId:(int)giftId andType:(GiftType)type {
    
    
    
    UIImage *image = [self.loaderManager imageGiftWithGiftType:type giftId:giftId];
    
    if (!image) {
        
        return image;
    }else{
        
        return nil;
    }
}

- (void)removeAllField {

    
}

@end
