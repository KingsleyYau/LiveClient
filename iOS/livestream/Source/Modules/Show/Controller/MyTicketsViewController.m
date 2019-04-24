//
//  MyTicketsViewController.m
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "MyTicketsViewController.h"
#import "ShowCell.h"
#import "LSSessionRequest.h"
#import "ShowAddCreditsView.h"
#import "LiveModule.h"
#import "ShowDetailViewController.h"
#import "LiveUrlHandler.h"
#import "AnchorPersonalViewController.h"
#import "LSAddCreditsViewController.h"
#define PageSize 50

@interface MyTicketsViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIScrollViewRefreshDelegate, ShowCellDelegate, ShowAddCreditsViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIView *noDataTipView;
@property (nonatomic, assign) int page;
@end

@implementation MyTicketsViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self.timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView unInitPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;

    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];

    [self.tableView registerNib:[UINib nibWithNibName:@"ShowCell" bundle:[LiveBundle mainBundle]] forCellReuseIdentifier:[ShowCell cellIdentifier]];

    self.items = [NSMutableArray array];

    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.items.count == 0) {
        [self.tableView startPullDown:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getShowList:(BOOL)loadMore {
    self.noDataTipView.hidden = YES;
    LSGetProgramListRequest *request = [[LSGetProgramListRequest alloc] init];

    int start = 0;
    if (!loadMore) {
        // 刷最新
        start = 0;
        [self.timer invalidate];
        self.timer = nil;
    } else {
        // 刷更多
        start = self.page * PageSize;
    }
    request.sortType = self.sortType;
    // 每页最大纪录数
    request.start = start;
    request.step = PageSize;

    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LSProgramItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MyTicketsViewController::getShowList( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            if (success) {
                self.failView.hidden = YES;

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

                if (!self.timer && self.sortType != PROGRAMLISTTYPE_HISTORY) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                }

                [self.items addObjectsFromArray:array];

                if (self.items.count == 0) {
                    self.noDataTipView.hidden = NO;
                }
                [self getShowTime:self.items];

                [self.tableView reloadData];
            } else {
                self.noDataTipView.hidden = YES;
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:NO];
                    [self.items removeAllObjects];
                    self.failView.hidden = NO;
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }

                [self.tableView reloadData];
            }
            self.view.userInteractionEnabled = YES;
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getShowTime:(NSArray *)array {
    for (LSProgramItemObject *item in array) {
        item.leftSecToEnter -= 10;
        item.leftSecToStart -= 10;
    }
}

- (void)countdown {
    [self getShowTime:self.items];

    [self.tableView reloadData];
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getShowList:NO];
}

- (void)pullUpRefresh {
    self.view.userInteractionEnabled = NO;
    [self getShowList:YES];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)pullUpRefresh:(UIScrollView *)scrollView {
    if (self.items.count >= PageSize * self.page) {
        // 上拉更多回调
        [self pullUpRefresh];
    } else {
        // 停止底部
        [self.tableView finishPullUp:NO];
    }
}

#pragma mark 失败界面点击事件
- (void)lsListViewControllerDidClick:(UIButton *)sender {
    [self reloadBtnClick:sender];
}

- (void)reloadBtnClick:(id)sender {
    self.failView.hidden = YES;

    [self.tableView startPullDown:YES];
}

#pragma mark TableViewDeleagate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ShowCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowCell *result = nil;
    ShowCell *cell = [ShowCell getUITableViewCell:tableView];
    result = cell;
    cell.cellDelegate = self;
    LSProgramItemObject *obj = [self.items objectAtIndex:indexPath.row];

    if (self.sortType == PROGRAMLISTTYPE_HISTORY) {
        [cell updateHistoryUI:obj];
    } else {
        [cell updateUI:obj];
    }

    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSProgramItemObject *obj = [self.items objectAtIndex:indexPath.row];
    ShowDetailViewController *vc = [[ShowDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.item = obj;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCellBtnDid:(NSInteger)type fromItem:(LSProgramItemObject *)item {
    if (type == 1) {
        [[LiveModule module].analyticsManager reportActionEvent:ShowEnterShowBroadcast eventCategory:EventCategoryShowCalendar];
        NSURL *url = [[LiveUrlHandler shareInstance] createUrlToShowRoomId:item.showLiveId anchorId:item.anchorId];
        [[LiveUrlHandler shareInstance] handleOpenURL:url];
    } else if (type == 2) {
        [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarClickGetTicket eventCategory:EventCategoryShowCalendar];
        ShowAddCreditsView *view = [[ShowAddCreditsView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        view.delegate = self;
        [view updateUI:item];
        [self.view.window addSubview:view];
    } else {
        [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarClickMyOtherShows eventCategory:EventCategoryShowCalendar];
        AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
        vc.anchorId = item.anchorId;
        vc.enterRoom = 1;
        vc.tabType = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark 购票成功回调
- (void)buyProgramSuccess:(LSProgramItemObject *)item {
    NSInteger row = [self.items indexOfObject:item];

    [self.items removeObjectAtIndex:row];
    [self.items insertObject:item atIndex:row];

    [self getShowTime:self.items];

    [self.tableView reloadData];
}

- (void)pushAddCreditVC {
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

@end
