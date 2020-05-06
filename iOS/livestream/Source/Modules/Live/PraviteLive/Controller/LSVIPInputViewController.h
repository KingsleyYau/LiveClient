//
//  LSVIPInputViewController.h
//  livestream
//
//  Created by Calvin on 2019/8/29.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSListViewController.h"
#import "LSVIPGiftPageViewController.h"
#import "LSVIPLiveViewController.h"

#import "LSLiveTextView.h"
#import "LSPhizPageView.h"
#import "LSTopGiftView.h"
#import "LSCheckButton.h"

#import "LSGiftManager.h"
#import "LSImManager.h"

#import "LiveRoom.h"
#import "LiveRoomGiftModel.h"
#import "RoomStyleItem.h"

@class LSVIPInputViewController;
@protocol InputViewControllerDelegate <NSObject>
@optional
- (void)onReEnterRoom:(LSVIPInputViewController *)vc;
- (void)pushToAddCredit:(LSVIPInputViewController *)vc;
- (void)showPubilcHangoutTipView:(LSVIPInputViewController *)vc;
- (void)didShowGiftListInfo:(LSVIPInputViewController *)vc;
- (void)didRemoveGiftListInfo:(LSVIPInputViewController *)vc;
- (void)pushStoreVC:(LSVIPInputViewController *)vc;
@end

@interface LSVIPInputViewController : LSListViewController

@property (nonatomic, weak) id<InputViewControllerDelegate> playDelegate;

#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

// 直播间字体
@property (nonatomic, strong) RoomStyleItem *roomStyleItem;

// 直播间界面
@property (nonatomic, strong) LSVIPLiveViewController *liveVC;

// 礼物列表界面管理器
@property (nonatomic, strong) LSVIPGiftPageViewController *giftVC;

#pragma mark - 文本输入控件

/** 登录管理器 **/
@property (nonatomic, strong) LSLoginManager *loginManager;

/** 发送按钮 **/
@property (nonatomic, weak) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendBtnWidth;

@property (weak, nonatomic) IBOutlet UIImageView *inviteFreeImage;

@property (weak, nonatomic) IBOutlet LSHighlightedButton *inviteBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteBtnWidth;

@property (nonatomic, weak) IBOutlet UIView * inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewRight;

/** 发送栏 **/
@property (nonatomic, weak) IBOutlet UIView *inputMessageView;

@property (weak, nonatomic) IBOutlet LSLiveTextView *inputTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputTextViewRight;

@property (weak, nonatomic) IBOutlet LSCheckButton *popBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popBtnWidth;

@property (weak, nonatomic) IBOutlet LSCheckButton *emotionBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emotionBtnWidth;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *bottomMsgLabel;

/** 发送栏底部约束 **/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewBottom;


/** 单击收起输入控件手势 **/
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (weak, nonatomic) IBOutlet UIButton *topGiftViewBtn;

/**  选择礼物承载界面 **/
@property (weak, nonatomic) IBOutlet UIView *chooseGiftListView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseGiftListViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseGiftListViewTop;
@property (weak, nonatomic) IBOutlet UIView *chooseTopGiftView;

@property (weak, nonatomic) IBOutlet LSTopGiftView *topGiftView;

@property (nonatomic, assign) int msgSuperTabelTop;

#pragma mark - 界面事件


/**
 关闭所有输入
 */
- (void)closeAllInputView;

- (void)hiddenBottomView;
- (void)showBottomView;

@end
