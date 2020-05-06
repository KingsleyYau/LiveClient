//
//  LSMyContactsViewController.m
//  livestream
//
//  Created by Calvin on 2019/6/19.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMyContactsViewController.h"
#import "GetContactListRequest.h"
#import "LSMycontactTableView.h"
#import "BookPrivateBroadcastViewController.h"
#import "LSSendMailViewController.h"
#import "QNChatViewController.h"
#import "LiveUrlHandler.h"
#import "AnchorPersonalViewController.h"
#import "LSShadowView.h"
#import "QNRiskControlManager.h"
#import "LiveModule.h"
@interface LSMyContactsViewController ()<UIScrollViewRefreshDelegate,LSMycontactTableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet LSMycontactTableView *tableView;
@end

@implementation LSMyContactsViewController

- (void)dealloc {
    [self.tableView unSetupPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"My Contacts";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.viewDidAppearEver) {
        [self.tableView startLSPullDown:YES];
        
        if (screenSize.width == 320) {
            self.noDataViewTop.constant = 60;
        }
    }
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)setupContainView {
    [super setupContainView];
    [self.tableView setupPullRefresh:self pullDown:YES pullUp:NO];
    self.tableView.tableViewDelegate = self;
    
    self.searchBtn.layer.cornerRadius = 5;
    self.searchBtn.layer.masksToBounds = YES;
    
    LSShadowView * shadowView = [[LSShadowView alloc]init];
    [shadowView showShadowAddView:self.searchBtn];
}

- (IBAction)searchBtnDid:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getContactListData {
    GetContactListRequest * request = [[GetContactListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSRecommendAnchorItemObject *> *array, int totalCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSMyContactsViewController::getContactListData %@,%ld", BOOL2SUCCESS(success), (long)array.count);
            self.view.userInteractionEnabled = YES;
            if (success) {
                if (array.count > 0) {
                    self.noMyContactsDataView.hidden = YES;
                    self.tableView.items = array;
                    [self.tableView reloadData];
                }
                else {
                    self.noMyContactsDataView.hidden = NO;
                }
            }
            else {
                self.tableView.hidden = YES;
                self.noMyContactsDataView.hidden = YES;
                self.failView.hidden = NO;
            }
            [self.tableView finishLSPullDown:YES];
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

- (void)lsListViewControllerDidClick:(UIButton *)sender {
    self.tableView.hidden = NO;
    self.failView.hidden = YES;
    [self.tableView startLSPullDown:YES];
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getContactListData];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

#pragma mark - MyContactsTableViewDelegate
- (void)mycontactTableViewDidSelectItem:(LSRecommendAnchorItemObject *)item {
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)mycontactTableViewDidClickInviteBtn:(LSRecommendAnchorItemObject *)item {
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorName:item.anchorNickName anchorId:item.anchorId roomType:LiveRoomType_Private];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)mycontactTableViewDidClickChatBtn:(LSRecommendAnchorItemObject *)item {
    if (![[QNRiskControlManager manager]isRiskControlType:RiskType_livechat withController:self]) {
        QNChatViewController *vc = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
        vc.womanId = item.anchorId;
        vc.photoURL = item.anchorAvatar;
        vc.firstName = item.anchorNickName;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)mycontactTableViewDidClickMailBtn:(LSRecommendAnchorItemObject *)item {
    LSSendMailViewController * vc = [[LSSendMailViewController alloc]initWithNibName:nil bundle:nil];
    vc.anchorId = item.anchorId;
    vc.anchorName = item.anchorNickName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)mycontactTableViewDidClickBookBtn:(LSRecommendAnchorItemObject *)item {
    BookPrivateBroadcastViewController *vc = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    vc.userId = item.anchorId;
    vc.userName = item.anchorNickName;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
