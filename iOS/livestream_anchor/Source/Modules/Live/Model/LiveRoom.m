//
//  LiveRoom.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoom.h"

#import "LSLoginManager.h"

#define DEVICEID_KEY "deviceid"
#define TOKEN_KEY "token"

@interface LiveRoom () {
    NSString *_roomId;
    NSString *_showId;
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

    if (_imLiveRoom) {
        _imLiveRoom.anchorId = _userId;
    }
    
    if (_showInfo) {
        _showInfo.anchorId = _userId;
    }
}

- (NSString *)userId {

    if (!_userId) {
        _userId = _imLiveRoom.anchorId;
    }
    
    if (!_userId) {
        _userId = _showInfo.anchorId;
    }
    
    return _userId;
}

- (NSString *)showId {
    if (!_showId) {
        _showId = _showInfo.showLiveId;
    }
    return _showId;
}

- (void)setShowId:(NSString *)showId
{
    _showId = showId;
    if (_showInfo.showLiveId.length > 0) {
        _showInfo.showLiveId = _showId;
    }
}

- (NSString *)playUrl {
    NSString *realUrl = @"";
    if (self.playUrlArray.count > 0) {
        NSString *url = [self.playUrlArray objectAtIndex:_playUrlIndex];
        realUrl = [NSString stringWithFormat:@"%@?" DEVICEID_KEY "=%@&" TOKEN_KEY "=%@", url, [[LSAnchorRequestManager manager] getDeviceId], [LSLoginManager manager].loginItem.token];
    }
    return realUrl;
}

- (NSArray<NSString *> *)publishUrlArray {
    if (!_publishUrlArray) {
        _publishUrlArray = _imLiveRoom.pushUrl;
    }
    return _publishUrlArray;
}

- (void)setPublishUrlArray:(NSArray<NSString *> *)publishUrlArray {
    _publishUrlArray = publishUrlArray;
    if (_imLiveRoom) {
        _imLiveRoom.pushUrl = _publishUrlArray;
    }
}

- (NSString *)publishUrl {
    NSString *realUrl = @"";
    if (self.publishUrlArray.count > 0) {
        NSString *url = [self.publishUrlArray objectAtIndex:_publishUrlIndex];
     
        realUrl = [NSString stringWithFormat:@"%@?" DEVICEID_KEY "=%@&" TOKEN_KEY "=%@", url, [[LSAnchorRequestManager manager] getDeviceId], [LSLoginManager manager].loginItem.token];
 
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
