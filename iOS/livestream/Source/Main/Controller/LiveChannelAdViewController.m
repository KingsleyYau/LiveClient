//
//  LiveChannelAdViewController.m
//  livestream
//
//  Created by test on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveChannelAdViewController.h"
#import "GetAnchorListRequest.h"
#import "LiveModule.h"
#import "LSHomePageViewController.h"
#import "LSMainViewController.h"
#import "GetAdAnchorListRequest.h"
#import "CloseAdAnchorListRequest.h"
@interface LiveChannelAdViewController () <LiveModuleDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;
/**  */
@property (nonatomic, strong) LiveChannelAdView *adView;
//@property (weak, nonatomic) IBOutlet LiveChannelAdView *adView;

/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (weak, nonatomic) IBOutlet LiveChannelContentView *collectionView;

@property (nonatomic, strong) NSMutableArray *items;

/** QN交互 */
@property (nonatomic, strong) LiveModule *module;
@end

@implementation LiveChannelAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //    self.adTopView = [LiveChannelTopView initWithLiveChannelView];

    self.module = [LiveModule module];
    self.module.delegate = self;

    self.sessionManager = [LSSessionRequestManager manager];

    //    self.adTopView.topViewdelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    [self getListRequest:YES];
    [self getAdList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.adView hideAnimation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)getAdList {
    GetAdAnchorListRequest *request = [[GetAdAnchorListRequest alloc] init];
    request.number = 4;

    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSLog(@"HotViewController::getListRequest( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            NSMutableArray *dataArray = [NSMutableArray array];
            if (success) {
                //                dataArray = (NSMutableArray *)array;
                for (int i = 0; i < request.number; i++) {
                    LiveRoomInfoItemObject *item = array[i];
                    if (item) {
                        [dataArray addObject:item];
                    }
                }
            }

            self.items = (NSMutableArray *)dataArray;
            //            LiveChannelAdViewController *liveChannel = [[LiveChannelAdViewController alloc] initWithNibName:nil bundle:nil];

            //            adView.contentView.items = dataArray;
            ////            [adView.contentView reloadData];
            ////            self.liveChannel = liveChannel;
            //
            //            adView.contentView.liveChannelDelegate = self;
            //
            //            adView.adViewDelegate = self;

            [self reloadData:YES];

        });

    };

    return [self.sessionManager sendRequest:request];
}

- (void)reloadData:(BOOL)isReloadView {
    if (!self.adView) {
        self.adView = [LiveChannelAdView initWithLiveChannelAdViewXib:self];
        [self.view addSubview:self.adView];
    }
    self.adView.contentView.items = self.items;
    [self.adView showAnimation];
    [self.adView.contentView reloadData];
}

- (void)liveChannelAdView:(LiveChannelAdView *)view didClickCloseBtn:(UIButton *)sender {

    [self closeAdList];
}

- (void)placeholderBackImageViewDidTap:(UITapGestureRecognizer *)gesture {
    NSLog(@"LiveChannelAdViewController-%s", __func__);
    //TODO::点击进入直播hot列表
}

- (void)liveChannelAdView:(LiveChannelAdView *)view didClickTopToList:(UIButton *)sender {
    NSLog(@"LiveChannelAdViewController-%s", __func__);
    //TODO::点击进入直播hot列表
}

- (void)liveChannelContentView:(LiveChannelContentView *)contentView didClickGoWatch:(UIButton *)btn {
    NSLog(@"LiveChannelAdViewController-%s", __func__);
    //TODO::点击进入直播hot列表
    //    LSMainViewController *main = [[LSMainViewController alloc] initWithNibName:nil bundle:nil];
    //    main.view.frame =  [UIScreen mainScreen].bounds;
    //    main.tabContainView.frame =  [UIScreen mainScreen].bounds;
    //    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:main];
    UIViewController *vc = [LiveModule module].moduleVC;
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:vc];
    [UIApplication sharedApplication].keyWindow.rootViewController = nvc;
}

- (void)liveChannelContentView:(LiveChannelContentView *)contentView didSelectLady:(NSInteger)item {
    NSLog(@"LiveChannelAdViewController-%s", __func__);
    //TODO::点击进入直播间主播个人热详情
}

- (void)liveChannelContentView:(LiveChannelContentView *)contentView didClickTop:(UIButton *)btn {
    NSLog(@"LiveChannelAdViewController-%s", __func__);
    //TODO::点击进入直播hot列表
    LSMainViewController *main = [[LSMainViewController alloc] initWithNibName:nil bundle:nil];
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:main];
    [UIApplication sharedApplication].keyWindow.rootViewController = nvc;
}

- (BOOL)closeAdList {
    CloseAdAnchorListRequest *request = [[CloseAdAnchorListRequest alloc] init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.adView hideAnimation];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    };
    return [self.sessionManager sendRequest:request];
}
@end
