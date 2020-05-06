//
//  LSLCLiveChatScheduleInfoItemObject.h
//  dating
//
//  Created by Alex on 20/4/08.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSLCLiveChatScheduleMsgItemObject.h"

@interface LSLCLiveChatScheduleInfoItemObject : NSObject

/** 难会员ID */
@property (nonatomic,copy) NSString *manId;
/** 女会员ID */
@property (nonatomic,copy) NSString *womanId;
/**  预约消息协议 */
@property (nonatomic,strong) LSLCLiveChatScheduleMsgItemObject * msg;

- (LSLCLiveChatScheduleInfoItemObject *)init;


@end
