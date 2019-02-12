//
//  LiveWebViewController.m
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveWebViewController.h"
#import "LSRequestManager.h"
#import "LSConfigManager.h"
#import "IntroduceView.h"
#import "LiveModule.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface LiveWebViewController ()

@end

@implementation LiveWebViewController
- (void)dealloc {
    NSLog(@"LiveWebViewController::dealloc()");
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:NSStringFromClass([self.superclass class]) bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isShowTaBar = YES;
    self.isFirstProgram = YES;
    
    NSString *intimacyUrl; // 拼接url
    NSString *anchorID = [NSString stringWithFormat:@"&anchorid=%@",self.anchorId];

    if (self.isIntimacy) {
        // 亲密度
        NSString *webSiteUrl = [LSConfigManager manager].item.intimacy;
        if (webSiteUrl.length > 0) {
            if ([webSiteUrl containsString:@"?"]) {
                intimacyUrl = [NSString stringWithFormat:@"%@&%@",webSiteUrl,anchorID];
            } else {
                intimacyUrl = [NSString stringWithFormat:@"%@?%@",webSiteUrl,anchorID];
            }
        }
    } else {
        intimacyUrl = self.url;
        if (!_isUserProtocol) {
            if (![intimacyUrl containsString:@"?"])
                intimacyUrl = [NSString stringWithFormat:@"%@?%@",intimacyUrl,anchorID];
            }
    }
    self.requestUrl = intimacyUrl;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示导航栏
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
     [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:19]}];
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


@end
