//
//  FileDownloadManager.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/26.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "FileDownloadManager.h"

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#import "RtmpPlayerOC.h"

#define IDENTIFYIER @"net.qdating.rtmpclient.BackgroundSession"
#define HLS_IDENTIFYIER @"net.qdating.rtmpclient.hls.BackgroundSession"

@implementation FileDownloadItem
- (id)init {
    self = [super init];
    self.url = @"";
    self.fileName = @"";
    self.filePath = @"";
    self.status = FileDownloadItemStatus_None;
    return self;
}
@end

static FileDownloadManager *gManager = nil;
@interface FileDownloadManager () <NSURLSessionDownloadDelegate, AVAssetDownloadDelegate>
@property (strong) NSURLSession *session;
@property (strong) NSMutableDictionary *downloadItemDict;
@property (strong) NSMutableArray *delegates;
@property (assign) BOOL isSessionOK;
@property (assign) BOOL isAssetSessionOK;
@property (strong) AVAssetDownloadURLSession *assetSession;
@end

@implementation FileDownloadManager
#pragma mark - 获取实例
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!gManager) {
            gManager = [[[self class] alloc] init];
        }
    });
    return gManager;
}

- (void)dealloc {
}

- (id)init {
    self = [super init];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:IDENTIFYIER];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.isSessionOK = YES;
    
    NSURLSessionConfiguration *assetConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:HLS_IDENTIFYIER];
    self.assetSession = [AVAssetDownloadURLSession sessionWithConfiguration:assetConfig assetDownloadDelegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.isAssetSessionOK = YES;
    
    self.downloadItemDict = [NSMutableDictionary dictionary];
    self.delegates = [NSMutableArray array];
    return self;
}

- (void)addDelegate:(id<NSURLSessionDelegate>)delegate {
    @synchronized(self) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<NSURLSessionDelegate>)delegate {
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<NSURLSessionDelegate> item = (id<NSURLSessionDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}

- (AVAssetDownloadTask *)downloadHLSURL:(NSString *)url {
    AVAssetDownloadTask *task = nil;
    if (self.isAssetSessionOK) {
        NSLog(@"[Start], %@", url);
        NSURL *assetURL = [NSURL URLWithString:url];
        AVURLAsset *hlsAsset = [AVURLAsset assetWithURL:assetURL];
        task = [self.assetSession assetDownloadTaskWithURLAsset:hlsAsset assetTitle:@"hls" assetArtworkData:nil options:nil];
        [task resume];
    } else {
        NSLog(@"[Start Fail], %@", url);
    }
    return task;
}

- (NSURLSessionDownloadTask *)downloadURL:(NSString *)url {
    NSURLSessionDownloadTask *task = nil;
    if (self.isSessionOK) {
        NSLog(@"[Start], %@", url);
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        task = [self.session downloadTaskWithRequest:req];
        [task resume];
    } else {
        NSLog(@"[Start Fail], %@", url);
    }
    return task;
}

- (void)cancel {
    self.isSessionOK = NO;
    [self.session invalidateAndCancel];
    [self.session resetWithCompletionHandler:^{
    }];
    self.isAssetSessionOK = NO;
    [self.assetSession invalidateAndCancel];
}

+ (NSString *)getMd5FromString:(NSString *)string {
    const char *str = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH] = {0};
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *code = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [code appendFormat:@"%02X", result[i]];
    }
    return code;
}

+ (void)getAllVideo:(NSString *)inputDir outputFilePaths:(NSMutableArray *)outputFilePaths {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;

    NSArray *fileArray = [fm contentsOfDirectoryAtPath:inputDir error:&error];
    if (!error) {
        for (NSString *fileName in fileArray) {
            BOOL isDirectory = YES;
            NSString *filePath = [inputDir stringByAppendingPathComponent:fileName];
            if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory]) {
                if (isDirectory) {
                    [[self class] getAllVideo:filePath outputFilePaths:outputFilePaths];
                } else {
                    if ([fileName containsString:@".frag"]) {
                        [outputFilePaths addObject:filePath];
                    }
                }
            }
        }
    } else {
        NSLog(@"error: %@", error);
    }
}

#pragma mark - MP4
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    for (NSValue *value in self.delegates) {
        id<NSURLSessionDownloadDelegate> delegate = value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
            [delegate URLSession:session
                             downloadTask:downloadTask
                             didWriteData:bytesWritten
                        totalBytesWritten:totalBytesWritten
                totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"fileOffset: %lld, expectedTotalBytes: %lld", fileOffset, expectedTotalBytes);
    for (NSValue *value in self.delegates) {
        id<NSURLSessionDownloadDelegate> delegate = value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:)]) {
            [delegate URLSession:session
                      downloadTask:downloadTask
                 didResumeAtOffset:fileOffset
                expectedTotalBytes:expectedTotalBytes];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *ouputDir = [NSString stringWithFormat:@"%@/download", cacheDir];
    NSString *ouputFile = [NSString stringWithFormat:@"%@/%@", ouputDir, downloadTask.response.suggestedFilename];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    [fm createDirectoryAtPath:ouputDir withIntermediateDirectories:YES attributes:nil error:&error];
    [fm moveItemAtURL:location toURL:[NSURL fileURLWithPath:ouputFile] error:&error];
    NSLog(@"%@", downloadTask.response.suggestedFilename);

    for (NSValue *value in self.delegates) {
        id<NSURLSessionDownloadDelegate> delegate = value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(URLSession:downloadTask:didFinishDownloadingToURL:)]) {
            [delegate URLSession:session
                             downloadTask:downloadTask
                didFinishDownloadingToURL:location];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"%@", error);
    BOOL bCanResume = NO;
    if (error) {
        NSData *data = error.userInfo[NSURLSessionDownloadTaskResumeData];
        if (data) {
            NSURLSessionDownloadTask *resumeTask = [session downloadTaskWithResumeData:data];
            [resumeTask resume];
            bCanResume = YES;
        }
    }

    if (!bCanResume) {
        for (NSValue *value in self.delegates) {
            id<NSURLSessionTaskDelegate> delegate = value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
                [delegate URLSession:session
                                    task:task
                    didCompleteWithError:error];
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    NSLog(@"FileDownloadManager::didBecomeInvalidWithError(), %@", error);
    for (NSValue *value in self.delegates) {
        id<NSURLSessionDelegate> delegate = value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(URLSession:didBecomeInvalidWithError:)]) {
            [delegate URLSession:session
                didBecomeInvalidWithError:error];
        }
    }

    if ([session isKindOfClass:[AVAssetDownloadURLSession class]]) {
        NSURLSessionConfiguration *assetConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:HLS_IDENTIFYIER];
        self.assetSession = [AVAssetDownloadURLSession sessionWithConfiguration:assetConfig assetDownloadDelegate:self delegateQueue:[NSOperationQueue mainQueue]];
        self.isAssetSessionOK = YES;
    } else {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:IDENTIFYIER];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        self.isSessionOK = YES;
    }
}

#pragma mark - HLS
- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"location: %@, url: %@", location, assetDownloadTask.URLAsset.URL.absoluteString);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *ouputDir = [NSString stringWithFormat:@"%@/download", cacheDir];
        NSString *ouputFile = [NSString stringWithFormat:@"%@/%@", ouputDir, [FileDownloadManager getMd5FromString:assetDownloadTask.URLAsset.URL.absoluteString]];

        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        [fm createDirectoryAtPath:ouputDir withIntermediateDirectories:YES attributes:nil error:&error];
        [fm moveItemAtURL:location toURL:[NSURL fileURLWithPath:ouputFile] error:&error];

        NSMutableArray *srcFilePaths = [NSMutableArray array];
        [[self class] getAllVideo:ouputFile outputFilePaths:srcFilePaths];

        NSString *dstFilePath = [NSString stringWithFormat:@"%@/%lu.mp4", ouputDir, [assetDownloadTask hash]];
        NSArray *sortPaths = [srcFilePaths sortedArrayUsingComparator:^(NSString *firstPath, NSString *secondPath) {
            NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstPath error:nil];
            NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondPath error:nil];
            id firstDate = [firstFileInfo objectForKey:NSFileModificationDate];
            id secondDate = [secondFileInfo objectForKey:NSFileModificationDate];
            return [firstDate compare:secondDate];
        }];
        
        [RtmpPlayerOC combine:sortPaths dstFilePath:dstFilePath];
        
        [fm removeItemAtPath:ouputFile error:&error];
        if (error) {
            NSLog(@"error: %@", error);
        }

        for (NSValue *value in self.delegates) {
            id<AVAssetDownloadDelegate> delegate = value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(URLSession:assetDownloadTask:didFinishDownloadingToURL:)]) {
                [delegate URLSession:session
                            assetDownloadTask:assetDownloadTask
                    didFinishDownloadingToURL:location];
            }
        }
    });
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad {
    NSLog(@"%.0f/%.0f second, %lu.mp4",
          CMTimeGetSeconds(timeRange.start), CMTimeGetSeconds(timeRangeExpectedToLoad.duration), [assetDownloadTask hash]);
    for (NSValue *value in self.delegates) {
        id<AVAssetDownloadDelegate> delegate = value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(URLSession:assetDownloadTask:didLoadTimeRange:totalTimeRangesLoaded:timeRangeExpectedToLoad:)]) {
            [delegate URLSession:session
                      assetDownloadTask:assetDownloadTask
                       didLoadTimeRange:timeRange
                  totalTimeRangesLoaded:loadedTimeRanges
                timeRangeExpectedToLoad:timeRangeExpectedToLoad];
        }
    }
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didResolveMediaSelection:(AVMediaSelection *)resolvedMediaSelection {
    NSLog(@"resolvedMediaSelection: %@", resolvedMediaSelection);
}

- (void)URLSession:(NSURLSession *)session aggregateAssetDownloadTask:(AVAggregateAssetDownloadTask *)aggregateAssetDownloadTask willDownloadToURL:(NSURL *)location API_AVAILABLE(ios(11.0)) {
    NSLog(@"location: %@", location);
}

- (void)URLSession:(NSURLSession *)session aggregateAssetDownloadTask:(AVAggregateAssetDownloadTask *)aggregateAssetDownloadTask didCompleteForMediaSelection:(AVMediaSelection *)mediaSelection API_AVAILABLE(ios(11.0)) {
    NSLog(@"mediaSelection: %@", mediaSelection);
}

- (void)URLSession:(NSURLSession *)session aggregateAssetDownloadTask:(AVAggregateAssetDownloadTask *)aggregateAssetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad forMediaSelection:(AVMediaSelection *)mediaSelection API_AVAILABLE(ios(11.0)) {
    NSLog(@"[Finish], loaded(%f, %f), expected(%f, %f), mediaSelection: %@",
          CMTimeGetSeconds(timeRange.start), CMTimeGetSeconds(timeRange.duration),
          CMTimeGetSeconds(timeRangeExpectedToLoad.start), CMTimeGetSeconds(timeRangeExpectedToLoad.duration),
          mediaSelection);
}

@end
