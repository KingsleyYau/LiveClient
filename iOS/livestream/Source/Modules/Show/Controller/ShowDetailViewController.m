//
//  ShowDetailViewController.m
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowDetailViewController.h"
#import "LiveModule.h"
#import "LSConfigManager.h"
#import "ShowAddCreditsView.h"
#import "AnchorPersonalViewController.h"
#import "LSAddCreditsViewController.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
@interface ShowDetailViewController ()<WKUIDelegate,WKNavigationDelegate>

@end

@implementation ShowDetailViewController

- (void)dealloc {
    NSLog(@"ShowDetailViewController::dealloc()");
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:NSStringFromClass([self.superclass class]) bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Show";
    
    self.isShowTaBar = YES;
    self.isFirstProgram = YES;
    
    NSString *webSiteUrl = [LSConfigManager manager].item.showDetailPage;
    if ([webSiteUrl containsString:@"?"]) {
       webSiteUrl = [NSString stringWithFormat:@"%@&live_show_id=%@",webSiteUrl,self.item.showLiveId];
    } else {
      webSiteUrl = [NSString stringWithFormat:@"%@?live_show_id=%@",webSiteUrl,self.item.showLiveId];
    }
    self.requestUrl = webSiteUrl;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setupRequestWebview {
    [super setupRequestWebview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)getTicket {
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)WatchNow {
    
}

- (void)pushLadyDetail {
    AnchorPersonalViewController * vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = self.item.anchorId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
