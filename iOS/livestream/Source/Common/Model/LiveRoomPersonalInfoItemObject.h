//
//  LiveRoomPersonalInfoItemObject.h
//  dating
//
//  Created by Alex on 17/5/24.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LiveRoomPersonalInfoItemObject : NSObject
// 头像url
@property (nonatomic, strong) NSString* photoUrl;
// 昵称
@property (nonatomic, strong) NSString* nickName;
// 性别（0:男性， 1:女性 ）
@property (nonatomic, assign) Gender gender;
// 出生日期（格式： 1980-01-01）
@property (nonatomic, strong) NSString* birthday;
@end
