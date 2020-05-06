//
//  ImScheduleRoomInfoObject.m
//  livestream
//
//  Created by Max on 2020/4/3.
//  Copyright © 2020年 net.qdating. All rights reserved.
//

#import "ImScheduleRoomInfoObject.h"

@implementation ImScheduleRoomInfoObject

- (id)init {
    if( self = [super init] ) {
        self.roomId = @"";
        self.nickName = @"";
        self.toId = @"";
        self.privScheId = @"";
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.toId = [coder decodeObjectForKey:@"toId"];
        self.privScheId = [coder decodeObjectForKey:@"privScheId"];
        self.msg = [coder decodeObjectForKey:@"msg"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.toId forKey:@"toId"];
    [coder encodeObject:self.privScheId forKey:@"privScheId"];
    [coder encodeObject:self.msg forKey:@"msg"];

}


@end
