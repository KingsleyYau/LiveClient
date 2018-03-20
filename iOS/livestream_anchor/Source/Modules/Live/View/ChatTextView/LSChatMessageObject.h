//
//  LSChatMessageObject.h
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSChatEmotion.h"

@interface LSChatMessageObject : NSObject
/**
 *  表情列表
 */
@property (nonatomic, retain) NSArray *emotionArray;

- (void)chatMessageHaveEmotionWithString:(NSString *)string;

@end
