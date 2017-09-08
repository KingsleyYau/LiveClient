//
//  LiveRoom.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoom.h"

@interface LiveRoom () {
    NSString *_roomId;
}
@end

@implementation LiveRoom
- (id)init {
    if( self = [super init] ) {
        
    }
    return self;
}

- (NSString *)roomId {
    if( !_roomId ) {
//        _roomId = _httpLiveRoom.roomId;
    }
    return _roomId;
}

- (void)setRoomId:(NSString *)roomId {
    _roomId = roomId;
}

- (NSString *)userId {
    return _httpLiveRoom.userId;
}

- (NSString *)userName {
    return _httpLiveRoom.nickName;
}

@end
