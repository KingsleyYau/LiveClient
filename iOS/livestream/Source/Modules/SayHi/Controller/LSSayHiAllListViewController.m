//
//  LSSayHiAllListViewController.m
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiAllListViewController.h"
#import "LSSayHiGetAllRequest.h"
#import "LSSayHiGetAnchorListRequest.h"
#import "LSSayHiAllListItemObject.h"
#import "LSSayHiRecommendView.h"
#import "AnchorPersonalViewController.h"
#import "LSSayHiDetailViewController.h"
#import "LSShadowView.h"
#import "LiveUrlHandler.h"
#define PageSize 50
#define collectionViewHeight   ([UIScreen mainScreen].bounds.size.width - 45) * 0.5 * 1.35

@interface LSSayHiAllListViewController ()<UIScrollViewRefreshDelegate,LSSayHiAllTableViewDelegate,LSSayHiRecommendViewDelegate>
@property (nonatomic, strong) LSSessionRequestManager *sessionRequestManager;
@property (nonatomic, strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet LSSayHiRecommendView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;
@property (weak, nonatomic) IBOutlet UILabel *allListNoteTips;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIImageView *sayHiEmptyIcon;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, assign) int page;
@end

@implementation LSSayHiAllListViewController

- (void)dealloc {
    [self.tableView unSetupPullRefresh];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupTableView];
    self.searchBtn.layer.cornerRadius = 6.0f;
    self.searchBtn.layer.masksToBounds = YES;
    LSShadowView *shadow = [[LSShadowView alloc] init];
    [shadow showShadowAddView:self.searchBtn];
    self.items = [NSMutableArray array];
    self.sessionRequestManager = [LSSessionRequestManager manager];
  
    [self hideNoSayHiTips];
}


- (void)setupTableView {
    // 初始化下拉
    [self.tableView setupPullRefresh:self pullDown:YES pullUp:YES];
    
    self.tableView.backgroundView = nil;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.tableViewDelegate = self;
    self.tableView.alwaysBounceVertical = YES;
    self.collectionHeight.constant = collectionViewHeight;
    self.collectionView.recommendDelegate = self;

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.tableView startLSPullDown:YES];
    
}


- (void)reloadData:(BOOL)isReload {
    if (self.items.count == 0) {
        [self showNoSayHiTips];
    }else {
        [self hideNoSayHiTips];
    }

    self.tableView.items = self.items;
    if (isReload) {
        [self.tableView reloadData];
    }
}


- (void)showNoSayHiTips {
    self.bottomView.hidden = NO;
    self.allListNoteTips.hidden = NO;
    self.sayHiEmptyIcon.hidden = NO;
}


- (void)hideNoSayHiTips {
    self.bottomView.hidden = YES;
    self.allListNoteTips.hidden = YES;
    self.sayHiEmptyIcon.hidden = YES;
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:NO];
    if (self.items.count == 0) {
        [self getAnchorList];
    }

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
    [self hideNoSayHiTips];
    self.failView.hidden = YES;

    LSSayHiGetAllRequest *request = [[LSSayHiGetAllRequest alloc] init];
    request.start = start;
    request.step = PageSize;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiAllItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSayHiAllListViewController::getListRequest (请求信件列表 success : %@, errnum : %d, errmsg : %@)",BOOL2SUCCESS(success), errnum, errmsg);
            self.view.userInteractionEnabled = YES;
            self.failView.hidden = YES;
            
            if (success) {
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishLSPullDown:YES];
                    // 清空列表
                    [self.items removeAllObjects];
                    self.page = 1;
                } else {
                    // 停止底部
                    [self.tableView finishLSPullUp:YES];

                    self.page++;
                }

                for (LSSayHiAllListItemObject *itemObj in item.list) {

                    [self addItemIfNotExist:itemObj];
                }
                [self reloadData:YES];

                if (!loadMore) {
                    if (self.items.count > 0) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            // 拉到最顶
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        });
                    }
                } 

            }else {
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishLSPullDown:NO];
                    [self.items removeAllObjects];
                    self.failView.hidden = NO;
                } else {
                    // 停止底部
                    [self.tableView finishLSPullUp:YES];
                }

                [self reloadData:YES];
            }
        });
    };
    bFlag = [self.sessionRequestManager sendRequest:request];
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
    [super lsListViewControllerDidClick:sender];
    [self hideNoSayHiTips];
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.tableView startLSPullDown:YES];
}


- (BOOL)getAnchorList {
    LSSayHiGetAnchorListRequest *request = [[LSSayHiGetAnchorListRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSSayHiAnchorItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSayHiAllListViewController::getAnchorList (请求推荐列表 success : %@, errnum : %d, errmsg : %@)",BOOL2SUCCESS(success), errnum, errmsg);
            if (array.count > 0) {
                self.collectionHeight.constant = collectionViewHeight;
                self.collectionView.items = array;
                [self.collectionView layoutIfNeeded];
                [self.collectionView reloadData];
            }else {
                self.collectionHeight.constant = 0;
                self.collectionView.hidden = YES;
            }

        });
    };
    
    return [self.sessionRequestManager sendRequest:request];
}


- (void)tableView:(LSSayHiAllTableView *)tableView didSelectSayHiDetail:(LSSayHiAllListItemObject *)item {

    LSSayHiDetailItemObject * detail = [[LSSayHiDetailItemObject alloc]init];
    detail.nickName = item.nickName;
    detail.age = item.age;
    detail.avatar = item.avatar;
    
    LSSayHiDetailViewController * vc = [[LSSayHiDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.sayHiID = item.sayHiId;
    vc.detail = detail;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)lsSayHiRecommendView:(LSSayHiRecommendView *)view didSelectAchor:(LSSayHiAnchorItemObject *)lady {
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = lady.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}
- (IBAction)searchAction:(id)sender {
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHomePage:LiveUrlMainListTypeHot];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}
@end
