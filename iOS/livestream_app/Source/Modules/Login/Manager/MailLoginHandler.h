//
//  MailLoginHandler.h
//  livestream
//
//  Created by Calvin on 2017/12/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILoginHandler.h"
#import "LiveLoginInfo.h"

@interface MailLoginHandler : ILoginHandler

@property (nonatomic, copy) NSString * email;
@property (nonatomic, copy) NSString * password;

- (BOOL)login:(LoginHandler)loginHandler;
- (BOOL)logout:(LogoutHandler)logoutHandler;
- (BOOL)autoLogin:(LoginHandler)loginHandler;
- (BOOL)registerHandler:(LoginHandler)registerHandler;
- (instancetype)initWithUserId:(NSString *)userId andPassword:(NSString *)password;
@end
