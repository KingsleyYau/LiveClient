//
//  StreamHlsViewController.m
//  RtmpClientTest
//
//  Created by Max on 2021/5/21.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import "StreamHlsViewController.h"
#import "OCTimer.h"
#import "LiveItem.h"
#import "StreamTitleView.h"

#import <AVFoundation/AVFoundation.h>

@interface StreamHlsViewController ()
@property (strong) IBOutlet NSLayoutConstraint *previewTop;
@property (strong) IBOutlet NSLayoutConstraint *previewViewRadio;
@property (strong) IBOutlet NSLayoutConstraint *previewViewBottom;
@property (weak) IBOutlet UIView *controlView;

@property (weak) IBOutlet UIView *playerView;
@property (strong) AVPlayerItem *item;
@property (strong) AVPlayer *player;
@property (strong) AVPlayerLayer *playerLayer;
@property (strong) NSArray<LiveItem *> *items;
@property (strong) LiveItem *liveItem;
@property (assign) NSInteger liveItemIndex;
@property (strong) OCTimer *timer;
@property (assign) UIDeviceOrientation deviceOrientation;
@end

@implementation StreamHlsViewController
- (void)dealloc {
    [self removeObserve];
    [self.player pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    // TODO:旋转
    self.deviceOrientation = [UIDevice currentDevice].orientation;

    // 加载数据
    [self reloadData];
    // 界面处理
    [self play];

    self.timer = [[OCTimer alloc] init];
    [self.timer startTimer:nil
              timeInterval:180 * NSEC_PER_SEC
                   starNow:YES
                    action:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self tryAllAD];
                        });
                    }];

    // 显示广告
    [self tryAllAD];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        // 添加旋转事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    [super viewDidAppear:animated];

    self.playerLayer.frame = self.playerView.frame;
    [self.player play];
}

- (void)reloadData {
    self.liveItemIndex = 0;
    NSMutableArray *newItems = [NSMutableArray array];

    LiveItem *liveItem = [[LiveItem alloc] init];
    liveItem.name = @"高清翡翠台";
    liveItem.url = @"http://116.199.5.52:8114/index.m3u8?Fsv_chan_hls_se_idx=188&FvSeid=1&Fsv_ctype=LIVES&Fsv_otype=1&Provider_id=&Pcontent_id=.m3u8";
    liveItem.logo = [UIImage imageNamed:@"TVB-HD"];
    [newItems addObject:liveItem];

    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"明珠台";
    liveItem.url = @"http://116.199.5.52:8114/index.m3u8?Fsv_chan_hls_se_idx=12&FvSeid=1&Fsv_ctype=LIVES&Fsv_otype=1&Provider_id=&Pcontent_id=.m3u8";
    liveItem.logo = [UIImage imageNamed:@"TVB-MZ"];
    [newItems addObject:liveItem];

    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"香港卫视";
    liveItem.url = @"http://zhibo.hkstv.tv/livestream/mutfysrq/playlist.m3u8";
    liveItem.logo = [UIImage imageNamed:@"HKS"];
    [newItems addObject:liveItem];
    
    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"香港电台";
    liveItem.url = @"http://rthklive1-lh.akamaihd.net/i/rthk31_1@167495/index_2052_av-p.m3u8?sd=10&rebase=on";
    [newItems addObject:liveItem];
    
    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"香港开电视";
    liveItem.url = @"http://media.fantv.hk/m3u8/archive/channel2_stream1.m3u8";
    [newItems addObject:liveItem];
    
    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"广州电视台综合频道";
    liveItem.url = @"https://aplays.gztv.com/live/zhonghes.m3u8?txTime=60A77C19&txSecret=a5f6ffc19fdfa0d8ff4d3860a4da98d6";
    [newItems addObject:liveItem];
    
    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"广州电视台新闻频道";
    liveItem.url = @"https://aplays.gztv.com/live/xinwen.m3u8?txTime=60A77B94&txSecret=8b7914caed9e724816849433acc3f345";
    [newItems addObject:liveItem];
    
    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"广州电视台影视频道";
    liveItem.url = @"https://aplays.gztv.com/live/yingshi.m3u8?txTime=60A77B1E&txSecret=ba8171e80b21a1728239474f29bdfd12";
    [newItems addObject:liveItem];

    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"浙江卫视";
    liveItem.url = @"http://hw-m-l.cztv.com/channels/lantian/channel01/360p.m3u8";
//    liveItem.logo = [UIImage imageNamed:@"HKS"];
    [newItems addObject:liveItem];
    
    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"韩国CBS";
    liveItem.url = @"http://cbs-live.gscdn.com/cbs-live/cbs-live.stream/playlist.m3u8";
    [newItems addObject:liveItem];
    
    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"韩国KBS1";
    liveItem.url = @"http://ebsonair.ebs.co.kr/groundwavefamilypc/familypc1m/chunklist_w1960240276.m3u8";
    [newItems addObject:liveItem];

    liveItem = [[LiveItem alloc] init];
    liveItem.name = @"韩国EBSeHD";
    liveItem.url = @"http://ebsonair.ebs.co.kr/plus3familypc/familypc1m/playlist.m3u8";
    [newItems addObject:liveItem];

    self.items = newItems;
    self.liveItem = [self.items objectAtIndex:self.liveItemIndex];
}

- (void)reloadTitleView {
    StreamTitleView *titleView = [StreamTitleView view];
    titleView.logoImageView.image = self.liveItem.logo;
    titleView.titleLabel.text = self.liveItem.name;
    titleView.activityView.hidden = self.item.playbackLikelyToKeepUp;

    [titleView.titleLabel sizeToFit];
    [titleView sizeToFit];
    self.navigationItem.titleView = titleView;
}

- (void)refreshLayer {
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.playerView.layer addSublayer:self.playerLayer];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame = self.playerView.frame;
}

- (void)play {
    [self removeObserve];
    [self.player pause];

    NSURL *url = [NSURL URLWithString:self.liveItem.url];
    self.item = [[AVPlayerItem alloc] initWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.item];

    [self refreshLayer];
    [self reloadTitleView];
    [self addObserve];
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

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 添加播放监听
- (void)addObserve {
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserve {
    [self.item removeObserver:self forKeyPath:@"status"];
    [self.item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString *, id> *)change context:(nullable void *)context {
    NSLog(@"keyPath: %@, status: %d, object: %@, ", keyPath, (int)self.item.status, object);
    if ([keyPath isEqualToString:@"status"]) {
        if (self.item.status == AVPlayerItemStatusFailed) {
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

@end
