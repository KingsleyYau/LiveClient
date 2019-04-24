//
//  LSChatDetailVideoViewController.h
//  livestream
//
//  Created by Randy_Fan on 2019/3/20.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSLiveChatManagerOC.h"
#import "LSLiveChatRequestManager.h"


@protocol LSChatDetailVideoViewControllerDelegate <NSObject>

@optional
- (void)videoDetailspushAddCreditsViewController;

@end

@interface LSChatDetailVideoViewController : LSGoogleAnalyticsViewController

@property (nonatomic, strong) LSLCLiveChatMsgItemObject *msgItem;
@property (nonatomic, strong) LSLCRecentVideoItemObject *recentItem;
@property (weak, nonatomic) id <LSChatDetailVideoViewControllerDelegate> viewDelegate;
@end
