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

@property (nonatomic, strong) NSMutableDictionary *fileNameDictionary;

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
        giftDownloadManager.fileNameDictionary = [[NSMutableDictionary alloc]init];
        giftDownloadManager.giftMuArray = [[NSMutableArray alloc]init];
        
    });
    
    return giftDownloadManager;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
     
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
        
        self.sessionManager = [SessionRequestManager manager];
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

#pragma mark - 请求礼物列表
- (void)GetLiveRoomAllGiftListRequest{
    
    _status = DOWNLOADSTART;
    
    GetLiveRoomAllGiftListRequest *request = [[GetLiveRoomAllGiftListRequest alloc]init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomGiftItemObject *> * _Nullable array) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                
                _status = DOWNLOADING;
                
                if ( self.giftMuArray.count > 0 && self.giftMuArray ) {
                    
                    [self.giftMuArray removeAllObjects];
                }
                
                if (array != nil && array.count ) {
                    self.giftMuArray = [array copy];
                    
                    // 下载大礼物动画
                    [self downLoadSrcImage];
                }
                
            }else{
                
                _status = DOWNLOADEND;
                NSLog(@"GetLiveRoomAllGiftListRequest ErrNum:%ld ErrMsg%@",(long)errnum,errmsg);
            }
        });
        
    };
    
    [self.sessionManager sendRequest:request];
}

#pragma mark - 下载礼物详情
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
            
            if (giftItem.type == GIFTTYPE_Heigh) {
                [self afnDownLoadFileWith:item.srcUrl giftId:item.giftId];
            }
            [self downLoadListImageWithUrl:item.imgUrl];
            [self downLoadSmallImageWithUrl:item.smallImgUrl];
        }
}

#pragma mark - 下载大礼物webp文件
- (void)afnDownLoadFileWith:(NSString *)fileUrl giftId:(NSString *)giftId {
    
    NSLog(@"livedownloadmanager :: afnDownLoadFileWith fileUrl %@",fileUrl);
    // 下载webp文件
    NSURL* url = [NSURL URLWithString:fileUrl];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [[AFNetWorkHelpr shareInstrue].manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *path = [[FileCacheManager manager] bigGiftCachePathWithGiftId:giftId];
        
        NSURL* documentsDirectoryURL = nil;
        if( path ) {
            documentsDirectoryURL = [NSURL fileURLWithPath:path];
        }
        return documentsDirectoryURL;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if( [response isKindOfClass:[NSHTTPURLResponse class]] ) {
            if( error == nil && ((NSHTTPURLResponse* )response).statusCode == 200 ) {
                
                if ([self.managerDelegate respondsToSelector:@selector(downLoadWasCompleteWithGiftId:)]) {
                    [self.managerDelegate downLoadWasCompleteWithGiftId:giftId];
                }
                
                NSString *fileName = [filePath lastPathComponent];
                NSLog(@"LiveGiftDownloadManager::afnDownLoadFileWith( WebP fileName : %@ )", fileName);
                _status = DOWNLOADEND;
            }
        }
        
    }];
    
    // 开始下载
    [downloadTask resume];
}

#pragma mark - 下载SmallImage
- (void)downLoadSmallImageWithUrl:(NSString *)url{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (image) {
            
            NSLog(@"LiveGiftDownloadManager::sDWebImageLoadSmallImage( smallImage imageURL : %@ )", imageURL);
        }
        
    }];
}

#pragma mark - 下载ListImage
- (void)downLoadListImageWithUrl:(NSString *)url{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (image) {
            
           NSLog(@"LiveGiftDownloadManager::sDWebImageLoadListImage( listImage imageURL : %@ )", imageURL);
        }
        
    }];
}

#pragma mark - 添加新的礼物Item
- (void)addNewGIftItemToArray:(LiveRoomGiftItemObject *)item {
    
    if (item.type == GIFTTYPE_Heigh) {
        [self afnDownLoadFileWith:item.srcUrl giftId:item.giftId];
    }
    [self downLoadListImageWithUrl:item.imgUrl];
    [self downLoadSmallImageWithUrl:item.smallImgUrl];
    
    [self.giftMuArray addObject:item];
}

#pragma mark - 根据礼物ID判断是否有该礼物
- (BOOL)judgeTheGiftidIsHere:(NSString *)giftId {
    
    BOOL isHere = NO;
    
    for (LiveRoomGiftItemObject *giftItem in self.giftMuArray) {
        
        if ([giftItem.giftId isEqualToString:giftId]) {
            
            isHere = YES;
        }
    }
    return isHere;
}

#pragma mark - 根据礼物id拿到礼物model
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
            }
        }
    }
    
    return item;
}

#pragma mark - 根据礼物id拿到webP文件路径
- (NSString *)doCheckLocalGiftWithGiftID:(NSString *)giftId{
    
    NSString *filePath = nil;
    NSString *webPPath = [[FileCacheManager manager] bigGiftCachePathWithGiftId:giftId];
    
    filePath = [self.fileNameDictionary objectForKey:giftId];
    
    if (!filePath) {
        
        filePath = webPPath;
        
        [self.fileNameDictionary setObject:filePath forKey:giftId];
    }
    return filePath;
}

#pragma mark - 根据礼物id拿到礼物SmallImgUrl
- (NSString *)backSmallImgUrlWithGiftID:(NSString *)giftId{
    
    NSString *samllImgUrl = nil;
    
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
                
                samllImgUrl = item.smallImgUrl;
            }
        }
    }
    return samllImgUrl;
}

#pragma mark - 根据礼物id拿到礼物ImgUrl
- (NSString *)backImgUrlWithGiftID:(NSString *)giftId{
    
    NSString *imgUrl = nil;
    
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
                
                imgUrl = item.imgUrl;
            }
        }
    }
    return imgUrl;
}

#pragma mark - 根据礼物id拿到礼物Type
- (GiftType)backImgTypeWithGiftID:(NSString *)giftId{
    
    GiftType type;
    
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
                
                type = item.type;
            }
        }
    }
    return type;
}

@end
