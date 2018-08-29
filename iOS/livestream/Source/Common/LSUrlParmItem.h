//
//  LSUrlParmItem.h
//  livestream
//
//  Created by randy on 2017/11/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveRoom.h"

@interface LSUrlParmItem : NSObject

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) LiveRoomType roomType;
@property (nonatomic, copy) NSString *roomTypeString;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *showId;
@property (nonatomic, copy) NSString *opentype;
@property (nonatomic, copy) NSString *apptitle;
@property (nonatomic, copy) NSString *anchorid;
@property (nonatomic, copy) NSString *gascreen;
@property (nonatomic, copy) NSString *styletype;
@property (nonatomic, copy) NSString *resumecb;
@end
