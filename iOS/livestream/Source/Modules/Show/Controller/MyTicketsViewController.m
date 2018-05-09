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
@interface MyTicketsViewController ()<UITableViewDelegate,UITableViewDataSource,LSListViewControllerDelegate,UIScrollViewDelegate,UIScrollViewRefreshDelegate,ShowCellDelegate,ShowAddCreditsViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) NSTimer * timer;
@property (weak, nonatomic) IBOutlet UIView *noDataTipView;
@end

@implementation MyTicketsViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
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
    
    self.items = [NSMutableArray array];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    // 设置失败页属性
    self.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");
    
    self.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");
    
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置不被NavigationBar和TabBar遮挡
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.tableView startPullDown:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getShowList:(BOOL)loadMore
{
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
        start = self.items ? ((int)self.items.count) : 0;
    }
    request.sortType = self.sortType;
    // 每页最大纪录数
    request.start = start;
    request.step = 10;
    
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LSProgramItemObject *> * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MyTicketsViewController::getShowList( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            if (success) {
                self.failView.hidden = YES;
                
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    // 清空列表
                    [self.items removeAllObjects];
                    
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }
                
                if (!self.timer && self.sortType != PROGRAMLISTTYPE_HISTORY) {
                    self.timer =  [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                }
                
                [self.items addObjectsFromArray:array];
                
                if (self.items.count == 0) {
                    self.noDataTipView.hidden = NO;
                }
                [self getShowTime:self.items];

                [self.tableView reloadData];
            }
            else
            {
                self.noDataTipView.hidden = YES;
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
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

- (void)getShowTime:(NSArray *)array
{
    NSMutableArray * data = [NSMutableArray array];
    for (LSProgramItemObject * item in array) {
        LSProgramItemObject * items = [[LSProgramItemObject alloc]init];
        items = item;
        items.countdownTime = items.countdownTime + 10;
        [data addObject:items];
    }
    self.items = data;
}

- (void)countdown
{
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
    // 上拉更多回调
    [self pullUpRefresh];
}

#pragma mark 失败界面点击事件
- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
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
    LSProgramItemObject * obj = [self.items objectAtIndex:indexPath.row];
    
    if (self.sortType == PROGRAMLISTTYPE_HISTORY) {
        [cell updateHistoryUI:obj];
    }
    else
    {
      [cell updateUI:obj];
    }
    
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSProgramItemObject * obj = [self.items objectAtIndex:indexPath.row];
    ShowDetailViewController * vc = [[ShowDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.item = obj;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCellBtnDid:(NSInteger)type fromItem:(LSProgramItemObject *)item
{
    if (type == 1) {
        [[LiveModule module].analyticsManager reportActionEvent:ShowEnterShowBroadcast eventCategory:EventCategoryShowCalendar];
        NSURL *url =[[LiveUrlHandler shareInstance] createUrlToShowRoomId:item.showLiveId userId:item.anchorId];
        [LiveUrlHandler shareInstance].url = url;
        [[LiveUrlHandler shareInstance] handleOpenURL];
    }
    else if (type == 2)
    {
        [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarClickGetTicket eventCategory:EventCategoryShowCalendar];
        ShowAddCreditsView * view = [[ShowAddCreditsView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        view.delegate = self;
        [view updateUI:item];
        [self.view.window addSubview:view];
    }
    else
    {
        [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarClickMyOtherShows eventCategory:EventCategoryShowCalendar];
        AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] init];
        vc.anchorId = item.anchorId;
        vc.enterRoom = 1;
        vc.tabType = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushAddCreditVc
{
    UIViewController *vc = [LiveModule module].addCreditVc;
    if (vc) {
        [self.navigationController pushViewController:vc animated:NO];
    }
}

@end
