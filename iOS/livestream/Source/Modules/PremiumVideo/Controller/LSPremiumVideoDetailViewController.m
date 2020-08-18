//
//  LSPremiumVideoDetailViewController.m
//  livestream
//
//  Created by Calvin on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumVideoDetailViewController.h"
#import "Masonry.h"
#import "QNChatTitleView.h"
#import "LSImageViewLoader.h"
#import "AnchorPersonalViewController.h"
#import "LSUserInfoManager.h"
#import "LSGetPremiumVideoDetailRequest.h"
#import "LSPremiumVideoDetailHeadView.h"
#import "LSGetAnchorPremiumVideoListRequest.h"
#import "LSRecommendPremiumVideoListRequest.h"
#import "LSAddInterestedPremiumVideoRequest.h"
#import "LSDeleteInterestedPremiumVideoRequest.h"
#import "LSConfigManager.h"
#import "LSVideoPlayManager.h"
#import "LSPremiumVideoDetailCell.h"
#import "LSPremiumVideoDetailUnlockCell.h"
#import "LSLadyVideoListCell.h"
#import "LSSendPremiumVideoKeyRequest.h"
#import "LSUnlockPremiumVideoRequest.h"
#import "LSRemindeSendPremiumVideoKeyRequest.h"
#import "LSPrePaidManager.h"
#import "DialogTip.h"
#import "LSTipsDialogView.h"
#import "LiveUrlHandler.h"
#import "LiveModule.h"
#import "LSPremiumInterestView.h"
#import "LSMailDetailViewController.h"
#import "LSGetEmfStatusRequest.h"

@interface LSPremiumVideoDetailViewController ()<UITableViewDelegate,UITableViewDataSource,LSPremiumVideoDetailHeadViewDeleagte,LSPremiumVideoDetailCellDelegate,LSLadyVideoListCellDelegate,LSPremiumInterestViewDelegate,LSMailDetailViewControllerrDelegate>

@property (nonatomic, strong) QNChatTitleView *titleView;
@property (nonatomic, strong) LSImageViewLoader *titleViewLoader;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingIcon;
@property (nonatomic, strong) LSPremiumVideoDetailHeadView * headView;
@property (strong, nonatomic) LSPremiumInterestView * footerView;
@property (nonatomic, strong) LSVideoPlayManager * playManager;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) LSPremiumVideoDetailItemObject * detailItem;
@property (nonatomic, copy) NSString * ladyName;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, assign) BOOL isShowKeyboard;
@property (nonatomic, assign) BOOL emfHasRead;
@property (nonatomic, strong) NSArray * footerData;
@end

@implementation LSPremiumVideoDetailViewController

- (void)dealloc {
    [self.headView deleteVideo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray array];
   
    NSMutableArray * images = [NSMutableArray array];
    for (int i = 1; i <= 7; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"Prelive_Loading%d",i]];
        [images addObject:image];
    }
    self.loadingIcon.animationImages = images;
    self.loadingIcon.animationDuration = 0.6;
    [self.loadingIcon startAnimating];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.playManager = [[LSVideoPlayManager alloc] init];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];

    // 标题
    self.titleView = [[QNChatTitleView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLadyDetail)];
    [self.titleView addGestureRecognizer:singleTap];
    self.titleView.personName.text = @"";
    self.titleView.loadingActivity.hidden = YES;
    self.titleView.loadingActivity.alpha = 0;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
        }];
    }

    self.navigationItem.titleView = self.titleView;
    
    // 获取用户信息
    WeakObject(self, weakSelf);
    self.titleViewLoader = [LSImageViewLoader loader];
    [[LSUserInfoManager manager] getUserInfo:weakSelf.womanId
                               finishHandler:^(LSUserInfoModel *_Nonnull item) {
        [weakSelf.titleViewLoader loadImageWithImageView:weakSelf.titleView.personIcon options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:LADYDEFAULTIMG finishHandler:nil];
        weakSelf.ladyName = item.nickName;
        weakSelf.isOnline = item.isOnline;
        weakSelf.photoUrl = item.photoUrl;
        weakSelf.titleView.personName.text = item.nickName;
        weakSelf.titleView.onlineIcon.hidden = !item.isOnline;
        weakSelf.titleView.loadingActivity.hidden = YES;
        weakSelf.titleView.loadingActivity.alpha = 0;
                               }];
}

-(void)getEmfStatus
{
    if (self.detailItem == nil || self.detailItem.emfId == nil || self.detailItem.emfId.length == 0) {
        return;
    }
    LSGetEmfStatusRequest *emfRequest = [[LSGetEmfStatusRequest alloc] init];
    emfRequest.emfId = self.detailItem.emfId;
    emfRequest.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, bool hasRead){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getEmfStatus::%@ errnum:%d ,errmsg:%@ ",BOOL2YES(success),errnum,errmsg);
            if (success) {
                self.emfHasRead = hasRead;
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:emfRequest];
}

- (void)showLadyDetail {
    //TODO:风控
    //if (![[RiskControlManager manager] isRiskControlType:RiskType_Ladyprofile]) {

    AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = self.womanId;
    vc.enterRoom = 1;
    [self.navigationController pushViewController:vc animated:YES];
    //}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    if (!self.viewDidAppearEver) {
        [self getVideoDetail];
    }

     // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.headView deleteVideo];
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 接口请求
//获取视频详情
- (void)getVideoDetail {
    LSGetPremiumVideoDetailRequest * request = [[LSGetPremiumVideoDetailRequest alloc]init];
    request.videoId = self.videoId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSPremiumVideoDetailItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getVideoDrtail::%@ errnum:%d ,errmsg:%@ ",BOOL2YES(success),errnum,errmsg);
            self.tableView.hidden = NO;
            self.loadingView.hidden = YES;
            [self getLadyVideoList];
            if (success) {
                self.detailItem = item;
                [self.headView removeFromSuperview];
                self.headView = nil;
                self.headView = [[LSPremiumVideoDetailHeadView alloc]init];
                self.headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LSPremiumVideoDetailHeadView getContentH:item isShowSub:NO]);
                self.headView.delegate = self;
                [self.tableView setTableHeaderView:self.headView];
                [self.headView setHeadViewUI:item];
                [self.tableView reloadData];
                
                if (item.lockStatus == LSLOCKSTATUS_LOCK_REPLY && self.videoKey.length > 0) {
                    [self premiumVideoDetailCellDidDidWatchVideo:self.videoKey];
                }
                
                [self getEmfStatus];
            }else {
                item.title = self.videoTitle;
                item.describe = self.videoSubTitle;
                self.detailItem = item;
                [self.headView removeFromSuperview];
                self.headView = nil;
                self.headView = [[LSPremiumVideoDetailHeadView alloc]init];
                self.headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LSPremiumVideoDetailHeadView getContentH:item isShowSub:NO]);
                self.headView.delegate = self;
                [self.tableView setTableHeaderView:self.headView];
                
                if (errnum == HTTP_LCC_ERR_PREMIUMVIDEO_VIDEO_DELETE_OR_EXIST) {
                    self.headView.noVideoView.hidden = NO;
                }else {
                    self.headView.errorTipView.hidden = NO;
                    [self.headView setVideoTitle:item];
                }
                [self.tableView reloadData];
            }
            
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

//获取女士视频列表
- (void)getLadyVideoList {
    [self.dataArray removeAllObjects];
    LSGetAnchorPremiumVideoListRequest * request = [[LSGetAnchorPremiumVideoListRequest alloc]init];
    request.anchorId = self.womanId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSPremiumVideoinfoItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getLadyVideoList::%@ listCount:%d , errnum:%d ,errmsg:%@ ",BOOL2YES(success),(int)array.count,errnum,errmsg);
            [self getHotVideoList];
            if (success) {
                if (array.count > 0) {
                    NSMutableArray * listArray = [NSMutableArray array];
                    if (array.count > 3) {
                        //添加当前主播视频之后的3个视频
                        BOOL isAdd = NO;
                        for (LSPremiumVideoinfoItemObject * item in array) {
                            if ([item.videoId isEqualToString:self.videoId]) {
                                isAdd = YES;
                                continue;
                            }
                            if (isAdd) {
                                [listArray addObject:item];
                                if (listArray.count == 3) {
                                    break;
                                }
                            }
                        }
                        //不够3个，继续添加前面的视频
                        if (listArray.count < 3) {
                            [listArray addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, 3-listArray.count)]];
                        }
                    }else  {
                        for (LSPremiumVideoinfoItemObject * item in array) {
                            if (![item.videoId isEqualToString:self.videoId]) {
                                [listArray addObject:item];
                            }
                        }
                    }
                    [self.dataArray addObjectsFromArray:listArray];
                    
                    //添加到下一个播放视频列表
                    if (listArray.count > 0) {
                        [self.headView setNextVideoUI:[self.dataArray firstObject]];
                    }
                    [self.tableView reloadData];
                }
            }else {
                
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

//获取推荐视频列表
- (void)getHotVideoList {
    LSRecommendPremiumVideoListRequest * request = [[LSRecommendPremiumVideoListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int num, NSArray<LSPremiumVideoinfoItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"hotVideoList::%@ listCount:%d , errnum:%d ,errmsg:%@ ",BOOL2YES(success),(int)array.count,errnum,errmsg);
            if (success) {
                self.footerData = array;
                if (self.dataArray.count == 0) {
                    [self.headView setNextVideoUI:[array firstObject]];
                }
                [self.footerView removeFromSuperview];
                self.footerView = nil;
                self.footerView = [[LSPremiumInterestView alloc]init];
                [self.footerView setTitleAlignment:NSTextAlignmentLeft];
                self.footerView.delegate = self;
                self.footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 290);
                [self.tableView setTableFooterView:self.footerView];
                self.footerView.itemsArray = self.footerData;
                [self.footerView reloadData];
                
                
            }else {
                
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataArray.count > 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0.1;
    if (section == 1) {
        height = 49;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 49)];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 20, 49)];
        label.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
        label.textColor = COLOR_WITH_16BAND_RGB(0xFF6600);
        label.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"VideoList_Name"),self.ladyName];
        [headerView addSubview:label];

        return headerView;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.detailItem.lockStatus == LSLOCKSTATUS_UNLOCK) {
            return [LSPremiumVideoDetailUnlockCell cellHeight];
        }else {
            return [LSPremiumVideoDetailCell cellHeight:self.detailItem];;
        }
    }
    return 117;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [[UITableViewCell alloc] init];
    if (indexPath.section == 0) {
        if (self.detailItem.lockStatus  == LSLOCKSTATUS_UNLOCK) {
            LSPremiumVideoDetailUnlockCell * cell = [LSPremiumVideoDetailUnlockCell getUITableViewCell:tableView];
            tableViewCell = cell;
            NSString * time = [[LSPrePaidManager manager]getLocalTimeFromTimestamp:self.detailItem.unlockTime timeFormat:@"yyyy-MM-dd"];
            cell.contentLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"unlocked_Tip"),time];
        }else {
            LSPremiumVideoDetailCell * cell = [LSPremiumVideoDetailCell getUITableViewCell:tableView];
            tableViewCell = cell;
            cell.cellDelegate = self;
            [cell loadUI:self.detailItem];
            if (self.videoKey.length > 0) {
                [cell setKeyCode:self.videoKey];
            }
        }
    }else {
        if (self.dataArray.count > 0) {
            LSLadyVideoListCell * cell = [LSLadyVideoListCell getUITableViewCell:tableView];
            tableViewCell = cell;
            cell.cellDelegate = self;
            cell.tag = indexPath.row;
            LSPremiumVideoinfoItemObject * item = self.dataArray[indexPath.row];
            [cell setVideoData:item];
        }
    }
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        LSPremiumVideoinfoItemObject * item = self.dataArray[indexPath.row];
        [self pushNextVideoDetail:item];
    }else {
        if (self.tableView.tx_y != 0 || self.isShowKeyboard) {
            [self.view endEditing:YES];
            // 动画收起键盘
             [UIView animateWithDuration:0.3 animations:^{
                 CGRect viewR = self.tableView.frame;
                 viewR.origin.y = 0;
                 self.tableView.frame = viewR;
             }];
        }
    }
}

#pragma mark - LadyVideoListCellDelegate
- (void)ladyVideoListCellDidFollow:(NSInteger)row {
    LSPremiumVideoinfoItemObject * item = self.dataArray[row];
    
    if (item.isInterested) {
        LSDeleteInterestedPremiumVideoRequest * request = [[LSDeleteInterestedPremiumVideoRequest alloc]init];
        request.videoId = item.videoId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"ladyVideoListCellDidFollow::%@ , errnum:%d ,errmsg:%@ ",BOOL2YES(success),errnum,errmsg);
                item.isInterested = NO;
            });
        };
        [[LSSessionRequestManager manager]sendRequest:request];
    }else {
        LSAddInterestedPremiumVideoRequest * request = [[LSAddInterestedPremiumVideoRequest alloc]init];
        request.videoId = item.videoId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"ladyVideoListCellDidFollow::%@ , errnum:%d ,errmsg:%@ ",BOOL2YES(success),errnum,errmsg);
                item.isInterested = YES;
            });
        };
        [[LSSessionRequestManager manager]sendRequest:request];
    }
}
#pragma mark - HeadVideDelegate
- (void)premiumVideoDetailHeadViewShowSub:(BOOL)isShow {
    self.headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LSPremiumVideoDetailHeadView getContentH:self.detailItem isShowSub:isShow]);
    [self.tableView reloadData];
}

- (void)premiumVideoDetailHeadViewDidFollowBtnDid {
    
    if (self.detailItem.isInterested) {
        LSDeleteInterestedPremiumVideoRequest * request = [[LSDeleteInterestedPremiumVideoRequest alloc]init];
        request.videoId = self.videoId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"premiumVideoDetailHeadViewDidFollowBtnDid:: Delete %@ , errnum:%d ,errmsg:%@ ",BOOL2YES(success),errnum,errmsg);
                self.detailItem.isInterested = NO;
            });
        };
        [[LSSessionRequestManager manager]sendRequest:request];
    }else {
        LSAddInterestedPremiumVideoRequest * request = [[LSAddInterestedPremiumVideoRequest alloc]init];
        request.videoId = self.videoId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"premiumVideoDetailHeadViewDidFollowBtnDid::Add %@ , errnum:%d ,errmsg:%@ ",BOOL2YES(success),errnum,errmsg);
                self.detailItem.isInterested = YES;
            });
        };
        [[LSSessionRequestManager manager]sendRequest:request];
    }
}

- (void)premiumVideoDetailHeadViewDidRetryBtnDid {
    self.loadingView.hidden = NO;
    self.tableView.hidden = YES;
    [self getVideoDetail];
}

- (void)premiumVideoDetailHeadViewDidBackBtnDid {
    
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"LSPremiumVideoViewController")]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
       NSURL *url = [[LiveUrlHandler shareInstance] createPrmiumVideoList];
     [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)premiumVideoDetailHeadViewDidNextVideoBtnDid:(NSString *)videoId {
    if (self.dataArray.count > 0) {
        for (LSPremiumVideoinfoItemObject * item in self.dataArray) {
            if ([item.videoId isEqualToString:videoId]) {
                [self pushNextVideoDetail:item];
                return;
            }
        }
    }else {
        
    }
}

- (void)pushNextVideoDetail:(LSPremiumVideoinfoItemObject *)item {
    LSPremiumVideoDetailViewController * vc = [[LSPremiumVideoDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.videoId = item.videoId;
    vc.womanId = item.anchorId;
    vc.videoTitle = item.title;
    vc.videoSubTitle = item.describe;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - FooterViewDelegate
- (void)didSelectInterestHeadViewItemWithIndex:(NSInteger)row {
    LSPremiumVideoinfoItemObject * item =[self.footerData objectAtIndex:row];
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)didSelectInterestItemWithIndex:(NSInteger)row {
    [self pushNextVideoDetail:[self.footerData objectAtIndex:row]];
}
#pragma mark - LSPremiumVideoDetailCellDelegate
//点击发送解锁码请求
- (void)premiumVideoDetailCellDidSendAccessKeyBtn {
    [self showLoading];
    LSSendPremiumVideoKeyRequest * request = [[LSSendPremiumVideoKeyRequest alloc]init];
    request.videoId = self.videoId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId, NSString *requestId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                [[LSTipsDialogView tipsDialogView]showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"AccessSent_Tip")];
                [self getVideoDetail];
            }else {
                [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

//点击付费解锁视频
- (void)premiumVideoDetailCellDidCreditsWatchVideo {
    
    NSString * tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"unlock_credits"),[LSConfigManager manager].item.premiumVideoCredit];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:tip preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Later") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Continue") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self creditsUnlockVideo];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)creditsUnlockVideo {
    [self showLoading];
    LSUnlockPremiumVideoRequest * request = [[LSUnlockPremiumVideoRequest alloc]init];
    request.type =LSUNLOCKACTIONTYPE_CREDIT;
    request.videoId = self.videoId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId, NSString *videoUrlFull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                [self getVideoDetail];
            }else {
                [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

//点击发送提醒
- (void)premiumVideoDetailCellDidSendReminderBtn {
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSInteger nowTime = [date timeIntervalSince1970];
    NSInteger time = nowTime - self.detailItem.requestLastTime;
    //一天内不给重复发送
    if (time < 86400) {
        NSString * tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SentReminder_Error_Tip"),[NSString stringWithFormat:@"%ld hours",(86400 - time)/60/60]];
        if ((86400 - time)/60/60 <= 2) {
            //2小时内
            tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SentReminder_Error_Tip"),[NSString stringWithFormat:@"%0.f minutes",ceil((86400 - time)/60.f)]];
        }
        [[DialogTip dialogTip]showDialogTip:self.view tipText:tip];
        
    }else {
        [self showLoading];
        LSRemindeSendPremiumVideoKeyRequest * request = [[LSRemindeSendPremiumVideoKeyRequest alloc]init];
        request.requestId = self.detailItem.requestId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *requestId, NSInteger currentTime, int limitSeconds) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideLoading];
                    if (success) {
                        [[LSTipsDialogView tipsDialogView]showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"SentReminder_Tip")];
                        [self getVideoDetail];
                    }else {
                        [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
                    }
                });
        };
        [[LSSessionRequestManager manager]sendRequest:request];
    }
}

#pragma mark - LSMailDetailViewControllerrDelegate
- (void)lsMailDetailViewController:(LSMailDetailViewController *)vc haveReadMailDetailMail:(LSHttpLetterListItemObject *)model index:(int)index
{
    NSLog(@"haveReadMailDetailMail:%@",model);
    //刷新邮件的已读状态
}

-(void)gotoMailDetail
{
    LSMailDetailViewController *vc = [[LSMailDetailViewController alloc] initWithNibName:nil bundle:nil];
    //vc.mailIndex = (int)[self.items indexOfObject:item];
    LSHttpLetterListItemObject *letterItem = [[LSHttpLetterListItemObject alloc] init];
    letterItem.anchorAvatar = self.photoUrl;
    letterItem.anchorId = self.detailItem.anchorId;
    letterItem.anchorNickName = self.ladyName;
    letterItem.onlineStatus = self.isOnline;
    letterItem.letterId = self.detailItem.emfId;
    letterItem.hasKey = YES;
    letterItem.letterSendTime = self.detailItem.requestLastTime;
    vc.letterItem = letterItem;
    vc.mailDetailDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

//点击进入解锁码信件详情
- (void)premiumVideoDetailCellDidDidCheckNowBtn {
    NSLog(@"premiumVideoDetailCellDidDidCheckNowBtn:%@",self.detailItem);
    //主播已回复解锁码，但解锁码邮件未读
    if (!self.emfHasRead) {
        NSString *creditTips = [[NSUserDefaults standardUserDefaults] objectForKey:@"Mail_CreditTips"];
        if (creditTips != nil) {
            [self gotoMailDetail];
        }else {
            NSString *msg = [NSString stringWithFormat:@"%.0f stamp (or %.1f credits) will be deducted from your account to open this mail, do you wish to continue?",[LSConfigManager manager].item.mailTariff.mailReadBase.stampPrice,[LSConfigManager manager].item.mailTariff.mailReadBase.creditPrice];
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self gotoMailDetail];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertVc addAction:cancelAction];
            [alertVc addAction:okAction];
            [self presentViewController:alertVc animated:YES completion:nil];
        }
    }else{
        //邮件已读
        [self gotoMailDetail];
    }
}

//点击解锁视频
- (void)premiumVideoDetailCellDidDidWatchVideo:(NSString *)keyStr {
    [self showLoading];
    LSUnlockPremiumVideoRequest * request = [[LSUnlockPremiumVideoRequest alloc]init];
    request.type =LSUNLOCKACTIONTYPE_KEY;
    request.accessKey = keyStr;
    request.videoId = self.videoId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId, NSString *videoUrlFull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                [self getVideoDetail];
            }else {
                [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

#pragma mark - 键盘监听
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];

    LSPremiumVideoDetailCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect rect= [cell.inputKeyView convertRect: cell.inputKeyView.bounds toView:[UIApplication sharedApplication].keyWindow];
    self.isShowKeyboard = YES;
    CGFloat inputViewBottom = rect.origin.y + rect.size.height;
    if (inputViewBottom > keyboardRect.origin.y) {
        //被挡住了
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewR = self.tableView.frame;
            viewR.origin.y = -(inputViewBottom - keyboardRect.origin.y + 10);
            self.tableView.frame = viewR;
        }];
    }else {
        //没挡住
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // 动画收起键盘
    self.isShowKeyboard = NO;
     [UIView animateWithDuration:0.3 animations:^{
         CGRect viewR = self.tableView.frame;
         viewR.origin.y = 0;
         self.tableView.frame = viewR;
     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tableView.tx_y != 0 || self.isShowKeyboard) {
        [self.view endEditing:YES];
        // 动画收起键盘
         [UIView animateWithDuration:0.3 animations:^{
             CGRect viewR = self.tableView.frame;
             viewR.origin.y = 0;
             self.tableView.frame = viewR;
         }];
    }
}
 
@end
