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

#define IDENTIFYIER @"net.qdating.rtmpclient.BackgroundSession"

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
@interface FileDownloadManager () <NSURLSessionDownloadDelegate>
@property (strong) NSURLSession *session;
@property (strong) NSMutableDictionary *downloadItemDict;
@property (strong) NSMutableArray *delegates;
@property (assign) BOOL isSessionOK;
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
    NSURLSessionConfiguration *assetConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"assetDowloadConfigIdentifier"];
    self.assetSession = [AVAssetDownloadURLSession sessionWithConfiguration:assetConfig assetDownloadDelegate:self delegateQueue:[NSOperationQueue mainQueue]];

    self.isSessionOK = YES;
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
    if (self.isSessionOK) {
        NSLog(@"FileDownloadManager::downloadHLS(), [Start], %@", url);
        NSURL *assetURL = [NSURL URLWithString:url];
        AVURLAsset *hlsAsset = [AVURLAsset assetWithURL:assetURL];
        task = [self.assetSession assetDownloadTaskWithURLAsset:hlsAsset assetTitle:@"hls" assetArtworkData:nil options:nil];
        [task resume];
    } else {
        NSLog(@"FileDownloadManager::downloadHLS(), [Start Fail], %@", url);
    }
    return task;
}

- (NSURLSessionDownloadTask *)downloadURL:(NSString *)url {
    NSURLSessionDownloadTask *task = nil;
    if (self.isSessionOK) {
        NSLog(@"FileDownloadManager::download(), [Start], %@", url);
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        task = [self.session downloadTaskWithRequest:req];
        [task resume];
    } else {
        NSLog(@"FileDownloadManager::download(), [Start Fail], %@", url);
    }
    return task;
}

- (void)cancel {
    self.isSessionOK = NO;
    [self.session invalidateAndCancel];
    [self.session resetWithCompletionHandler:^{
    }];
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
    NSLog(@"FileDownloadManager::didResumeAtOffset(), fileOffset: %lld, expectedTotalBytes: %lld", fileOffset, expectedTotalBytes);
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
    NSLog(@"FileDownloadManager::didFinishDownloadingToURL(), %@", downloadTask.response.suggestedFilename);

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
    NSLog(@"FileDownloadManager::didCompleteWithError(), %@", error);
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

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:IDENTIFYIER];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.isSessionOK = YES;
}

#pragma mark - HLS
- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"FileDownloadManager::didFinishDownloadingToURL(), location: %@", location);
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *ouputDir = [NSString stringWithFormat:@"%@/download", cacheDir];
    NSString *ouputFile = [NSString stringWithFormat:@"%@/%@", ouputDir, [[self class] getMd5FromString:assetDownloadTask.URLAsset.URL.absoluteString]];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    [fm createDirectoryAtPath:ouputDir withIntermediateDirectories:YES attributes:nil error:&error];
    [fm moveItemAtURL:location toURL:[NSURL fileURLWithPath:ouputFile] error:&error];
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad {
    NSLog(@"FileDownloadManager::didLoadTimeRange(), %.0f/%.0f second",
          CMTimeGetSeconds(timeRange.start), CMTimeGetSeconds(timeRangeExpectedToLoad.duration));
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didResolveMediaSelection:(AVMediaSelection *)resolvedMediaSelection {
    NSLog(@"FileDownloadManager::didResolveMediaSelection(), resolvedMediaSelection: %@", resolvedMediaSelection);
}

- (void)URLSession:(NSURLSession *)session aggregateAssetDownloadTask:(AVAggregateAssetDownloadTask *)aggregateAssetDownloadTask willDownloadToURL:(NSURL *)location API_AVAILABLE(ios(11.0)) {
    NSLog(@"FileDownloadManager::willDownloadToURL(), location: %@", location);
}

- (void)URLSession:(NSURLSession *)session aggregateAssetDownloadTask:(AVAggregateAssetDownloadTask *)aggregateAssetDownloadTask didCompleteForMediaSelection:(AVMediaSelection *)mediaSelection API_AVAILABLE(ios(11.0)) {
    NSLog(@"FileDownloadManager::didCompleteForMediaSelection(), mediaSelection: %@", mediaSelection);
}

- (void)URLSession:(NSURLSession *)session aggregateAssetDownloadTask:(AVAggregateAssetDownloadTask *)aggregateAssetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad forMediaSelection:(AVMediaSelection *)mediaSelection API_AVAILABLE(ios(11.0)) {
    NSLog(@"FileDownloadManager::didLoadTimeRange(), [Finish], loaded(%f, %f), expected(%f, %f), mediaSelection: %@",
          CMTimeGetSeconds(timeRange.start), CMTimeGetSeconds(timeRange.duration),
          CMTimeGetSeconds(timeRangeExpectedToLoad.start), CMTimeGetSeconds(timeRangeExpectedToLoad.duration),
          mediaSelection);
}

@end
