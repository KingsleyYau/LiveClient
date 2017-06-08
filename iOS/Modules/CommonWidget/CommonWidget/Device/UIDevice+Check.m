//
//  Device+Check.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "UIDevice+Check.h"

@implementation UIDevice(Check)
+ (BOOL)canDail {
    UIDevice *device = [UIDevice currentDevice];
    NSString *devicetype = device.model;
    if([devicetype isEqualToString:@"iPhone"]){
        return YES;
    }
    return NO;
}
@end
