//
//  AnchorPersonalViewController.m
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AnchorPersonalViewController.h"
#import "LiveModule.h"
#import "LSConfigManager.h"
#import "LSUserUnreadCountManager.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface AnchorPersonalViewController () <LSUserUnreadCountManagerDelegate>

@end

@implementation AnchorPersonalViewController

- (void)dealloc {
    [[LSUserUnreadCountManager shareInstance] removeDelegate:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:NSStringFromClass([self.superclass class]) bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeAll;

    self.tabType = 0;
    self.isShowTaBar = NO;
    self.isFirstProgram = YES;

    [[LSUserUnreadCountManager shareInstance] addDelegate:self];

    NSString *anchorPage = [LSConfigManager manager].item.anchorPage;
    NSString *anchorid = [NSString stringWithFormat:@"anchorid=%@", self.anchorId]; // 主播id;
    NSString *enterroom = @"enterroom=1";                                           //[NSString stringWithFormat:@"enterroom=%d",self.enterRoom];
    NSString *tabType = [NSString stringWithFormat:@"tabtype=%d", (int)self.tabType];

    if ([anchorPage containsString:@"?"]) {
        anchorPage = [NSString stringWithFormat:@"%@&%@&%@&%@", anchorPage, anchorid, enterroom, tabType];
    } else {
        anchorPage = [NSString stringWithFormat:@"%@?%@%@&%@", anchorPage, anchorid, enterroom, tabType];
    }

    self.requestUrl = anchorPage;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSInteger unreadCount = [[LSUserUnreadCountManager shareInstance] getAssignLadyUnreadCount:self.anchorId];
    NSString *unreadCountString = [NSString stringWithFormat:@"%ld", (long)unreadCount];
    [self nativeTransferNotifyLiveAppUnreadCountJavaScript:unreadCountString];
}

- (void)setupRequestWebview {
    [super setupRequestWebview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSInteger unreadCount = [[LSUserUnreadCountManager shareInstance] getAssignLadyUnreadCount:self.anchorId];
    NSString *unreadCountString = [NSString stringWithFormat:@"%ld", (long)unreadCount];
    [self nativeTransferNotifyLiveAppUnreadCountJavaScript:unreadCountString];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)nativeTransferNotifyLiveAppUnreadCountJavaScript:(NSString *)unreadCount {
    if (self.didFinshNav) {
        [self.webView webViewNotifyLiveAppUnreadCount:unreadCount
                                              Handler:^(id _Nullable response, NSError *_Nullable error){

                                              }];
    }
}

- (void)onGetChatlistUnreadCount:(int)count {
    NSInteger unreadCount = [[LSUserUnreadCountManager shareInstance] getAssignLadyUnreadCount:self.anchorId];
    NSString *unreadCountString = [NSString stringWithFormat:@"%ld", (long)unreadCount];
    [self nativeTransferNotifyLiveAppUnreadCountJavaScript:unreadCountString];
}

- (void)webViewLoadingFinshCallBack {
    [super webViewLoadingFinshCallBack];
    NSInteger unreadCount = [[LSUserUnreadCountManager shareInstance] getAssignLadyUnreadCount:self.anchorId];
    NSString *unreadCountString = [NSString stringWithFormat:@"%ld", (long)unreadCount];
    if (self.viewDidAppearEver) {
        [self nativeTransferNotifyLiveAppUnreadCountJavaScript:unreadCountString];
    }
}


@end
