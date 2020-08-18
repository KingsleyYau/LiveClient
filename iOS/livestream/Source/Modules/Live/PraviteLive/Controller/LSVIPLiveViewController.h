//
//  LSVIPLiveViewController.h
//  livestream
//
//  Created by Calvin on 2019/8/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSListViewController.h"

#import "GPUImageView.h"
#import "LSUITextFieldAlign.h"
#import "TableSuperView.h"
#import "DriveView.h"
#import "BarrageView.h"
#import "BarrageModelCell.h"
#import "GiftComboView.h"
#import "BigGiftAnimationView.h"
#import "LSChatPrepaidView.h"
#import "LSPurchaseCreditsView.h"
#import "LSScheduleListView.h"
#import "LSLivePrepaidTipView.h"
#import "LSPrepaidInfoView.h"
#import "LSPrePaidPickerView.h"

#import "GiftComboManager.h"
#import "LiveStreamPlayer.h"
#import "LSLiveVCManager.h"

@class LSVIPLiveViewController;
@protocol LSVIPLiveViewControllerDelegate <NSObject>
@optional
- (void)onReEnterRoom:(LSVIPLiveViewController *)vc;
- (void)noCreditPushTo:(LSVIPLiveViewController *)vc;
- (void)showHangoutTipView:(LSVIPLiveViewController *)vc;
- (void)closeAllInputView:(LSVIPLiveViewController *)vc;
- (void)pushStoreVC:(LSVIPLiveViewController *)vc;
@end

@interface LSVIPLiveViewController : LSListViewController

// 直播间字体
@property (nonatomic, strong) RoomStyleItem *roomStyleItem;

//直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

//模糊背景
@property (weak, nonatomic) IBOutlet UIView *bgView;

//模糊背景头像
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

//头部
@property (weak, nonatomic) IBOutlet UIView *liveHeadView;

#pragma mark - 弹幕控件
@property (nonatomic, weak) IBOutlet BarrageView *barrageView;

//视频控件
@property (weak, nonatomic) IBOutlet GPUImageView *videoView;

#pragma mark - 互动直播ActivityView
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *preActivityView;
//双向视频
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet GPUImageView *previewVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImageView;
@property (weak, nonatomic) IBOutlet UIButton *camBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camBtnBottom;
@property (weak, nonatomic) IBOutlet UIButton *stopVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *showBtn;
//消息区
@property (weak, nonatomic) IBOutlet TableSuperView *msgSuperView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgSuperViewH;
@property (nonatomic, weak) IBOutlet LSTableView *msgTableView;
// 底部阴影底部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgSuperViewBottom;
// 消息列表顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgTableViewTop;
// 收起消息列表按钮
@property (weak, nonatomic) IBOutlet UIButton *pushDownBtn;
// 鲜花礼品按钮
@property (weak, nonatomic) IBOutlet UIButton *stroeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stroeBtnHeight;
#pragma mark - 未读消息控件
// 未读消息提示view
@property (nonatomic, weak) IBOutlet UIView *msgTipsView;
// 未读消息提示label
@property (nonatomic, weak) IBOutlet UILabel *msgTipsLabel;
// 未读消息数量
@property (assign) NSInteger unReadMsgCount;

// 连击礼物区
@property (weak, nonatomic) IBOutlet UIView *giftView;

// 预付费按钮
@property (weak, nonatomic) IBOutlet UIButton *scheduleBtn;
@property (weak, nonatomic) IBOutlet UIView *scheduleBtnView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scheduleBtnViewBottom;

@property (weak, nonatomic) IBOutlet UILabel *scheduleNumLabel;

@property (weak, nonatomic) IBOutlet UIView *scheduleLessenView;
@property (weak, nonatomic) IBOutlet UILabel *lessenTipLabel;


#pragma mark - 大礼物展现界面
@property (nonatomic, strong) BigGiftAnimationView *giftAnimationView;

#pragma mark - 大礼物播放队列
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

#pragma mark - 坐骑控件
@property (nonatomic, strong) DriveView *driveView;

@property (nonatomic, strong) LSChatPrepaidView *prepaidView;
@property (nonatomic, strong) LSPrepaidInfoView *prepaidInfoView;
@property (nonatomic, strong) LSPrePaidPickerView *pickerView;
@property (nonatomic, strong) LSPurchaseCreditsView *purchaseCreditView;
@property (nonatomic, strong) LSScheduleListView *scheduleListView;
@property (nonatomic, strong) LSLivePrepaidTipView *prepaidTipView;
// 隐藏预付费列表提示按钮
@property (nonatomic, strong) UIButton *prepaidTipViewBgBtn;
#pragma mark - 代理
@property (nonatomic, weak) id<LSVIPLiveViewControllerDelegate> liveDelegate;

@property (nonatomic, assign) BOOL isWantLeave;

// 聊天顶部间隔
@property (nonatomic, assign) NSInteger topInterval;
// 聊天列表是否收起
@property (nonatomic, assign) BOOL isMsgPushDown;

#pragma mark - 流播放推送事件
- (void)play;
- (void)stopPlay;
- (void)initPublish;
- (void)publish;
- (void)stopPublish;

#pragma mark - 逻辑事件
/**
 发送消息/弹幕
 @param text 文本内容
 @return 成功失败
 */
- (BOOL)sendMsg:(NSString *)text isLounder:(BOOL)isLounder;

/**
 置顶子View
 @param view 视图
 */
- (void)bringSubviewToFrontFromView:(UIView *)view;

// 关闭/开启直播间声音(LiveChat使用)
- (void)openOrCloseSuond:(BOOL)isClose;

//显示信用点不足界面
- (void)showAddCreditsView:(NSString *)tip;

// 聊天列表滚到底部
- (void)chatListScrollToEnd;

- (void)scrollToEnd:(BOOL)animated;

//关闭双向视频
- (void)stopCamVideo;
@end


