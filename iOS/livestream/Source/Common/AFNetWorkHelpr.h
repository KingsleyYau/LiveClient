//
//  AFNetWorkHelpr.h
//  livestream
//
//  Created by randy on 17/6/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFNetWorkHelpr : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *manager;

+ (instancetype)shareInstrue;

@end
