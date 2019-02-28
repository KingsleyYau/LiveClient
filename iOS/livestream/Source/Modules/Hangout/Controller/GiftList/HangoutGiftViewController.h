//
//  HangoutGiftViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/18.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSCheckButton.h"
#import "LSUserInfoManager.h"
#import "LSGiftManager.h"
#import "LiveRoom.h"

@class HangoutGiftViewController;
@protocol HangoutGiftViewControllerDelegate <NSObject>
// 显示balanceView
- (void)showMyBalanceView:(HangoutGiftViewController *)vc;
// 设置礼物是否私密发送
- (void)selectSecrettyState:(BOOL)state;
// 发送多人互动连击礼物
- (void)sendComboGiftForAnchor:(NSMutableArray *)anchors giftItem:(LSGiftManagerItem *)item clickId:(int)clickId;
// 发送多人互动礼物 (除了连击)
- (void)sendGiftForAnchor:(NSMutableArray *)anchors giftItem:(LSGiftManagerItem *)item clickId:(int)clickId;

@end

@interface HangoutGiftViewController : LSGoogleAnalyticsViewController

@property (strong, nonatomic) LiveRoom *liveRoom;

// 是否私密发送开关
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
// 信用点
@property (weak, nonatomic) IBOutlet UILabel *creditLabel;

@property (weak, nonatomic) id<HangoutGiftViewControllerDelegate> giftDelegate;

@property (nonatomic, strong) NSMutableArray<LSUserInfoModel *> *chatAnchorArray;

- (void)reloadGiftList;

@end
