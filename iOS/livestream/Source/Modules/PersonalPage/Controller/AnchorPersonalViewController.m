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

@interface AnchorPersonalViewController ()<LSUserUnreadCountManagerDelegate>

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
    
    if (@available(iOS 11, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tabType = 0;
    self.isShowTaBar = NO;
    self.isFirstProgram = YES;
    
    [[LSUserUnreadCountManager shareInstance] addDelegate:self];
    
    NSString *anchorPage = [LSConfigManager manager].item.anchorPage;
    NSString *anchorid = [NSString stringWithFormat:@"anchorid=%@",self.anchorId]; // 主播id;
    NSString *enterroom = @"enterroom=1";//[NSString stringWithFormat:@"enterroom=%d",self.enterRoom];
    NSString *tabType = [NSString stringWithFormat:@"tabtype=%d",(int)self.tabType];
    
    if ([anchorPage containsString:@"?"]) {
        anchorPage = [NSString stringWithFormat:@"%@&%@&%@&%@",anchorPage,anchorid,enterroom,tabType];
    } else {
        anchorPage = [NSString stringWithFormat:@"%@?%@%@&%@",anchorPage,anchorid,enterroom,tabType];
    }
    
    self.requestUrl = anchorPage;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.viewDidAppearEver) {
        // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
        [self.navigationController setNavigationBarHidden:NO];
        self.navigationController.navigationBar.hidden = NO;
    } else {
        // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
        [self.navigationController setNavigationBarHidden:YES];
        self.navigationController.navigationBar.hidden = YES;
    }
    
    NSInteger unreadCount = [[LSUserUnreadCountManager shareInstance] getAssignLadyUnreadCount:self.anchorId];
    NSString *unreadCountString = [NSString stringWithFormat:@"%ld",(long)unreadCount];
    [self nativeTransferNotifyLiveAppUnreadCountJavaScript:unreadCountString];
}

- (void)setupRequestWebview {
    [super setupRequestWebview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSInteger unreadCount = [[LSUserUnreadCountManager shareInstance] getAssignLadyUnreadCount:self.anchorId];
    NSString *unreadCountString = [NSString stringWithFormat:@"%ld",(long)unreadCount];
    [self nativeTransferNotifyLiveAppUnreadCountJavaScript:unreadCountString];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)nativeTransferNotifyLiveAppUnreadCountJavaScript:(NSString *)unreadCount {
    if (self.didFinshNav) {
        [self.webView webViewNotifyLiveAppUnreadCount:unreadCount Handler:^(id  _Nullable response, NSError * _Nullable error) {
            
        }];
    }
}

- (void)onGetChatlistUnreadCount:(int)count {
    NSInteger unreadCount = [[LSUserUnreadCountManager shareInstance] getAssignLadyUnreadCount:self.anchorId];
    NSString *unreadCountString = [NSString stringWithFormat:@"%ld",(long)unreadCount];
    [self nativeTransferNotifyLiveAppUnreadCountJavaScript:unreadCountString];
}


- (void)webViewLoadingFinshCallBack {
    [super webViewLoadingFinshCallBack];
    NSInteger unreadCount = [[LSUserUnreadCountManager shareInstance] getAssignLadyUnreadCount:self.anchorId];
    NSString *unreadCountString = [NSString stringWithFormat:@"%ld",(long)unreadCount];
    if (self.viewDidAppearEver) {
        [self nativeTransferNotifyLiveAppUnreadCountJavaScript:unreadCountString];
    }

}
@end
