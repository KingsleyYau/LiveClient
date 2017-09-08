//
//  RemberLiveRoomModel.h
//  livestream
//
//  Created by randy on 2017/9/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveRoom.h"

@interface RoomTypePrice : NSObject

@property (nonatomic, assign)RoomType roomType;
@property (nonatomic, assign)double price;

@end


@interface RemberLiveRoomModel : NSObject

@property (nonatomic, strong) RoomTypePrice *typePrice;

+ (instancetype)liveRoomModel;

- (void)fristComeIntheLiveRoom:(RoomType)type price:(double)price;

- (BOOL)getToRoomtyprPrice:(RoomType)type;

@end

