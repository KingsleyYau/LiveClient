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
#import "SessionRequestManager.h"
#import "GetGiftDetailRequest.h"

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
        
        giftDownloadManager = [[LiveGiftDownloadManager alloc] init];
    });
    
    return giftDownloadManager;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
     
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
        self.sessionManager = [SessionRequestManager manager];
        self.fileNameDictionary = [[NSMutableDictionary alloc] init];
        self.giftMuArray = [[NSMutableArray alloc] init];
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
    
    GetAllGiftListRequest *request = [[GetAllGiftListRequest alloc] init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<GiftInfoItemObject *> * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {

                _status = DOWNLOADING;
                if (array != nil && array.count ) {
                    
                    for (GiftInfoItemObject *object in array) {
                        
                        AllGiftItem *item = [[AllGiftItem alloc] init];
                        item.infoItem = object;
                        [self.giftMuArray addObject:item];
                        
                        if ( self.giftMuArray.count == array.count ) {
                            // 下载大礼物动画
                            [self downLoadSrcImage];
                        }
                    }
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
    
    for (AllGiftItem *giftItem in self.giftMuArray) {
        
        if (giftItem.infoItem.type == GIFTTYPE_Heigh) {
            [self afnDownLoadFileWith:giftItem.infoItem.srcwebpUrl giftId:giftItem.infoItem.giftId];
        }
        [self downLoadSmallImageWithUrl:giftItem.infoItem.smallImgUrl];
        [self downLoadMiddleImageWithUrl:giftItem.infoItem.middleImgUrl];
        [self downLoadBigImageWithUrl:giftItem.infoItem.bigImgUrl];
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

#pragma mark - 下载礼物小图标(文本聊天框显示)
- (void)downLoadSmallImageWithUrl:(NSString *)url{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (image) {
            NSLog(@"LiveGiftDownloadManager::sDWebImageLoadSmallImage( smallImage imageURL : %@ )", imageURL);
        }
    }];
}

#pragma mark - 下载礼物中图标(礼物列表显示)
- (void)downLoadMiddleImageWithUrl:(NSString *)url{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (image) {
           NSLog(@"LiveGiftDownloadManager::sDWebImageLoadMiddleImage( MiddleImage imageURL : %@ )", imageURL);
        }
    }];
}

#pragma mark - 下载礼物大图标(连击播放显示)
- (void)downLoadBigImageWithUrl:(NSString *)url{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (image) {
            NSLog(@"LiveGiftDownloadManager::sDWebImageLoadBigImage( BigImage imageURL : %@ )", imageURL);
        }
    }];
}

#pragma mark - 添加新的礼物Item
//- (void)addNewGIftItemToArray:(LiveRoomGiftItemObject *)item {
//    
//    if (item.type == GIFTTYPE_Heigh) {
//        [self afnDownLoadFileWith:item.srcUrl giftId:item.giftId];
//    }
//    [self downLoadListImageWithUrl:item.imgUrl];
//    [self downLoadSmallImageWithUrl:item.smallImgUrl];
//    
//    [self.giftMuArray addObject:item];
//}
- (void)haveListNotGift:(NSString *)giftId{
    
    
    
    
}

#pragma mark - 根据礼物ID判断是否有该礼物
- (BOOL)judgeTheGiftidIsHere:(NSString *)giftId {
    
    BOOL isHere = NO;
    
//    for (LiveRoomGiftItemObject *giftItem in self.giftMuArray) {
//        
//        if ([giftItem.giftId isEqualToString:giftId]) {
//            
//            isHere = YES;
//        }
//    }
    return isHere;
}

#pragma mark - 根据礼物id拿到礼物model
- (AllGiftItem *)backGiftItemWithGiftID:(NSString *)giftId{
    
    AllGiftItem *item = [[AllGiftItem alloc]init];
    
    if (self.giftMuArray.count != 0) {
        
        for (AllGiftItem *giftItem in self.giftMuArray) {
            
            if ([giftItem.infoItem.giftId isEqualToString:giftId]) {
                
                item.infoItem.giftId = giftItem.infoItem.giftId;
                item.infoItem.name = giftItem.infoItem.name;
                item.infoItem.smallImgUrl = giftItem.infoItem.smallImgUrl;
                item.infoItem.middleImgUrl = giftItem.infoItem.middleImgUrl;
                item.infoItem.bigImgUrl = giftItem.infoItem.bigImgUrl;
                item.infoItem.srcFlashUrl = giftItem.infoItem.srcFlashUrl;
                item.infoItem.srcwebpUrl = giftItem.infoItem.srcwebpUrl;
                item.infoItem.credit = giftItem.infoItem.credit;
                item.infoItem.multiClick = giftItem.infoItem.multiClick;
                item.infoItem.type = giftItem.infoItem.type;
                item.infoItem.level = giftItem.infoItem.level;
                item.infoItem.loveLevel = giftItem.infoItem.loveLevel;
                item.infoItem.sendNumList = giftItem.infoItem.sendNumList;
                item.infoItem.updateTime = giftItem.infoItem.updateTime;
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
    
    if (self.giftMuArray.count != 0) {
        
        for (AllGiftItem *giftItem in self.giftMuArray) {
            
            if ([giftItem.infoItem.giftId isEqualToString:giftId]) {
                
                samllImgUrl = giftItem.infoItem.smallImgUrl;
            }
        }
    }
    return samllImgUrl;
}

#pragma mark - 根据礼物id拿到礼物MiddleImgUrl
- (NSString *)backMiddleImgUrlWithGiftID:(NSString *)giftId{
    
    NSString *middleImgUrl = nil;
    
    if (self.giftMuArray.count != 0) {
        
        for (AllGiftItem *giftItem in self.giftMuArray) {
            
            if ([giftItem.infoItem.giftId isEqualToString:giftId]) {
                
                middleImgUrl = giftItem.infoItem.middleImgUrl;
            }
        }
    }
    return middleImgUrl;
}

#pragma mark - 根据礼物id拿到礼物BigImgUrl
- (NSString *)backBigImgUrlWithGiftID:(NSString *)giftId{
    
    NSString *bigImgUrl = nil;
    
    if (self.giftMuArray.count != 0) {
        
        for (AllGiftItem *giftItem in self.giftMuArray) {
            
            if ([giftItem.infoItem.giftId isEqualToString:giftId]) {
                
                bigImgUrl = giftItem.infoItem.bigImgUrl;
            }
        }
    }
    return bigImgUrl;
}

#pragma mark - 根据礼物id拿到礼物Type
- (GiftType)backImgTypeWithGiftID:(NSString *)giftId{
    
    GiftType type;
    
    if (self.giftMuArray.count != 0) {
        
        for (AllGiftItem *giftItem in self.giftMuArray) {
            
            if ([giftItem.infoItem.giftId isEqualToString:giftId]) {
                type = giftItem.infoItem.type;
            }
        }
    }
    return type;
}

#pragma mark - 获取指定礼物详情
- (void)requestListnotGift{
    
    
}

@end
