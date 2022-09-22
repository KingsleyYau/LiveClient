//
//  StreamHlsViewController.m
//  RtmpClientTest
//
//  Created by Max on 2021/5/21.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import "StreamHlsViewController.h"
#import "StreamLiveItemTableViewController.h"
#import "OCTimer.h"
#import "LiveItem.h"
#import "LiveCategory.h"
#import "StreamTitleView.h"
#import "LiveStreamSession.h"
#import "FileDownloadManager.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface StreamHlsViewController () <StreamLiveItemTableViewControllerDelegate, AVPictureInPictureControllerDelegate, NSURLSessionDownloadDelegate>
@property (strong) IBOutlet NSLayoutConstraint *previewTop;
@property (strong) IBOutlet NSLayoutConstraint *previewViewRadio;
@property (strong) IBOutlet NSLayoutConstraint *previewViewBottom;
@property (weak) IBOutlet UIView *controlView;
@property (weak) IBOutlet UIButton *recordButton;

@property (weak) IBOutlet UIView *playerView;
@property (strong) AVPlayerItem *playerItem;
@property (strong) AVPlayer *player;
@property (strong) AVPlayerLayer *playerLayer;

@property (strong) NSArray<LiveCategory *> *categories;
@property (assign) NSInteger categoryIndex;

@property (strong) NSArray<LiveItem *> *items;
@property (strong) LiveItem *liveItem;
@property (assign) NSInteger liveItemIndex;

@property (strong) OCTimer *timer;
@property (assign) UIDeviceOrientation deviceOrientation;

@property (strong) AVPictureInPictureController *pictureVC;
@property (strong) NSURLSessionTask *task;
@end

@implementation StreamHlsViewController
- (void)dealloc {
    [[FileDownloadManager manager] removeDelegate:self];
    [self stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Nav-ListButton"] style:UIBarButtonItemStylePlain target:self action:@selector(listAction:)];

    // TODO:旋转
    self.deviceOrientation = [UIDevice currentDevice].orientation;

    self.timer = [[OCTimer alloc] init];
    [self.timer startTimer:nil
              timeInterval:60 * NSEC_PER_SEC
                   starNow:YES
                    action:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showBanner];
                        });
                    }];

    [[FileDownloadManager manager] addDelegate:self];

    [self.recordButton setImage:[UIImage imageNamed:@"CheckButtonSelected"] forState:UIControlStateSelected];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        // 添加旋转事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        // 加载数据
        [self requestCategories];
    }
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stop];
    [self.pictureVC stopPictureInPicture];
    [self.timer stopTimer];
}

#pragma mark - 数据
- (void)requestCategories {
    NSString *url = @"https://maxzoon.cn/api/tv_list";
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req
                                                                 completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                                     if (!error) {
                                                                         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             [self handleData:dict];
                                                                         });
                                                                     } else {
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             [self toast:@"网络错误, 请稍后重试."];
                                                                         });
                                                                     }
                                                                 }];
    [task resume];
}

- (void)handleData:(NSDictionary *)dict {
    NSNumber *err = dict[@"errno"];
    if ([err isEqualToNumber:@0]) {
        NSMutableArray *categories = [NSMutableArray array];
        NSArray *dict_categories = dict[@"data"];
        for (NSDictionary *dict_category in dict_categories) {
            LiveCategory *category = [[LiveCategory alloc] init];
            [categories addObject:category];

            category.name = dict_category[@"category"];
            NSMutableArray *category_items = [NSMutableArray array];
            NSArray *dict_category_items = dict_category[@"items"];
            for (NSDictionary *dict_category_item in dict_category_items) {
                LiveItem *item = [[LiveItem alloc] init];
                item.name = dict_category_item[@"name"];
                item.url = dict_category_item[@"url"];
                [category_items addObject:item];
            }
            category.items = category_items;
        }
        self.categories = categories;

        [self reloadData];

    } else {
        NSString *errmsg = dict[@"errmsg"];
        NSString *tips = [NSString stringWithFormat:@"网络错误, 请稍后重试. [%@]", errmsg];
        [self toast:tips];
    }
}

- (void)reloadData {
    self.categoryIndex = 0;
    if (self.categories.count > 0) {
        self.items = self.categories[self.categoryIndex].items;
        self.liveItemIndex = 0;
        if (self.items.count > 0) {
            self.liveItem = [self.items objectAtIndex:self.liveItemIndex];
            [self play];
        }
    }
}

#pragma mark - 界面
- (void)reloadTitleView {
    StreamTitleView *titleView = [StreamTitleView view];
    titleView.logoImageView.image = self.liveItem.logo;
    titleView.titleLabel.text = self.liveItem.name;
    titleView.activityView.hidden = self.playerItem.playbackLikelyToKeepUp;

    [titleView.titleLabel sizeToFit];
    [titleView sizeToFit];
    self.navigationItem.titleView = titleView;
}

- (void)refreshLayer {
    self.playerLayer.frame = CGRectMake(0, 0, self.playerView.frame.size.width, self.playerView.frame.size.height);
}

#pragma mark - 播放控制
- (void)play {
    [self stop];

    if (self.liveItem) {
        NSURL *url = [NSURL URLWithString:self.liveItem.url];
        self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
        if (self.player) {
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        } else {
            self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            [self.playerView.layer addSublayer:self.playerLayer];
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            self.pictureVC = [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
            self.pictureVC.delegate = self;
        }
        [self.player play];

        [self refreshLayer];
        [self reloadTitleView];
        [self addObserve];

        [[LiveStreamSession session] startPlay];
    }
}

- (void)stop {
    if (self.playerItem) {
        [self removeObserve];
        [self.player pause];
        self.playerItem = nil;
        [[LiveStreamSession session] stopPlay];
    }
}

- (IBAction)preAction:(UIButton *)sender {
    // TODO:切换上一个频道
    if (self.liveItemIndex == 0) {
        self.liveItemIndex = self.items.count;
    }

    self.liveItemIndex--;
    self.liveItemIndex %= self.items.count;

    self.liveItem = [self.items objectAtIndex:self.liveItemIndex];
    NSLog(@"切换上一个频道[%@]", self.liveItem.name);
    [self play];
}

- (IBAction)nextAction:(UIButton *)sender {
    // TODO:切换下一个频道
    self.liveItemIndex++;
    self.liveItemIndex %= self.items.count;

    self.liveItem = [self.items objectAtIndex:self.liveItemIndex];
    NSLog(@"切换下一个频道[%@]", self.liveItem.name);
    [self play];
}

- (IBAction)listAction:(id)sender {
    // TODO:节目列表
    StreamLiveItemTableViewController *vc = [[StreamLiveItemTableViewController alloc] initWithNibName:nil bundle:nil];
    vc.categories = self.categories;
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc
                                            animated:YES
                                          completion:^{

                                          }];
}

- (IBAction)pictureAction:(id)sender {
    // TODO:画中画
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        if ([self.pictureVC isPictureInPictureActive]) {
            [self.pictureVC stopPictureInPicture];
        } else {
            [self.pictureVC startPictureInPicture];
        }
    }
}

- (IBAction)recordAction:(UIButton *)sender {
    // TODO:录制
    if (sender.selected) {
        [self.task cancel];
    } else {
        self.task = [[FileDownloadManager manager] downloadHLSURL:self.liveItem.url];
    }
    sender.selected = !sender.selected;
}

- (void)streamTableView:(StreamLiveItemTableViewController *)vc didSelectLiveItem:(LiveItem *)liveItem category:(LiveCategory *)category {
    // TODO:选择频道
    self.categoryIndex = [self.categories indexOfObject:category];
    self.items = self.categories[self.categoryIndex].items;
    self.liveItemIndex = [self.items indexOfObject:liveItem];
    self.liveItem = [self.items objectAtIndex:self.liveItemIndex];
    [self play];
}

#pragma mark - 画中画通知
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"");
}
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"");
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"");
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"");
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    NSLog(@"");
}

#pragma mark - 添加播放监听
- (void)addObserve {
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserve {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString *, id> *)change context:(nullable void *)context {
    NSLog(@"keyPath: %@, status: %d, object: %@, ", keyPath, (int)self.playerItem.status, object);
    if ([keyPath isEqualToString:@"status"]) {
        if (self.playerItem.status == AVPlayerItemStatusFailed) {
            NSString *tips = [NSString stringWithFormat:@"当前频道失效, 切换到下一个频道"];
            [self toast:tips];
            [self nextAction:nil];
        }
    } else if (
        [keyPath isEqualToString:@"playbackBufferEmpty"] ||
        [keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        // 刷新状态栏
        [self reloadTitleView];

        // 继续播放
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            [self.player play];
        }
    }
}

#pragma mark - 旋转和全屏播放
- (void)deviceOrientationChange:(id)sender {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsValidInterfaceOrientation(deviceOrientation)) {
        self.deviceOrientation = deviceOrientation;
        [self changeOrientation];
    }
}

- (void)changeOrientation {
    UIDeviceOrientation deviceOrientation = self.deviceOrientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            // Device oriented vertically, home button on the bottom
            NSLog(@"StreamViewController::deviceOrientationChange( [Portrait] )");
        case UIDeviceOrientationPortraitUpsideDown: {
            // Device oriented vertically, home button on the top
            NSLog(@"StreamViewController::deviceOrientationChange( [PortraitUpsideDown] )");
            [self hideControll:NO];
        } break;
        case UIDeviceOrientationLandscapeLeft:
            // Device oriented horizontally, home button on the right
            NSLog(@"StreamViewController::deviceOrientationChange( [LandscapeLeft] )");
        case UIDeviceOrientationLandscapeRight: {
            // Device oriented horizontally, home button on the left
            NSLog(@"StreamViewController::deviceOrientationChange( [LandscapeRight] )");
            [self hideControll:YES];
        } break;
        default:
            break;
    }
}

- (void)hideControll:(BOOL)hidden {
    if ([self.navigationController.topViewController isEqual:self]) {
        [self.navigationController setNavigationBarHidden:hidden];
    }
    self.controlView.hidden = hidden;

    if (hidden) {
        [NSLayoutConstraint deactivateConstraints:@[ self.previewViewRadio ]];
        [NSLayoutConstraint activateConstraints:@[ self.previewViewBottom ]];
    } else {
        [NSLayoutConstraint deactivateConstraints:@[ self.previewViewBottom ]];
        [NSLayoutConstraint activateConstraints:@[ self.previewViewRadio ]];
    }
    [self.view layoutSubviews];
    [self refreshLayer];
}

#pragma mark - HLS
- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    if (self.task == assetDownloadTask) {
        NSLog(@"location: %@", location);

        dispatch_async(dispatch_get_main_queue(), ^{
        });
    }
}

@end
