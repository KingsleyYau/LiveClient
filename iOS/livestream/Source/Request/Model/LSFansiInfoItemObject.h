//
//  LSFansiInfoItemObject
//  dating
//
//  Created by Alex on 20/08/04.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
#import "LSFansiPrivItemObject.h"
@interface LSFansiInfoItemObject : NSObject
/**
 * 观众信息结构体
 * fansiPriv         观众权限
 */
@property (nonatomic, strong) LSFansiPrivItemObject* _Nullable fansiPriv;

@end
