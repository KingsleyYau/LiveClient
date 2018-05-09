//
//  PlayViewController.h
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSUITapImageView.h"
#import "LiveRoomTextField.h"
#import "LSPageChooseKeyboardView.h"
#import "BackpackPresentView.h"
#import "LiveSendBarView.h"
#import "YMAudienceView.h"
#import "LiveViewController.h"
#import "LiveGiftDownloadManager.h"
#import "LiveRoom.h"
#import "ManDetailView.h"
#import "LSCheckButton.h"

@class PlayViewController;
@protocol PlayViewControllerDelegate <NSObject>
@optional
- (void)onReEnterRoom:(PlayViewController *)vc;
- (void)onCloseLiveRoom:(PlayViewController *)vc;
- (void)sendInviteToAudience:(PlayViewController *)vc;
@end

@interface PlayViewController : LSGoogleAnalyticsViewController

@property (nonatomic, weak) id<PlayViewControllerDelegate> playDelegate;

#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

/** 显示界面 **/
@property (strong) LiveViewController *liveVC;

#pragma mark - 文本输入控件

/** 登录管理器 **/
@property (nonatomic, strong) LSLoginManager *loginManager;

/** @聊天观众昵称控件 **/
@property (weak, nonatomic) IBOutlet UIView *chatAudienceView;
@property (weak, nonatomic) IBOutlet UILabel *audienceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet LSCheckButton *selectBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatAudienceViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatAudienceViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audienceNameLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowImageViewWidth;


/** 聊天按钮 **/
@property (nonatomic, weak) IBOutlet UIButton * chatBtn;

/** 礼物按钮 **/
@property (nonatomic, weak) IBOutlet UIButton *giftBtn;

@property (weak, nonatomic) IBOutlet LiveSendBarView *liveSendBarView;

/** 发送栏 **/
@property (nonatomic, weak) IBOutlet UIView *inputMessageView;

// 礼物左边约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftBtnTailing;

/** 发送栏底部约束 **/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewBottom;

/** 输入框高度约束 **/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewHeight;

/** 单击收起输入控件手势 **/
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

/**  背包礼物界面 **/
@property (strong, nonatomic) BackpackPresentView *backpackView;

/**  选择礼物承载界面 **/
@property (weak, nonatomic) IBOutlet UIView *chooseGiftListView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseGiftListViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseGiftListViewWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseGiftListViewTop;

/**
 男士资料控件
 */
@property (nonatomic, strong) ManDetailView *manDetailView;

// 当前选中礼物下标
@property (nonatomic, assign) NSInteger presentRow;

/**
 关闭所有输入
 */
- (void)closeAllInputView;

- (void)hiddenBottomView;
- (void)showBottomView;

- (void)hiddenchatAudienceView;

@end
