//
//  LSSayHiResponseListViewController.m
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiResponseListViewController.h"
#import "LSSayHiGetResponseRequest.h"
#import "LSUserUnreadCountManager.h"
#import "LSSayHiGetAnchorListRequest.h"
#import "LiveRoomCreditRebateManager.h"
#import "LSAddCreditsViewController.h"
#import "LSSayHiChooseView.h"
#import "LSSayHiRecommendView.h"
#import "AnchorPersonalViewController.h"
#import "LSShadowView.h"
#import "LSSayHiDetailViewController.h"
#import "LiveUrlHandler.h"
#define PageSize 50
#define SayHiSortTpye @"SayHiSortTpye"
#define SayHiSortTpyeUnread @"Unread"
#define SayHiSortTpyeNew @"Newest"

#define collectionViewHeight   ([UIScreen mainScreen].bounds.size.width - 45) * 0.5 * 1.35
@interface LSSayHiResponseListViewController ()<UIScrollViewRefreshDelegate,LSSayHiResponseListTableViewDelegate,LSSayHiChooseViewDelegate,LSSayHiRecommendViewDelegate>
@property (nonatomic, strong) LSSessionRequestManager *sessionRequestManager;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) int page;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
@property (nonatomic, strong) LSSayHiChooseView *chooseView;
@property (weak, nonatomic) IBOutlet LSSayHiRecommendView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;
@property (weak, nonatomic) IBOutlet UILabel *responeseListNoteTips;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIImageView *sayHiEmptyIcon;
/**  */
@property (nonatomic, assign) LSSayHiListType type;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseBtnBottom;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
/**
 *  单击收起输入控件手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation LSSayHiResponseListViewController

- (void)dealloc {
    [self.tableView unInitPullRefresh];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupTableView];

    self.searchBtn.layer.cornerRadius = 6.0f;
    self.searchBtn.layer.masksToBounds = YES;
    self.chooseBtn.layer.cornerRadius = self.chooseBtn.frame.size.height * 0.5f;
    self.chooseBtn.layer.masksToBounds = YES;
    
    NSString *sortType = [[NSUserDefaults standardUserDefaults] objectForKey:SayHiSortTpye];
    if (sortType && sortType.length > 0) {
        if ([sortType isEqualToString:SayHiSortTpyeUnread]) {
            [self.chooseBtn setTitle:@"Unread First" forState:UIControlStateNormal];
        }else {
            [self.chooseBtn setTitle:@"Newest First" forState:UIControlStateNormal];
        }
    }else {
        [self.chooseBtn setTitle:@"Unread First" forState:UIControlStateNormal];
    }
    
    if (IS_IPHONE_X) {
        self.chooseBtnBottom.constant = 55;
    }
    
    LSShadowView *chooseShadow = [[LSShadowView alloc] init];
    [chooseShadow showShadowAddView:self.chooseBtn];
    
    LSShadowView *shadow = [[LSShadowView alloc] init];
    [shadow showShadowAddView:self.searchBtn];
    
    self.type = LSSAYHILISTTYPE_UNREAD;
    
    self.items = [NSMutableArray array];
    self.sessionRequestManager = [LSSessionRequestManager manager];
    [self hideNoSayHiTips];
}

- (void)setupChooseView {
    if (!self.chooseView) {
        self.chooseView = [[LSSayHiChooseView alloc] init];
        [self.view addSubview:self.chooseView];
        [self.view bringSubviewToFront:self.chooseView];
        [self.chooseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view.mas_right).offset(-20);
            make.bottom.equalTo(self.chooseBtn.mas_top).offset(-7);
            make.height.equalTo(@(140));
            make.width.equalTo(@(159));
        }];
        self.chooseView.delegate = self;
        self.chooseView.hidden = NO;
    }else {
        self.chooseView.hidden = NO;
    }
    NSString *sortType = [[NSUserDefaults standardUserDefaults] objectForKey:SayHiSortTpye];
    if (sortType && sortType.length > 0) {
        if ([sortType isEqualToString:SayHiSortTpyeUnread]) {
            self.chooseView.isSelectedUnread = YES;
            [self.chooseBtn setTitle:@"Unread First" forState:UIControlStateNormal];
        }else {
            self.chooseView.isSelectedUnread = NO;
            [self.chooseBtn setTitle:@"Newest First" forState:UIControlStateNormal];
        }
    }else {
        self.chooseView.isSelectedUnread = YES;
    }
    [self addSingleTap];
}

- (void)setupTableView {
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.tableViewDelegate = self;
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
    [self.tableView startPullDown:YES];
    
}

- (void)reloadData:(BOOL)isReload {
    if (self.items.count == 0) {
        [self showNoSayHiTips];
    }else {
        [self hideNoSayHiTips];
        self.chooseBtn.hidden = NO;
    }
    
    self.tableView.items = self.items;
    if (isReload) {
        [self.tableView reloadData];
    }
}


- (void)showNoSayHiTips {
    self.bottomView.hidden = NO;
    self.responeseListNoteTips.hidden = NO;
    self.sayHiEmptyIcon.hidden = NO;
    self.chooseBtn.hidden = YES;
}


- (void)hideNoSayHiTips {
    self.bottomView.hidden = YES;
    self.responeseListNoteTips.hidden = YES;
    self.sayHiEmptyIcon.hidden = YES;

}

- (IBAction)chooseAction:(id)sender {
    [self setupChooseView];
}


- (void)addSingleTap {
    // 增加点击收起键盘手势
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeChooseView)];
        [self.tableView addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    // 移除点击收起键盘手势
    if (self.singleTap) {
        [self.tableView removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

- (void)closeChooseView {
    self.chooseView.hidden = YES;
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
    NSLog(@"LSSayHiResponseListViewController::getListRequest( loadMore : %@ )", BOOL2YES(loadMore));
    
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
    
    LSSayHiGetResponseRequest *request = [[LSSayHiGetResponseRequest alloc] init];
    request.start = start;
    request.step = PageSize;
    request.type = self.type;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResponseItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSayHiResponseListViewController::getListRequest (请求sayHiResponse列表 success : %@, errnum : %d, errmsg : %@)",BOOL2SUCCESS(success), errnum, errmsg);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SayHiGetUnreadCount" object:nil];
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
                
                for (LSSayHiResponseListItemObject *itemObj in item.list) {
                    
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
    bFlag = [self.sessionRequestManager sendRequest:request];
    return bFlag;
}

- (void)addItemIfNotExist:(LSSayHiResponseListItemObject *_Nonnull)itemNew {
    bool bFlag = NO;
    
    for (LSSayHiResponseListItemObject *item in self.items) {
        if ([item.responseId isEqualToString:itemNew.responseId]) {
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
    [self hideNoSayHiTips];
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.tableView startPullDown:YES];
}



- (void)tableView:(LSSayHiResponseListTableView *)tableView didSelectSayHiDetail:(LSSayHiResponseListItemObject *)item {
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"SayHiAgainTip"]) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromSelf(@"BUY_TIP") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
              //TODO: 跳转到指定的详情页
            [self pushSayHiDetailVC:item];
        }];
        UIAlertAction * aginAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"AGAIN_TIP") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"SayHiAgainTip"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [alertController addAction:aginAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else {
        //TODO: 跳转到指定的详情页
        [self pushSayHiDetailVC:item];
    }
}

- (void)pushSayHiDetailVC:(LSSayHiResponseListItemObject *)item {
    LSSayHiDetailItemObject * detail = [[LSSayHiDetailItemObject alloc]init];
    detail.nickName = item.nickName;
    detail.age = item.age;
    detail.avatar = item.avatar;
    
    LSSayHiDetailViewController * vc = [[LSSayHiDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.sayHiID = item.sayHiId;
    vc.responseId = item.responseId;
    vc.detail = detail;
    [self.navigationController pushViewController:vc animated:YES];
}


- (BOOL)getAnchorList {
    LSSayHiGetAnchorListRequest *request = [[LSSayHiGetAnchorListRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSSayHiAnchorItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSayHiResponseListViewController::getAnchorList (请求推荐列表 success : %@, errnum : %d, errmsg : %@)",BOOL2SUCCESS(success), errnum, errmsg);
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


- (void)sayHiChooseViewSelected:(BOOL)isUnread {
    self.chooseView.hidden = YES;
    [self removeSingleTap];
    if (isUnread) {
        self.type = LSSAYHILISTTYPE_UNREAD;
        [self.chooseBtn setTitle:@"Unread First" forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:SayHiSortTpyeUnread forKey:SayHiSortTpye];
    }else {
        self.type = LSSAYHILISTTYPE_LATEST;
        [self.chooseBtn setTitle:@"Newest First" forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:SayHiSortTpyeNew forKey:SayHiSortTpye];
    }
    [self.tableView startPullDown:YES];
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
