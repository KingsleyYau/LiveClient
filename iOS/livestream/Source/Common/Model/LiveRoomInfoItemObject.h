//
//  LiveRoomInfoItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveRoomInfoItemObject : NSObject
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* nickName;
@property (nonatomic, strong) NSString* photoUrl;
@property (nonatomic, strong) NSString* roomId;
@property (nonatomic, strong) NSString* roomName;
@property (nonatomic, strong) NSString* roomPhotoUrl;
// 直播间状态（0:离线（Offline） 正在直播（Live））
@property (nonatomic, assign) int status;
@property (nonatomic, assign) int fansNum;
@property (nonatomic, strong) NSString* country;
@end
