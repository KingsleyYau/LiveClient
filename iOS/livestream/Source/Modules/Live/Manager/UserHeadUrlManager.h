//
//  UserHeadUrlManager.h
//  livestream
//
//  Created by randy on 2017/6/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetLiveRoomUserPhotoRequest.h"

@interface UserHeadUrlManager : NSObject

@property (nonatomic, strong) NSString *photoUrl;

@property (nonatomic, strong) NSString *userId;

+ (instancetype)manager;

// 请求用户图片
- (NSString *)getLiveRoomUserPhotoRequestWithUserId:(NSString *)userId andType:(PhotoType)type;

@end
