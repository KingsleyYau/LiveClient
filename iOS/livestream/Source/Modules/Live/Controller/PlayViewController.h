//
//  PlayViewController.h
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSListViewController.h"

#import "GiftPageViewController.h"
#import "LiveViewController.h"

#import "LSGiftManager.h"
#import "LSImManager.h"

#import "LSUITapImageView.h"
#import "CountTimeButton.h"
#import "LiveRoomTextField.h"
#import "LSPageChooseKeyboardView.h"
#import "LiveSendBarView.h"
#import "LiveRoom.h"
#import "CreditView.h"

#import "LiveRoomGiftModel.h"

@class PlayViewController;
@protocol PlayViewControllerDelegate <NSObject>
@optional
- (void)didChangeGiftList:(PlayViewController *)vc;
- (void)onReEnterRoom:(PlayViewController *)vc;
- (void)pushToAddCredit:(PlayViewController *)vc;
- (void)showPubilcHangoutTipView:(PlayViewController *)vc;
@end

@interface PlayViewController : LSListViewController
@property (nonatomic, weak) id<PlayViewControllerDelegate> playDelegate;

#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

// 直播间界面
@property (strong) LiveViewController *liveVC;

// 礼物列表界面管理器
@property (nonatomic, strong) GiftPageViewController *giftVC;

#pragma mark - 文本输入控件

/** 登录管理器 **/
@property (nonatomic, strong) LSLoginManager *loginManager;

/** 喇叭按钮 **/
@property (nonatomic, weak) IBOutlet LSUITapImageView *chatBtn;

/** 礼物按钮 **/
@property (nonatomic, weak) IBOutlet UIButton *giftBtn;

@property (weak, nonatomic) IBOutlet LiveSendBarView *liveSendBarView;

/** 发送栏 **/
@property (nonatomic, weak) IBOutlet UIView *inputMessageView;

// 才艺点播按钮
@property (weak, nonatomic) IBOutlet UIButton *talentBtn;

// 才艺点播按钮宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *talentBtnWidth;

// 才艺点播左边约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *talentBtnTailing;

// 随机礼物背景
@property (weak, nonatomic) IBOutlet UIImageView *randomGiftImageView;

// 随机礼物按钮
@property (weak, nonatomic) IBOutlet UIButton *randomGiftBtn;

// 随机礼物按钮宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *randomGiftBtnBgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *randomGiftBtnWidth;

// 随机礼物左边约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *randomGiftBtnTailing;

/** 发送栏底部约束 **/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewBottom;

/** 输入框高度约束 **/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewHeight;

/** 单击收起输入控件手势 **/
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

/**  选择礼物列表界面 **/
@property (strong, nonatomic) LSPageChooseKeyboardView *giftListKeyboardView;

/**  选择礼物承载界面 **/
@property (weak, nonatomic) IBOutlet UIView *chooseGiftListView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseGiftListViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseGiftListViewWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseGiftListViewTop;

// balanceView
@property (nonatomic, strong) CreditView *creditView;

@property (nonatomic, assign) int msgSuperTabelTop;

#pragma mark - 界面事件

/**
 点击礼物按钮
 
 @param sender <#sender description#>
 */
- (IBAction)giftAction:(id)sender;

/**
 关闭所有输入
 */
- (void)closeAllInputView;

- (void)hiddenBottomView;
- (void)showBottomView;

@end
