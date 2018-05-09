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
@interface ShowListViewController ()<UITableViewDelegate,UITableViewDataSource,ShowCellDelegate,ShowAddCreditsViewDelegate,LSListViewControllerDelegate,UIScrollViewDelegate,UIScrollViewRefreshDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
//列表数据
@property (nonatomic, strong) NSMutableArray *items;
//原始数据
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIView *noDataTipView;
@property (nonatomic, strong) NSTimer * timer;
@end

@implementation ShowListViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView unInitPullRefresh];
}

- (void)initCustomParam
{
    [super initCustomParam];
    
    LSUITabBarItem *tabBarItem = [[LSUITabBarItem alloc] init];
    self.tabBarItem = tabBarItem;
    self.tabBarItem.title = @"Calendar";
    self.tabBarItem.image = [[UIImage imageNamed:@"TabBarShow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBarShow-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSDictionary *normalColor = [NSDictionary dictionaryWithObject:Color(51, 51, 51, 1) forKey:NSForegroundColorAttributeName];
    NSDictionary *selectedColor = [NSDictionary dictionaryWithObject:Color(52, 120, 247, 1) forKey:NSForegroundColorAttributeName];
    [self.tabBarItem setTitleTextAttributes:normalColor forState:UIControlStateNormal];
    [self.tabBarItem setTitleTextAttributes:selectedColor forState:UIControlStateSelected];
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
    
    self.dataArray = [NSMutableArray array];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    // 设置失败页属性
    self.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");
    
    self.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");
    
    self.delegate = self;
}

- (void)settableViewHeadView
{
    NSString * str = [LSConfigManager manager].item.showDescription;
    CGRect rect = [str boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, rect.size.height + 10)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, SCREEN_WIDTH - 30, rect.size.height)];
    label.font = [UIFont systemFontOfSize:15];
    label.numberOfLines = 0;
    label.textColor = COLOR_WITH_16BAND_RGB(0x666666);
    label.text = [LSConfigManager manager].item.showDescription;
    [headView addSubview:label];
    [self.tableView setTableHeaderView:headView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置不被NavigationBar和TabBar遮挡
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (self.dataArray.count == 0 || self.isLoadData) {
      self.isLoadData = NO;
      [self.tableView startPullDown:YES];
    }
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
        LSUITabBarItem * tabbar = (LSUITabBarItem *)self.tabBarItem;
        tabbar.badgeValue = nil;
        [self.timer invalidate];
        self.timer = nil;
    } else {
        // 刷更多
        start = self.dataArray ? ((int)self.dataArray.count) : 0;
    }
    request.sortType = PROGRAMLISTTYPE_STARTTIEM;
    // 每页最大纪录数
    request.start = start;
    request.step = 10;
    
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LSProgramItemObject *> * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"ShowListViewController::getShowList( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            if (success) {
                self.failView.hidden = YES;
                
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    // 清空列表
                    [self.dataArray removeAllObjects];

                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }
                
                if (!self.timer) {
                    self.timer =  [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                }
                
                [self.dataArray addObjectsFromArray:array];
            
                if (self.dataArray.count == 0) {
                     self.noDataTipView.hidden = NO;
                }
                
                [self getShowTime:self.dataArray];

                [self settableViewHeadView];
                
                [self.tableView reloadData];
            }
            else
            {
                self.noDataTipView.hidden = YES;
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    [self.dataArray removeAllObjects];
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

- (void)countdown
{
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
    // 上拉更多回调
    [self pullUpRefresh];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"%@",scrollView);
}

#pragma mark 失败界面点击事件
- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
    [self reloadBtnClick:sender];
}

- (void)reloadBtnClick:(id)sender {
    self.failView.hidden = YES;
   
    [self.tableView startPullDown:YES];
}

#pragma mark TableViewDelegateAndDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ShowCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * array = [[self.items objectAtIndex:section] objectForKey:@"time"];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowCell *result = nil;
    ShowCell *cell = [ShowCell getUITableViewCell:tableView];
    result = cell;
    
    if (self.items > 0) {
        LSProgramItemObject * obj = [[[self.items objectAtIndex:indexPath.section] objectForKey:@"time"] objectAtIndex:indexPath.row];
        cell.cellDelegate = self;
        
        [cell updateUI:obj];
    }

    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.items.count > 0) {
        LSProgramItemObject * obj = [[[self.items objectAtIndex:indexPath.section] objectForKey:@"time"] objectAtIndex:indexPath.row];
        
        ShowDetailViewController * vc = [[ShowDetailViewController alloc]initWithNibName:nil bundle:nil];
        vc.item = obj;
        [self.navigationController pushViewController:vc animated:YES];
    }
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 20)];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, _tableView.frame.size.width-15, 20)];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = COLOR_WITH_16BAND_RGB(0x979797);
    label.text = [[self.items objectAtIndex:section] objectForKey:@"day"];
    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

#pragma mark 购票成功回调
- (void)buyProgramSuccess:(LSProgramItemObject *)item
{
    
    NSInteger row = [self.dataArray indexOfObject:item];
    
    [self.dataArray removeObjectAtIndex:row];
    [self.dataArray insertObject:item atIndex:row];
    
    [self getShowTime:self.dataArray];
    
    [self.tableView reloadData];
}

- (void)pushAddCreditVc
{
    UIViewController *vc = [LiveModule module].addCreditVc;
    if (vc) {
        [self.navigationController pushViewController:vc animated:NO];
    }
}

#pragma mark 时间分组
- (void)getShowTime:(NSArray *)array
{
    
    NSMutableArray *data = [NSMutableArray array];
    for (LSProgramItemObject * item in array) {
        LSProgramItemObject * items = [[LSProgramItemObject alloc]init];
        items = item;
        items.leftSecToEnter = items.leftSecToEnter - 10;
        [data addObject:items];
    }
    
    NSMutableArray *timeArray = [NSMutableArray array];
    
    NSMutableArray *dayArary = [NSMutableArray array];
    
    for (LSProgramItemObject *obj in data) {
        NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
        stampFormatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        [stampFormatter setDateFormat:@"MMM dd"];
        NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:obj.startTime];
        NSString *timeStr = [stampFormatter stringFromDate:timeDate];
        //拼接时间和obj
        [timeArray addObject:@{@"time":timeStr,@"obj":obj}];
        
        NSDate *dayDate = [NSDate dateWithTimeIntervalSince1970:obj.startTime];
        NSString *dayStr = [stampFormatter stringFromDate:dayDate];
        [dayArary addObject:dayStr];
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
