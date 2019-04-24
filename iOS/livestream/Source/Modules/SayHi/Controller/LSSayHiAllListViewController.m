//
//  LSSayHiAllListViewController.m
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiAllListViewController.h"
#import "LSSayHiGetAllRequest.h"
#import "LSSayHiAllListItemObject.h"
#define PageSize 50
@interface LSSayHiAllListViewController ()<UIScrollViewRefreshDelegate>
@property (nonatomic, strong) LSSessionRequestManager *seesionRequestManager;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) int page;
@end

@implementation LSSayHiAllListViewController

- (void)dealloc {
    [self.tableView unInitPullRefresh];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupTableView];
    
    
    self.items = [NSMutableArray array];
    self.seesionRequestManager = [LSSessionRequestManager manager];
}


- (void)setupTableView {
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if (!self.viewDidAppearEver) {
        [self.tableView startPullDown:YES];
    }
}

- (void)reloadData:(BOOL)isReload {
    if (self.items.count == 0) {

    }else {

    }

    self.tableView.items = self.items;
    if (isReload) {
        [self.tableView reloadData];
    }
}
#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
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
    NSLog(@"LSSayHiAllListViewController::getListRequest( loadMore : %@ )", BOOL2YES(loadMore));

    BOOL bFlag = NO;

    int start = 0;
    if (!loadMore) {
        // 刷最新
        start = 0;

    } else {
        // 刷更多
        start = self.page * PageSize;
    }

    // 隐藏没有数据内容
//    [self hideNoMailTips];
    self.failView.hidden = YES;

    LSSayHiGetAllRequest *request = [[LSSayHiGetAllRequest alloc] init];
    request.start = start;
    request.step = PageSize;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiAllItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSMailViewController::getListRequest (请求信件列表 success : %@, errnum : %d, errmsg : %@)",BOOL2SUCCESS(success), errnum, errmsg);
            self.view.userInteractionEnabled = YES;
            self.failView.hidden = YES;
            if (success) {
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    // 清空列表
                    [self.items removeAllObjects];
                    self.page = 1;
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];

                    self.page++;
                }

                for (LSSayHiAllListItemObject *itemObj in item.list) {

                    [self addItemIfNotExist:itemObj];
                }
                [self reloadData:YES];



            }else {
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:NO];
                    [self.items removeAllObjects];
                    self.failView.hidden = NO;
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }

                [self reloadData:YES];
            }
        });
    };
    bFlag = [self.seesionRequestManager sendRequest:request];
    return bFlag;
}

- (void)addItemIfNotExist:(LSSayHiAllListItemObject *_Nonnull)itemNew {
    bool bFlag = NO;

    for (LSSayHiAllListItemObject *item in self.items) {
        if ([item.sayHiId isEqualToString:itemNew.sayHiId]) {
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

- (void)lsListViewControllerDidClick:(UIButton *)sender {
    self.failView.hidden = YES;
//    [self hideNoMailTips];
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.tableView startPullDown:YES];
}
@end
