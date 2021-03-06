//
//  FileDownloadManager.h
//  RtmpClientTest
//
//  Created by Max on 2020/10/26.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVAssetDownloadTask.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum FileDownloadItemStatus {
    FileDownloadItemStatus_None,
    FileDownloadItemStatus_Downloading,
    FileDownloadItemStatus_Pause,
} FileDownloadItemStatus;

@interface FileDownloadItem : NSObject
@property (strong) NSString* url;
@property (strong) NSString* fileName;
@property (strong) NSString* filePath;
@property (assign) FileDownloadItemStatus status;
@property (strong) NSData* resumeData;
@end

@interface FileDownloadManager : NSObject
+ (instancetype)manager;
- (void)addDelegate:(id<NSURLSessionDelegate>)delegate;
- (void)removeDelegate:(id<NSURLSessionDelegate>)delegate;
- (NSURLSessionDownloadTask *)downloadURL:(NSString *)url;
- (AVAssetDownloadTask *)downloadHLSURL:(NSString *)url;
- (void)cancel;
+ (NSString *)getMd5FromString:(NSString *)string;
+ (void)getAllVideo:(NSString *)inputDir outputFilePaths:(NSMutableArray *)outputFilePaths;
@end

NS_ASSUME_NONNULL_END
