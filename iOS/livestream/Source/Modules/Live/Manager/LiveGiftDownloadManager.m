//
//  LiveGiftDownloadManager.m
//  livestream
//
//  Created by randy on 2017/6/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveGiftDownloadManager.h"
#import "LoginManager.h"
#import "AFNetWorkHelpr.h"
#import "FileCacheManager.h"
#import "ImageViewLoader.h"

@interface LiveGiftDownloadManager ()<LoginManagerDelegate>

@property (nonatomic, strong) LoginManager* loginManager;

// 礼物对象数组
@property (nonatomic, strong) NSMutableArray *giftMuArray;

@property (nonatomic, strong) NSMutableDictionary *fileNameDictionary;

@property (nonatomic, strong) NSMutableArray *pathMutableArray;

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@end

@implementation LiveGiftDownloadManager

+ (instancetype)giftDownloadManager{
    
    static LiveGiftDownloadManager *giftDownloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        giftDownloadManager = [[LiveGiftDownloadManager alloc]init];
    });
    
    return giftDownloadManager;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
     
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
        
        self.sessionManager = [SessionRequestManager manager];
        
        self.pathMutableArray = [[NSMutableArray alloc]init];
    }
    return self;
}


// 监听登录回调
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSInteger)errnum errmsg:(NSString *)errmsg{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (success) {
            
            // 请求礼物列表
            [self GetLiveRoomAllGiftListRequest];
        }

    });
}

// 请求礼物列表
- (void)GetLiveRoomAllGiftListRequest{
    
    GetLiveRoomAllGiftListRequest *request = [[GetLiveRoomAllGiftListRequest alloc]init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomGiftItemObject *> * _Nullable array) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                
                [self.giftMuArray removeAllObjects];
                
                if (array != nil && array.count ) {
                    self.giftMuArray = [array copy];
                    
                    // 下载大礼物动画
                    [self downLoadSrcImage];
                }
                
            }else{
                
                NSLog(@"GetLiveRoomAllGiftListRequest ErrNum:%ld ErrMsg%@",(long)errnum,errmsg);
            }
            
        });
        
    };
    
    [self.sessionManager sendRequest:request];
}

// 下载聊天列表礼物图
- (void)downLoadSmallImageWithUrl:(NSString *)url{

    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (error) {
            
            NSLog(@"SDWebImageLoadError:%@",error);
        }
        
        if (image) {
            
            
        }
        
    }];
}

// 下载礼物列表展示图
- (void)downLoadListImageWithUrl:(NSString *)url{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
       
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (error) {
            
            NSLog(@"SDWebImageLoadError:%@",error);
        }
        
        if (image) {
            
            
        }
        
    }];
}

// 下载大礼物动画文件
- (void)downLoadSrcImage{
        
        for (LiveRoomGiftItemObject *giftItem in self.giftMuArray) {
            
            LiveRoomGiftItemObject *item = [[LiveRoomGiftItemObject alloc]init];
            item.giftId = giftItem.giftId;
            item.name = giftItem.name;
            item.smallImgUrl = giftItem.smallImgUrl;
            item.imgUrl = giftItem.imgUrl;
            item.srcUrl = giftItem.srcUrl;
            item.coins = giftItem.coins;
            item.multi_click = giftItem.multi_click;
            item.type = giftItem.type;
            item.update_time = giftItem.update_time;
            
            if (!giftItem.multi_click) {
                
                // 下载webp文件
                self.path = [[FileCacheManager manager] bigGiftCachePathWithGiftId:item.giftId];
                [self afnDownLoadFileWith:item.srcUrl path:self.path];
            }
            
            [self downLoadListImageWithUrl:item.imgUrl];
            
            [self downLoadSmallImageWithUrl:item.smallImgUrl];
        }
}

// 下载大礼物webp文件
- (void)afnDownLoadFileWith:(NSString *)fileUrl path:(NSString *)path {
    NSURL* url = [NSURL URLWithString:fileUrl];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [[AFNetWorkHelpr shareInstrue].manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSURL* documentsDirectoryURL = nil;
        if( path ) {
            documentsDirectoryURL = [NSURL fileURLWithPath:path];
        }
        return documentsDirectoryURL;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if( [response isKindOfClass:[NSHTTPURLResponse class]] ) {
            if( error == nil && ((NSHTTPURLResponse* )response).statusCode == 200 ) {
                
                NSString *fileName = [filePath lastPathComponent];
                NSLog(@"LiveGiftDownloadManager::afnDownLoadFileWith( WebP fileName : %@ )", fileName);
            }
        }
        
    }];
    
    // 开始下载
    [downloadTask resume];
}


// 根据礼物id拿到webP文件
- (NSData *)doCheckLocalGiftWithGiftID:(NSString *)giftId{
    
    NSData *fileData = nil;
    NSString *filePath = [[FileCacheManager manager] bigGiftCachePathWithGiftId:giftId];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    fileData = [self.fileNameDictionary objectForKey:giftId];
    
    if (!fileData) {
        fileData = [fileManager contentsAtPath:filePath];
        
        if (fileData) {
            [self.fileNameDictionary setObject:fileData forKey:giftId];
        }
    }
    
    return fileData;
}

// 根据礼物id拿到礼物model
- (LiveRoomGiftItemObject *)backGiftItemWithGiftID:(NSString *)giftId{
    
    LiveRoomGiftItemObject *item = [[LiveRoomGiftItemObject alloc]init];
    
    if (self.giftMuArray != 0) {
        
        for (LiveRoomGiftItemObject *giftItem in self.giftMuArray) {
            
            if ([giftItem.giftId isEqualToString:giftId]) {
                
                item.giftId = giftItem.giftId;
                item.name = giftItem.name;
                item.smallImgUrl = giftItem.smallImgUrl;
                item.imgUrl = giftItem.imgUrl;
                item.srcUrl = giftItem.srcUrl;
                item.coins = giftItem.coins;
                item.multi_click = giftItem.multi_click;
                item.type = giftItem.type;
                item.update_time = giftItem.update_time;
                
                return item;
            }
        }
    }
    
    return nil;
}

// 根据礼物id拿到礼物model
- (NSString *)backSmallImgUrlWithGiftID:(NSString *)giftId{
    
    LiveRoomGiftItemObject *item = [[LiveRoomGiftItemObject alloc]init];
    
    if (self.giftMuArray != 0) {
        
        for (LiveRoomGiftItemObject *giftItem in self.giftMuArray) {
            
            if ([giftItem.giftId isEqualToString:giftId]) {
                
                item.giftId = giftItem.giftId;
                item.name = giftItem.name;
                item.smallImgUrl = giftItem.smallImgUrl;
                item.imgUrl = giftItem.imgUrl;
                item.srcUrl = giftItem.srcUrl;
                item.coins = giftItem.coins;
                item.multi_click = giftItem.multi_click;
                item.type = giftItem.type;
                item.update_time = giftItem.update_time;
                
                return item.smallImgUrl;
            }
        }
    }
    
    return nil;
}

// 根据礼物id拿到礼物model
- (NSString *)backImgUrlWithGiftID:(NSString *)giftId{
    
    LiveRoomGiftItemObject *item = [[LiveRoomGiftItemObject alloc]init];
    
    if (self.giftMuArray != 0) {
        
        for (LiveRoomGiftItemObject *giftItem in self.giftMuArray) {
            
            if ([giftItem.giftId isEqualToString:giftId]) {
                
                item.giftId = giftItem.giftId;
                item.name = giftItem.name;
                item.smallImgUrl = giftItem.smallImgUrl;
                item.imgUrl = giftItem.imgUrl;
                item.srcUrl = giftItem.srcUrl;
                item.coins = giftItem.coins;
                item.multi_click = giftItem.multi_click;
                item.type = giftItem.type;
                item.update_time = giftItem.update_time;
                
                return item.imgUrl;
            }
        }
    }
    
    return nil;
}

@end
