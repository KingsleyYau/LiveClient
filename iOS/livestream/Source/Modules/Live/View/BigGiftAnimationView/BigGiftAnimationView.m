//
//  BigGiftAnimationView.m
//  livestream
//
//  Created by randy on 17/6/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BigGiftAnimationView.h"
#import "LiveGiftDownloadManager.h"

@interface BigGiftAnimationView()<LiveGiftDownloadManagerDelegate>

@property (nonatomic, strong)UIImage *carWebPImage;
@property (nonatomic, strong) LiveGiftDownloadManager *downloadManager;

@end

@implementation BigGiftAnimationView
static BigGiftAnimationView *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedObject{
    dispatch_once(&onceToken, ^(void){
        if (sharedInstance == nil) {
            sharedInstance = [[BigGiftAnimationView alloc] init];
            [sharedInstance carWebPImage];
            sharedInstance.downloadManager = [LiveGiftDownloadManager giftDownloadManager];
            sharedInstance.downloadManager.managerDelegate = self;
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

- (void)starAnimationWithGiftID:(NSString *)giftID {
    
    NSString *filePath = [[LiveGiftDownloadManager giftDownloadManager]doCheckLocalGiftWithGiftID:giftID];
    NSData *imageData = [[NSFileManager defaultManager]contentsAtPath:filePath];
    
    // 如果没文件再去下载
    if (imageData == nil) {
        LiveRoomGiftItemObject *item = [self.downloadManager backGiftItemWithGiftID:giftID];
        [self.downloadManager  afnDownLoadFileWith:item.srcUrl giftId:giftID];
        
    }else{
        
        YYImage *image = [YYImage imageWithData:imageData];
        self.carGiftView.contentMode = UIViewContentModeScaleAspectFit;
        self.carGiftView.image = image;
        [self addSubview:self.carGiftView];
    }
}

- (void)downLoadWasCompleteWithGiftId:(NSString *)giftId{
    
    NSString *filePath = [[LiveGiftDownloadManager giftDownloadManager]doCheckLocalGiftWithGiftID:giftId];
    NSData *imageData = [[NSFileManager defaultManager]contentsAtPath:filePath];
    YYImage *image = [YYImage imageWithData:imageData];
    self.carGiftView.contentMode = UIViewContentModeScaleAspectFit;
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
