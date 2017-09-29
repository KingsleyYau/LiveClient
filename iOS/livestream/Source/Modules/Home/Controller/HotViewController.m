//
//  HotViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "HotViewController.h"
#import "PlayViewController.h"
#import "PreLiveViewController.h"

#import "SessionRequestManager.h"
#import "PublicViewController.h"
#import "GetAnchorListRequest.h"
#import "IntroduceViewController.h"
#import "GetAnchorListRequest.h"
#import "FollowCollectionView.h"
#import "LoginManager.h"
#import "BookPrivateBroadcastViewController.h"
#define PageSize 10
@interface HotViewController () <UIScrollViewRefreshDelegate, HotTableViewDelegate>

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager *sessionManager;

/**
 列表
 */
@property (nonatomic, strong) NSMutableArray *items;


@end

@implementation HotViewController

- (void)initCustomParam {
    [super initCustomParam];

    self.items = [NSMutableArray array];

    self.sessionManager = [SessionRequestManager manager];
    
    
    // 设置失败页属性
    self.failTipsText = @"Failed to load";
    
    self.failBtnText = @"Reload";
    
    self.delegateSelect = @selector(reloadBtnClick:);

}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.items.count == 0 && !self.viewDidAppearEver) {
        // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
        [self.tableView startPullDown:YES];
        
    }    
    
}


- (void)setupContainView {
    [super setupContainView];

    // 初始化主播列表
    [self setupTableView];

    //        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    //    flow.minimumLineSpacing = 5.0f;
    //    flow.minimumInteritemSpacing = 5.0f;
    //    flow.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
    //    FollowCollectionView *vc = [[FollowCollectionView alloc] initWithFrame:CGRectMake(0, 0, 414, 300) collectionViewLayout:flow];
    //    [self.view addSubview:vc];
}



- (void)setupTableView {
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
   

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];

    UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 100)];
    vc.backgroundColor = [UIColor cyanColor];

    //    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    UIButton *btn = [[UIButton alloc] initWithFrame:vc.frame];
    //    btn.center = vc.center;
    [btn setBackgroundImage:[UIImage imageNamed:@"Home_HotAndFollow_TableViewHeader_Banner"] forState:UIControlStateNormal];
    [vc addSubview:btn];

    [btn addTarget:self action:@selector(adBannerClickAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.tableView setTableHeaderView:vc];
    
//     self.tableView.headerViewHeight = self.tableView.tableHeaderView.height;
    [self.tableView setHeaderContent:self.tableView.tableHeaderView.height];
    [self.tableView.tableHeaderView setHidden:YES];

    self.tableView.tableViewDelegate = self;
}



- (void)adBannerClickAction:(UIButton *)btn {
    IntroduceViewController *introduceVc = [[IntroduceViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:introduceVc animated:YES];
    NSLog(@"%s", __func__);
}

#pragma mark - 数据逻辑


- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    if (isReloadView) {
        
        NSMutableSet *set = [NSMutableSet set];
        
        NSPredicate *duplicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
            
            LiveRoomInfoItemObject *objItem = (LiveRoomInfoItemObject*)obj;
            
            BOOL seen = [set containsObject:objItem.userId];
            
            if (!seen) {
                
                [set addObject:objItem.userId];
                
            }
            return !seen;
            
        }];
        
        
        NSArray *noRepeatArray = [NSMutableArray arrayWithArray:[self.items filteredArrayUsingPredicate:duplicate]];
        
        self.tableView.items = noRepeatArray;
//        self.tableView.items = self.items;
        [self.tableView reloadData];

//        UITableViewCell *cell = [self.tableView visibleCells].firstObject;
//        NSIndexPath *index = [self.tableView indexPathForCell:cell];
//        NSInteger row = index.row;
//
//        if (self.items.count > 0) {
//            if (row < self.items.count) {
//                NSIndexPath *nextLadyIndex = [NSIndexPath indexPathForRow:row inSection:0];
//            [self.tableView scrollToRowAtIndexPath:nextLadyIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            }
//        }
    }
}

- (void)tableView:(HotTableView *)tableView didSelectItem:(LiveRoomInfoItemObject *)item {
//    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
//    LiveRoom *liveRoom = [[LiveRoom alloc] init];
//    liveRoom.roomType = LiveRoomType_Public;
//    liveRoom.httpLiveRoom = item;
//    vc.liveRoom = liveRoom;
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;

//    [self getListRequest:NO];
//    [self initTestData];

    [self getListRequest:NO];

}

- (void)pullUpRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:YES];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)pullUpRefresh:(UIScrollView *)scrollView {
    // 上拉更多回调
    [self pullUpRefresh];

}

#pragma mark 数据逻辑
- (BOOL)getListRequest:(BOOL)loadMore {
    NSLog(@"HotViewController::getListRequest( loadMore : %@ )", BOOL2YES(loadMore));

    BOOL bFlag = NO;

    GetAnchorListRequest *request = [[GetAnchorListRequest alloc] init];

    int start = 0;
    if (!loadMore) {
        // 刷最新
        start = 0;

    } else {
        // 刷更多
        start = self.items ? ((int)self.items.count) : 0;
    }

    // 每页最大纪录数
    request.start = start;
    request.step = PageSize;
    request.hasWatch = NO;

    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"HotViewController::getListRequest( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            if (success) {
                [self.tableView.tableHeaderView setHidden:NO];
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    // 清空列表
                    [self.items removeAllObjects];

                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }

                for (LiveRoomInfoItemObject *item in array) {
                    [self addItemIfNotExist:item];
                }

                [self reloadData:YES];

                if (!loadMore) {
                    if (self.items.count > 0) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            // 拉到最顶
//                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                            [self.tableView scrollsToTop];
                        });
                    
                    }
                }else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        // 拉到下一页
                        UITableViewCell *cell = [self.tableView visibleCells].firstObject;
                        NSIndexPath *index = [self.tableView indexPathForCell:cell];
                        NSInteger row = index.row;
                        NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:row + 1 inSection:0];
                        [self.tableView scrollToRowAtIndexPath:nextIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        
                    });
                }
            } else {
           
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                     self.items = nil;
                    [self.tableView.tableHeaderView setHidden:YES];
                    self.failView.hidden = NO;

                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }

                [self reloadData:YES];
            }
            self.view.userInteractionEnabled = YES;
        
        });

    };

    bFlag = [self.sessionManager sendRequest:request];

    return bFlag;
}

- (void)addItemIfNotExist:(LiveRoomInfoItemObject *_Nonnull)itemNew {
    bool bFlag = NO;

    for (LiveRoomInfoItemObject *item in self.items) {
        if ([item.userId isEqualToString:itemNew.userId]) {
            // 已经存在
            bFlag = true;
            break;
        }
    }

    if (!bFlag) {
        // 不存在
        [self.items addObject:itemNew];
    }
}

- (void)reloadBtnClick:(id)sender {
    self.failView.hidden = YES;
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
//    [self getListRequest:YES];
    [self.tableView startPullDown:YES];
}

/** 免费的公开直播间 */
- (void)tableView:(HotTableView *)tableView didPublicViewFreeBroadcast:(NSInteger)index {
    // TODO:点击立即免费公开
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Public;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    
    KKNavigationController* nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

/** 付费的公开直播间 */
- (void)tableView:(HotTableView *)tableView didPublicViewVipFeeBroadcast:(NSInteger)index {
    // TODO:点击立即付费公开
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Public_VIP;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    
    KKNavigationController* nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

/** 普通的私密直播间 */
- (void)tableView:(HotTableView *)tableView didPrivateStartBroadcast:(NSInteger)index {
    // TODO:点击立即付费私密
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Private;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    
    KKNavigationController* nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}
/** 豪华的私密直播间 */
- (void)tableView:(HotTableView *)tableView didStartVipPrivteBroadcast:(NSInteger)index {
    // TODO:点击立即付费豪华私密
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Private;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    
    KKNavigationController* nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

/** 预约的私密直播间 */
- (void)tableView:(HotTableView *)tableView didBookPrivateBroadcast:(NSInteger)index {
    // TODO:预约的私密直播间
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    BookPrivateBroadcastViewController * vc = [[BookPrivateBroadcastViewController alloc]initWithNibName:nil bundle:nil];
    vc.userId = item.userId;
    vc.userName = item.nickName;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
