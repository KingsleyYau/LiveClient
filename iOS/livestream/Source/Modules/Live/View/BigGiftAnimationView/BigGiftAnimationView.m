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
            sharedInstance.downloadManager = [LiveGiftDownloadManager manager];
            sharedInstance.downloadManager.managerDelegate = sharedInstance;
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
//        self.carGiftView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
    }
    return self;
}

- (BOOL)starAnimationWithGiftID:(NSString *)giftID {
    
    BOOL isHaveImage = NO;
    
    NSString *filePath = [[LiveGiftDownloadManager manager] doCheckLocalGiftWithGiftID:giftID];
    NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    YYImage *image = [YYImage imageWithData:imageData];
    
    // 如果没文件再去下载或者下载不成功
    if (image == nil) {
        AllGiftItem *item = [self.downloadManager backGiftItemWithGiftID:giftID];
        // 删除本地文件
        [self.downloadManager deletWebpPath:giftID];
        [self.downloadManager afnDownLoadFileWith:giftID giftItem:item];
        
        isHaveImage = NO;
    }else{
        
        self.carGiftView.contentMode = UIViewContentModeScaleAspectFit;
        self.carGiftView.image = image;
        [self addSubview:self.carGiftView];
        [self.carGiftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@SCREEN_HEIGHT);
        }];
        
        isHaveImage = YES;
    }
    
    return isHaveImage;
}

- (UIImage *)carWebPImage{
    
    if (!_carWebPImage) {
        
        _carWebPImage = [YYImage imageNamed:@"gift"];
    }
    return _carWebPImage;
}

@end
