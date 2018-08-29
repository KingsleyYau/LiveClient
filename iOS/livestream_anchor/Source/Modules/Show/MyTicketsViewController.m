//
//  MyTicketsViewController.m
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "MyTicketsViewController.h"
#import "ShowCell.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "AnchorPersonalViewController.h"
#import "MyShowDetailViewController.h"
#define PageSize 50
@interface MyTicketsViewController ()<UITableViewDelegate,UITableViewDataSource,LSListViewControllerDelegate,UIScrollViewDelegate,UIScrollViewRefreshDelegate,ShowCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, strong) NSTimer * timer;
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
    
    // 设置失败页属性
    self.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");
    
    self.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");
    
    self.delegate = self;
    
     [self.tableView startPullDown:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置不被NavigationBar和TabBar遮挡
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getShowList:(BOOL)loadMore
{
    self.noDataTipView.hidden = YES;
    
    int start = 0;
    if (!loadMore) {
        // 刷最新
        start = 0;
        [self.timer invalidate];
        self.timer = nil;
    } else {
        // 刷更多
        start = (int)self.page * PageSize;
    }
    [[LSAnchorRequestManager manager] anchorGetProgramList:start step:PageSize status:self.sortType finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LSAnchorProgramItemObject *> * _Nullable list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MyTicketsViewController::getShowList( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)list.count);
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
                    
                    if (list.count > 0) {
                      self.page++;
                    }
                }
                
                if (!self.timer && self.sortType != ANCHORPROGRAMLISTTYPE_HISTORY) {
                    self.timer =  [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                }
                
                [self.items addObjectsFromArray:list];
                
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
        
    }];
    
}

- (void)getShowTime:(NSArray *)array
{
    NSMutableArray * data = [NSMutableArray array];
    for (LSAnchorProgramItemObject * item in array) {
        LSAnchorProgramItemObject * items = [[LSAnchorProgramItemObject alloc]init];
        items = item;
        items.leftSecToEnter = items.leftSecToEnter - 10;
        items.leftSecToStart = items.leftSecToStart - 10;
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
    if (self.items.count >= PageSize * self.page) {
        // 上拉更多回调
        [self pullUpRefresh];
    }
    else {
        // 停止底部
        [self.tableView finishPullUp:NO];
    }
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
    LSAnchorProgramItemObject * obj = [self.items objectAtIndex:indexPath.row];
    
    if (self.sortType == ANCHORPROGRAMLISTTYPE_HISTORY) {
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
    LSAnchorProgramItemObject * obj = [self.items objectAtIndex:indexPath.row];
    MyShowDetailViewController *detail = [[MyShowDetailViewController alloc] initWithNibName:nil bundle:nil];
    detail.liveShowId = obj.showLiveId;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)showCellBtnDidFromItem:(LSAnchorProgramItemObject *)item
{
    // 生成直播间跳转的URL
    NSURL *url =[[LiveUrlHandler shareInstance] createUrlToShowRoomId:item.showLiveId userId:item.anchorId];
    [LiveUrlHandler shareInstance].url = url;
    [[LiveUrlHandler shareInstance] handleOpenURL];
}


@end
