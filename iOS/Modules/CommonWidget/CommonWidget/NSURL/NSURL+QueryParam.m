//
//  NSURL+QueryParam.m
//  CommonWidget
//
//  Created by Max on 16/10/19.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "NSURL+QueryParam.h"

@implementation NSURL(QueryParam)
- (NSString *)parameterForKey:(NSString *)key {
    NSDictionary *parameters = [self parameters];
    if(parameters == nil) {
        return nil;
    }
    return parameters[key];
}

-(NSDictionary  *)parameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *query = [self query];
    NSArray *values = [query componentsSeparatedByString:@"&"];
    
    if( values == nil || values.count == 0 )
        return nil;
    
    for(NSString *value in values) {
        NSArray *param = [value componentsSeparatedByString:@"="];
        if( param == nil || param.count == 2 ) {
            [parameters setObject:param[1] forKey:param[0]];
        }
    }
    
    return parameters;
}

@end
