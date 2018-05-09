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
#import "LSAnchorImManager.h"
#import "PublicVipViewController.h"
#import "LiveStreamPublisher.h"
#import "LiveStreamPlayer.h"
#import "DialogTip.h"
#import "PreLiveViewController.h"

typedef enum : NSUInteger {
    LiveShowTypePublic,
    LiveShowTypeShow
}LiveShowType;



@interface PreStartPublicViewController ()<PreStartPublicAutoInviteTableViewCellDelegate,PreStartNowTableViewCellDelegate,PreStartPublicHeaderViewDelegate>

@property (nonatomic, strong) LSAnchorImManager *imManager;
@property (nonatomic, strong) LSAnchorRequestManager *requestManager;
@property (nonatomic, strong) PreStartPublicHeaderView *headerView;

@end

@implementation PreStartPublicViewController

- (void)dealloc {
    NSLog(@"PreStartPublicViewController::( [dealloc] )");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableHeaderView];
    [self setupTableFooterView];
    self.requestManager = [LSAnchorRequestManager manager];
}

- (void)setupTableHeaderView {
    UIView *view = [[UIView alloc] init];
    [view setFrame:CGRectMake(0, 0, screenSize.width, screenSize.width)];
    PreStartPublicHeaderView *headerView = [PreStartPublicHeaderView headerView];
    headerView.delegate = self;
    self.headerView = headerView;
    [self.headerView setFrame:CGRectMake(0, 0, screenSize.width, screenSize.width)];
    [view addSubview:self.headerView];
    [self.tableView setTableHeaderView:view];
}

- (void)setupTableFooterView {
    
    UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(15, 0, screenSize.width - 15, 100)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0, vc.frame.size.width , vc.frame.size.height)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor =COLOR_WITH_16BAND_RGB(0x666666);
    label.text = NSLocalizedStringFromSelf(@"START_BROADCAST_TIP");
    [vc addSubview:label];
    
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
        if (cell.autoInviteSwitch.isOn) {
            [self setAutoInvite:ZBSETPUSHTYPE_START];
        }else {
            [self setAutoInvite:ZBSETPUSHTYPE_CLOSE];
        }
        result = cell;
    } else {
        PreStartNowTableViewCell *cell = [PreStartNowTableViewCell getUITableViewCell:tableView];
        cell.startNowDelegate = self;
        result = cell;
    }
    result.selectionStyle = UITableViewCellSelectionStyleNone;
    return  result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)preStartNowTableViewCell:(PreStartNowTableViewCell *)cell didStartBroadcast:(UIButton *)sender {
    [[LSAnchorRequestManager manager] anchorCheckPublicRoomType:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, AnchorPublicRoomType liveShowType,  NSString * _Nonnull liveShowId){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"PreStartPublicViewController::anchorCheckPublicRoomType( [检测房间类型] success : %@)",(success == YES) ? @"成功" : @"失败");
            sender.userInteractionEnabled = YES;
            if (success) {
                //  房间类型
                switch (liveShowType) {
                    case ANCHORPUBLICROOMTYPE_OPEN:{
                        // 进入公开直播间
                        [self enterPublicRoom:sender];
                    }break;
                    case ANCHORPUBLICROOMTYPE_PROGRAM: {
                        // 进入节目直播间
                        PreLiveViewController *preLive = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
                        preLive.liveShowId = liveShowId;
                        preLive.status = PreLiveStatus_Show;
                        [self navgationControllerPresent:preLive];
                    }break;
                    default:
                        break;
                }
                
            }else {
                sender.userInteractionEnabled = YES;
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
        });
    }];
}


- (void)enterPublicRoom:(UIButton *)sender {
    [self.headerView showVideoLoadView];
    BOOL bFlag = [[LSAnchorImManager manager] enterPublicRoom:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString * _Nonnull errMsg, ZBImLiveRoomObject * _Nonnull roomItem) {
        NSLog(@"PreStartPublicViewController::enterPublicRoom( [主播发送进入公开直播间] success : %@, errType : %d, errMsg : %@, roomId : %@ )",(success == YES) ? @"成功" : @"失败", errType, errMsg, roomItem.roomId);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.headerView hiddenVideoLoadView];
            sender.userInteractionEnabled = YES;
            if (success) {
                PublicVipViewController *vc = [[PublicVipViewController alloc] initWithNibName:nil bundle:nil];
                LiveRoom *room = [[LiveRoom alloc] init];
                room.userId = roomItem.anchorId;
                room.roomId = roomItem.roomId;
                room.roomType = [[LSAnchorImManager manager] roomTypeToLiveRoomType:roomItem.roomType];
                room.playUrlArray = roomItem.pullUrl;
                room.publishUrlArray = roomItem.pushUrl;
                room.leftSeconds = roomItem.leftSeconds;
                room.maxFansiNum = roomItem.maxFansiNum;
                room.imLiveRoom = roomItem;
                vc.liveRoom = room;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errMsg];
            }
        });
    }];
    
    if (!bFlag) {
        [self.headerView hiddenVideoLoadView];
        [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"CONNECTING_SERVER_FAIL")];
        sender.userInteractionEnabled = YES;
    }
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

- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
    nvc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    nvc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    nvc.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil];
    [nvc.navigationBar setTitleTextAttributes:attributes];
    [nvc.navigationItem setHidesBackButton:YES];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}
@end
