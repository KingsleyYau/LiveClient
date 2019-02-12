//
//  LadyListNotificationView.h
//  dating
//
//  Created by Calvin on 16/12/20.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSLCLiveChatMsgItemObject.h"
#import "LSLiveChatManagerOC.h"
#import "LSImageViewLoader.h"
@class LSLCLiveChatMsgItemObject;
@class QNLadyListNotificationView;
@protocol LadyListNotificationViewDelegate <NSObject>
//浮窗通知点击回调
- (void)LadyListNotificationViewDidToChat:(LSLCLiveChatUserItemObject *)item;

@end


@interface QNLadyListNotificationView : UIView

@property (weak, nonatomic) id<LadyListNotificationViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *notificationView;
@property (weak, nonatomic) IBOutlet UIImageView *ladyImageView;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chatIcon;
@property (weak, nonatomic) IBOutlet UIImageView *camshareInviteIcon;
@property (weak, nonatomic) IBOutlet UILabel *msgStatus;

+ (instancetype)initLadyListNotificationViewXibLoadUser:(LSLCLiveChatUserItemObject *)user msg:(NSString *)msg msgItem:(LSLCLiveChatMsgItemObject*)item;

- (void)removeNotificationView;
@end
