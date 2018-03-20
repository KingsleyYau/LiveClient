//
//  PreStartPublicViewController.m
//  livestream_anchor
//
//  Created by test on 2018/3/1.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreStartPublicViewController.h"
#import "PreStartNowTableViewCell.h"
#import "PreStartPublicAutoInviteTableViewCell.h"
#import "PreStartPublicHeaderView.h"
#import "ZBLSImManager.h"
#import "PublicVipViewController.h"
#import "LiveStreamPublisher.h"
#import "LiveStreamPlayer.h"


@interface PreStartPublicViewController ()<PreStartPublicAutoInviteTableViewCellDelegate,PreStartNowTableViewCellDelegate,PreStartPublicHeaderViewDelegate>

@property (nonatomic, strong) ZBLSImManager *imManager;
@property (nonatomic, strong) ZBLSRequestManager *requestManager;
@property (nonatomic, strong)   PreStartPublicHeaderView *headerView;

@end

@implementation PreStartPublicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupTableFooterView];
    [self setupTableHeaderView];
    self.requestManager = [ZBLSRequestManager manager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableHeaderView {
    PreStartPublicHeaderView *headerView = [PreStartPublicHeaderView headerView];
    headerView.delegate = self;
    self.headerView = headerView;
    [self.tableView setTableHeaderView:self.headerView];
}

- (void)setupTableFooterView {

    UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(15, 0, screenSize.width - 15, 100)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0, vc.frame.size.width , vc.frame.size.height)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:13];
    label.text = @"Pornography and violent content is strictly prohibited. Before starting your live broadcast please read  the Broadcaster Code of Conduct and all other policies of our platform. Please be aware of that violating our policies will lead to the termination of your account. ";
    [vc addSubview:label];
    self.tableView.backgroundColor =  COLOR_WITH_16BAND_RGB(0xEDECF1);;

    [self.tableView setTableFooterView:vc];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.headerView stopPreViewVideoPlay];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.headerView startPreViewVideoPlay];
}


//- (void)clickToClose:(UIButton *)sender {
//
//}
- (void)preStartPublicHeaderViewCloseAction:(PreStartPublicHeaderView *)headView {
        [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark TableViewDeletage
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.row == 0) {
        height = [PreStartPublicAutoInviteTableViewCell cellHeight];
    } else {
        height = [PreStartNowTableViewCell cellHeight];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    if (indexPath.row == 0) {
        PreStartPublicAutoInviteTableViewCell *cell = [PreStartPublicAutoInviteTableViewCell getUITableViewCell:tableView];
        cell.startPublicAutoInviteDelegate = self;
        result = cell;
    } else {
        PreStartNowTableViewCell *cell = [PreStartNowTableViewCell getUITableViewCell:tableView];
        cell.startNowDelegate = self;
        result = cell;
    }
    return  result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)preStartNowTableViewCell:(PreStartNowTableViewCell *)cell didStartBroadcast:(UIButton *)sender {
    [self showLoading];
    [[ZBLSImManager manager] enterPublicRoom:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString * _Nonnull errMsg, ZBImLiveRoomObject * _Nonnull roomItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                PublicVipViewController *vc = [[PublicVipViewController alloc] initWithNibName:nil bundle:nil];
                LiveRoom *room = [[LiveRoom alloc] init];
                room.userId = roomItem.anchorId;
                room.roomId = roomItem.roomId;
                room.roomType = [[ZBLSImManager manager] roomTypeToLiveRoomType:roomItem.roomType];
                room.playUrlArray = roomItem.pullUrl;
                room.publishUrlArray = roomItem.pushUrl;
                room.leftSeconds = roomItem.leftSeconds;
                room.maxFansiNum = roomItem.maxFansiNum;
                vc.liveRoom = room;
                [self.navigationController pushViewController:vc animated:YES];
            }
        });
    }];
}

- (void)preStartPublicAutoInviteTableViewCell:(PreStartPublicAutoInviteTableViewCell *)cell didOpenAutoInvitation:(UISwitch *)sender {
    if (sender.isOn) {
        NSLog(@"%d on ",sender.isOn);
        [self setAutoInvite:ZBSETPUSHTYPE_START];
    }else {
        NSLog(@"%d off",sender.isOn);
        [self setAutoInvite:ZBSETPUSHTYPE_CLOSE];
    }
}


- (void)setAutoInvite:(ZBSetPushType)isOpen {
    [self.requestManager anchorSetAutoPush:isOpen finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSLog(@"PreStartPublicViewController anchorSetAutoPush : success  %d",success);
            }
        });
    }];
}
@end
