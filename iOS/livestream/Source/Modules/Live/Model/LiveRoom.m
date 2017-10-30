//
//  LiveRoom.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoom.h"

#import "LSRequestManager.h"
#import "LSLoginManager.h"

#define DEVICEID_KEY "deviceid"
#define TOKEN_KEY "token"

@interface LiveRoom () {
    NSString *_roomId;
    NSString *_userId;
    NSString *_userName;
    NSString *_playUrl;
    NSString *_publishUrl;
    double _roomCredit;

    NSInteger _playUrlIndex;
    NSInteger _publishUrlIndex;
}
@end

@implementation LiveRoom
- (id)init {
    if (self = [super init]) {
        _playUrlIndex = 0;
        _publishUrlIndex = 0;
    }
    return self;
}

#pragma mark - Get/Set方法
- (NSString *)roomId {
    if (!_roomId) {
        _roomId = _imLiveRoom.roomId;
    }
    return _roomId;
}

- (void)setRoomId:(NSString *)roomId {
    _roomId = roomId;
    if (_imLiveRoom) {
        _imLiveRoom.roomId = _roomId;
    }
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    if (_httpLiveRoom) {
        _httpLiveRoom.userId = _userId;
    }
}

- (NSString *)userId {
    if (!_userId) {
        _userId = _httpLiveRoom.userId;
    }
    return _userId;
}

- (NSString *)userName {
    if (!_userName) {
        _userName = _httpLiveRoom.nickName;
    }

    if (!_userName) {
        _userName = _imLiveRoom.nickName;
    }

    return _userName;
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
}

- (NSString *)photoUrl {
    return _httpLiveRoom.photoUrl;
}

- (NSString *)roomPhotoUrl {
    return _httpLiveRoom.roomPhotoUrl;
}

- (double)roomCredit {
    if (!_roomCredit) {
        _roomCredit = _imLiveRoom.credit;
    }
    return _roomCredit;
}

- (void)setRoomCredit:(double)roomCredit {
    _roomCredit = roomCredit;
}

- (NSArray<NSString *> *)playUrlArray {
    if (!_playUrlArray) {
        _playUrlArray = _imLiveRoom.videoUrls;
    }
    return _playUrlArray;
}

- (NSString *)playUrl {
    if (!_playUrl || _playUrl.length == 0) {
        if (self.playUrlArray.count > 0) {
            NSString *url = [self.playUrlArray objectAtIndex:_playUrlIndex];
            _playUrl = [NSString stringWithFormat:@"%@?"DEVICEID_KEY"=%@&"TOKEN_KEY"=%@", url, [[LSRequestManager manager] getDeviceId], [LSLoginManager manager].loginItem.token];
        }
    }
    return _playUrl;
}

- (NSArray<NSString *> *)publishUrlArray {
    if (!_publishUrlArray) {
        _publishUrlArray = _imLiveRoom.manPushUrl;
    }
    return _publishUrlArray;
}

- (NSString *)publishUrl {
    if (!_publishUrl || _publishUrl.length == 0) {
        if (self.publishUrlArray.count > 0) {
            NSString *url = [self.publishUrlArray objectAtIndex:_publishUrlIndex];
            _publishUrl = [NSString stringWithFormat:@"%@?"DEVICEID_KEY"=%@&"TOKEN_KEY"=%@", url, [[LSRequestManager manager] getDeviceId], [LSLoginManager manager].loginItem.token];
        }
    }
    return _publishUrl;
}

#pragma mark - 其他方法
- (void)reset {
    // 清空旧的流地址
    _playUrlIndex = 0;
    _publishUrlIndex = 0;
    self.playUrlArray = nil;
    self.publishUrlArray = nil;
}

- (NSString *)changePlayUrl {
    if (self.playUrlArray.count > 0) {
        _playUrlIndex = _playUrlIndex++ % self.playUrlArray.count;
    }

    return self.playUrl;
}

- (NSString *)changePublishUrl {
    if (self.publishUrlArray.count > 0) {
        _publishUrlIndex = _publishUrlIndex++ % self.publishUrlArray.count;
    }

    return self.publishUrl;
}

@end
