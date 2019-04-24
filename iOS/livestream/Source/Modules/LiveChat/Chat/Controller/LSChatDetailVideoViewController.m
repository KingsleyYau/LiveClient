//
//  LSChatDetailVideoViewController.m
//  livestream
//
//  Created by Randy_Fan on 2019/3/20.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSChatDetailVideoViewController.h"
#import "LSAddCreditsViewController.h"

#import "LSVideoPlayManager.h"
#import "LSImageViewLoader.h"
#import "LSLiveChatManagerListener.h"

#import "LSShadowView.h"
#import "LSLadyVideoProgressView.h"
#import "LSVideoView.h"

#import "LiveGobalManager.h"

@interface LSChatDetailVideoViewController ()<LSVideoPlayManagerDelegate, LSLiveChatManagerListenerDelegate>

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIView *coverShadowView;

@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet UIView *buyVideoView;
@property (weak, nonatomic) IBOutlet UILabel *anchorsTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *playNowBtn;

@property (weak, nonatomic) IBOutlet UIView *retryView;
@property (weak, nonatomic) IBOutlet UILabel *retryLabel;
@property (weak, nonatomic) IBOutlet UIButton *reteyButton;

@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;

@property (weak, nonatomic) IBOutlet UILabel *representLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeView;

@property (strong, nonatomic) UIVisualEffectView *effectView;

@property (strong, nonatomic) LSVideoPlayManager *playManager;

@property (strong, nonatomic) LSLiveChatManagerOC *liveChatManager;

// 是否点击播放按钮
@property (assign, nonatomic) BOOL isPlay;

@property (strong, nonatomic) LSVideoView *showVideoView;
// 是否正在播放
@property (assign, nonatomic) BOOL isPlaying;
// 是否在后台
@property (assign, nonatomic) BOOL isBack;

@end

@implementation LSChatDetailVideoViewController

- (void)dealloc {
    [self.liveChatManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.playManager = [[LSVideoPlayManager alloc] init];
    [self.playManager setVideoAspectFill:NO];
    
    self.liveChatManager = [LSLiveChatManagerOC manager];
    [self.liveChatManager addDelegate:self];
    
    self.isPlay = NO;
    
    self.isShowNavBar = NO;
    
    self.isPlaying = NO;
    
    self.isBack = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reteyButton.layer.cornerRadius = self.reteyButton.frame.size.height / 2;
    self.reteyButton.layer.masksToBounds = YES;
    LSShadowView *reteyShadow = [[LSShadowView alloc] init];
    [reteyShadow showShadowAddView:self.reteyButton];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.effectView];
    [self.view insertSubview:self.effectView aboveSubview:self.backgroundImageView];
    
    // 判断入口
    if (self.msgItem) {
        self.representLabel.text = self.msgItem.videoMsg.videoDesc;
        
        UIImage *image = [UIImage imageWithContentsOfFile:self.msgItem.videoMsg.bigPhotoFilePath];
        if (image) {
            self.coverImageView.image = image;
            self.backgroundImageView.image = image;
        } else {
            [self.liveChatManager getVideoPhoto:self.msgItem.fromId videoId:self.msgItem.videoMsg.videoId inviteId:self.msgItem.inviteId];
        }
    } else {
        self.representLabel.text = self.recentItem.title;
        [[LSImageViewLoader loader] loadImageWithImageView:self.coverImageView options:0 imageUrl:self.recentItem.videoCover placeholderImage:nil finishHandler:^(UIImage *image) {
            
        }];
        [[LSImageViewLoader loader] loadImageWithImageView:self.backgroundImageView options:0 imageUrl:self.recentItem.videoCover placeholderImage:nil finishHandler:^(UIImage *image) {
            
        }];
    }
    
    self.showVideoView = [[LSVideoView alloc] initWithFrame:self.view.bounds isSlider:YES isShowPlayTime:0 isPerformShow:NO];
    self.showVideoView.userInteractionEnabled = NO;
    [self.showVideoView setProgressPlaySuspendOrStart:NO];
    [self.view insertSubview:self.showVideoView belowSubview:self.coverImageView];
    [self.showVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.playManager.delegate = self;
    
    if (self.msgItem) {
        if (self.msgItem.videoMsg.charge) {
            [self showPlayView];
        } else {
            [self showBuyVideoView];
        }
    } else {
        [self showPlayView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 如果在直播间中 关闭直播间声音
    [[LiveGobalManager manager] openOrCloseLiveSound:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.playManager removeVideoView];
    [self.playManager removeNotification];
    
    [[LiveGobalManager manager] openOrCloseLiveSound:YES];
}

#pragma mark - 界面显示/隐藏
- (void)showBuyVideoView {
    self.showVideoView.hidden = NO;
    self.effectView.hidden = NO;
    self.buyVideoView.hidden = NO;
    self.backgroundImageView.hidden = NO;
    self.coverImageView.hidden = NO;
    self.coverShadowView.hidden = NO;
    self.representLabel.hidden = NO;
    self.shadowView.hidden = YES;
    self.playVideoButton.hidden = YES;
    self.retryView.hidden = YES;
    [self activeViewIsHidden:YES];
}

- (void)showPlayView {
    self.showVideoView.hidden = NO;
    self.effectView.hidden = NO;
    self.backgroundImageView.hidden = NO;
    self.coverImageView.hidden = NO;
    self.coverShadowView.hidden = NO;
    self.playVideoButton.hidden = NO;
    self.representLabel.hidden = NO;
    self.shadowView.hidden = YES;
    self.retryView.hidden = YES;
    self.buyVideoView.hidden = YES;
    [self activeViewIsHidden:YES];
}

- (void)showErrorTipView:(NSString *)tip isShowRetry:(BOOL)isShow {
    self.showVideoView.hidden = NO;
    self.effectView.hidden = NO;
    self.backgroundImageView.hidden = NO;
    self.coverImageView.hidden = NO;
    self.coverShadowView.hidden = NO;
    self.retryView.hidden = NO;
    self.retryLabel.text = tip;
    self.reteyButton.hidden = !isShow;
    self.representLabel.hidden = NO;
    self.shadowView.hidden = YES;
    self.buyVideoView.hidden = YES;
    self.playVideoButton.hidden = YES;
    [self activeViewIsHidden:YES];
}

- (void)hiddenAllView {
    self.representLabel.hidden = NO;
    self.showVideoView.hidden = YES;
    self.shadowView.hidden = YES;
    self.effectView.hidden = YES;
    self.backgroundImageView.hidden = YES;
    self.coverImageView.hidden = YES;
    self.coverShadowView.hidden = YES;
    self.buyVideoView.hidden = YES;
    self.retryView.hidden = YES;
    self.playVideoButton.hidden = YES;
}

- (void)activeViewIsHidden:(BOOL)isHidden {
    self.activeView.hidden = isHidden;
    if (isHidden) {
        [self.activeView stopAnimating];
        self.view.userInteractionEnabled = YES;
    } else {
        [self.activeView startAnimating];
        self.view.userInteractionEnabled = NO;
    }
}

#pragma mark - LSVideoPlayManagerDelegate
- (void)onRecvVideoPlayOrSuspend:(BOOL)isSuspend {
    if (!self.isBack) {
        self.isPlaying = !isSuspend;
    }
}

- (void)onRecvShowLadyProgressView:(BOOL)isShow {
    self.representLabel.hidden = isShow;
}

- (void)onRecvVideoDownloadFail {
}

- (void)onRecvVideoDownloadSucceed:(NSString *)path {
}

- (void)onRecvVideoPlayFailed {
    // TODO: 视频播放失败
    [self showErrorTipView:NSLocalizedStringFromSelf(@"6Vs-AX-cjx.text") isShowRetry:YES];
}

- (void)onRecvVideoPlayDone {
    // TODO: 视频播放完成
    self.isPlaying = NO;
    self.shadowView.hidden = NO;
    self.playVideoButton.hidden = NO;
}

- (void)onRecvVideoPlayBufferEmpty {
    // TODO: 缓冲加载中
    [self activeViewIsHidden:NO];
}

- (void)onRecvVideoPlayLikelyToKeepUp {
    // TODO: 进行跳转后有数据可以播放
    [self activeViewIsHidden:YES];
}

- (void)onRecvVideoIsReadyToPlay {
    // TODO: 缓冲可以播放
    self.isPlaying = YES;
    [self activeViewIsHidden:YES];
}

#pragma mark - Action
- (IBAction)buyVideoAction:(id)sender {
    BOOL result = [self.liveChatManager videoFee:self.msgItem.fromId videoId:self.msgItem.videoMsg.videoId inviteId:self.msgItem.inviteId];
    if (result) {
        [self activeViewIsHidden:NO];
    } else {
        [self activeViewIsHidden:YES];
        [self showErrorTipView:NSLocalizedString(@"NetworkError", nil) isShowRetry:YES];
    }
}

- (IBAction)retryPlayAction:(id)sender {
    if (self.msgItem) {
        BOOL result = [self.liveChatManager videoFee:self.msgItem.fromId videoId:self.msgItem.videoMsg.videoId inviteId:self.msgItem.inviteId];
        if (result) {
            [self activeViewIsHidden:NO];
        } else {
            [self activeViewIsHidden:YES];
            [self showErrorTipView:NSLocalizedString(@"NetworkError", nil) isShowRetry:YES];
        }
    } else {
        [self hiddenAllView];
        [self activeViewIsHidden:NO];
        [self.playManager playChatVideo:self.recentItem.videoUrl forView:self.videoView playTime:0 isShowSlider:YES isShowPlayTime:NO isUrlPlay:YES];
    }
}

- (IBAction)playVideoAction:(id)sender {
    self.isPlay = YES;
    
    [self hiddenAllView];
    [self activeViewIsHidden:NO];
    
    if (self.msgItem) {
        NSData *data = [NSData dataWithContentsOfFile:self.msgItem.videoMsg.videoFilePath];
        if (data) {
            [self.playManager playChatVideo:self.msgItem.videoMsg.videoFilePath forView:self.videoView playTime:0 isShowSlider:YES isShowPlayTime:NO isUrlPlay:NO];
        } else {
            [self.liveChatManager getVideo:self.msgItem.fromId videoId:self.msgItem.videoMsg.videoId inviteId:self.msgItem.inviteId videoUrl:self.msgItem.videoMsg.videoUrl msgId:(int)self.msgItem.msgId];
        }
    } else {
        [self.playManager playChatVideo:self.recentItem.videoUrl forView:self.videoView playTime:0 isShowSlider:YES isShowPlayTime:NO isUrlPlay:YES];
    }
}

#pragma mark - LSLiveChatManagerListenerDelegate
- (void)onVideoFee:(bool)success errNo:(NSString *)errNo errMsg:(NSString *)errMsg msgItem:(LSLCLiveChatMsgItemObject *)msgItem {
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSChatDetailVideoViewController::onVideoFee([购买视频回调] success : %@, errNo : %@, errMsg : %@, msgId : %ld)",BOOL2SUCCESS(success), errNo, errMsg, (long)msgItem.msgId);
        
        [weakSelf activeViewIsHidden:YES];
        
        BOOL isEqUserId = [weakSelf.msgItem.fromId isEqualToString:msgItem.fromId];
        BOOL isEqVideoId = [weakSelf.msgItem.videoMsg.videoId isEqualToString:msgItem.videoMsg.videoId];
        BOOL isEqInviteId = [weakSelf.msgItem.inviteId isEqualToString:msgItem.inviteId];
        
        if (isEqUserId && isEqVideoId && isEqInviteId) {
            if (success) {
                weakSelf.msgItem.videoMsg.charge = YES;
                
                if (msgItem.videoMsg.videoUrl.length > 0) {
                    weakSelf.msgItem.videoMsg.videoUrl = msgItem.videoMsg.videoUrl;
                }
                
                weakSelf.isPlay = NO;
                // 购买成功 下载视频
                [weakSelf.liveChatManager getVideo:weakSelf.msgItem.fromId videoId:weakSelf.msgItem.videoMsg.videoId inviteId:weakSelf.msgItem.inviteId videoUrl:weakSelf.msgItem.videoMsg.videoUrl msgId:(int)weakSelf.msgItem.msgId];
                
                [weakSelf showPlayView];
            } else {
                if ([self.liveChatManager isNoMoneyWithErrCode:errNo]) {
                    if (self.viewDelegate != nil && [self.viewDelegate respondsToSelector:@selector(videoDetailspushAddCreditsViewController)]) {
                        [self.viewDelegate videoDetailspushAddCreditsViewController];
                    }
                } else if (msgItem.procResult.errType == LSLIVECHAT_LCC_ERR_CONNECTFAIL) {
                    [weakSelf showErrorTipView:NSLocalizedString(@"NetworkError", nil) isShowRetry:YES];
                } else {
                    [weakSelf showErrorTipView:errMsg isShowRetry:NO];
                }
            }
        }
    });
}

- (void)onGetVideo:(LSLIVECHAT_LCC_ERR_TYPE)errType userId:(NSString *)userId videoId:(NSString *)videoId inviteId:(NSString *)inviteId videoPath:(NSString *)videoPath msgList:(NSArray<LSLCLiveChatMsgItemObject *> *)msgList {
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSChatDetailVideoViewController::onGetVideo([获取视频路径] errType : %d, userId : %@, videoId : %@, inviteId : %@, videoPath : %@)",errType, userId, videoId, inviteId, videoPath);
        
        [weakSelf activeViewIsHidden:YES];
        
        BOOL isEqUserId = [weakSelf.msgItem.fromId isEqualToString:userId];
        BOOL isEqVideoId = [weakSelf.msgItem.videoMsg.videoId isEqualToString:videoId];
        BOOL isEqInviteId = [weakSelf.msgItem.inviteId isEqualToString:inviteId];
        if (errType == LSLIVECHAT_LCC_ERR_SUCCESS && isEqUserId && isEqVideoId && isEqInviteId) {
            
            weakSelf.msgItem.videoMsg.videoFilePath = videoPath;
            
            if (weakSelf.isPlay) {
                NSData *data = [NSData dataWithContentsOfFile:videoPath];
                if (data) {
                    [weakSelf hiddenAllView];
                    [weakSelf.playManager playChatVideo:weakSelf.msgItem.videoMsg.videoFilePath forView:weakSelf.videoView playTime:0 isShowSlider:YES isShowPlayTime:NO isUrlPlay:NO];
                }
            }
        }
    });
}

- (void)onGetVideoPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(NSString *)errNo errMsg:(NSString *)errMsg userId:(NSString *)userId inviteId:(NSString *)inviteId videoId:(NSString *)videoId videoType:(VIDEO_PHOTO_TYPE)videoType videoPath:(NSString *)videoPath msgList:(NSArray<LSLCLiveChatMsgItemObject *> *)msgList {
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isEqUserId = [weakSelf.msgItem.fromId isEqualToString:userId];
        BOOL isEqVideoId = [weakSelf.msgItem.videoMsg.videoId isEqualToString:videoId];
        BOOL isEqInviteId = [weakSelf.msgItem.inviteId isEqualToString:inviteId];
        if (errType == LSLIVECHAT_LCC_ERR_SUCCESS && isEqUserId && isEqVideoId && isEqInviteId) {
            weakSelf.msgItem.videoMsg.bigPhotoFilePath = videoPath;
            
            UIImage *image = [UIImage imageWithContentsOfFile:videoPath];
            if (image) {
                weakSelf.coverImageView.image = image;
                weakSelf.backgroundImageView.image = image;
            }
        }
    });
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    self.isBack = YES;
    if (self.isPlaying) {
        [self.playManager setVideoPlayAndSuspend:NO];
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    self.isBack = NO;
    if (self.isPlaying) {
        [self.playManager setVideoPlayAndSuspend:YES];
    }
}

@end
