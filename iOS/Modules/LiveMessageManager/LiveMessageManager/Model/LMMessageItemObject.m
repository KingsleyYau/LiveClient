//
//  LMPrivateMsgContactObject.m
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LMMessageItemObject.h"
@interface LMMessageItemObject () <NSCoding>
@end


@implementation LMMessageItemObject

- (id)init {
    if( self = [super init] ) {
        self.sendMsgId = -1;
        self.msgId = -1;
        self.sendType = LMSendType_Unknow;
        self.fromId = @"";
        self.toId = @"";
        self.createTime = 0;
        self.statusType = LMStatusType_Unprocess;
        self.msgType = LMMT_Unknow;
        self.sendErr = LCC_ERR_FAIL;
        self.userItem = nil;
        self.privateItem = nil;
        self.systemItem = nil;
        self.warningItem = nil;
        self.timeMsgItem = nil;
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.sendMsgId = [coder decodeIntForKey:@"sendMsgId"];
        self.msgId = [coder decodeIntForKey:@"msgId"];
        self.sendType = [coder decodeIntForKey:@"sendType"];
        self.fromId = [coder decodeObjectForKey:@"fromId"];
        self.toId = [coder decodeObjectForKey:@"toId"];
        self.createTime = [coder decodeIntegerForKey:@"createTime"];
        self.statusType = [coder decodeIntForKey:@"statusType"];
        self.msgType = [coder decodeIntForKey:@"msgType"];
        self.sendErr = [coder decodeIntForKey:@"sendErr"];
        self.userItem = [coder decodeObjectForKey:@"userItem"];
        self.privateItem = [coder decodeObjectForKey:@"privateItem"];
        self.systemItem = [coder decodeObjectForKey:@"systemItem"];
        self.warningItem = [coder decodeObjectForKey:@"warningItem"];
        self.timeMsgItem = [coder decodeObjectForKey:@"timeMsgItem"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.sendMsgId forKey:@"sendMsgId"];
    [coder encodeInt:self.msgId forKey:@"msgId"];
    [coder encodeInt:self.sendType forKey:@"sendType"];
    [coder encodeObject:self.fromId forKey:@"fromId"];
    [coder encodeObject:self.toId forKey:@"toId"];
    [coder encodeInteger:self.createTime forKey:@"createTime"];
    [coder encodeInt:self.statusType forKey:@"statusType"];
    [coder encodeInt:self.msgType forKey:@"msgType"];
    [coder encodeInt:self.sendErr forKey:@"sendErr"];
    [coder encodeObject:self.userItem forKey:@"userItem"];
    [coder encodeObject:self.privateItem forKey:@"privateItem"];
    [coder encodeObject:self.systemItem forKey:@"systemItem"];
    [coder encodeObject:self.warningItem forKey:@"warningItem"];
    [coder encodeObject:self.timeMsgItem forKey:@"timeMsgItem"];
}

@end
