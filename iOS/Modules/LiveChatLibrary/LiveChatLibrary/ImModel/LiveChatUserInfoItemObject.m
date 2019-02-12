//
//  LiveChatUserInfoItemObject.m
//  dating
//
//  Created by  Samson on 5/30/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat用户信息类

#import "LiveChatUserInfoItemObject.h"

@implementation LiveChatUserInfoItemObject

- (LiveChatUserInfoItemObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.userId = @"";
        self.userName = @"";
        self.server = @"";
        self.imgUrl = @"";
        self.sexType = USER_SEX_FEMALE;
        self.age = 0;
        self.weight = @"";
        self.height = @"";
        self.country = @"";
        self.province = @"";
        self.videoChat = NO;
        self.videoCount = 0;
        self.marryType = MT_UNKNOW;
        self.childrenType = CT_UNKNOW;
        self.status = USTATUS_UNKNOW;
        self.userType = UT_UNKNOW;
        self.orderValue = 0;
        self.deviceType = DEVICE_TYPE_UNKNOW;
        self.clientType = CLIENT_UNKNOW;
        self.clientVersion = @"";
        self.needTrans = NO;
        self.transUserId = @"";
        self.transUserName = @"";
        self.transBind = NO;
        self.transStatus = USTATUS_UNKNOW;
    }
    return self;
}

@end
