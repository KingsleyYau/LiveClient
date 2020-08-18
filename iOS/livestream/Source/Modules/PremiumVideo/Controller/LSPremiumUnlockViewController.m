//
//  LSPremiumUnlockViewController.m
//  livestream
//
//  Created by Albert on 2020/7/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumUnlockViewController.h"
#import "LSSayHiGetResponseRequest.h"
#import "LSSessionRequestManager.h"
#import "LSPremiumRequestFooterView.h"
#import "LSRecommendPremiumVideoListRequest.h"
#import "LSGetPremiumVideoListRequest.h"
#import "LSPremiumVideoDetailViewController.h"
#import "AnchorPersonalViewController.h"
#import "LSGetPremiumVideoRecentlyWatchedListRequest.h"
#import "LSUnlockPremiumVideoRequest.h"
#import "DialogTip.h"
#import "LSPremiumVideoDetailViewController.h"
#import "LSDeleteInterestedPremiumVideoRequest.h"
#import "LSAddInterestedPremiumVideoRequest.h"
#import "LiveWebViewController.h"
#import "LSConfigManager.h"
#define PageSize (20)

@interface LSPremiumUnlockViewController ()<UIScrollViewRefreshDelegate, LSPremiumRequestTableViewDelegate, LSPremiumInterestViewDelegate>
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) LSSessionRequestManager *sessionRequestManager;

@property (nonatomic, strong) NSMutableArray *interestItems;

@end

@implementation LSPremiumUnlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.items = [NSMutableArray array];
    self.page = 0;
    self.sessionRequestManager = [LSSessionRequestManager manager];
    
    self.interestItems = [NSMutableArray array];
    
    [self setupSubViews];
    [self setupTableView];
}

-(void)setupSubViews
{
    [self.tipLabel setText:@"You have not watched any videos recently."];
    [self.tipLabel setFont:[UIFont fontWithName:@"ArialMT" size:14]];
    [self.tipLabel setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0]];
     
    NSString *str = @"Videos you recently watched will be add here automatically.Check the stunning videos and get started. Go now.";
    
    [self.richLabel setAttributedText:str RangeText:@"Go now" NormalColor:Color(102, 102, 102, 1) RangeColor:Color(0, 102, 255, 1) WithFont:[UIFont fontWithName:@"ArialMT" size:14] UnderLine:YES LineSpace:5.0];
    self.richLabelH.constant = [self.richLabel getTotalHeight];
    
    [self.richLabel addTapGesture:self sel:@selector(richLabelTap:)];
    
    self.interestView = [[LSPremiumInterestView alloc] init];
    self.interestView.delegate = self;
    [self.interestView setHidden:YES];
    [self.view addSubview:self.interestView];
    [self.interestView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset = 20;
        make.left.right.bottom.equalTo(self.view);
//        make.bottom.equalTo(self.view);
//        make.left.right.equalTo(self.view).offset = 20.f;
    }];
}

- (void)setupTableView {
    // 初始化下拉
    [self.listTableView setupPullRefresh:self pullDown:YES pullUp:YES];
    
    self.listTableView.backgroundView = nil;
    self.listTableView.showsVerticalScrollIndicator = NO;
    self.listTableView.showsHorizontalScrollIndicator = NO;
    self.listTableView.tableViewDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11, *)) {
        self.listTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if (self.items.count == 0) {
        [self.listTableView startLSPullDown:YES];
    }
}

-(void)showNoDataView:(BOOL)show
{
    if (show) {
        [self.tipLabel setHidden:NO];
        [self.richLabel setHidden:NO];
        [self.lineView setHidden:NO];
        [self.nodataImgView setHidden:NO];
        if (self.interestItems.count == 0) {
            [self getInterestList];
        }else{
            [self.interestView setHidden:NO];
        }
    }else{
        [self.tipLabel setHidden:YES];
        [self.richLabel setHidden:YES];
        [self.lineView setHidden:YES];
        [self.nodataImgView setHidden:YES];
        [self.interestView setHidden:YES];
    }
}

- (void)reloadInterestData{
    if (self.items.count == 0 && self.interestItems.count > 0) {
        [self.interestView setHidden:NO];
        [self.interestView setItemsArray:self.interestItems];
    }else{
        [self.interestView setHidden:YES];
    }
    [self.interestView reloadData];
}

- (void)reloadData:(BOOL)isReload {
    //[self.items removeAllObjects];//测试空数据
    if (self.items.count == 0) {
        [self showNoDataView:YES];
    }else {
        [self showNoDataView:NO];
    }

    self.listTableView.items = self.items;
    if (isReload) {
        [self.listTableView reloadData];
    }
    if (self.items.count == 0) {
        [self getInterestList];
    }
}

-(void)richLabelTap:(UITapGestureRecognizer *)tap
{
    NSLog(@"richLabelTap------------");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 数据加载
-(BOOL)getInterestList
{
    LSRecommendPremiumVideoListRequest *request = [[LSRecommendPremiumVideoListRequest alloc] init];
    request.num = 2;
    
    self.interestView.userInteractionEnabled = NO;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int num, NSArray<LSPremiumVideoinfoItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@::getListRequest (请求 LSGetInterestedPremiumVideoListRequest 列表 success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);
            self.interestView.userInteractionEnabled = YES;
            if (success) {
                // 清空列表
                [self.interestItems removeAllObjects];
                
                for (LSPremiumVideoinfoItemObject *itemObj in array) {
                    //[self addItemIfNotExist:itemObj];
                    [self.interestItems addObject:itemObj];
                }
                
                if (self.interestItems.count > 0) {
                    //有数据
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        //显示感兴趣的页面
                        [self reloadInterestData];
                    });
                }
            }else {
                [self.interestItems removeAllObjects];
                [self reloadInterestData];
            }
        });
    };
    BOOL bFlag = [self.sessionRequestManager sendRequest:request];
    return bFlag;
}


- (BOOL)getListRequest:(BOOL)refresh {
    NSLog(@"%@::getListRequest( refresh : %@ )", [self class],BOOL2YES(refresh));
    
    BOOL bFlag = NO;

    int start = 0;
    if (refresh) {
        // 刷最新
        start = 0;
        self.page = 0;
    } else {
        // 刷更多
        start = self.page * PageSize;
    }
    
    self.view.userInteractionEnabled = NO;
    
    LSGetPremiumVideoRecentlyWatchedListRequest *request = [[LSGetPremiumVideoRecentlyWatchedListRequest alloc] init];
    request.start = start;
    request.step = PageSize;

    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int totalCount, NSArray<LSPremiumVideoRecentlyWatchedItemObject *> *array){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@::getListRequest (请求 GetPremiumVideoRecentlyWatchedListRequest列表 success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);
            if (success) {
                if (refresh) {
                    // 停止头部
                    [self.listTableView finishLSPullDown:YES];
                    // 清空列表
                    [self.items removeAllObjects];
                    self.page = 1;
                } else {
                    // 停止底部
                    [self.listTableView finishLSPullUp:YES];
                    
                    self.page++;
                }
                
                for (LSPremiumVideoRecentlyWatchedItemObject *itemObj in array) {
                    //[self addItemIfNotExist:itemObj];
                    [self.items addObject:itemObj];
                }
                [self reloadData:YES];
                
                if (refresh) {
                    if (self.items.count > 0) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            // 拉到最顶
                            [self.listTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        });
                    }
                }
                
            }else {
                if (refresh) {
                    // 停止头部
                    [self.listTableView finishLSPullDown:NO];
                    [self.items removeAllObjects];
                } else {
                    // 停止底部
                    [self.listTableView finishLSPullUp:YES];
                }
                
                [self reloadData:YES];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
            });
        });
    };
    bFlag = [self.sessionRequestManager sendRequest:request];
    return bFlag;
}

#pragma mark - LSPremiumRequestTableViewDelegate
- (void)tableView:(LSPremiumRequestTableView *)tableView didSelectPremiumRequestDetail:(LSPremiumVideoinfoItemObject *)item
{
    //点击列表
    if (item == nil) {
        //点击了提示语
    }else{
        LSPremiumVideoinfoItemObject * obj = item;//[self.items objectAtIndex:index];
        LSPremiumVideoDetailViewController * vc = [[LSPremiumVideoDetailViewController alloc]initWithNibName:nil bundle:nil];
        vc.womanId = obj.anchorId;
        vc.videoId = obj.videoId;
        vc.videoTitle = obj.title;
        vc.videoSubTitle = obj.describe;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(LSPremiumRequestTableView *)tableView didViewAllPremiumRequestDetail:(NSInteger)index
{
    //进入视频详情
    LSPremiumVideoRecentlyWatchedItemObject * obj = [self.items objectAtIndex:index];
    LSPremiumVideoDetailViewController * vc = [[LSPremiumVideoDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.womanId = obj.premiumVideoInfo.anchorId;
    vc.videoId = obj.premiumVideoInfo.videoId;
    vc.videoTitle = obj.premiumVideoInfo.title;
    vc.videoSubTitle = obj.premiumVideoInfo.describe;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(LSPremiumRequestTableView *)tableView didCollectPremiumRequestDetail:(NSInteger)index
{
    LSPremiumVideoAccessKeyItemObject *item = [self.items objectAtIndex:index];
    if (item.premiumVideoInfo.isInterested) {
        //取消收藏
        LSDeleteInterestedPremiumVideoRequest *request = [[LSDeleteInterestedPremiumVideoRequest alloc] init];
        request.videoId = item.premiumVideoInfo.videoId;

        [self showLoading];
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@::(请求 LSDeleteInterestedPremiumVideoRequest success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);
                if (success) {
                    for (LSPremiumVideoAccessKeyItemObject *itemObj in self.items) {
                        if ([itemObj.premiumVideoInfo.videoId isEqual:item.premiumVideoInfo.videoId]) {
                            itemObj.premiumVideoInfo.isInterested = NO;
                        }
                    }
                    //[self reloadData:YES];
                    [self.listTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }else{
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                }
                [self hideLoading];
            });
        };
        [self.sessionRequestManager sendRequest:request];
    }else{
        //添加收藏
        LSAddInterestedPremiumVideoRequest *request = [[LSAddInterestedPremiumVideoRequest alloc] init];
        request.videoId = item.premiumVideoInfo.videoId;
        [self showLoading];
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@::(请求 LSAddInterestedPremiumVideoRequest success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);

                if (success) {
                    for (LSPremiumVideoAccessKeyItemObject *itemObj in self.items) {
                        if ([itemObj.premiumVideoInfo.videoId isEqual:item.premiumVideoInfo.videoId]) {
                            itemObj.premiumVideoInfo.isInterested = YES;
                        }
                    }
//                    [self reloadData:YES];
                    [self.listTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }else{
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                }
                [self hideLoading];
            });
        };
        [self.sessionRequestManager sendRequest:request];
    }
}

- (void)tableView:(LSPremiumRequestTableView *)tableView didUserHeadPremiumRequestDetail:(NSInteger)index
{
    LSPremiumVideoAccessKeyItemObject * item = [self.items objectAtIndex:index];
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.premiumVideoInfo.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

-(void)didTapTipLabel{
    //点击前往公告介绍页面
    NSLog(@"点击前往公告介绍页面");
    NSString *url = [LSConfigManager manager].item.howItWorkUrl;
    LSWKWebViewController *webViewController = [[LSWKWebViewController alloc] initWithNibName:nil bundle:nil];
    UILabel * titleLab = [[UILabel alloc] init];
    titleLab.textColor = COLOR_WITH_16BAND_RGB(0x383838);
    titleLab.text = @"How Premium Videos works";
    titleLab.font = [UIFont systemFontOfSize:17.0];
    webViewController.navigationItem.titleView = titleLab;
    webViewController.requestUrl = url;
    webViewController.isShowTaBar = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - LSPremiumInterestViewDelegate 点击感兴趣item回调
-(void)didSelectInterestItemWithIndex:(NSInteger)row
{
    //进入视频详情
    LSPremiumVideoinfoItemObject * obj = [self.interestItems objectAtIndex:row];
    LSPremiumVideoDetailViewController * vc = [[LSPremiumVideoDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.womanId = obj.anchorId;
    vc.videoId = obj.videoId;
    vc.videoTitle = obj.title;
    vc.videoSubTitle = obj.describe;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)didSelectInterestHeadViewItemWithIndex:(NSInteger)row
{
    LSPremiumVideoinfoItemObject * item = [self.interestItems objectAtIndex:row];
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:YES];
    if (self.items.count == 0) {
        //[self getAnchorList];
    }

}

- (void)pullUpRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:NO];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
