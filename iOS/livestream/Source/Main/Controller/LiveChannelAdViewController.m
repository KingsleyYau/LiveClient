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
#import "LiveUrlHandler.h"
#import "LiveService.h"
#import "LSMainViewController.h"
@interface LiveChannelAdViewController () <LiveModuleDelegate,LiveChannelAdViewDelegate,LiveChannelContentViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;
/**  */
@property (nonatomic, strong) LiveChannelAdView *adView;
//@property (weak, nonatomic) IBOutlet LiveChannelAdView *adView;

/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (weak, nonatomic) IBOutlet LiveChannelContentView *collectionView;

@property (nonatomic, strong) NSMutableArray <LiveRoomInfoItemObject *> *items;

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
    
    self.module = [LiveModule module];
    
    
    self.sessionManager = [LSSessionRequestManager manager];
  
    BOOL result =  [self getAdList];
    NSLog(@"[self getAdList] = %d",result);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    [self getListRequest:YES];
//     BOOL result =  [self getAdList];
//    NSLog(@"[self getAdList] = %d",result);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.adView hideAnimation];
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
            NSLog(@"livechannel::getAdList( [%@], count : %ld )", BOOL2SUCCESS(success), (long)array.count);
            NSMutableArray *dataArray = [NSMutableArray array];
            if (success) {
                //如果推荐主播超过4个则显示4个,如果少于2个则显示单张封面图,超过2个显示个数
                if (array.count > request.number) {
                    for (int i = 0; i < request.number; i++) {
                        LiveRoomInfoItemObject *item = array[i];
                        if (item) {
                            [dataArray addObject:item];
                        }
                    }
                }else if(array.count <= 2){
                    
                }else {
                    for (int i = 0; i < array.count; i++) {
                        LiveRoomInfoItemObject *item = array[i];
                        if (item) {
                            [dataArray addObject:item];
                        }
                    }
                }
                
            }
            
            self.items = (NSMutableArray *)dataArray;
            
            
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
    [[LiveModule module].analyticsManager reportActionEvent:LiveChannelClickLiveAd eventCategory:EventCategoryQN];
    [self pushToList];
}


- (void)liveChannelContentView:(LiveChannelContentView *)contentView didClickGoWatch:(UIButton *)btn {
    NSLog(@"LiveChannelAdViewController-%s", __func__);
    //TODO::点击进入直播hot列表
    
    [[LiveModule module].analyticsManager reportActionEvent:LiveChannelClickGoWatch eventCategory:EventCategoryQN];
    [self pushToList];
}

- (void)liveChannelContentView:(LiveChannelContentView *)contentView didSelectLady:(NSInteger)item {
    NSLog(@"LiveChannelAdViewController-%s", __func__);
    //TODO::点击进入直播间主播个人详情
    [[LiveModule module].analyticsManager reportActionEvent:LiveChannelClickCover eventCategory:EventCategoryQN];
    
    [LiveModule module].showListGuide = NO;
    LiveRoomInfoItemObject *itemInfo = [self.items objectAtIndex:item];
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToLookLadyAnchorId:itemInfo.userId];
    [[LiveModule module].serviceManager openSpecifyService:url];
    
    
    
    
}

- (void)liveChannelContentView:(LiveChannelContentView *)contentView didClickTop:(UIButton *)btn {
    NSLog(@"LiveChannelAdViewController-%s", __func__);
    //TODO::点击进入直播hot列表
    [[LiveModule module].analyticsManager reportActionEvent:LiveChannelClickGoWatch eventCategory:EventCategoryQN];
    [self pushToList];
    
}

- (void)pushToList {
    
    NSURL *url = [NSURL URLWithString:@"qpidnetwork://app/open?site:4&service=live&module=main"];
    [LiveModule module].showListGuide = YES;
    [[LiveModule module].serviceManager openSpecifyService:url];

}

- (BOOL)closeAdList {
    
    [[LiveModule module].analyticsManager reportActionEvent:LiveChannelCloseAd eventCategory:EventCategoryQN];
    CloseAdAnchorListRequest *request = [[CloseAdAnchorListRequest alloc] init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.adView hideAnimation];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
        });
    };
    return [self.sessionManager sendRequest:request];
}
@end
