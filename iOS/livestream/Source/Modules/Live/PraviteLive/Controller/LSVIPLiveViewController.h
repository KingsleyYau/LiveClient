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
#import "BarrageModel.h"
#import "BarrageModelCell.h"

#import "GiftComboView.h"

#import "GiftComboManager.h"
#import "LiveStreamPlayer.h"
#import "LSImManager.h"
#import "LSLoginManager.h"
#import "PublicLiveMsgManager.h"

#import "MsgItem.h"
#import "LiveRoom.h"

#import "BigGiftAnimationView.h"
#import "RoomStyleItem.h"


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

// 流播放组件
@property (nonatomic, strong) LiveStreamPlayer *player;

// 直播间字体
@property (nonatomic, strong) RoomStyleItem *roomStyleItem;

//直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

//IM管理器
@property (nonatomic, strong) LSImManager *imManager;

//登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;

//模糊背景
@property (weak, nonatomic) IBOutlet UIView *bgView;

//模糊背景头像
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

//头部
@property (weak, nonatomic) IBOutlet UIView *liveHeadView;

//视频控件
@property (weak, nonatomic) IBOutlet GPUImageView *videoView;

#pragma mark - 互动直播ActivityView
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *preActivityView;
//双向视频
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet GPUImageView *previewVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImageView;
@property (weak, nonatomic) IBOutlet UIButton *camBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camBtnBottom;
@property (weak, nonatomic) IBOutlet UIButton *stopVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *showBtn;
//消息区
@property (weak, nonatomic) IBOutlet TableSuperView *msgSuperView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgSuperViewH;
@property (nonatomic, weak) IBOutlet UITableView *msgTableView;
// 底部阴影底部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgSuperViewBottom;
// 消息列表顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgTableViewTop;
// 收起消息列表按钮
@property (weak, nonatomic) IBOutlet UIButton *pushDownBtn;
// 鲜花礼品按钮
@property (weak, nonatomic) IBOutlet UIButton *stroeBtn;
#pragma mark - 未读消息控件
// 未读消息提示view
@property (nonatomic, weak) IBOutlet UIView *msgTipsView;
// 未读消息提示label
@property (nonatomic, weak) IBOutlet UILabel *msgTipsLabel;
// 未读消息数量
@property (assign) NSInteger unReadMsgCount;

//连击礼物区
@property (weak, nonatomic) IBOutlet UIView *giftView;

#pragma mark - 大礼物展现界面
@property (nonatomic, strong) BigGiftAnimationView *giftAnimationView;

#pragma mark - 大礼物播放队列
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

#pragma mark - 坐骑控件
@property (nonatomic, strong) DriveView *driveView;

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
 增加本地提示
 
 @param text 文本内容
 */
- (void)addTips:(NSAttributedString *)text;

/**
 增加连击
 
 @param giftItem 礼物object
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
 
 @param view 视图
 */
- (void)bringSubviewToFrontFromView:(UIView *)view;

///**
// 显示预览界面
// */
//- (void)showPreview;

/**
 邀请当前直播间主播Hangout
 
 @param recommendId 推荐ID
 @param anchorId 主播ID
 @param anchorName 主播昵称
 */
- (void)inviteAnchorWithHangout:(NSString *)recommendId anchorId:(NSString *)anchorId anchorName:(NSString *)anchorName;

// 关闭/开启直播间声音(LiveChat使用)
- (void)openOrCloseSuond:(BOOL)isClose;

//显示信用点不足界面
- (void)showAddCreditsView:(NSString *)tip;

// 聊天列表滚到底部
- (void)chatListScrollToEnd;

- (void)scrollToEnd:(BOOL)animated;

@end


