//
//  NSStringCheck.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Check)

/**
 *  检查是否表情
 *
 *  @return YES:表情/NO:不是表情
 */
- (BOOL)isEmotion;


- (BOOL)containEmoji;
@end
