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
    NSString *_photoUrl;
    NSString *_playUrl;
    NSString *_publishUrl;
    double _roomCredit;

    NSArray<NSString *> *_playUrlArray;
    NSInteger _playUrlIndex;
    NSArray<NSString *> *_publishUrlArray;
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

    if (_imLiveRoom) {
        _imLiveRoom.userId = _userId;
    }
}

- (NSString *)userId {
    if (!_userId) {
        _userId = _httpLiveRoom.userId;
    }

    if (!_userId) {
        _userId = _imLiveRoom.userId;
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

    if (_httpLiveRoom) {
        _httpLiveRoom.nickName = _userName;
    }

    if (_imLiveRoom) {
        _imLiveRoom.nickName = _userName;
    }
}

- (NSString *)photoUrl {
    if (!_photoUrl) {
        if (_httpLiveRoom) {
            _photoUrl = _httpLiveRoom.photoUrl;
        }
    }

    if (!_photoUrl) {
        if (_imLiveRoom) {
            _photoUrl = _imLiveRoom.photoUrl;
        }
    }

    return _photoUrl;
}

- (void)setPhotoUrl:(NSString *)photoUrl {
    _photoUrl = photoUrl;
    if (_httpLiveRoom) {
        _httpLiveRoom.photoUrl = _photoUrl;
    }
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

- (NSArray<NSString *> *)playUrlArray {
    if (!_playUrlArray) {
        _playUrlArray = _imLiveRoom.videoUrls;
    }
    return _playUrlArray;
}

- (void)setPlayUrlArray:(NSArray<NSString *> *)playUrlArray {
    _playUrlArray = playUrlArray;
    if (_imLiveRoom) {
        _imLiveRoom.videoUrls = _playUrlArray;
    }
}

- (NSString *)playUrl {
    NSString *realUrl = @"";
    if (self.playUrlArray.count > 0) {
        NSString *url = [self.playUrlArray objectAtIndex:_playUrlIndex];
        realUrl = [NSString stringWithFormat:@"%@?" DEVICEID_KEY "=%@&" TOKEN_KEY "=%@", url, [[LSRequestManager manager] getDeviceId], [LSLoginManager manager].loginItem.token];
    }
    return realUrl;
}

- (NSArray<NSString *> *)publishUrlArray {
    if (!_publishUrlArray) {
        _publishUrlArray = _imLiveRoom.manPushUrl;
    }
    return _publishUrlArray;
}

- (void)setPublishUrlArray:(NSArray<NSString *> *)publishUrlArray {
    _publishUrlArray = publishUrlArray;
    if (_imLiveRoom) {
        _imLiveRoom.manPushUrl = _publishUrlArray;
    }
}

- (NSString *)publishUrl {
    NSString *realUrl = @"";
    if (self.publishUrlArray.count > 0) {
        NSString *url = [self.publishUrlArray objectAtIndex:_publishUrlIndex];
        realUrl = [NSString stringWithFormat:@"%@?" DEVICEID_KEY "=%@&" TOKEN_KEY "=%@", url, [[LSRequestManager manager] getDeviceId], [LSLoginManager manager].loginItem.token];
    }
    return realUrl;
}

#pragma mark - 其他方法
- (void)reset {
    // 清空旧的流地址
    NSLog(@"LiveRoom::reset()");
    _playUrlIndex = 0;
    _publishUrlIndex = 0;
    self.playUrlArray = nil;
    self.publishUrlArray = nil;
}

- (NSString *)changePlayUrl {
    NSLog(@"LiveRoom::changePlayUrl( _playUrlIndex : %d, playUrlArray : %@ )", (int)_playUrlIndex, self.playUrlArray);
    if (self.playUrlArray.count > 0) {
        _playUrlIndex++;
        _playUrlIndex = _playUrlIndex % self.playUrlArray.count;
    }

    return self.playUrl;
}

- (NSString *)changePublishUrl {
    NSLog(@"LiveRoom::changePublishUrl( _publishUrlIndex : %d, publishUrlArray : %@ )", (int)_publishUrlIndex, self.publishUrlArray);
    if (self.publishUrlArray.count > 0) {
        _publishUrlIndex++;
        _publishUrlIndex = _publishUrlIndex % self.publishUrlArray.count;
    }

    return self.publishUrl;
}

@end
