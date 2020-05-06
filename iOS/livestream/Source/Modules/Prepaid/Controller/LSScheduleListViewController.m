//
//  LSScheduleListViewController.m
//  livestream
//
//  Created by Calvin on 2020/4/15.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleListViewController.h"
#import "LSScheduleListTopTypeView.h"
#import "LSPrePaidManager.h"
#import "LSScheduleExpiredCell.h"
#import "LSScheduleAcceptCell.h"
#import "DialogTip.h"
#import "LSScheduleComfirmedCell.h"
#import "LiveUrlHandler.h"
#import "LiveModule.h"
#import "LSScheduleDetailsViewController.h"
@interface LSScheduleListViewController ()<LSPrePaidManagerDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewRefreshDelegate,LSScheduleAcceptCellDelegate,LSScheduleComfirmedCellDelegate>
@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, assign) NSInteger selectRow;
@property (nonatomic, strong) NSArray * dataArray;
@property (nonatomic, assign) BOOL isRequstData;
@property (nonatomic, strong) NSTimer * timer;
@end

@implementation LSScheduleListViewController

- (void)dealloc {
    [[LSPrePaidManager manager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topViewH.constant = 0;
    self.tableViewY.constant = 0;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.dataArray = [NSArray array];
    
    [self.tableView setupPullRefresh:self pullDown:YES pullUp:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[LSPrePaidManager manager] addDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isRequstData = YES;
    self.dataArray = @[];
    [self.tableView reloadData];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
}

- (void)loadData
{
    [self.timer invalidate];
    self.timer = nil;
    if (self.isRequstData) {
        [self getListData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isRequstData = NO;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)setupContainView {
    [super setupContainView];
    
    if (self.type == ScheduleType_Pending || self.type == ScheduleType_Confirmed) {
        self.topViewH.constant = 44;
        self.tableViewY.constant = 44;
        
        self.titleArray = self.type == ScheduleType_Pending?@[@"Pending your confirmation",@"Pending her confirmation"]:@[@"Confirmed",@"Completed",@"Missed",@"Canceled"];
        
        self.selectRow = 0;
        
        [self showSelectTopView];
    }
    
    [self.tableView setTableFooterView:[UIView new]];
}

#pragma mark - 头部选择器
- (void)showSelectTopView {
    LSScheduleListTopTypeView * view = [[LSScheduleListTopTypeView alloc]init];
    view.titleLabel.text = self.titleArray[self.selectRow];
    view.arrowIcon.hidden = NO;
    [view.viewBtn addTarget:self action:@selector(showTopTypeView) forControlEvents:UIControlEventTouchUpInside];
     [self.topView addSubview:view];
    
     [view mas_updateConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self.topView.mas_left);
         make.width.equalTo(self.topView.mas_width);
         make.height.equalTo(@44);
     }];
}

- (void)showTopTypeView {
       self.topViewH.constant = 44;
       self.tableViewY.constant = 44;

       for (int i = 0; i<self.titleArray.count; i++) {
           LSScheduleListTopTypeView * view = [[LSScheduleListTopTypeView alloc]init];
           view.titleLabel.text = self.titleArray[i];
           if (self.selectRow == i) {
               view.selectIcon.hidden = NO;
           }
           view.viewBtn.tag = i;
           [view.viewBtn addTarget:self action:@selector(topViewDid:) forControlEvents:UIControlEventTouchUpInside];
           [self.topView addSubview:view];
           [view mas_updateConstraints:^(MASConstraintMaker *make) {
               make.left.equalTo(self.topView.mas_left);
               make.width.equalTo(self.topView.mas_width);
               make.height.equalTo(@44);
               make.top.equalTo(@(i*44)) ;
           }];
       }
       self.topViewH.constant = self.titleArray.count * 44;
    }

- (void)hideTopTypeView {
    self.topViewH.constant = 44;
    self.tableViewY.constant = 44;
    [self.topView removeAllSubviews];
    [self showSelectTopView];
}

- (void)topViewDid:(UIButton *)btn {
    self.selectRow = btn.tag;
    if (self.type == ScheduleType_Pending) {
        self.selectRow = btn.tag;
    }else {
        switch (btn.tag) {
              case 0:
                  self.type = ScheduleType_Confirmed;
              break;
              case 1:
                  self.type = ScheduleType_Completed;
              break;
              case 2:
                  self.type = ScheduleType_Missed;
              break;
              case 3:
                  self.type = ScheduleType_Canceled;
              break;
              default:
                  break;
          }
    }
    [self hideTopTypeView];
    [self showSelectTopView];
    [self getListData];
}

#pragma mark - 请求数据
- (void)getListData {
    self.noDataLabel.hidden = YES;
    self.noDataImage.hidden = YES;
    LSScheduleSendFlagType sendType = LSSCHEDULESENDFLAGTYPE_ALL;
    if (self.type == ScheduleType_Pending) {
        if (self.selectRow == 0) {
            sendType = LSSCHEDULESENDFLAGTYPE_ANCHOR;
        }else {
            sendType = LSSCHEDULESENDFLAGTYPE_MAN;
        }
    }
    [self showLoading];
    [[LSPrePaidManager manager]getScheduleList:(LSScheduleInviteStatus)self.type sendFlag:sendType anchorId:@"" start:0 step:100];
}

- (void)onRecvGetScheduleList:(HTTP_LCC_ERR_TYPE)errnum array:(NSArray<LSScheduleInviteListItemObject *> *)array {
     dispatch_async(dispatch_get_main_queue(), ^{
         [self hideLoading];
         [self.tableView finishLSPullDown:YES];
         NSLog(@"LSScheduleListViewController::onRecvGetScheduleList count:%ld",array.count);
         if (errnum == HTTP_LCC_ERR_SUCCESS) {
             if (self.type ==ScheduleType_Pending || self.type == ScheduleType_Confirmed) {
                  [[NSNotificationCenter defaultCenter]postNotificationName:@"ReloadScheduleListCount" object:nil];
                 self.dataArray = array;
                 if (self.type == ScheduleType_Confirmed) {
                    
                     NSMutableArray * aArray = [NSMutableArray array];
                     NSMutableArray * bArray = [NSMutableArray array];
                     NSMutableArray * cArray = [NSMutableArray array];
                     NSMutableArray * dArray = [NSMutableArray array];
                     for (LSScheduleInviteListItemObject *item in array) {
                            if (item.isActive) {
                                [aArray addObject:item];
                          }else {
                              //可以激活
                              if (item.startTime - [[NSDate new]timeIntervalSince1970] < 0) {
                                  [bArray addObject:item];
                              }
                              //即将激活
                              else if (item.startTime - [[NSDate new]timeIntervalSince1970] < 1800) {
                                  [cArray addObject:item];
                              }
                              else{
                                  [dArray addObject:item];
                              }
                          }
                     }
                     
                     NSMutableArray * tableArray = [NSMutableArray array];
                     
                     if (aArray.count > 0) {
                         [tableArray addObject:@{@"title":NSLocalizedStringFromSelf(@"STARTED_TITLE"),@"titleBGColor":COLOR_WITH_16BAND_RGB(0xB752B6),@"TextColor":COLOR_WITH_16BAND_RGB(0xB752B6)}];
                        [tableArray addObjectsFromArray:aArray];
                     }
                     if (bArray.count > 0) {
                         [tableArray addObject:@{@"title":NSLocalizedStringFromSelf(@"STARTED_NOW_TITLE"),@"titleBGColor":COLOR_WITH_16BAND_RGB(0xFFE1DB),@"TextColor":COLOR_WITH_16BAND_RGB(0xFC2B00)}];
                         [tableArray addObjectsFromArray:bArray];
                     }
                     
                     if (cArray.count > 0) {
                         [tableArray addObject:@{@"title":NSLocalizedStringFromSelf(@"STARTED_WILL_TITLE"),@"titleBGColor":COLOR_WITH_16BAND_RGB(0xFFE8D9),@"TextColor":COLOR_WITH_16BAND_RGB(0xFE6903)}];
                         [tableArray addObjectsFromArray:cArray];
                     }
                     
                     [tableArray addObjectsFromArray:dArray];

                     self.dataArray = tableArray;
                 }
             }else{
               self.dataArray = array;
             }
             [self.tableView reloadData];
             if (array.count > 0) {
                 self.noDataLabel.hidden = YES;
                 self.noDataImage.hidden = YES;
                
             }else {
                 self.noDataLabel.hidden = NO;
                 self.noDataImage.hidden = NO;
             }
         } else {
             self.noDataLabel.hidden = NO;
             self.noDataImage.hidden = NO;
         }
     });
}

- (void)onRecvSendAcceptSchedule:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime scheduleInviteId:(NSString *)inviteId duration:(int)duration roomInfoItem:(ImScheduleRoomInfoObject *)roomInfoItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
        if (errnum == HTTP_LCC_ERR_SUCCESS) {
            [self getListData];
            [[DialogTip dialogTip]showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"ACCEPT_TIP")];
        } else {
            [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
        }
    });
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self getListData];
}

#pragma talbeViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellH = 0;
    switch (self.type) {
        case ScheduleType_Pending:
             cellH = [LSScheduleAcceptCell cellHeight];
            break;
        case ScheduleType_Confirmed: {
            id item = self.dataArray[indexPath.row];
            if ([item isKindOfClass:[NSDictionary class]]) {
                cellH = 32;
            }
            else {
                LSScheduleInviteListItemObject * item = self.dataArray[indexPath.row];
                cellH = [LSScheduleComfirmedCell cellHeight:item];
            }
        }break;
        case ScheduleType_Completed:
        case ScheduleType_Missed:
        case ScheduleType_Canceled:
        case ScheduleType_Declined:
        case ScheduleType_Expired:
           cellH = [LSScheduleExpiredCell cellHeight];
            break;
        default:
            break;
    }
    return cellH;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *result = [[UITableViewCell alloc] init];
    
    switch (self.type) {
        case ScheduleType_Pending:{
            LSScheduleAcceptCell * cell = [LSScheduleAcceptCell getUITableViewCell:tableView];
            result = cell;
            cell.cellDelegate = self;
            cell.tag = indexPath.row;
            LSScheduleInviteListItemObject * item = self.dataArray[indexPath.row];
            [cell updateUI:item];
        }break;
        case ScheduleType_Confirmed:{
            id item = self.dataArray[indexPath.row];
            if ([item isKindOfClass:[NSDictionary class]]) {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellName"];
                result = cell;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                 cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                 UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
                 [cell addSubview:view];
                 NSDictionary * dic = self.dataArray[indexPath.row];
                 cell.textLabel.text = [dic objectForKey:@"title"];
                 cell.textLabel.textColor = [dic objectForKey:@"TextColor"];
                 cell.backgroundColor = [dic objectForKey:@"titleBGColor"];
                 view.backgroundColor = [dic objectForKey:@"TextColor"];
                    
            }else {
                LSScheduleComfirmedCell * cell = [LSScheduleComfirmedCell getUITableViewCell:tableView];
                result = cell;
                cell.cellDeleagte = self;
                cell.tag = indexPath.row;
                LSScheduleInviteListItemObject * item = self.dataArray[indexPath.row];
                [cell updateUI:item];
            }
        }break;
        case ScheduleType_Completed:
        case ScheduleType_Missed:
        case ScheduleType_Canceled:
        case ScheduleType_Declined:
        case ScheduleType_Expired:{
            LSScheduleExpiredCell * cell = [LSScheduleExpiredCell getUITableViewCell:tableView];
            result = cell;
            LSScheduleInviteListItemObject * item = self.dataArray[indexPath.row];
            [cell updateUI:item];
        }break;
        default:
            break;
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.topViewH.constant != 44) {
        [self hideTopTypeView];
    }else {
        id item = self.dataArray[indexPath.row];
        if (![item isKindOfClass:[NSDictionary class]]) {
           LSScheduleInviteListItemObject * item = self.dataArray[indexPath.row];
            LSScheduleDetailsViewController * vc = [[LSScheduleDetailsViewController alloc]initWithNibName:nil bundle:nil];
            vc.listItem = item;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)scheduleAcceptCellDidAcceptBtn:(NSInteger)row {
    LSScheduleInviteListItemObject * item = self.dataArray[row];
    [self showLoading];
    [[LSPrePaidManager manager]sendAcceptScheduleInvite:item.inviteId duration:item.duration infoObj:nil];
}

- (void)scheduleAcceptCellDidViewBtn:(NSInteger)row {
    //TODO:进入预付费详情
    LSScheduleInviteListItemObject * item = self.dataArray[row];
     LSScheduleDetailsViewController * vc = [[LSScheduleDetailsViewController alloc]initWithNibName:nil bundle:nil];
     vc.listItem = item;
     [self.navigationController pushViewController:vc animated:YES];
}

- (void)scheduleComfirmedCellDidStartBtn:(NSInteger)row {
    LSScheduleInviteListItemObject * item = self.dataArray[row];
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorName:item.anchorInfo.nickName anchorId:item.anchorInfo.anchorId roomType:LiveRoomType_Private];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

@end
