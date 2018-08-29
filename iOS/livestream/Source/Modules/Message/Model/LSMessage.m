//
//  LSMessage.m
//  livestream
//
//  Created by Calvin on 2018/6/19.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMessage.h"

@implementation LSMessage

- (id)init {
    if( self = [super init] ) {
        self.msgId = -1;
        self.sender = MessageSenderUnknow;
        self.type = MessageTypeUnknow;
        self.status = MessageStatusUnknow;
        self.text = nil;
        self.attText = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.msgId = [coder decodeIntegerForKey:@"msgId"];
        self.text = [coder decodeObjectForKey:@"text"];
        self.attText = [coder decodeObjectForKey:@"attText"];
        self.sender = (Sender)[[coder decodeObjectForKey:@"sender"] intValue];
        self.type = (Type)[[coder decodeObjectForKey:@"type"] intValue];
        self.status = (Status)[[coder decodeObjectForKey:@"status"] intValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.msgId forKey:@"msgId"];
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.attText forKey:@"attText"];
    [coder encodeObject:[NSNumber numberWithInt:self.sender] forKey:@"sender"];
    [coder encodeObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
    [coder encodeObject:[NSNumber numberWithInt:self.status] forKey:@"status"];
}

- (id)copyWithZone:(NSZone *)zone {
    LSMessage *messageItem = [[[self class] allocWithZone:zone] init];
    messageItem.msgId = self.msgId;
    messageItem.text = [self.text copy];
    messageItem.attText = [self.attText copy];
    messageItem.sender = self.sender;
    messageItem.type = self.type;
    messageItem.status = self.status;
    return messageItem;
}
@end
