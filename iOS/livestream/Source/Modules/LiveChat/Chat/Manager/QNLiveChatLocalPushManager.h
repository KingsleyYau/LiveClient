//
//  LiveChatLocalPushManager.h
//  dating
//
//  Created by Calvin on 17/8/10.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSLCLiveChatMsgItemObject.h"
#import "LSLiveChatManagerOC.h"
@protocol QNLiveChatLocalPushManagerDelegate <NSObject>

- (void)liveChatPushManager:(NSString *)msg andMsgItem:(LSLCLiveChatMsgItemObject *)msgObj formLady:(LSLCLiveChatUserItemObject *)userItem;

@end

@interface QNLiveChatLocalPushManager : NSObject


@property (nonatomic, weak) id<QNLiveChatLocalPushManagerDelegate> delegate;

+ (QNLiveChatLocalPushManager *)sharedInstance;

 
@end
