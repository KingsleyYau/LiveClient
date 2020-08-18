//
//  VouchersListViewController.m
//  livestream
//
//  Created by Calvin on 17/10/13.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "VouchersListViewController.h"
#import "VouchersListTableViewCell.h"
#import "VoucherListRequest.h"
#import "GetChatVoucherListRequest.h"
#import "DialogTip.h"
#import "AnchorPersonalViewController.h"
@interface VouchersListViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewRefreshDelegate,TTTAttributedLabel>

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet LSTableView *tableView;
@property (nonatomic, strong) NSMutableArray * array;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@property (nonatomic, assign) BOOL isRequstData;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSString *anchorId;
@property (nonatomic, strong) NSArray * showArray;
@end

@implementation VouchersListViewController

- (void)dealloc {
    [self.tableView unSetupPullRefresh];
    NSLog(@"VouchersListViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.array = [NSMutableArray array];
    self.sessionManager = [LSSessionRequestManager manager];
    self.infoBtn.layer.cornerRadius = 5;
    self.infoBtn.layer.masksToBounds = YES;
    
    [self.tableView setTableFooterView:[UIView new]];
    
    [self.tableView setupPullRefresh:self pullDown:YES pullUp:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isRequstData = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
}

- (void)loadData
{
    [self.timer invalidate];
    self.timer = nil;
    if (self.isRequstData) {
        [self showLoading];
        [self loadAllVoucher];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isRequstData = NO;
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark 重新加载
- (void)lsListViewControllerDidClick:(UIButton *)sender {
    [super lsListViewControllerDidClick:sender];
    [self showLoading];
    [self loadAllVoucher];
}

/**
 *  下拉刷新
 */
- (void)pullDownRefresh {
    
    [self loadAllVoucher];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

#pragma mark 获取试聊券
- (void)loadAllVoucher {
    [self getLiveVoucherListRequest];
}


- (void)getLiveVoucherListRequest
{
    //    self.infoView.hidden = YES;
    self.failView.hidden = YES;
    [self hideNoDataView];
    //self.tableView.hidden = NO;
    VoucherListRequest * request = [[VoucherListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<VoucherItemObject *> * _Nullable array, int totalCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"VouchersListViewController::getLiveVoucherListRequest (获取直播试聊卷 success : %@, errnum : %d, errmsg : %@ ,array: %lu)",BOOL2SUCCESS(success), errnum, errmsg,(unsigned long)array.count);
            NSLog(@"%@",self.showArray);
            [self hideLoading];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"MyBackPackGetUnreadCount" object:nil];
            [self.array removeAllObjects];
            for (VoucherItemObject *item in array) {
                [self addItemIfNotExist:item];
            }
            
            if (success) {
                [self getChatVoucherListRequest];
            }
            else
            {
                [self hideLoading];
                [self.tableView finishLSPullDown:YES];
                if (array.count == 0) {
                    self.failView.hidden = NO;
                }
                else
                {
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
                }
            }
        });
    };
    
    [self.sessionManager sendRequest:request];
}

- (void)getChatVoucherListRequest {
    GetChatVoucherListRequest *request = [[GetChatVoucherListRequest alloc] init];
    request.finishHandler = ^(BOOL success, NSString *errnum, NSString *errmsg, NSArray<VoucherItemObject *> *array, int totalCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"VouchersListViewController::getChatVoucherListRequest (获取聊天试聊卷 success : %@, errnum : %@, errmsg : %@ , array : %lu)",BOOL2SUCCESS(success), errnum, errmsg,(unsigned long)array.count);
            NSLog(@"%@",self.showArray);
            if (success) {
                for (VoucherItemObject *item in array) {
                    [self addItemIfNotExist:item];
                }
            
                if (self.array.count == 0) {
                    [self showNoDataView];
                    self.noDataTip.text = @"No Vouchers available.";
                }
            }
            else
            {
                if (array.count == 0) {
                    self.failView.hidden = NO;
                }
                else
                {
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
                }
            }
            self.showArray = [self.array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                VoucherItemObject * item1 = obj1;
                VoucherItemObject * item2 = obj2;
                return item1.grantedDate < item2.grantedDate;
            }];
            [self.tableView reloadData];
            [self.tableView finishLSPullDown:YES];
            
        });
    };
    [self.sessionManager sendRequest:request];
}


- (void)addItemIfNotExist:(VoucherItemObject *_Nonnull)itemNew {
    bool bFlag = NO;
    
    for (VoucherItemObject *item in self.array) {
        if ([item.voucherId isEqualToString:itemNew.voucherId]) {
            // 已经存在
            bFlag = true;
            break;
        }
    }
    
    if (!bFlag) {
        // 不存在
        [self.array addObject:itemNew];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VouchersListTableViewCell cellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *result = [[UITableViewCell alloc] init];
    VouchersListTableViewCell * cell = [VouchersListTableViewCell getUITableViewCell:tableView];
    result = cell;
    
    
    if (indexPath.row < self.showArray.count) {
        
        VoucherItemObject * obj = [self.showArray objectAtIndex:indexPath.row];
        
        
        cell.voucherTime.text = [NSString stringWithFormat:@"%d",obj.offsetMin];
        
        cell.voucherCondition.delegate = self;
        
        [cell updateValidTime:obj.startValidDate expTime:obj.expDate];
        
        cell.voucherCondition.tag = indexPath.row;
        
        if (obj.voucherType == VOUCHERTYPE_BROADCAST) {
            // 直播类型试聊卷
            cell.bgImageV.image = [UIImage imageNamed:@"MyBackpack_LiveVoucherBg"];
            
            cell.voucherType.textColor = COLOR_WITH_16BAND_RGB(0x297AF3);
            // 指定主播
            if (obj.anchorType == ANCHORTYPE_APPOINTANCHOR) {
                
                [cell updatelimitedVoucherType:NSLocalizedStringFromSelf(@"Only_broadcaster") withAchor:obj.anchorId];
                
            }else {
                // 不限和没看过直播的主播
                //没看过直播的主播
                if (obj.anchorType == ANCHORTYPE_NOSEEANCHOR) {
                    cell.voucherCondition.text = NSLocalizedStringFromSelf(@"New broadcasters");
                }else {
                    cell.voucherCondition.text = NSLocalizedStringFromSelf(@"No_limit");
                }
            }
            
            // 公开
            if (obj.useRoomType == USEROOMTYPE_PUBLIC) {
                cell.voucherType.text = NSLocalizedStringFromSelf(@"Only_Public");
            } else if (obj.useRoomType == USEROOMTYPE_PRIVATE) {
                //私密
                cell.voucherType.text = NSLocalizedStringFromSelf(@"Only_Private");
            } else {
                cell.voucherType.text = NSLocalizedStringFromSelf(@"No limit sessions");
            }
            
        }else {
            // livechat聊天试聊卷
            cell.bgImageV.image = [UIImage imageNamed:@"MyBackpack_ChatVoucherBg"];
            cell.voucherType.textColor = COLOR_WITH_16BAND_RGB(0x00CC33);
            
            // 指定主播
            if (obj.anchorType == ANCHORTYPE_APPOINTANCHOR) {
                
                [cell updatelimitedVoucherType:NSLocalizedStringFromSelf(@"Only_Chat") withAchor:obj.anchorId];
                
            }else {
                // 不限和没聊过的主播
                // 没聊过的主播
                if (obj.anchorType == ANCHORTYPE_NOSEEANCHOR) {
                    cell.voucherCondition.text = NSLocalizedStringFromSelf(@"New_Chat");
                }else {
                    cell.voucherCondition.text = NSLocalizedStringFromSelf(@"No_Limit_Chat");
                }
            }
            
            
            cell.voucherType.text = NSLocalizedStringFromSelf(@"Chat_Vorcher");
            
        }
        
        cell.unreadIcon.hidden = obj.read;
        
        
    }
    
    return result;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if( [[url absoluteString] isEqualToString:[NSString stringWithFormat:@"%d",(int)label.tag]] ) {
        if (label.tag < self.showArray.count) {
            VoucherItemObject * obj = [self.showArray objectAtIndex:label.tag];
            AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
            listViewController.anchorId = obj.anchorId;
            listViewController.enterRoom = 1;
            [self.navigationController pushViewController:listViewController animated:YES];
        }
    }
}


@end

