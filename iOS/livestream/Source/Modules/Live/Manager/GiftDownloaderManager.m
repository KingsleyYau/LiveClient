//
//  GiftDownloaderManager.m
//  livestream
//
//  Created by randy on 17/6/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftDownloaderManager.h"
#import "GiftModel.h"

#define GiftDocLocalFilePath [NSString stringWithFormat:@"%@/%@/", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],@"Gift"]
#define LiveGiftArray @"LiveGiftArray"
#define GiftVersion   @"GiftVersion"

@interface GiftDownloaderManager()

@property (nonatomic, strong) NSString *listDocumentPath;
@property (nonatomic, strong) NSString *windowDocumentPath;
@property (nonatomic, strong) NSString *chatDocumentPath;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) NSArray *giftLists; // 礼物列表
@property (nonatomic, strong) NSMutableDictionary *imgGiftDict;  // 中等列表礼物
@property (nonatomic, strong) NSMutableDictionary *surGiftDict;  // 送出大礼物
@property (nonatomic, strong) NSMutableDictionary *chatGiftDict; // 聊天礼物图片

@end

@implementation GiftDownloaderManager

static GiftDownloaderManager *loadManager;

+ (instancetype)loadManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        loadManager = [[GiftDownloaderManager alloc] init];
        loadManager.isDownloading = NO;
        
        // 图片文件目录
        loadManager.listDocumentPath = [NSString stringWithFormat:@"%@%@", GiftDocLocalFilePath,@"img"];
        loadManager.windowDocumentPath = [NSString stringWithFormat:@"%@%@",GiftDocLocalFilePath,@"src"];
        loadManager.chatDocumentPath = [NSString stringWithFormat:@"%@%@",GiftDocLocalFilePath,@"chat"];
        
        // 初始化字典
        loadManager.imgGiftDict = [[NSMutableDictionary alloc] init];
        loadManager.surGiftDict = [[NSMutableDictionary alloc] init];
        loadManager.chatGiftDict = [[NSMutableDictionary alloc] init];
    });
    
    return loadManager;
}


- (void)saveImageToField:(NSArray *)imageList version:(NSInteger)version{
    
    self.giftLists = imageList;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger saveVersion = [defaults integerForKey:GiftVersion];
    
    if (saveVersion < version) {

        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:imageList];
        [defaults setObject:data forKey:LiveGiftArray];
        [defaults setInteger:version forKey:GiftVersion];
        [defaults synchronize];
       
        // 下载图片到本地
        [self downloadImage:imageList];
    }

}

+ (NSArray *)liveGifts {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:LiveGiftArray];
    NSArray *giftArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return giftArray;
}


#pragma mark - 下载网络图片到本地
- (void)downloadImage:(NSArray *)giftArray {
    
    // 删除本地缓存
    [self removeAllGiftPath];
    
    // 创建线程异步下载图片资源到本地
    for (GiftModel *gifModel in giftArray) {
        
        [NSThread detachNewThreadSelector:@selector(downloadLiveGiftWithUrl:) toTarget:self withObject:gifModel.imgurl];
        [NSThread detachNewThreadSelector:@selector(downloadLiveGiftWithUrl:) toTarget:self withObject:gifModel.srcurl];
    }
}

// 下载礼物图片
- (void)downloadLiveGiftWithUrl:(NSString *)imgUrl {
    
    NSArray *separateArray = [imgUrl componentsSeparatedByString:@"gift/"];
    if (separateArray.count != 2) {
        return;
    }
    
    NSArray *fileNameArray = [separateArray[1]  componentsSeparatedByString:@"?"];
    if (fileNameArray.count != 2) {
        return;
    }
    
    NSString *fileName = fileNameArray[0];
    NSString *folderName = @"list";
    
    if([fileName rangeOfString:@"/"].location != NSNotFound) {
        
        
        NSArray *filePathArray = [fileName  componentsSeparatedByString:@"/"];
        if (filePathArray.count != 2) {
            return;
        }
        folderName = filePathArray[0];
        fileName = filePathArray[1];
    }
    else {
        
        folderName = @"list";
    }
    
    NSArray *keyNameArray = [fileName componentsSeparatedByString:@"."];
    
    
    NSString *keyName = keyNameArray[0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@/",GiftDocLocalFilePath,folderName];
    
    NSString *pngPath = [NSString stringWithFormat:@"%@%@",filePath,fileName];
    
    // 创建文件目录，保存文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        
        [fileManager createDirectoryAtPath:filePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        NSLog(@"礼物保存路径：%@",filePath);
    }
    
    NSURL *url = [NSURL URLWithString:imgUrl];
    
    // 获取到图片的原始数据
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    
    BOOL result = [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    if (result) {
        
        NSLog(@"礼物图片保存成功");
    }
    else {
        NSLog(@"礼物图片保存失败");
    }

}

// 清除所有礼物图片缓存
- (void)removeAllGiftPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSArray *cacheFileNameArray = [fileManager contentsOfDirectoryAtPath:GiftDocLocalFilePath error:&error];
    
    NSEnumerator *e = [cacheFileNameArray objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        [fileManager removeItemAtPath:[GiftDocLocalFilePath stringByAppendingPathComponent:filename] error:NULL];
    }
}

- (UIImage *)imageGiftWithGiftType:(GiftType)type giftId:(int)giftId{
    
    UIImage *image = nil;
    NSString *giftIdStr = [NSString stringWithFormat:@"%d",giftId];
    
    if (type == GiftTypeList) {
        
        image = [self.imgGiftDict objectForKey:giftIdStr];
        if (!image) {
            // 保存图片到字典缓存
            NSString *fileNamePath = [NSString stringWithFormat:@"%@/%d.png", _listDocumentPath, giftId];
            image = [UIImage imageWithContentsOfFile:fileNamePath];
            if (image) {
                [self.imgGiftDict setObject:image forKey:giftIdStr];
            }
        }
        
    }else if (type == GiftTypeChat) {
        
        image = [self.chatGiftDict objectForKey:giftIdStr];
        if (!image) {
            NSString *fileNamePath = [NSString stringWithFormat:@"%@/%d.png",_chatDocumentPath, giftId];
            image = [UIImage imageWithContentsOfFile:fileNamePath];
            if (image) {
                [self.chatGiftDict setObject:image forKey:giftIdStr];
            }
        }
        
    }else if (type == GiftTypeWindow) {
        
        image = [self.surGiftDict objectForKey:giftIdStr];
        if (!image) {
            NSString *fileNamePath = [NSString stringWithFormat:@"%@/%d.png",_windowDocumentPath, giftId];
            image = [UIImage imageWithContentsOfFile:fileNamePath];
            if (image) {
                [self.surGiftDict setObject:image forKey:giftIdStr];
            }
        }
        
    }
    
    return image;
}

@end
