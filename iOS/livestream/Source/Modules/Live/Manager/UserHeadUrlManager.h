//
//  UserHeadUrlManager.h
//  livestream
//
//  Created by randy on 2017/6/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetLiveRoomUserPhotoRequest.h"

typedef enum {
    REQUESTNONE = 0,
    REQUESTSTART,
    REQUESTEND
} RequestImgUrlState;


@interface UserInfoItem : NSObject

@property (nonatomic, strong) NSString *userHeadUrl;

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSString *coverUrl;

@property (nonatomic, assign) RequestImgUrlState requestState;

@end

typedef void (^RequestUserPhotoEnd)(NSString *userId,UserInfoItem *item);


@interface UserHeadUrlManager : NSObject

@property (nonatomic, strong) NSString *photoUrl;

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, assign) RequestImgUrlState requestState;

/** 请求回图片url后 */
@property (nonatomic, strong) RequestUserPhotoEnd requestUserPhotoEnd;

+ (instancetype)manager;

// 请求用户图片
- (void)getLiveRoomUserPhotoRequestWithUserId:(NSString *)userId andType:(PhotoType)type requestEnd:(RequestUserPhotoEnd)requestEnd;

@end
