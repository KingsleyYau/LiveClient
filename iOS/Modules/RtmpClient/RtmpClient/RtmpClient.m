//
//  RtmpClient.m
//  RtmpClient
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RtmpClient.h"

#include <rtmpdump/RtmpDump.h>
using namespace coollive;

@interface RtmpClient () {
    
}
@end

@implementation RtmpClient
#pragma mark - 全局初始化
+ (void)gobalInit {
    RtmpDump::GobalInit();
}

@end
