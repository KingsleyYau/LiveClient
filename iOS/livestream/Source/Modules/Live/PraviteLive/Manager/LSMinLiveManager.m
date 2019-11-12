//
//  LSMinLiveManager.m
//  livestream
//
//  Created by Calvin on 2019/11/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMinLiveManager.h"

@interface LSMinLiveManager ()<LSMinLiveViewDelegate>

@end

@implementation LSMinLiveManager

+ (instancetype)manager {
    static LSMinLiveManager *minLiveManager = nil;
    if (minLiveManager == nil) {
        minLiveManager = [[LSMinLiveManager alloc] init];
    }
    return minLiveManager;
}

- (void)setMinViewAddVC:(UIViewController *)vc {
    
    self.minView = [[LSMinLiveView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 180, vc.view.tx_height - 230, 170, 220)];
    self.minView.delegate = self;
    [vc.view addSubview:self.minView];
    [vc.view bringSubviewToFront:self.minView];
    self.minView.hidden = YES;
}

- (void)showMinLive {
    self.minView.hidden = NO;
    if (self.publicLiveVC) {
        self.publicLiveVC.playVC.liveVC.player.playView = self.minView.videoView;
    }
    if (self.privateLiveVC){
        self.privateLiveVC.playVC.liveVC.player.playView = self.minView.videoView;
    }
}

- (void)hidenMinLive {
    self.minView.hidden = YES;
    self.privateLiveVC = nil;
    self.publicLiveVC = nil;
}

- (void)minLiveViewDidCloseBtn {
    [self hidenMinLive];
}

- (void)minLiveViewDidVideo {
    if (self.publicLiveVC) {
        self.publicLiveVC.playVC.liveVC.player.playView = self.publicLiveVC.playVC.liveVC.videoView;
    }
    if (self.privateLiveVC){
        self.privateLiveVC.playVC.liveVC.player.playView = self.privateLiveVC.playVC.liveVC.videoView;
    }
    
    if ([self.delegate respondsToSelector:@selector(pushMaxLive)]) {
        [self.delegate pushMaxLive];
    }
}
@end
