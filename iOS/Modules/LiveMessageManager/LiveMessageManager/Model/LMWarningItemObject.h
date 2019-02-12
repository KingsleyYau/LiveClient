//
// LMWarningItemObject.h
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ILiveMessageDef.h"
@interface LMWarningItemObject : NSObject
/**
 * 私信警告信息
 * message     私信警告内容
 */
@property (nonatomic, assign) LMWarningType warnType;

@end
