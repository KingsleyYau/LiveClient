//
//  PronViewController.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/23.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "PronViewController.h"
#import "AppDelegate.h"
#import "FileDownloadManager.h"
#import "RtmpPlayerOC.h"

#import "NSObject+Property.h"
#import "OCTimer.h"

#import <AVKit/AVKit.h>

@interface DownloadAttachment : NSTextAttachment
@property (strong) NSURLSessionTask *task;
@property (strong) NSAttributedString *statusString;
@end

@implementation DownloadAttachment
@end

@interface PronViewController ()
@property (weak) IBOutlet StreamWebView *webView;
@property (weak) IBOutlet UIButton *downloadBtn;
@property (weak) IBOutlet UITextView *downloadTextView;
@property (weak) IBOutlet UIButton *autoPlayButton;
@property (assign) BOOL forward;

@property (strong) NSMutableDictionary *urlDict;
@property (strong) NSMutableDictionary *urlCheckDict;

@property (weak) IBOutlet UITextField *textFieldAddress;
@property (strong) NSURLSession *session;

@property (strong) NSMutableDictionary *taskURLDict;
@property (strong) NSString *downloadUrlString;
@property (assign) BOOL isHLS;
@property (strong) OCTimer *timer;

@property (strong) AVPlayerItem *playerItem;
@property (strong) AVPlayer *player;

@property (assign) BOOL autoPlay;
@end

@implementation PronViewController
+ (NSString *)jqueryScript {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"File/jquery.min" ofType:@"js"];
    NSString *javascript = [NSString stringWithContentsOfFile:path encoding:kCFStringEncodingASCII error:nil];
    return javascript;
}

- (void)dealloc {
    [[FileDownloadManager manager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 界面处理
    self.title = @"Browser";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Nav-BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];

    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadButton.frame = CGRectMake(0, 0, 24, 24);
    [downloadButton setImage:[UIImage imageNamed:@"DownloadButton"] forState:UIControlStateNormal];
    [downloadButton addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(0, 0, 24, 24);
    [playButton setImage:[UIImage imageNamed:@"PlayButton"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithCustomView:downloadButton],
        [[UIBarButtonItem alloc] initWithCustomView:playButton]
    ];

    // 是否自动下载
    [self.autoPlayButton setImage:[UIImage imageNamed:@"CheckButtonSelected"] forState:UIControlStateSelected];
    self.autoPlayButton.selected = self.autoPlay;
    self.downloadBtn.enabled = NO;

    // 浏览界面
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.hidden = YES;

    self.taskURLDict = [NSMutableDictionary dictionary];

    NSString *urlString = self.baseUrl;
    if (urlString.length == 0) {
        urlString = @"https://www.baidu.com";
    }

    self.textFieldAddress.text = urlString;

    [[FileDownloadManager manager] addDelegate:self];

    WKUserScript *usrScript = [[WKUserScript alloc] initWithSource:[[self class] jqueryScript] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.webView.configuration.userContentController addUserScript:usrScript];

    [self goAction:nil];

    self.timer = [[OCTimer alloc] init];
    [self.timer startTimer:nil
              timeInterval:120 * NSEC_PER_SEC
                   starNow:YES
                    action:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self tryAllAD:nil];
                        });
                    }];
    
    // 显示广告
    [self tryAllAD:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

}

#pragma mark - 持久化
- (NSString *)baseUrl {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *baseUrl = [userDefaults objectForKey:@"baseUrl"];
    return baseUrl;
}

- (void)setBaseUrl:(NSString *)baseUrl {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:baseUrl forKey:@"baseUrl"];
    [userDefaults synchronize];
}

- (BOOL)autoPlay {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL autoPlay = [userDefaults boolForKey:@"autoPlay"];
    return autoPlay;
}

- (void)setAutoPlay:(BOOL)autoPlay {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:autoPlay forKey:@"autoPlay"];
    [userDefaults synchronize];
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)goAction:(UIButton *)sender {
    self.downloadUrlString = @"";
    self.downloadBtn.enabled = NO;

    NSString *urlString = self.textFieldAddress.text;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.webView loadRequest:request];

    self.baseUrl = urlString;
}

- (IBAction)viewAction:(UIButton *)sender {
    self.webView.hidden = !self.webView.hidden;
    self.downloadTextView.hidden = !self.downloadTextView.hidden;
}

- (IBAction)autoPlayAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.autoPlay = sender.selected;
}

- (IBAction)checkDownloadURL:(BOOL)autoPlay {
    if (self.downloadUrlString.length == 0) {
        self.urlDict = [NSMutableDictionary dictionary];
        self.urlCheckDict = [NSMutableDictionary dictionary];
        self.downloadBtn.enabled = NO;

        NSString *trackVideoIdKey = @"VIDEO_SHOW.trackVideoId";
        [self.webView evaluateJavaScript:trackVideoIdKey
                       completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                           if (!error) {
                               NSString *videoId = (NSString *)response;
                               NSLog(@"video_id: %@", response);
                               [self checkVideoUrls:videoId autoPlay:autoPlay];
                           }
                       }];
    }
}

- (void)checkVideoUrls:(NSString *)videoId autoPlay:(BOOL)autoPlay {
    NSString *qualityItemsKey = [NSString stringWithFormat:@"qualityItems_%@", videoId];
    [self.webView evaluateJavaScript:qualityItemsKey
                   completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                       if (!error) {
                           NSArray *items = (NSArray *)response;
                           for (NSDictionary *dict in items) {
                               NSString *resolution = dict[@"id"];
                               NSString *url = dict[@"url"];
                               NSLog(@"%@, %@", resolution, url);
                               self.urlDict[resolution] = url;
                           }
                           [self check:autoPlay];
                       }
                   }];
}

- (void)play {
    [self stop];

    if (self.downloadUrlString.length > 0) {
        NSURL *url = [NSURL URLWithString:self.downloadUrlString];
        AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
        vc.view.frame = self.view.bounds;
        vc.videoGravity = AVLayerVideoGravityResizeAspect;
        vc.showsPlaybackControls = YES;
        vc.allowsPictureInPicturePlayback = YES;
        
        self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
        if (self.player) {
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        } else {
            self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        }
        vc.player = self.player;
        
        [self presentViewController:vc animated:YES completion:^{
            [self.player play];
        }];
    }
}

- (void)stop {
    if (self.playerItem) {
        [self.player pause];
        self.playerItem = nil;
    }
}

- (void)check:(BOOL)autoPlay {
    //    NSString *original = self.urlDict[@"ORIGINAL"];
    //    if (self.urlDict.count >= 1 || original.length > 0) {
    self.downloadBtn.enabled = YES;
    [self selectDownloadURL];

    if (autoPlay && self.autoPlayButton.selected) {
        [self play];
    }
    //    }
}

- (IBAction)cleanAction:(UIButton *)sender {
    [[FileDownloadManager manager] cancel];
    [self.taskURLDict removeAllObjects];
    [self changeDownloadStatus];

    //        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    //        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
    //                         completionHandler:^(NSArray<WKWebsiteDataRecord *> *__nonnull records) {
    //                             for (WKWebsiteDataRecord *record in records) {
    //                                 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
    //                                                                           forDataRecords:@[ record ]
    //                                                                        completionHandler:^{
    //                                                                            NSLog(@"PronViewController::cleanAction(), %@", record.displayName);
    //                                                                        }];
    //                             }
    //                         }];
}

- (IBAction)playAction:(UIButton *)sender {
    if (self.downloadUrlString.length == 0) {
        [self toast:@"No video urls can be play."];
        return;
    }
    
    [self play];
}

- (IBAction)downloadAction:(UIButton *)sender {
    if (self.downloadUrlString.length == 0) {
        [self toast:@"No video urls can be download."];
        return;
    }

    self.webView.hidden = YES;
    self.downloadTextView.hidden = NO;

    NSURLSessionTask *task;
    if (self.isHLS) {
        task = [[FileDownloadManager manager] downloadHLSURL:self.downloadUrlString];
    } else {
        task = [[FileDownloadManager manager] downloadURL:self.downloadUrlString];
    }
    //    NSURLSessionDownloadTask *task = [[FileDownloadManager manager] downloadURL:self.downloadUrlString];
    if (task) {
        DownloadAttachment *att = [[DownloadAttachment alloc] init];
        att.task = task;
        NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:@"[Download]"
                                                                                 attributes:@{
                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                     NSForegroundColorAttributeName : [UIColor blueColor],
                                                                                 }];
        NSString *content = [NSString stringWithFormat:@" %@", self.downloadUrlString];
        NSMutableAttributedString *contentAttStr = [[NSMutableAttributedString alloc] initWithString:content
                                                                                          attributes:@{
                                                                                              NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                              NSForegroundColorAttributeName : [self isDarkStyle] ? [UIColor whiteColor] : [UIColor darkGrayColor]
                                                                                          }];
        [line appendAttributedString:contentAttStr];
        att.statusString = line;

        @synchronized(self) {
            NSString *hash = [NSString stringWithFormat:@"%lu", [task hash]];
            self.taskURLDict[hash] = att;
        }
        [self changeDownloadStatus];
    }
}

- (void)selectDownloadURL {
    int maxResolution = 0;
    NSString *urlString = self.urlDict[@"ORIGINAL"];
    if (urlString.length == 0) {
        for (NSString *key in self.urlDict) {
            NSString *value = self.urlDict[key];
            NSURL *url = [NSURL URLWithString:value];
            NSString *path = url.path;

            NSString *regex = @"^.*.mp4$";
            NSRange range = [path rangeOfString:regex options:NSRegularExpressionSearch | NSBackwardsSearch];
            if (range.length > 0) {
                regex = @"[0-9]*P";
                NSRange range = [path rangeOfString:regex options:NSRegularExpressionSearch | NSBackwardsSearch];
                if (range.length > 0) {
                    NSRange range1 = NSMakeRange(range.location, range.length - 1);
                    NSString *resolution = [path substringWithRange:range1];
                    NSLog(@"[MP4], resolution: %@", resolution);
                    if (maxResolution < [resolution intValue]) {
                        maxResolution = [resolution intValue];
                        urlString = value;
                    }
                }
            }
        }

        if (urlString.length > 0) {
            self.isHLS = NO;
        }
    }

    if (urlString.length == 0) {
        for (NSString *key in self.urlDict) {
            NSString *value = self.urlDict[key];
            NSURL *url = [NSURL URLWithString:value];
            NSString *path = url.path;

            NSString *regex = @"^.*.m3u8";
            NSRange range = [path rangeOfString:regex options:NSRegularExpressionSearch | NSBackwardsSearch];
            if (range.length > 0) {
                regex = @"[0-9]*P";
                NSRange range = [path rangeOfString:regex options:NSRegularExpressionSearch | NSBackwardsSearch];
                if (range.length > 0) {
                    NSRange range1 = NSMakeRange(range.location, range.length - 1);
                    NSString *resolution = [path substringWithRange:range1];
                    NSLog(@"[HLS], resolution: %@", resolution);
                    if (maxResolution < [resolution intValue]) {
                        maxResolution = [resolution intValue];
                        urlString = value;
                    }
                }
            }
        }

        if (urlString.length > 0) {
            self.isHLS = YES;
        }
    }

    NSLog(@"[Select], %@", urlString);
    self.downloadUrlString = urlString;

    //    if (urlString.length > 0) {
    //        NSString *tips = [NSString stringWithFormat:@"%@ Found!", self.downloadUrlString];
    //        [self toast:tips];
    //    }
}

- (void)changeDownloadStatus {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    for (NSString *key in self.taskURLDict) {
        DownloadAttachment *att = (DownloadAttachment *)self.taskURLDict[key];
        NSAttributedString *line = [[NSAttributedString alloc] initWithAttributedString:att.statusString];
        [attrString appendAttributedString:line];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    self.downloadTextView.attributedText = attrString;
}

#define KB (1024)
#define MB (1024 * KB)
#define GB (1024 * MB)
- (NSString *)readableSize:(NSInteger)size {
    NSString *result = @"";
    NSString *unit = @"B";
    float floatSize = (1.0 * size);
    if (floatSize > GB) {
        floatSize = floatSize / GB;
        unit = @"G";
        result = [NSString stringWithFormat:@"%.2f%@", floatSize, unit];
    } else if (floatSize > MB) {
        floatSize = floatSize / MB;
        unit = @"M";
        result = [NSString stringWithFormat:@"%.1f%@", floatSize, unit];
    } else if (floatSize > KB) {
        floatSize = floatSize / KB;
        unit = @"K";
        result = [NSString stringWithFormat:@"%.0f%@", floatSize, unit];
    }
    return result;
}

#pragma mark - MP4
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    NSString *urlString = downloadTask.currentRequest.URL.absoluteString;
    float percent = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    NSString *percentString = [NSString stringWithFormat:@"(%@/%@) %.0f%%", [self readableSize:totalBytesWritten], [self readableSize:totalBytesExpectedToWrite], percent * 100];

    DownloadAttachment *att = [[DownloadAttachment alloc] init];
    att.task = downloadTask;
    NSString *attURL = [NSString stringWithFormat:@"Cancel://%lu", [downloadTask hash]];
    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:@"[Cancel]"
                                                                             attributes:@{
                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                 NSForegroundColorAttributeName : [UIColor blueColor],
                                                                                 NSLinkAttributeName : attURL,
                                                                                 NSAttachmentAttributeName : att
                                                                             }];
    NSString *content = [NSString stringWithFormat:@" %@ - %@", downloadTask.response.suggestedFilename, percentString];
    NSMutableAttributedString *contentAttStr = [[NSMutableAttributedString alloc] initWithString:content
                                                                                      attributes:@{
                                                                                          NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                          NSForegroundColorAttributeName : [self isDarkStyle] ? [UIColor whiteColor] : [UIColor darkGrayColor]
                                                                                      }];
    [line appendAttributedString:contentAttStr];
    att.statusString = line;

    @synchronized(self) {
        if (urlString.length > 0) {
            NSString *hash = [NSString stringWithFormat:@"%lu", [downloadTask hash]];
            self.taskURLDict[hash] = att;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeDownloadStatus];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSString *urlString = downloadTask.currentRequest.URL.absoluteString;
    float percent = 1.0 * fileOffset / expectedTotalBytes;
    NSString *percentString = [NSString stringWithFormat:@"(%@/%@) %.0f%%", [self readableSize:fileOffset], [self readableSize:expectedTotalBytes], percent * 100];
    NSLog(@"percentString: %@", percentString);

    DownloadAttachment *att = [[DownloadAttachment alloc] init];
    att.task = downloadTask;
    NSString *attURL = [NSString stringWithFormat:@"Cancel://%lu", [downloadTask hash]];
    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:@"[Cancel]"
                                                                             attributes:@{
                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                 NSForegroundColorAttributeName : [UIColor blueColor],
                                                                                 NSLinkAttributeName : attURL,
                                                                                 NSAttachmentAttributeName : att
                                                                             }];
    NSString *content = [NSString stringWithFormat:@" %@ - %@", downloadTask.response.suggestedFilename, percentString];
    NSMutableAttributedString *contentAttStr = [[NSMutableAttributedString alloc] initWithString:content
                                                                                      attributes:@{
                                                                                          NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                          NSForegroundColorAttributeName : [self isDarkStyle] ? [UIColor whiteColor] : [UIColor darkGrayColor]
                                                                                      }];
    [line appendAttributedString:contentAttStr];
    att.statusString = line;

    @synchronized(self) {
        if (urlString.length > 0) {
            NSString *hash = [NSString stringWithFormat:@"%lu", [downloadTask hash]];
            self.taskURLDict[hash] = att;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeDownloadStatus];
    });
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

    NSString *urlString = downloadTask.currentRequest.URL.absoluteString;
    DownloadAttachment *att = [[DownloadAttachment alloc] init];
    att.task = downloadTask;
    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:@"[Finish]"
                                                                             attributes:@{
                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                 NSForegroundColorAttributeName : [UIColor greenColor]
                                                                             }];
    NSString *content = [NSString stringWithFormat:@" %@", downloadTask.response.suggestedFilename];
    NSMutableAttributedString *contentAttStr = [[NSMutableAttributedString alloc] initWithString:content
                                                                                      attributes:@{
                                                                                          NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                          NSForegroundColorAttributeName : [self isDarkStyle] ? [UIColor whiteColor] : [UIColor darkGrayColor]
                                                                                      }];
    [line appendAttributedString:contentAttStr];
    att.statusString = line;

    @synchronized(self) {
        if (urlString.length > 0) {
            NSString *hash = [NSString stringWithFormat:@"%lu", [downloadTask hash]];
            self.taskURLDict[hash] = att;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeDownloadStatus];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"%@", error);
    if (error) {
        AVAssetDownloadTask *assetDownloadTask = nil;
        if ([task isKindOfClass:[AVAssetDownloadTask class]]) {
            assetDownloadTask = (AVAssetDownloadTask *)task;
        }
        NSString *urlString = assetDownloadTask ? assetDownloadTask.URLAsset.URL.absoluteString : task.currentRequest.URL.absoluteString;
        DownloadAttachment *att = [[DownloadAttachment alloc] init];
        att.task = task;
        NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:@"[Error]"
                                                                                 attributes:@{
                                                                                     NSForegroundColorAttributeName : [UIColor redColor]
                                                                                 }];
        NSString *suggestedFilename = assetDownloadTask ? [NSString stringWithFormat:@"%ld", [assetDownloadTask hash]] : [NSString stringWithFormat:@"%@", task.response.suggestedFilename];
        ;
        NSString *content = [NSString stringWithFormat:@" %@", suggestedFilename];
        NSMutableAttributedString *contentAttStr = [[NSMutableAttributedString alloc] initWithString:content
                                                                                          attributes:@{
                                                                                              NSForegroundColorAttributeName : [self isDarkStyle] ? [UIColor whiteColor] : [UIColor darkGrayColor]
                                                                                          }];
        [line appendAttributedString:contentAttStr];
        att.statusString = line;
        @synchronized(self) {
            if (urlString.length > 0) {
                NSString *hash = [NSString stringWithFormat:@"%lu", [task hash]];
                self.taskURLDict[hash] = att;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeDownloadStatus];
        });
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - HLS
- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad {
    NSString *urlString = assetDownloadTask.URLAsset.URL.absoluteString;
    float percent = 1.0 * CMTimeGetSeconds(timeRange.start) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration);
    NSString *percentString = [NSString stringWithFormat:@"(%.0f/%.0f) seconds %.0f%%",
                                                         CMTimeGetSeconds(timeRange.start),
                                                         CMTimeGetSeconds(timeRangeExpectedToLoad.duration),
                                                         percent * 100];

    NSLog(@"%.0f/%.0f seconds",
          CMTimeGetSeconds(timeRange.start), CMTimeGetSeconds(timeRangeExpectedToLoad.duration));

    DownloadAttachment *att = [[DownloadAttachment alloc] init];
    att.task = assetDownloadTask;
    NSString *attURL = [NSString stringWithFormat:@"Cancel://%lu", [assetDownloadTask hash]];
    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:@"[Cancel]"
                                                                             attributes:@{
                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                 NSForegroundColorAttributeName : [UIColor blueColor],
                                                                                 NSLinkAttributeName : attURL,
                                                                                 NSAttachmentAttributeName : att
                                                                             }];
    NSString *content = [NSString stringWithFormat:@" %lu - %@", [assetDownloadTask hash], percentString];
    NSMutableAttributedString *contentAttStr = [[NSMutableAttributedString alloc] initWithString:content
                                                                                      attributes:@{
                                                                                          NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                          NSForegroundColorAttributeName : [self isDarkStyle] ? [UIColor whiteColor] : [UIColor darkGrayColor]
                                                                                      }];
    [line appendAttributedString:contentAttStr];
    att.statusString = line;

    @synchronized(self) {
        if (urlString.length > 0) {
            NSString *hash = [NSString stringWithFormat:@"%lu", [assetDownloadTask hash]];
            self.taskURLDict[hash] = att;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeDownloadStatus];
    });
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"location: %@", location);

    NSString *urlString = assetDownloadTask.URLAsset.URL.absoluteString;
    DownloadAttachment *att = [[DownloadAttachment alloc] init];
    att.task = assetDownloadTask;
    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:@"[Finish]"
                                                                             attributes:@{
                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                 NSForegroundColorAttributeName : [UIColor greenColor]
                                                                             }];
    NSString *content = [NSString stringWithFormat:@" %lu", [assetDownloadTask hash]];
    NSMutableAttributedString *contentAttStr = [[NSMutableAttributedString alloc] initWithString:content
                                                                                      attributes:@{
                                                                                          NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                          NSForegroundColorAttributeName : [self isDarkStyle] ? [UIColor whiteColor] : [UIColor darkGrayColor]
                                                                                      }];
    [line appendAttributedString:contentAttStr];
    att.statusString = line;

    @synchronized(self) {
        if (urlString.length > 0) {
            NSString *hash = [NSString stringWithFormat:@"%lu", [assetDownloadTask hash]];
            self.taskURLDict[hash] = att;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeDownloadStatus];
    });
}

#pragma mark - WebView回调
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
    if (navigationAction.targetFrame.mainFrame) {
        NSLog(@"mainFrame:%d, %ld, %@", navigationAction.targetFrame.mainFrame, navigationAction.navigationType, navigationAction.request.URL.absoluteString);
    }
    if ([self.textFieldAddress.text isEqual:navigationAction.request.URL.absoluteString] || (navigationAction.targetFrame.mainFrame)) {
        self.textFieldAddress.text = navigationAction.request.URL.absoluteString;
    }

    if (navigationAction.navigationType == WKNavigationTypeBackForward) {
        self.forward = NO;
        self.title = webView.title;
    } else {
        self.forward = YES;
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    NSLog(@"forMainFrame:%d, %@, URL:%@", navigationResponse.forMainFrame, webView.title, navigationResponse.response.URL.absoluteString);
    [self checkDownloadURL:self.forward];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error: %@", error);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"");
    self.title = @"Loading...";
    self.downloadUrlString = @"";
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"title: %@", webView.title);
    self.title = webView.title;
    [self showBanner];
    [self checkDownloadURL:self.forward];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error:%@", error);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"");
}

#pragma mark - 输入回调
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL result = YES;
    [textField resignFirstResponder];
    return result;
}

#pragma mark - 富文本回调
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"Cancel"]) {
        NSString *hash = [URL host];
        DownloadAttachment *att = (DownloadAttachment *)self.taskURLDict[hash];
        [att.task cancel];
    }
    return YES;
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    //    BOOL bFlag = NO;

    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];

    if (height != 0) {
        // 弹出键盘

    } else {
        // 收起键盘
    }

    [UIView animateWithDuration:duration
                     animations:^{
                         // Make all constraint changes here, Called on parent view
                         [self.view layoutIfNeeded];

                     }
                     completion:^(BOOL finished){

                     }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    // 动画收起键盘
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

@end
