//
//  LiveViewController.h
//  livestream
//
//  Created by Max on 2017/5/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

#import "ChatTextView.h"
#import "GPUImageView.h"
#import "UITextFieldAlign.h"

#import "ImageViewLoader.h"

#import "BarrageView.h"
#import "BarrageModel.h"
#import "BarrageModelCell.h"

#import "GiftComboView.h"
#import "GiftComboManager.h"

#import "IMManager.h"
#import "LoginManager.h"
#import "MsgItem.h"

#import "BigGiftAnimationView.h"

#define PlaceholderFontSize 16
#define PlaceholderFont [UIFont boldSystemFontOfSize:PlaceholderFontSize]

#define MaxInputCount 70

@interface LiveViewController : KKViewController
#pragma mark - 退出按钮
@property (nonatomic, weak) IBOutlet UIButton* btnCancel;

#pragma mark - 直播间信息
@property (nonatomic, strong) NSString* roomId;

#pragma mark - IM管理器
@property (nonatomic, strong) IMManager* imManager;

#pragma mark - 登录管理器
@property (nonatomic, strong) LoginManager* loginManager;

#pragma mark - 主播信息控件
@property (nonatomic, weak) IBOutlet UIView* roomView;
@property (nonatomic, weak) IBOutlet UIImageViewTopFit* imageViewHeader;
@property (nonatomic, strong) ImageViewLoader* imageViewHeaderLoader;
@property (nonatomic, weak) IBOutlet UIButton* favourBtn;
@property (weak, nonatomic) IBOutlet UILabel *announNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *audienceNumLabel;

#pragma mark - 榜单信息控件
@property (nonatomic, weak) IBOutlet UIView* fansView;

#pragma mark - 连击控件
@property (nonatomic, weak) IBOutlet UIView* giftView;

#pragma mark - 弹幕控件
@property (nonatomic, weak) IBOutlet BarrageView* barrageView;

#pragma mark - 消息列表控件
@property (nonatomic, weak) IBOutlet UITableView* msgTableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* msgTableViewBottom;

@property (nonatomic, weak) IBOutlet UIView* msgTipsView;
@property (nonatomic, weak) IBOutlet UILabel* msgTipsLabel;

#pragma mark - 视频控件
@property (nonatomic, weak) IBOutlet GPUImageView* videoView;

/**
 未读消息数量
 */
@property (assign) NSInteger unReadMsgCount;

#pragma mark - 大礼物展现界面
@property (nonatomic, strong) BigGiftAnimationView *giftAnimationView;

#pragma mark - 大礼物播放队列
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

#pragma mark - 按钮事件
- (IBAction)fansAction:(id)sender;

#pragma mark - 逻辑事件
/**
 发送消息/弹幕

 @param text 文本内容
 @return 成功失败
 */
- (BOOL)sendMsg:(NSString *)text isLounder:(BOOL)isLounder;

/**
 增加连击

 @param giftItem <#giftItem description#>
 */
- (void)addCombo:(GiftItem *)giftItem;

/**
 显示大礼物
 
 @param giftID 大礼物ID
 */
- (void)starBigAnimationWithGiftID:(NSString *)giftID;

/**
 点赞动画
 */
- (void)showLike;

/**
 插入直播间点赞消息
 */
- (void)addLikeMessage:(NSString *)nickName;

/**
 插入直播间送礼消息
 */
- (void)addGiftMessageNickName:(NSString *)nickName giftID:(NSString *)giftID giftNum:(int)giftNum;

@end
