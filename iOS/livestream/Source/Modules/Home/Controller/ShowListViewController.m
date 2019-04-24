//
//  ShowListViewController.m
//  livestream
//
//  Created by Calvin on 2018/4/18.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowListViewController.h"
#import "ShowCell.h"
#import "ShowAddCreditsView.h"
#import "LiveModule.h"
#import "LSGetProgramListRequest.h"
#import "LSImManager.h"
#import "ShowDetailViewController.h"
#import "LSConfigManager.h"
#import "LiveUrlHandler.h"
#import "AnchorPersonalViewController.h"
#import "LSBuyProgramRequest.h"
#import "DialogTip.h"
#import "LSAddCreditsViewController.h"
#define PageSize 50

@interface ShowListViewController () <UITableViewDelegate, UITableViewDataSource, ShowCellDelegate, ShowAddCreditsViewDelegate, UIScrollViewDelegate, UIScrollViewRefreshDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
//列表数据
@property (nonatomic, strong) NSMutableArray *items;
//原始数据
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIView *noDataTipView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) ShowAddCreditsView *addCreditsView;
@property (nonatomic, assign) int page;

/**
 是否加载数据
 */
@property (nonatomic, assign) BOOL isLoadData;
/**
 是否第一次登录
 */
@property (nonatomic, assign) BOOL isFirstLogin;
@end

@implementation ShowListViewController

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    [self.tableView unInitPullRefresh];
}

- (void)initCustomParam {
    [super initCustomParam];

    self.navigationTitle = @"Calendar";
    
    // 是否第一次登录
    self.isFirstLogin = NO;
    // 是否刷新数据
    self.isLoadData = NO;
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

    self.dataArray = [NSMutableArray array];

    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)settableViewHeadView {
    NSString *str = NSLocalizedStringFromSelf(@"ShowTopMsg");
    if (str.length > 0) {
        CGRect rect = [str boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15] } context:nil];
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, rect.size.height + 10)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, SCREEN_WIDTH - 30, rect.size.height)];
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        label.textColor = COLOR_WITH_16BAND_RGB(0x666666);
        label.text = str;
        [headView addSubview:label];
        [self.tableView setTableHeaderView:headView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self viewDidAppearGetList:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - HTTP登录调用
- (void)setupLoadData:(BOOL)isLoadData {
    self.isLoadData = isLoadData;
}

- (void)setupFirstLogin:(BOOL)isFirstLogin {
    self.isFirstLogin = isFirstLogin;
}

- (void)viewDidAppearGetList:(BOOL)isSwitchSite {
    // 第一次http登录成功刷列表
    if (self.isFirstLogin || isSwitchSite || self.isLoadData) {
        // 界面是否显示
        if (self.viewDidAppearEver) {
            [self.tableView startPullDown:YES];
            self.isFirstLogin = NO;
        }
    }
}

- (void)reloadUnreadNum {
}

- (void)getShowList:(BOOL)loadMore {
    self.noDataTipView.hidden = YES;
    LSGetProgramListRequest *request = [[LSGetProgramListRequest alloc] init];

    int start = 0;
    if (!loadMore) {
        // 刷最新
        start = 0;
        LSUITabBarItem *tabbar = (LSUITabBarItem *)self.tabBarItem;
        tabbar.badgeValue = nil;
        [self.timer invalidate];
        self.timer = nil;
    } else {
        // 刷更多
        start = self.page * PageSize;
    }
    request.sortType = PROGRAMLISTTYPE_STARTTIEM;
    // 每页最大纪录数
    request.start = start;
    request.step = PageSize;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LSProgramItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"ShowListViewController::getShowList( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            if (success) {
                self.failView.hidden = YES;
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    // 清空列表
                    [self.dataArray removeAllObjects];
                    [self.items removeAllObjects];
                    self.page = 1;

                    // 下拉刷新成功回调
                    if ([self.showDelegate respondsToSelector:@selector(reloadNowShowList)]) {
                        [self.showDelegate reloadNowShowList];
                    }
                    self.isLoadData = NO;
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];

                    self.page++;
                }

                if (!self.timer) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                }

                [self.dataArray addObjectsFromArray:array];

                if (self.dataArray.count == 0) {
                    self.noDataTipView.hidden = NO;
                } else {
                    [self getShowTime:self.dataArray];
                }
                [self settableViewHeadView];

                [self.tableView reloadData];

            } else {
                self.noDataTipView.hidden = YES;
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:NO];
                    [self.dataArray removeAllObjects];
                    [self.items removeAllObjects];
                    self.failView.hidden = NO;
                    self.isLoadData = YES;
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

- (void)countdown {
    [self getShowTime:self.dataArray];

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

    if (self.dataArray.count >= PageSize * self.page) {
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

#pragma mark TableViewDelegateAndDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ShowCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = [[self.items objectAtIndex:section] objectForKey:@"time"];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowCell *result = nil;
    ShowCell *cell = [ShowCell getUITableViewCell:tableView];
    result = cell;

    if (self.items > 0) {
        LSProgramItemObject *obj = [[[self.items objectAtIndex:indexPath.section] objectForKey:@"time"] objectAtIndex:indexPath.row];
        cell.cellDelegate = self;

        [cell updateUI:obj];
    }

    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.items.count > 0) {
        LSProgramItemObject *obj = [[[self.items objectAtIndex:indexPath.section] objectForKey:@"time"] objectAtIndex:indexPath.row];

        ShowDetailViewController *vc = [[ShowDetailViewController alloc] initWithNibName:nil bundle:nil];
        vc.item = obj;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showCellBtnDid:(NSInteger)type fromItem:(LSProgramItemObject *)item {
    if (type == 1) {
        [[LiveModule module].analyticsManager reportActionEvent:ShowEnterShowBroadcast eventCategory:EventCategoryShowCalendar];
        NSURL *url = [[LiveUrlHandler shareInstance] createUrlToShowRoomId:item.showLiveId anchorId:item.anchorId];
        [[LiveUrlHandler shareInstance] handleOpenURL:url];
    } else if (type == 2) {
        [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarClickGetTicket eventCategory:EventCategoryShowCalendar];
        self.addCreditsView = [[ShowAddCreditsView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.addCreditsView.delegate = self;
        [self.addCreditsView updateUI:item];
        [self.view.window addSubview:self.addCreditsView];
    } else {
        [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarClickMyOtherShows eventCategory:EventCategoryShowCalendar];
        AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
        vc.anchorId = item.anchorId;
        vc.enterRoom = 1;
        vc.tabType = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 20)];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, _tableView.frame.size.width - 15, 20)];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = COLOR_WITH_16BAND_RGB(0x979797);
    label.text = [[self.items objectAtIndex:section] objectForKey:@"day"];
    [headerView addSubview:label];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

#pragma mark 购票成功回调

- (void)showAddCreditsViewGetTicketBtnDid:(NSString *)showId {

    [self showLoading];
    self.addCreditsView.userInteractionEnabled = NO;
    [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarConfirmGetTicket eventCategory:EventCategoryShowCalendar];
    LSBuyProgramRequest *request = [[LSBuyProgramRequest alloc] init];
    request.liveShowId = showId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, double leftCredit) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            self.addCreditsView.userInteractionEnabled = YES;
            if (success) {
                [[DialogTip dialogTip] showDialogTip:[LiveModule module].moduleVC.view tipText:NSLocalizedStringFromSelf(@"ADD_CREDITS_SUCCESS")];

                self.addCreditsView.obj.ticketStatus = PROGRAMTICKETSTATUS_BUYED;
                self.addCreditsView.obj.isHasFollow = YES;

                [self.addCreditsView removeFromSuperview];

                NSInteger row = [self.dataArray indexOfObject:self.addCreditsView.obj];

                [self.dataArray removeObjectAtIndex:row];
                [self.dataArray insertObject:self.addCreditsView.obj atIndex:row];

                [self getShowTime:self.dataArray];

                [self.tableView reloadData];
            } else {

                if (errnum == HTTP_LCC_ERR_NO_CREDIT) {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromSelf(@"ADD_CREDITS_MSG") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    UIAlertAction *addAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"ADD_CREDITS", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self pushAddCreditVC];
                    }];
                    [alertVC addAction:cancelAC];
                    [alertVC addAction:addAC];
                    [self presentViewController:alertVC animated:YES completion:nil];
                } else {
                    [[DialogTip dialogTip] showDialogTip:[LiveModule module].moduleVC.view.window tipText:errmsg];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)pushAddCreditVC {
    [self.addCreditsView removeFromSuperview];
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark 时间分组
- (void)getShowTime:(NSArray *)array {
    NSMutableArray *data = [NSMutableArray array];
    for (LSProgramItemObject *item in array) {
        LSProgramItemObject *items = [[LSProgramItemObject alloc] init];
        items = item;
        items.leftSecToEnter = items.leftSecToEnter - 10;
        items.leftSecToStart = items.leftSecToStart - 10;
        [data addObject:items];
    }

    NSMutableArray *timeArray = [NSMutableArray array];

    NSMutableArray *dayArary = [NSMutableArray array];

    for (LSProgramItemObject *obj in data) {
        NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
        stampFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [stampFormatter setDateFormat:@"MMM dd"];
        NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:obj.startTime];
        NSString *timeStr = [stampFormatter stringFromDate:timeDate];
        //拼接时间和obj
        [timeArray addObject:@{ @"time" : timeStr,
                                @"obj" : obj }];

        NSDate *dayDate = [NSDate dateWithTimeIntervalSince1970:obj.startTime];
        NSString *dayStr = [stampFormatter stringFromDate:dayDate];
        [dayArary addObject:dayStr];
    }

    if (timeArray.count == 0) {
        return;
    }

    NSMutableArray *dateArray = [NSMutableArray arrayWithArray:timeArray];

    NSMutableArray *times = [@[] mutableCopy];
    for (int i = 0; i < dateArray.count; i++) {

        NSString *string = [dateArray[i] objectForKey:@"time"];

        NSMutableArray *tempArray = [@[] mutableCopy];

        [tempArray addObject:[dateArray[i] objectForKey:@"obj"]];

        for (int j = i + 1; j < dateArray.count; j++) {

            NSString *jstring = [dateArray[j] objectForKey:@"time"];

            if ([string isEqualToString:jstring]) {

                LSProgramItemObject *obj = [dateArray[j] objectForKey:@"obj"];
                [tempArray addObject:obj];

                [dateArray removeObjectAtIndex:j];
                j -= 1;
            }
        }

        [times addObject:tempArray];
    }

    NSMutableArray *listAry = [[NSMutableArray alloc] init];
    for (NSString *str in dayArary) {
        if (![listAry containsObject:str]) {
            [listAry addObject:str];
        }
    }

    NSMutableArray * objArray = [NSMutableArray array];
    for (int i = 0; i < times.count; i++) {
        
        NSDictionary *dic = @{ @"day" : [listAry objectAtIndex:i],
                               @"time" : [times objectAtIndex:i] };
        [objArray addObject:dic];
    }
    
    self.items = objArray;
}

@end
