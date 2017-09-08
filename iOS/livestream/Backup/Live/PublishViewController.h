//
//  PublishViewController.h
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

@interface PublishViewController : KKViewController
#pragma mark - 直播间信息
@property (nonatomic, strong) NSString* roomId;

#pragma mark - 推流地址

/**
 推流地址
 */
@property (nonatomic, strong) NSString* url;

#pragma mark - 文本输入控件

/**
 *  聊天按钮
 */
@property (nonatomic, weak) IBOutlet UIButton* btnChat;

/**
 *  发送按钮约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* btnChatWidth;

/**
 *  分享按钮
 */
@property (nonatomic, weak) IBOutlet UIButton* btnShare;

/**
 *  发送按钮约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* btnShareWidth;

/**
 *  控制按钮
 */
@property (nonatomic, weak) IBOutlet KKCheckButton* btnConfig;

/**
 *  控制按钮约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* btnConfigWidth;

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
 点击聊天按钮
 
 @param sender <#sender description#>
 */
- (IBAction)chatAction:(id)sender;

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
