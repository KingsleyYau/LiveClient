//
//  LiveGiftDownloadManager.m
//  livestream
//
//  Created by randy on 2017/6/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveGiftDownloadManager.h"
#import "LSLoginManager.h"
#import "AFNetWorkHelpr.h"
#import "LSFileCacheManager.h"
#import "LSImageViewLoader.h"
#import "LSSessionRequestManager.h"
#import "GetGiftDetailRequest.h"
#import "GiftListRequest.h"
#import "GetGiftDetailRequest.h"
#import "LSYYImage.h"

@interface LiveGiftDownloadManager () <LoginManagerDelegate>

@property (nonatomic, strong) LSLoginManager *loginManager;

@property (nonatomic, strong) NSMutableDictionary *fileNameDictionary;

/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, assign) BOOL isFirstLogin;

@property (nonatomic, strong) NSArray *webpArray;

@end

@implementation LiveGiftDownloadManager

+ (instancetype)manager {

    static LiveGiftDownloadManager *giftDownloadManager = nil;
    if (giftDownloadManager == nil) {
        giftDownloadManager = [[LiveGiftDownloadManager alloc] init];
    }
    return giftDownloadManager;
}

- (instancetype)init {
    self = [super init];

    if (self) {

        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
        self.sessionManager = [LSSessionRequestManager manager];
        self.fileNameDictionary = [[NSMutableDictionary alloc] init];
        self.giftMuArray = [[NSMutableArray alloc] init];
        self.bigGiftDownloadDic = [[NSMutableDictionary alloc] init];
        self.bigGiftDataDictionary = [[NSMutableDictionary alloc] init];
        self.isFirstLogin = YES;
        self.webpArray = [[NSArray alloc] init];
    }
    return self;
}

// 监听HTTP登录
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(NSInteger)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {

            if (self.isFirstLogin) {
                // 请求礼物列表
                [self getLiveRoomAllGiftListHaveNew:YES
                                            request:^(BOOL success, NSMutableArray *liveRoomGiftList){
                                            }];
            }
        }
    });
}

#pragma mark - 请求礼物列表
- (void)getLiveRoomAllGiftListHaveNew:(BOOL)haveNew request:(RequestFinshtBlock)callBack {

    if (self.giftMuArray.count && !haveNew) {

        callBack(YES, self.giftMuArray);

    } else {

        GetAllGiftListRequest *request = [[GetAllGiftListRequest alloc] init];
        request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, NSArray<GiftInfoItemObject *> *_Nullable array) {
            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"LiveGiftDownloadManager::GetAllGiftListRequest( [发送获取所有礼物列表请求结果], success : %d, errnum : %ld, errmsg : %@, count : %u )", success, (long)errnum, errmsg, (unsigned int)array.count);
                if (success) {
                    // 清空旧数据
                    [self.giftMuArray removeAllObjects];
                    
                    if (array != nil && array.count) {
                        for (GiftInfoItemObject *object in array) {
                            AllGiftItem *item = [[AllGiftItem alloc] init];
                            item.infoItem = object;
                            if (!self.giftMuArray) {
                                self.giftMuArray = [[NSMutableArray alloc] init];
                            }
                            [self.giftMuArray addObject:item];
                        }
                        // 下载大礼物动画
                        [self downLoadSrcImage];
                        callBack(success, self.giftMuArray);
                    }
                    self.isFirstLogin = NO;

                } else {
                    self.giftMuArray = nil;
                    callBack(success, self.giftMuArray);
                    self.isFirstLogin = YES;
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
}

#pragma mark - 下载礼物详情
- (void)downLoadSrcImage {

    NSMutableArray *bigArray = [[NSMutableArray alloc] init];
    for (AllGiftItem *giftItem in self.giftMuArray) {

        if (giftItem.infoItem.type == GIFTTYPE_Heigh) {

            [bigArray addObject:giftItem];
        }
        [self downLoadSmallImage:giftItem.infoItem.smallImgUrl];
        [self downLoadMiddleImage:giftItem.infoItem.middleImgUrl];
        [self downLoadBigImage:giftItem.infoItem.bigImgUrl];
    }
    self.webpArray = bigArray;
    [self downLoadWebpImage];
}

- (void)downLoadWebpImage {

    for (AllGiftItem *item in self.webpArray) {
        [self afnDownLoadFileWith:item.infoItem.srcwebpUrl giftItem:item];
    }
}

#pragma mark - 下载指定礼物详情
- (void)downLoadGiftDetail:(NSString *)giftID {

    AllGiftItem *item = [self backGiftItemWithGiftID:giftID];

    if (item.infoItem.type == GIFTTYPE_Heigh) {
        [self afnDownLoadFileWith:item.infoItem.srcwebpUrl giftItem:item];
    }
    [self downLoadSmallImage:item.infoItem.smallImgUrl];
    [self downLoadMiddleImage:item.infoItem.middleImgUrl];
    [self downLoadBigImage:item.infoItem.bigImgUrl];
}

#pragma mark - 下载大礼物webp文件
- (void)afnDownLoadFileWith:(NSString *)webpUrl giftItem:(AllGiftItem *)giftItem {
    //    NSLog(@"LiveGiftDownloadManager::afnDownLoadFileWith( [下载webp文件], fileUrl %@ )", webpUrl);

    NSString *filePath = [[LiveGiftDownloadManager manager] doCheckLocalGiftWithGiftID:giftItem.infoItem.giftId];
    NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    LSYYImage *image = [LSYYImage imageWithData:imageData];

    if (image == nil) {
        // 删除本地礼物
        [self deletWebpPath:giftItem.infoItem.giftId];

        // 下载webp文件
        _status = DOWNLOADSTART;
        NSURL *url = [NSURL URLWithString:webpUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

        NSURLSessionDownloadTask *downloadTask = [[AFNetWorkHelpr shareInstrue].manager downloadTaskWithRequest:request
            progress:^(NSProgress *_Nonnull downloadProgress) {

                float pargress = downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
                if (pargress == 1) {
                    _status = DOWNLOADEND;
                    giftItem.isDownloading = NO;
                    [self.bigGiftDownloadDic setObject:giftItem forKey:giftItem.infoItem.giftId];

                    if ([self.managerDelegate respondsToSelector:@selector(downloadState:)]) {
                        [self.managerDelegate downloadState:_status];
                    }
                } else {
                    _status = DOWNLOADING;
                    giftItem.isDownloading = YES;
                    [self.bigGiftDownloadDic setObject:giftItem forKey:giftItem.infoItem.giftId];
                }

            }
            destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {

                NSString *path = [[LSFileCacheManager manager] bigGiftCachePathWithGiftId:giftItem.infoItem.giftId];

                NSURL *documentsDirectoryURL = nil;
                if (path) {
                    documentsDirectoryURL = [NSURL fileURLWithPath:path];
                }
                return documentsDirectoryURL;

            }
            completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {

                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {

                    NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
                    if (error == nil && (code == 200 || code == 304)) {

                        NSLog(@"LiveGiftDownloadManager::afnDownLoadFileWith( [webp文件下载成功], WebP fileName : %@ )", [filePath lastPathComponent]);
                    } else {
                        _status = DOWNLOADFAIL;
                        [self deletWebpPath:giftItem.infoItem.giftId];
                        NSLog(@"LiveGiftDownloadManager::afnDownLoadFileWith( [webP下载失败...], WebPUrl : %@ )", webpUrl);
                    }

                } else {
                    _status = DOWNLOADFAIL;
                    [self deletWebpPath:giftItem.infoItem.giftId];
                    NSLog(@"LiveGiftDownloadManager::afnDownLoadFileWith( [webP下载失败...], WebPUrl : %@ )", webpUrl);
                }
            }];
        // 开始下载
        [downloadTask resume];
    }
}

//// SDWebImage下载webp文件
//- (void)getBigGiftWebpImageWithUrl:(NSString *)url giftItem:(AllGiftItem *)giftItem finishHandler:(DownLoadWebpHandler)finishHandler {
//
//    [[SDWebImageManager sharedManager].imageDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
//    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//
//        float currentProgress = (float)receivedSize / (float)expectedSize;
//        if (currentProgress == 1) {
//            _status = DOWNLOADEND;
//            giftItem.isDownloading = NO;
//            [self.bigGiftDownloadDic setObject:giftItem forKey:giftItem.infoItem.giftId];
//
//            if ([self.managerDelegate respondsToSelector:@selector(downloadState:)]) {
//                [self.managerDelegate downloadState:_status];
//            }
//        } else {
//            _status = DOWNLOADING;
//            giftItem.isDownloading = YES;
//            [self.bigGiftDownloadDic setObject:giftItem forKey:giftItem.infoItem.giftId];
//        }
//
//    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
//
//        NSLog(@"LiveGiftDownloadManager::getBigGiftWebpImageWithUrl : success: %@, error: %@, imageURL: %@"
//              ,(image != nil) ? @"成功" : @"失败", error, imageURL);
//
//        if (data) {
//            finishHandler(YES, image, data);
//        } else {
//            finishHandler(NO, nil, nil);
//        }
//    }];
//}

// 删除大礼物文件
- (void)deletWebpPath:(NSString *)giftId {
    NSString *path = [[LSFileCacheManager manager] bigGiftCachePathWithGiftId:giftId];
    [[LSFileCacheManager manager] removeDirectory:path];
}

#pragma mark - 下载礼物小图标(文本聊天框显示)
- (void)downLoadSmallImage:(NSString *)url {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:url]
        options:0
        progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

        }
        completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
            if (image) {
//                NSLog(@"LiveGiftDownloadManager::downLoadSmallImage( [下载礼物小图标结果], smallImage imageURL : %@ )", imageURL);
            }
        }];
}

#pragma mark - 下载礼物中图标(礼物列表显示)
- (void)downLoadMiddleImage:(NSString *)url {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:url]
        options:0
        progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

        }
        completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
            if (image) {
                //                NSLog(@"LiveGiftDownloadManager::downLoadMiddleImage( [下载礼物中图标结果], middleImage imageURL : %@ )", imageURL);
            }
        }];
}

#pragma mark - 下载礼物大图标(连击播放显示)
- (void)downLoadBigImage:(NSString *)url {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:url]
        options:0
        progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

        }
        completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
            if (image) {
                //                NSLog(@"LiveGiftDownloadManager::downLoadBigImage( [下载礼物大图标结果], bigImage imageURL : %@ )", imageURL);
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
- (void)haveListNotGift:(NSString *)giftId {
}

#pragma mark - 根据礼物ID判断是否有该礼物
- (BOOL)judgeTheGiftidIsHere:(NSString *)giftId {

    BOOL isHere = NO;

    for (AllGiftItem *giftItem in self.giftMuArray) {

        if ([giftItem.infoItem.giftId isEqualToString:giftId]) {

            isHere = YES;
        }
    }
    return isHere;
}

#pragma mark - 根据礼物id拿到礼物model
- (AllGiftItem *)backGiftItemWithGiftID:(NSString *)giftId {

    AllGiftItem *item = [[AllGiftItem alloc] init];

    if (self.giftMuArray.count != 0) {

        for (AllGiftItem *giftItem in self.giftMuArray) {

            if ([giftItem.infoItem.giftId isEqualToString:giftId]) {

                item.infoItem = giftItem.infoItem;
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
- (NSString *)doCheckLocalGiftWithGiftID:(NSString *)giftId {

    NSString *filePath = nil;
    NSString *webPPath = [[LSFileCacheManager manager] bigGiftCachePathWithGiftId:giftId];

    filePath = [self.fileNameDictionary objectForKey:giftId];

    if (!filePath) {

        filePath = webPPath;

        [self.fileNameDictionary setObject:filePath forKey:giftId];
    }
    return filePath;
}

#pragma mark - 根据礼物id拿到礼物SmallImgUrl
- (NSString *)backSmallImgUrlWithGiftID:(NSString *)giftId {

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
- (NSString *)backMiddleImgUrlWithGiftID:(NSString *)giftId {

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
- (NSString *)backBigImgUrlWithGiftID:(NSString *)giftId {

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
- (GiftType)backImgTypeWithGiftID:(NSString *)giftId {
    GiftType type = GIFTTYPE_UNKNOWN;

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
- (void)requestListnotGiftID:(NSString *)giftId {

    GetGiftDetailRequest *request = [[GetGiftDetailRequest alloc] init];
    request.giftId = giftId;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, GiftInfoItemObject *_Nullable item) {
        dispatch_async(dispatch_get_main_queue(), ^{

            if (success) {

                AllGiftItem *allItem = [[AllGiftItem alloc] init];
                allItem.infoItem = item;
                for (int i = 0; i < self.giftMuArray.count; i++) {
                    AllGiftItem *model = self.giftMuArray[i];
                    if (![model.infoItem.giftId isEqualToString:item.giftId] && i == self.giftMuArray.count - 1) {
                        [self.giftMuArray addObject:allItem];
                    }
                }
                // 下载礼物
                [self downLoadGiftDetail:giftId];
            }
        });
    };
}

@end
