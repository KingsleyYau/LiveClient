//
//  ChatPhotoDataManager.m
//  dating
//
//  Created by Calvin on 2018/12/21.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSChatPhotoDataManager.h"
#import "LSChatPhoneAlbumPhoto.h"
#import "LSFileCacheManager.h"
#define PreloadPhotoCount 10

static LSChatPhotoDataManager *chatPhotoDataManager;

@interface LSChatPhotoDataManager ()<PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) NSMutableArray * item;
@property NSInteger photoPage; //加载相册页数
@property (atomic, assign) BOOL isStop;//停止加载相册
@property (nonatomic, strong) NSMutableArray *delegates;

@property (atomic, assign) NSInteger lastUpdateCount;//上次更新图片的数量
@end

@implementation LSChatPhotoDataManager

+ (instancetype)manager {
    if (chatPhotoDataManager == nil) {
        chatPhotoDataManager = [[[self class] alloc] init];
    }
    return chatPhotoDataManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.item = [NSMutableArray array];
        self.delegates = [NSMutableArray array];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

- (BOOL)addDelegate:(id<ChatPhotoDataManagerDelegate>)delegate {
    BOOL result = NO;
    
    @synchronized(self.delegates) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<ChatPhotoDataManagerDelegate> item = (id<ChatPhotoDataManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                NSLog(@"ChatPhotoDataManager::addDelegate() add again, delegate:<%@>", delegate);
                result = YES;
                break;
            }
        }
        
        // 未存在则添加
        if (!result) {
            [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
            result = YES;
        }
    }
    
    return result;
}

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<ChatPhotoDataManagerDelegate>)delegate {
    BOOL result = NO;
    [self resetEditState];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<ChatPhotoDataManagerDelegate> item = (id<ChatPhotoDataManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
    }
    
    // log
    if (!result) {
        NSLog(@"ChatPhotoDataManager::removeDelegate() fail, delegate:<%@>", delegate);
    }
    
    return result;
}

- (NSArray*)photoPathArray {
    return self.item;
}

- (void)resetEditState {
    for (LSChatPhoneAlbumPhoto *albumPhoto in self.item) {
        albumPhoto.isEdit = NO;
    }
}

- (NSString *)getOriginalPhotoPath:(UIImage *)image andImageName:(NSString *)name {
    UIImage *fixOrientationImage = [image fixOrientation];
    // 保存到本地
    LSFileCacheManager *fileCacheManager = [LSFileCacheManager manager];
    NSString *path = [fileCacheManager imageUploadSCompressSizeCachePath:fixOrientationImage fileName:name];
    return path;
}

- (void)choosePhotoURL:(NSString *)url {
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<ChatPhotoDataManagerDelegate> delegate = (id<ChatPhotoDataManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onChoosePhotoURL:)]) {
                [delegate onChoosePhotoURL:url];
            }
        }
    }
}

- (void)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
        
        PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
        if (self.lastUpdateCount == result.count && self.item.count != 0) {
            //图片数量相同，不更新
             [self uploadPhotoUI];
            return;
        }
        self.lastUpdateCount = result.count;
        //__weak typeof(self) weakSelf = self;
        [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                PHAsset *asset = (PHAsset *)obj;
                // 增加相册图片缓存
                LSChatPhoneAlbumPhoto *albumPhoto = [[LSChatPhoneAlbumPhoto alloc] init];
                albumPhoto.asset = asset;
                albumPhoto.fileName = [asset valueForKey:@"filename"];
                // 相册Item
                [self.item addObject:albumPhoto];

                if (result.count - 1 == idx) {
                    [self uploadPhotoUI];
                }
            });
        }];
    });
}

- (void)uploadPhotoUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self.delegates) {
            for (NSValue *value in self.delegates) {
                id<ChatPhotoDataManagerDelegate> delegate = (id<ChatPhotoDataManagerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(chatPhotoDataManagerReloadData)]) {
                    [delegate chatPhotoDataManagerReloadData];
                }
            }
        }
    });
}

//相册变化回调
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"相册改变了");
        [self.item removeAllObjects];
        [self getAllAssetInPhotoAblumWithAscending:NO];
    });
}

- (void)synchronousSaveImageWithPhotosWithImage:(UIImage *)image {
    __block NSString *createdAssetId = nil;
    
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId != nil)
    {
        // 在保存完毕后取出图片
        PHAsset * asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil] objectAtIndex:0];
        
        // 增加相册图片缓存
        LSChatPhoneAlbumPhoto *albumPhoto = [[LSChatPhoneAlbumPhoto alloc] init];
        albumPhoto.asset = asset;
        albumPhoto.fileName = [asset valueForKey:@"filename"];
        // 相册Item
        [self.item insertObject:albumPhoto atIndex:0];
    }
    
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<ChatPhotoDataManagerDelegate> delegate = (id<ChatPhotoDataManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(chatPhotoDataManagerReloadData)]) {
                [delegate chatPhotoDataManagerReloadData];
            }
        }
    }
}

@end
