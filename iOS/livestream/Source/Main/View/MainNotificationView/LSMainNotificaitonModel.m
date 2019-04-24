//
//  LSMainNotificaitonModel.m
//  livestream
//
//  Created by Calvin on 2019/1/17.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSMainNotificaitonModel.h"

@implementation LSMainNotificaitonModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.notifiID = @"";
        self.userId = @"";
        self.photoUrl = @"";
        self.friendUrl = @"";
        self.userName = @"";
        self.contentStr = @"";
        self.msgType = MsgStatus_Chat;
        self.isAuto = NO;
        self.createTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

@end
