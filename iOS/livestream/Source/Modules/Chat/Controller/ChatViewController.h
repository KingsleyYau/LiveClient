//
//  ChatViewController.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "GoogleAnalyticsViewController.h"

#import "ChatTitleView.h"
#import "ChatTextView.h"

@interface ChatViewController : GoogleAnalyticsViewController

/**
 *  消息列表
 */
@property (nonatomic, weak) IBOutlet UITableView* tableView;

/**
 *  发送栏
 */
@property (nonatomic, weak) IBOutlet UIView* inputMessageView;

/**
 *  输入框
 */
@property (nonatomic, weak) IBOutlet ChatTextView* textView;

/**
 *  输入框高度约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inputMessageViewHeight;

/**
 *  输入框底部约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inputMessageViewBottom;

/**
 *  头像
 */
@property (nonatomic, strong) UIImageView *personImageView;

/**
 *  女士信息
 */
@property (nonatomic, strong) NSString *womanId;
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *photoURL;

@property (weak, nonatomic) IBOutlet KKCheckButton *emotionBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;


@property (weak, nonatomic) IBOutlet UIView *tipChargeView;
@property (weak, nonatomic) IBOutlet UIButton *closeTipBtn;

@end
