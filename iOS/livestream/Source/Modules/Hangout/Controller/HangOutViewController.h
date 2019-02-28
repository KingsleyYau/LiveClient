//
//  HangOutViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"

#import "LiveRoom.h"
#import "RoomStyleItem.h"

#import "HangoutSendBarView.h"
#import "TableSuperView.h"

@interface HangOutViewController : LSGoogleAnalyticsViewController

// 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;
// 外部跳转邀请主播ID 昵称
@property (nonatomic, copy) NSString *inviteAnchorId;
@property (nonatomic, copy) NSString *inviteAnchorName;

// 窗口底部界面
@property (weak, nonatomic) IBOutlet UIView *videoBottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoBottomViewTop;


// 关闭放大窗口
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;

// 打开控制台按钮
@property (weak, nonatomic) IBOutlet UIButton *openControlBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openControlBtnBottom;


#pragma mark - @聊天观众昵称控件
/** @聊天观众昵称控件 **/
@property (weak, nonatomic) IBOutlet UIView *chatAudienceView;
@property (weak, nonatomic) IBOutlet UILabel *audienceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet LSCheckButton *selectBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatAudienceViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatAudienceViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audienceNameLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowImageViewWidth;

#pragma mark - 消息列表控件
// 聊天框底部阴影
@property (weak, nonatomic) IBOutlet TableSuperView *tableSuperView;
// 聊天框
@property (nonatomic, weak) IBOutlet UITableView *msgTableView;
// 底部阴影顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgSuperViewTop;
// 直播间字体
@property (nonatomic, strong) RoomStyleItem *roomStyleItem;

#pragma mark - 未读消息控件
// 未读消息提示view
@property (nonatomic, weak) IBOutlet UIView *msgTipsView;
// 未读消息提示label
@property (nonatomic, weak) IBOutlet UILabel *msgTipsLabel;
// 未读消息数量
@property (assign) NSInteger unReadMsgCount;

#pragma mark - 输入框控件
// 发送栏
@property (nonatomic, weak) IBOutlet UIView *inputMessageView;
// 聊天框背景
@property (weak, nonatomic) IBOutlet UIView *chatBackgroundView;
// 输入栏
@property (weak, nonatomic) IBOutlet HangoutSendBarView *hangoutSendBarView;
// 聊天按钮
@property (nonatomic, weak) IBOutlet UIButton * chatBtn;
// 礼物按钮
@property (nonatomic, weak) IBOutlet UIButton *giftBtn;
// 发送栏底部约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewBottom;
// 输入框高度约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewHeight;

// 主播/礼物队列 添加对象
- (void)anchorArrayAddObject:(IMLivingAnchorItemObject *)obj;
- (void)roomGiftListAddObject:(IMRecvGiftItemObject *)obj;

// 更新子视图界面显示
- (void)upDateChildView:(NSString *)anchorId;

@end
