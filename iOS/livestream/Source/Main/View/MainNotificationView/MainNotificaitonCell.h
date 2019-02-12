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
@property (weak, nonatomic) IBOutlet UILabel *msgStatus;
@property (weak, nonatomic) IBOutlet UILabel *chatMsg;
@property (weak, nonatomic) IBOutlet UIImageView *onlineImage;
@property (weak, nonatomic) IBOutlet UIImageView *chatHead;

@property (weak, nonatomic) IBOutlet UIView *liveNotificationView;
@property (weak, nonatomic) IBOutlet UIImageView *liveHead;
@property (weak, nonatomic) IBOutlet UIImageView *liveFriendHead;
@property (weak, nonatomic) IBOutlet UILabel *liveName;
@property (weak, nonatomic) IBOutlet UILabel *liveMsg;

@property (nonatomic, assign) CGFloat time;
@property (nonatomic, assign) CGFloat countdownTime;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
+ (NSString *)cellIdentifier;

- (void)loadChatNotificationViewUI:(LSMainNotificaitonModel *)item;
- (void)loadLiveNotificationViewUI:(LSMainNotificaitonModel *)item;
- (void)startCountdown:(NSInteger)time;
@end

