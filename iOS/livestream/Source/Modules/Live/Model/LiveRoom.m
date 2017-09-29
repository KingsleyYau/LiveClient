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
    NSString *_playUrl;
    NSString *_publishUrl;
    double   _roomCredit;
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
        _roomId = _imLiveRoom.roomId;
    }
    return _roomId;
}

- (void)setRoomId:(NSString *)roomId {
    _roomId = roomId;
    if( _imLiveRoom ) {
        _imLiveRoom.roomId = _roomId;
    }
}

- (NSString *)userId {
    return _httpLiveRoom.userId;
}

- (NSString *)userName {
    return _httpLiveRoom.nickName;
}

- (NSString *)photoUrl {
    return _httpLiveRoom.photoUrl;
}

- (double)roomCredit {
    if ( !_roomCredit ) {
        _roomCredit = _imLiveRoom.credit;
    }
    return _roomCredit;
}

- (void)setRoomCredit:(double)roomCredit {
    _roomCredit = roomCredit;
}

- (NSString *)playUrl {
    if( !_playUrl || _playUrl.length == 0 ) {
        if( _imLiveRoom.videoUrls.count > 0 ) {
            _playUrl = [_imLiveRoom.videoUrls objectAtIndex:0];
        }
    }
    return _playUrl;
}

- (void)setPlayUrl:(NSString *)playUrl {
    _playUrl = playUrl;
}

- (NSString *)publishUrl {
    if( !_publishUrl || _publishUrl.length == 0 ) {
        if( _imLiveRoom.manPushUrl.count > 0 ) {
            _publishUrl = [_imLiveRoom.manPushUrl objectAtIndex:0];
        }
    }
    return _publishUrl;
}

- (void)setPublishUrl:(NSString *)publishUrl {
    _publishUrl = publishUrl;
}

@end
