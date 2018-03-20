//
//  AFNetWorkHelpr.m
//  livestream
//
//  Created by randy on 17/6/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AFNetWorkHelpr.h"

@interface AFNetWorkHelpr()

@end

@implementation AFNetWorkHelpr

static AFHTTPSessionManager *manager;

+ (instancetype)shareInstrue{
    
    static AFNetWorkHelpr *helpr;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (helpr == nil)
        {
            helpr = [[AFNetWorkHelpr alloc] init];
            manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.requestSerializer.timeoutInterval = 10;
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml",@"text/css", nil];
            helpr.manager = manager;
        }
    });
    
    return helpr;
}

@end
