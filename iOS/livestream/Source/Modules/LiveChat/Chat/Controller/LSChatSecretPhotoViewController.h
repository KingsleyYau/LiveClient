//
//  ChatSecretPhotoViewController.h
//  dating
//
//  Created by test on 16/7/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatMsgItemObject.h"
#import "LSLoginManager.h"
#import "LSGoogleAnalyticsViewController.h"
#import <AFNetworkReachabilityManager.h>

@protocol LSChatSecretPhotoViewControllerDelegate <NSObject>

@optional
- (void)photoDetailspushAddCreditsViewController;

@end

@interface LSChatSecretPhotoViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UIImageView *secretImageView;

@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *ladyName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ladyNameH;
@property (weak, nonatomic) IBOutlet UIImageView *lockIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameH;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) id <LSChatSecretPhotoViewControllerDelegate> viewDelegate;
/**
 *  购买提示
 */
@property (weak, nonatomic) IBOutlet UILabel *creditTip;
/**
 *  购买按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
/**
 *  下载提示
 */
@property (weak, nonatomic) IBOutlet UILabel *downTip;
/**
 *  下载图片按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *downBtn;

/** 聊天 */
@property (nonatomic,strong) LSLCLiveChatMsgItemObject *msgItem;


- (void)reloadMsgItem:(LSLCLiveChatMsgItemObject *)msgItem;

@end
