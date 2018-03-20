//
//  ILoginHandler.h
//  livestream
//
//  Created by Calvin on 2017/12/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveLoginInfo.h"
typedef void (^LoginHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull userSid);

typedef void (^LogoutHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

@interface ILoginHandler : NSObject

- (BOOL)login:(LoginHandler _Nullable )loginHandler;
- (BOOL)logout:(LogoutHandler _Nullable)logoutHandler;
- (BOOL)autoLogin:(LoginHandler _Nullable)loginHandler;
- (BOOL)registerHandler:(LoginHandler _Nullable)registerHandler;

@property (nonatomic, strong) LiveLoginInfo * _Nullable loginInfo;

@end
