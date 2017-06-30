//
//  PlayViewController.h
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"
#import "GetLiveRoomHotListRequest.h"
#import "PresentView.h"

@interface PlayViewController : KKViewController

@property (nonatomic, strong) LiveRoomInfoItemObject* liveInfo;

#pragma mark - 文本输入控件

/**
 *  喇叭按钮
 */
@property (nonatomic, weak) IBOutlet UIButton* btnChat;

/**
 *  喇叭按钮约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* btnChatWidth;

/**
 *  分享按钮
 */
@property (nonatomic, weak) IBOutlet UIButton* btnShare;

/**
 *  分享按钮约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* btnShareWidth;

/**
 *  礼物按钮
 */
@property (nonatomic, weak) IBOutlet UIButton* btnGift;

/**
 *  礼物按钮约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* btnGiftWidth;

/**
 *  发送按钮
 */
@property (nonatomic, weak) IBOutlet UIButton* btnSend;

/**
 *  发送按钮约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* btnSendWidth;

/**
 弹幕按钮
 */
@property (nonatomic, weak) IBOutlet KKCheckButton* btnLouder;

/**
 输入框圆角
 */
@property (nonatomic, weak) IBOutlet UIView* inputBackgroundView;

/**
 输入框背景颜色
 */
@property (nonatomic, weak) IBOutlet UIView* inputBackgroundColorView;

/**
 *  输入框
 */
@property (nonatomic, weak) IBOutlet BLTextField* inputTextField;

/**
 *  发送栏
 */
@property (nonatomic, weak) IBOutlet UIView* inputMessageView;

/**
 *  发送栏底部约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inputMessageViewBottom;

/**
 *  输入框高度约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inputMessageViewHeight;

/**
 *  单击收起输入控件手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

/**
 礼物列表view
 */
@property (weak, nonatomic) IBOutlet PresentView *presentView;

/**
 点击聊天按钮
 
 @param sender <#sender description#>
 */
- (IBAction)chatAction:(id)sender;

/**
 点击分享按钮
 
 @param sender <#sender description#>
 */
- (IBAction)shareAction:(id)sender;

/**
 点击礼物按钮
 
 @param sender <#sender description#>
 */
- (IBAction)giftAction:(id)sender;

/**
 点击发送按钮
 
 @param sender <#sender description#>
 */
- (IBAction)sendAction:(id)sender;

@end
