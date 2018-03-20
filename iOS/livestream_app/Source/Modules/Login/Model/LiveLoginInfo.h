//
//  LiveLoginInfo.h
//  livestream
//
//  Created by randy on 2017/12/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSEmailRegisterRequest.h"
@interface LiveLoginInfo : NSObject

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *inviteCode;
@property (nonatomic, assign) GenderType gender;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *photoUrl;
@end
