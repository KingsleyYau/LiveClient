//
//  HangOutUserViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/7.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveRoom.h"

#import <GPUImage.h>
#import "GiftStatisticsView.h"
#import "LSGoogleAnalyticsViewController.h"

@class HangOutUserViewController;
@protocol HangOutUserViewControllerDelegate <NSObject>
@optional
- (void)userLongPressTapBoost:(BOOL)isBoost;
- (void)showManPushError:(NSString *)errmsg errNum:(LCC_ERR_TYPE)errNum;
@end

@interface HangOutUserViewController : LSGoogleAnalyticsViewController

@property (nonatomic, strong) LiveRoom *liveRoom;

@property (weak, nonatomic) IBOutlet GPUImageView *videoView;

@property (weak, nonatomic) IBOutlet UIView *comboGiftView;

@property (weak, nonatomic) IBOutlet GiftStatisticsView *giftCountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftCountViewWidth;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UIButton *startCloseBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBackgroundBtn;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (nonatomic, assign) BOOL isBoostView;

@property (weak, nonatomic) id <HangOutUserViewControllerDelegate> userDelegate;

- (void)publish;

- (void)stopPublish;

#pragma mark - 停止播流 置空播放器
- (void)resetPublish;

#pragma mark - 获取/设置推流声音
- (void)setThePublishMute:(BOOL)isMute;

- (void)reloadVideoStatus;

- (void)showGiftCount:(NSMutableArray *)bugforList;
// 刷新吧台礼物列表
- (void)reloadGiftCountView;

@end
