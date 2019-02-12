//
//  ChatVoiceManager.h
//  dating
//
//  Created by Calvin on 17/5/2.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSFileCacheManager.h"
@interface QNChatVoiceManager : NSObject

- (void)saveVoiceReadMessage:(NSString *)voiceId;
- (BOOL)voiceMessageIsRead:(NSString *)voiceId;
- (BOOL)removeVoiceReadMessage:(NSString *)voiceId;
@end
