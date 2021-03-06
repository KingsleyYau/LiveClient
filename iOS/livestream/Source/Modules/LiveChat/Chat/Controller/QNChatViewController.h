//
//  QNChatViewController.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSGoogleAnalyticsPageViewController.h"
#import "LSChatInputToolView.h"
#import "QNChatTitleView.h"
#import "QNChatTextView.h"

@interface QNChatViewController : LSGoogleAnalyticsViewController
/**
 *  消息列表
 */
@property (weak) IBOutlet LSTableView *tableView;
/**
 *  发送栏
 */
@property (weak) IBOutlet UIView *inputMessageView;
/**
 *  输入框
 */
@property (weak) IBOutlet QNChatTextView *textView;
/**
*  工具界面
*/
@property (weak, nonatomic) IBOutlet LSChatInputToolView *chatInputToolView;
/**
 *  输入框高度约束
 */
@property (weak) IBOutlet NSLayoutConstraint *inputMessageViewHeight;
/**
 *  输入框底部约束
 */
@property (weak) IBOutlet NSLayoutConstraint *inputMessageViewBottom;
/**
 *  头像
 */
@property (strong) UIImageView *personImageView;

/** 女士邀请消息 */
@property (nonatomic, copy) NSString *ladyInviteMsg;
/**
 *  女士信息
 */
@property (strong) NSString *womanId;
@property (strong) NSString *firstName;
@property (strong) NSString *photoURL;


@property (weak) IBOutlet UIImageView *voiceImageView;
 

@end
