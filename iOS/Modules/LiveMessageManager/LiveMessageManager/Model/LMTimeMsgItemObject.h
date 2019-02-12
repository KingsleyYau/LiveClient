//
// LMTimeMsgItemObject.h
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LMTimeMsgItemObject : NSObject
/**
 * 私信时间信息
 * msgTime     时间分组时间（LMMessageitem中的createTime是创建时间，分组时间用这个）
 */
@property (nonatomic, assign) NSInteger msgTime;

@end
