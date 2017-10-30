 
//
//  LSURLQueryParam.m
//  CommonWidget
//
//  Created by Max on 16/10/19.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "LSURLQueryParam.h"

@implementation LSURLQueryParam
+ (NSString *)urlParamForKey:(NSString *)key url:(NSURL *)url {
    NSDictionary *parameters = [LSURLQueryParam urlParameters:url];
    if (parameters == nil) {
        return nil;
    }
    return parameters[key];
}

+ (NSDictionary *)urlParameters:(NSURL *)url {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    NSString *query = [url query];
    NSArray *values = [query componentsSeparatedByString:@"&"];

    if (values == nil || values.count == 0)
        return nil;

    for (NSString *value in values) {
        NSArray *param = [value componentsSeparatedByString:@"="];
        if (param == nil || param.count == 2) {
            [parameters setObject:param[1] forKey:param[0]];
        }
    }

    return parameters;
}

@end
