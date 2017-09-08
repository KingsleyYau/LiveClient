//
//  RemberLiveRoomModel.m
//  livestream
//
//  Created by randy on 2017/9/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RemberLiveRoomModel.h"

@interface RemberLiveRoomModel ()

@property (nonatomic, strong) NSMutableDictionary *mutableDic;

@end

@implementation RemberLiveRoomModel

+ (instancetype)liveRoomModel{
    
    static RemberLiveRoomModel *liveRoomModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        liveRoomModel = [[RemberLiveRoomModel alloc] init];
        liveRoomModel.mutableDic = [[NSMutableDictionary alloc] init];
        liveRoomModel.typePrice = [[RoomTypePrice alloc] init];
    });
    
    return liveRoomModel;
}


- (void)fristComeIntheLiveRoom:(RoomType)type price:(double)price{
    
    RoomTypePrice *typePrice = [[RoomTypePrice alloc] init];
    typePrice.roomType = type;
    typePrice.price = price;
    
    [self.mutableDic setObject:typePrice forKey:[NSString stringWithFormat:@"%u",type]];
}


- (BOOL)getToRoomtyprPrice:(RoomType)type{
    
    BOOL haveModel = NO;
    
    RoomTypePrice *typePrice = [self.mutableDic objectForKey:[NSString stringWithFormat:@"%u",type]];
    if (typePrice) {
        haveModel = YES;
        self.typePrice = typePrice;
    }
    return haveModel;
}


@end



@implementation RoomTypePrice


@end


