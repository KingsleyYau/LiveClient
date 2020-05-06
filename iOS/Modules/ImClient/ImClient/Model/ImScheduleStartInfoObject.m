//
//  ImScheduleStartInfoObject.m
//  livestream
//
//  Created by Max on 2020/4/8.
//  Copyright © 2020年 net.qdating. All rights reserved.
//

#import "ImScheduleStartInfoObject.h"

@implementation ImScheduleStartInfoObject

- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.anchorNickName = @"";
        self.status = IMCHATONLINESTATUS_OFF;
        self.anchorAvatar = @"";
        self.startTime = 0;
        self.endTime = 0;
        self.msg = @"";
        self.schNum = 0;
        self.countdownNum = 0;
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorNickName = [coder decodeObjectForKey:@"anchorNickName"];
        self.status = [coder decodeIntForKey:@"status"];
        self.anchorAvatar = [coder decodeObjectForKey:@"anchorAvatar"];
        self.startTime = [coder decodeIntegerForKey:@"startTime"];
        self.endTime = [coder decodeIntegerForKey:@"endTime"];
        self.msg = [coder decodeObjectForKey:@"msg"];
        self.schNum = [coder decodeIntForKey:@"schNum"];
        self.countdownNum = [coder decodeIntForKey:@"countdownNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorNickName forKey:@"anchorNickName"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeObject:self.anchorAvatar forKey:@"anchorAvatar"];
    [coder encodeInteger:self.startTime forKey:@"startTime"];
    [coder encodeInteger:self.endTime forKey:@"endTime"];
    [coder encodeObject:self.msg forKey:@"msg"];
    [coder encodeInt:self.schNum forKey:@"schNum"];
    [coder encodeInt:self.countdownNum forKey:@"countdownNum"];

}


@end
