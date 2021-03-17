//
//  NSObject+Property.m
//  RtmpClientTest
//
//  Created by Max on 2021/3/17.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import "NSObject+Property.h"
#import <objc/runtime.h>

@implementation NSObject (Property)
- (NSDictionary *)properties {
    unsigned int outCount, index;
    objc_property_t *properties_t = class_copyPropertyList([self class], &outCount);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (index = 0; index < outCount; index++) {
        objc_property_t t_property = properties_t[index];
        NSString *attributeName = [NSString stringWithUTF8String:property_getName(t_property)];
        [dict setObject:[self valueForKey:attributeName]
                 forKey:attributeName];
    }
    return dict;
}
@end
