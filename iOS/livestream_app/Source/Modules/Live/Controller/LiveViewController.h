//
//  LiveViewController.h
//  livestream
//
//  Created by Max on 2017/5/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

#import "LSChatTextView.h"
#import "GPUImageView.h"
#import "LSUITextFieldAlign.h"
#import "TableSuperView.h"
#import "DriveView.h"

#import "BarrageView.h"
#import "BarrageModel.h"
#import "BarrageModelCell.h"

#import "GiftComboView.h"
#import "GiftComboManager.h"

#import "LSImManager.h"
#import "LSLoginManager.h"
#import "MsgItem.h"
#import "LiveRoom.h"

#import "BigGiftAnimationView.h"
#import "LiveRoomMsgManager.h"
#import "RoomStyleItem.h"

#define PlaceholderFontSize DESGIN_TRANSFORM_3X(14)
#define PlaceholderFont [UIFont boldSystemFontOfSize:PlaceholderFontSize]

#define MaxInputCount 70

@class LiveViewController;
@protocol LiveViewControllerDelegate <NSObject>
@optional
- (void)onReEnterRoom:(LiveViewController *)vc;
- (void)bringRewardViewInTop:(LiveViewController *)vc;
- (void)noCreditPushTo:(LiveViewController *)vc;
- (void)liveViewIsPlay:(LiveViewController *)vc;
@end

@interface LiveViewController : LSGoogleAnalyticsViewController
#pragma mark - 调试信息
@property (nonatomic, weak) IBOutlet UILabel *debugLabel;

#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

#pragma mark - IM管理器
@property (nonatomic, strong) LSImManager *imManager;

#pragma mark - 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;

#pragma mark - 连击控件
@property (nonatomic, weak) IBOutlet UIView *giftView;

#pragma mark - 弹幕控件
@property (nonatomic, weak) IBOutlet BarrageView *barrageView;

#pragma mark - 消息列表控件
// 聊天框底部阴影
@property (weak, nonatomic) IBOutlet TableSuperView *tableSuperView;
// 聊天框
@property (nonatomic, weak) IBOutlet UITableView *msgTableView;
// 底部阴影底部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgSuperViewBottom;
// 底部阴影顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgSuperViewTop;
// 底部界面
@property (weak, nonatomic) IBOutlet UIView *liveBottomView;
// 直播间字体
@property (nonatomic, strong) RoomStyleItem *roomStyleItem;
// 直播间底部界面背景图
@property (weak, nonatomic) IBOutlet UIImageView *liveBottomGroundView;

#pragma mark - 未读消息控件
// 未读消息提示view
@property (nonatomic, weak) IBOutlet UIView *msgTipsView;
// 未读消息提示label
@property (nonatomic, weak) IBOutlet UILabel *msgTipsLabel;
// 未读消息数量
@property (assign) NSInteger unReadMsgCount;

#pragma mark - 邀请私密直播按钮
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;

@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

#pragma mark - 视频控件
@property (weak, nonatomic) IBOutlet UIImageView *videoBgImageView;
@property (nonatomic, weak) IBOutlet GPUImageView *videoView;

#pragma mark - 预览视频控件
/**
 预览视频宽度约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewVideoViewWidth;
@property (weak, nonatomic) IBOutlet GPUImageView *previewVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIButton *showBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *startVideoBtn;
@property (weak, nonatomic) IBOutlet UIImageView *startVideoImageView;

#pragma mark - 大礼物展现界面
@property (nonatomic, strong) BigGiftAnimationView *giftAnimationView;

#pragma mark - 大礼物播放队列
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

#pragma mark - 坐骑控件
@property (nonatomic, strong) DriveView *driveView;

#pragma mark - 代理
@property (nonatomic, weak) id<LiveViewControllerDelegate> liveDelegate;

#pragma mark - 返点按钮
@property (weak, nonatomic) IBOutlet UIView *rewardedBgView;
@property (weak, nonatomic) IBOutlet UIButton *rewardedBtn;

#pragma mark - 互动直播ActivityView
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *preActivityView;


@property (nonatomic, assign) BOOL isWantLeave;

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
 增加本地提示

 @param text 文本内容
 */
- (void)addTips:(NSAttributedString *)text;

/**
 增加连击

 @param giftItem <#giftItem description#>
 */
- (void)addCombo:(GiftItem *)giftItem;

/**
 显示大礼物
 
 @param giftID 大礼物ID
 */
- (void)starBigAnimationWithGiftID:(NSString *)giftID;

/**
 插入直播间关注消息
 */
//- (void)addAudienceFollowLiverMessage:(NSString *)nickName;

/**
 置顶子View

 @param view <#view description#>
 */
- (void)bringSubviewToFrontFromView:(UIView *)view;

/**
 坐骑出现动画
 */
- (void)userHaveJoinToRoom;

/**
 显示预览界面
 */
- (void)showPreview;

@end
