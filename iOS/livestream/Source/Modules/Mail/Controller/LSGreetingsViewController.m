//
//  LSGreetingsViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/11/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGreetingsViewController.h"
#import "LSGreetingDetailViewController.h"

#import "MailTableView.h"

#import "LiveUrlHandler.h"
#import "LSSessionRequestManager.h"
#import "LSGetLoiListRequest.h"
#import "LSOutOfCreditsView.h"
#import "LSOutOfPoststampView.h"
#import "LSShadowView.h"

#define kFunctionViewHeight 88
#define PageSize 20

@interface LSGreetingsViewController ()<UIScrollViewRefreshDelegate,MailTableViewDelegate,LSOutOfCreditsViewDelegate,LSOutOfPoststampViewDelegate,LSGreetingDetailViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MailTableView *tableView;
@property (nonatomic, strong) LSSessionRequestManager *seesionRequestManager;
@property (weak, nonatomic) IBOutlet UIImageView *noDataIcon;
@property (weak, nonatomic) IBOutlet UILabel *noDataTips;
@property (weak, nonatomic) IBOutlet UILabel *noDataNote;
@property (weak, nonatomic) IBOutlet UIButton *noDataSearchBtn;

@property (weak, nonatomic) IBOutlet LSHighlightedButton *searchBtn;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) int page;

@end

@implementation LSGreetingsViewController

- (void)dealloc {
    NSLog(@"LSGreetingsViewController::dealloc()");
    
    [self.tableView unSetupPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"GREETING", nil);
    
    self.searchBtn.layer.masksToBounds = YES;
    self.searchBtn.layer.cornerRadius = 5;
    self.seesionRequestManager = [LSSessionRequestManager manager];
    self.items = [NSMutableArray array];
    
    self.noDataSearchBtn.layer.cornerRadius = 6.0f;
    self.noDataSearchBtn.layer.masksToBounds = YES;
    // 初始化按钮阴影背景
    LSShadowView * shadowView = [[LSShadowView alloc] init];
    [shadowView showShadowAddView:self.noDataSearchBtn];
    
    [self hideNoMailTips];
    
    // 设置上/下拉
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (!self.viewDidAppearEver) {
        [self.tableView startLSPullDown:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupTableView {
    self.tableView.frame = CGRectMake(0, kFunctionViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kFunctionViewHeight);
    // 初始化下拉
    [self.tableView setupPullRefresh:self pullDown:YES pullUp:YES];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.mailDelegate = self;
}

- (void)hideNoMailTips {
    self.noDataIcon.hidden = YES;
    self.noDataTips.hidden = YES;
    self.noDataSearchBtn.hidden = YES;
    self.noDataNote.hidden = YES;
}
- (void)showNoMailTips {
    self.noDataIcon.hidden = NO;
    self.noDataTips.hidden = NO;
    self.noDataSearchBtn.hidden = NO;
    self.noDataNote.hidden = NO;
}

- (void)reloadData:(BOOL)isReload {
    if (self.items.count == 0) {
        [self showNoMailTips];
    }else {
        [self hideNoMailTips];
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
    NSLog(@"LSGreetingsViewController::getListRequest( loadMore : %@ )", BOOL2YES(loadMore));
    BOOL bFlag = NO;
    
    int start = 0;
    if (!loadMore) {
        // 刷最新
        start = 0;
    } else {
        // 刷更多
        start = self.page * PageSize;
    }
    
    // 请求接口隐藏没有数据和失败页
    [self hideNoMailTips];
    self.failView.hidden = YES;
    
    LSGetLoiListRequest *request = [[LSGetLoiListRequest alloc] init];
    request.start = start;
    request.step = PageSize;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSHttpLetterListItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
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
                
                for (LSHttpLetterListItemObject *item in array) {
                    
                    [self addLadyIfNotExist:item];
                }
                [self reloadData:YES];
                
            } else {
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
    bFlag = [self.seesionRequestManager sendRequest:request];
    return bFlag;
}

- (void)addLadyIfNotExist:(LSHttpLetterListItemObject *_Nonnull)listItem {
    bool bFlag = NO;
    for (LSHttpLetterListItemObject *item in self.items) {
        if ([listItem.letterId isEqualToString:item.letterId]) {
            // 已经存在
            bFlag = YES;
            break;
        }
    }
    if (!bFlag) {
        // 不存在
        [self.items addObject:listItem];
    }
}

#pragma mark - MailTableViewDelegate
- (void)tableView:(MailTableView *)tableView cellDidSelectRowAtIndexPath:(LSHttpLetterListItemObject *)model index:(NSInteger)index  {
    LSGreetingDetailViewController *vc = [[LSGreetingDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.greetingDetailDelegate = self;
    vc.letterItem = model;
    vc.greetingMailIndex = (int)index;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)searchAction:(id)sender {
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHomePage:LiveUrlMainListTypeHot];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

- (IBAction)scrollTopAction:(id)sender {
//    [self.tableView scrollsToTop];
//    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self scrollToTop];
//    [[LSOutOfPoststampView initWithActionViewDelegate:self] outOfPoststampShowCreditView:self.navigationController.view balanceCount:@"3"];
//    [[LSOutOfCreditsView initWithActionViewDelegate:self] outOfCreditShowPoststampAndAddCreditView:self.navigationController.view poststampCount:@"2"];
    
}

- (void)scrollToTop {
    if ([self.tableView numberOfRowsInSection:0] > 0) {
        NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - LSGreetingDetailViewControllerDelegate
- (void)lsGreetingDetailViewController:(LSGreetingDetailViewController *)vc haveReadGreetingDetailMail:(LSHttpLetterListItemObject *)model index:(int)index {
    if (self.items.count > 0) {
        [self.items removeObjectAtIndex:index];
    }
    [self.items insertObject:model atIndex:index];
    
    self.tableView.items = self.items;
    
    [self.tableView reloadData];
}

- (void)lsGreetingDetailViewController:(LSGreetingDetailViewController *)vc haveReplyGreetingDetailMail:(LSHttpLetterListItemObject *)model index:(int)index {
    if (self.items.count > 0) {
        [self.items removeObjectAtIndex:index];
    }
    [self.items insertObject:model atIndex:index];
    
    self.tableView.items = self.items;
    
    [self.tableView reloadData];
}

- (void)lsListViewControllerDidClick:(UIButton *)sender {
    self.failView.hidden = YES;
    [self hideNoMailTips];
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.tableView startLSPullDown:YES];
}

@end
