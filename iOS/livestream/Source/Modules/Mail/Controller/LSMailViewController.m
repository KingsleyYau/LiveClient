//
//  LSMailViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/11/21.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMailViewController.h"
#import "LSSelectBoxView.h"
#import "MailTableView.h"
#import "LSGetEmfboxListRequest.h"
#import "LiveUrlHandler.h"
#import "LSMailDetailViewController.h"
#import "LSOutBoxViewController.h"
#import "LSShadowView.h"

#define kFunctionViewHeight 88
#define PageSize 20


@interface LSMailViewController ()<LSSelectBoxViewDelegate,UIScrollViewRefreshDelegate,MailTableViewDelegate,LSMailDetailViewControllerrDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIButton *selectBoxBtn;

@property (weak, nonatomic) IBOutlet MailTableView *tableView;

@property (nonatomic, strong) LSSelectBoxView *selectBoxView;

@property (nonatomic, assign) BOOL isInbox;
/** 是否收件 */
@property (nonatomic, assign) LSEMFType mailType;
/** 单击收起输入控件手势 **/
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) LSSessionRequestManager *seesionRequestManager;

@property (weak, nonatomic) IBOutlet UIImageView *noDataIcon;
@property (weak, nonatomic) IBOutlet UILabel *noDataTips;
@property (weak, nonatomic) IBOutlet UILabel *noDataNote;
@property (weak, nonatomic) IBOutlet LSHighlightedButton *noDataSearchBtn;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) int page;
@end

@implementation LSMailViewController

- (void)dealloc {
    NSLog(@"LSMailViewController::dealloc()");
    [self.tableView unSetupPullRefresh];
    [self removeSingleTap];
}

- (void)initCustomParam {
    [super initCustomParam];
    
    //    self.isInbox = YES;
    self.mailType = LSEMFTYPE_INBOX;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = NSLocalizedString(@"Mail", nil);
    
    self.items = [NSMutableArray array];
    self.seesionRequestManager = [LSSessionRequestManager manager];

    self.noDataSearchBtn.layer.cornerRadius = 6.0f;
    self.noDataSearchBtn.layer.masksToBounds = YES;
    // 初始化按钮阴影背景
    LSShadowView * shadowView = [[LSShadowView alloc]init];
    [shadowView showShadowAddView:self.noDataSearchBtn];
    
    [self hideNoMailTips];
    [self setupSelectBoxView];
    [self setupTableView];
    [self addSingleTap];
}

- (void)setupSelectBoxView {
    
    self.selectBoxView = [[LSSelectBoxView alloc] init];
    self.selectBoxView.delegate = self;
    [self.view addSubview:self.selectBoxView];
    [self.selectBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectBoxBtn);
        make.top.equalTo(self.selectBoxBtn);
        make.width.equalTo(@186);
        make.height.equalTo(@96);
    }];
    self.selectBoxView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self reportDidShowPage:self.mailType];
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

    if (self.mailType == LSEMFTYPE_INBOX) {
        self.noDataTips.text = NSLocalizedStringFromSelf(@"NO_INBOX_TIP");
    } else if (self.mailType == LSEMFTYPE_OUTBOX) {
        self.noDataTips.text = NSLocalizedStringFromSelf(@"NO_OUTBOX_TIP");
    }
}


- (void)reloadData:(BOOL)isReload {
    if (self.items.count == 0) {
        [self showNoMailTips];
    }else {
        [self hideNoMailTips];
    }
    self.tableView.mailType = self.mailType;
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
    NSLog(@"LSMailViewController::getListRequest( loadMore : %@ )", BOOL2YES(loadMore));
    
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
    [self hideNoMailTips];
    self.failView.hidden = YES;
    
    LSGetEmfboxListRequest *request = [[LSGetEmfboxListRequest alloc] init];
    request.type = self.mailType;
    request.start = start;
    request.step = PageSize;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSHttpLetterListItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSMailViewController::getListRequest (请求信件列表 success : %@, errnum : %d, errmsg : %@)",BOOL2SUCCESS(success), errnum, errmsg);
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

#pragma mark - LSSelectBoxViewDelegate
- (void)didClickInbox {
    self.selectBoxView.hidden = YES;
    [self.selectBoxBtn setTitle:NSLocalizedStringFromSelf(@"INBOX") forState:UIControlStateNormal];
    [self.selectBoxBtn setTitle:NSLocalizedStringFromSelf(@"INBOX") forState:UIControlStateHighlighted];
    
    self.mailType = LSEMFTYPE_INBOX;
    [self reportDidShowPage:self.mailType];
    [self.tableView startLSPullDown:NO];

}

- (void)didClickOutbox {
    self.selectBoxView.hidden = YES;
    [self.selectBoxBtn setTitle:NSLocalizedStringFromSelf(@"OUTBOX") forState:UIControlStateNormal];
    [self.selectBoxBtn setTitle:NSLocalizedStringFromSelf(@"OUTBOX") forState:UIControlStateHighlighted];
    
    self.mailType = LSEMFTYPE_OUTBOX;
    [self reportDidShowPage:self.mailType];
    [self.tableView startLSPullDown:NO];

}

#pragma mark - MailTableViewDelegate
- (void)tableView:(MailTableView *)tableView cellDidSelectRowAtIndexPath:(LSHttpLetterListItemObject *)model index:(NSInteger)index {
    // 当前收件发件选择框存在
    if (!self.selectBoxView.hidden) {
        [self singleTapAction];
    }else if (self.mailType == LSEMFTYPE_INBOX) {
        
        if (!model.hasRead) {
            NSString *creditTips = [[NSUserDefaults standardUserDefaults] objectForKey:@"Mail_CreditTips"];
            if (creditTips != nil) {
                [self mailListDidClickToPushMailDetail:model index:index];
            }else {
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Credits_Tips") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self mailListDidClickToPushMailDetail:model index:index];
                }];
                UIAlertAction *noAsk = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Not_Again") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"Mail_CreditTips" forKey:@"Mail_CreditTips"];
                    [self mailListDidClickToPushMailDetail:model index:index];
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertVc addAction:okAction];
                [alertVc addAction:noAsk];
                [alertVc addAction:cancelAction];
                [self presentViewController:alertVc animated:YES completion:nil];
            }
        }else {
            [self mailListDidClickToPushMailDetail:model index:index];
        }
    }else if(self.mailType == LSEMFTYPE_OUTBOX) {
        [self outBoxListDidClickToPushMailDetail:model index:index];
    }
    
}


// TODO: 接收邮件详情的代理方法 更新邮件未读
- (void)lsMailDetailViewController:(LSMailDetailViewController *)vc haveReadMailDetailMail:(LSHttpLetterListItemObject *)model index:(int)index{
    if (self.items.count > 0) {
        [self.items removeObjectAtIndex:index];
    }
    [self.items insertObject:model atIndex:index];
    
    self.tableView.items = self.items;
    
    [self.tableView reloadData];
}

// TODO: 接收邮件详情的代理方法 更新邮件已回复
- (void)lsMailDetailViewController:(LSMailDetailViewController *)vc haveReplyMailDetailMail:(LSHttpLetterListItemObject *)model index:(int)index {
    if (self.items.count > 0) {
        [self.items removeObjectAtIndex:index];
    }
    [self.items insertObject:model atIndex:index];
    
    self.tableView.items = self.items;
    
    [self.tableView reloadData];
}

- (IBAction)noMailSearchAction:(id)sender {
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHomePage:LiveUrlMainListTypeHot];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}



/**
 收信详情

 @param model 信件内容
 @param index 信件下标
 */
- (void)mailListDidClickToPushMailDetail:(LSHttpLetterListItemObject *)model index:(NSInteger)index{
    // TODO: 跳转EMF情页
    LSMailDetailViewController *vc = [[LSMailDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.mailIndex = (int)index;
    vc.letterItem = model;
    vc.mailDetailDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];

}


/**
 发信详情

 @param model 信件内容
 @param index 信件下标
 */
- (void)outBoxListDidClickToPushMailDetail:(LSHttpLetterListItemObject *)model index:(NSInteger)index{
    LSOutBoxViewController *vc = [[LSOutBoxViewController alloc] initWithNibName:nil bundle:nil];
    vc.letterItem = model;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void)tableViewWillBeginDragging {
    [self singleTapAction];
}

- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        [self.topView addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.topView removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}


/**
 展开选择框背景点击事件
 */
- (void)singleTapAction {
    if (!self.selectBoxView.hidden) {
        self.selectBoxView.hidden = YES;
    }
}


- (IBAction)selectBoxAction:(id)sender {
    self.selectBoxView.hidden = NO;
}

- (void)lsListViewControllerDidClick:(UIButton *)sender {
    self.failView.hidden = YES;
    [self hideNoMailTips];
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.tableView startLSPullDown:YES];
}
@end
