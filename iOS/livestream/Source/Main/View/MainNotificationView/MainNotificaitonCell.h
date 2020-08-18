//
//  MainNotificaitonCell.h
//  livestream
//
//  Created by Calvin on 2019/1/18.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMainNotificaitonModel.h"
#import "LSImageViewLoader.h"


@interface MainNotificaitonCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *chatNotificationView;
@property (weak, nonatomic) IBOutlet UILabel *chatName;
@property (weak, nonatomic) IBOutlet TopLeftLabel *chatMsg;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *chatHead;
@property (weak, nonatomic) IBOutlet UIView *liveNotificationView;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *liveHead;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *liveFriendHead;
@property (weak, nonatomic) IBOutlet UILabel *liveName;
@property (weak, nonatomic) IBOutlet TopLeftLabel *liveMsg;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, assign) NSInteger countdownTime;
@property (weak, nonatomic) IBOutlet UIImageView *colorView;
@property (weak, nonatomic) IBOutlet UIView *scheduledTimeView;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
+ (NSString *)cellIdentifier;

- (void)loadChatNotificationViewUI:(LSMainNotificaitonModel *)item;
- (void)loadLiveNotificationViewUI:(LSMainNotificaitonModel *)item;
- (void)startCountdown:(NSInteger)time;
@end

