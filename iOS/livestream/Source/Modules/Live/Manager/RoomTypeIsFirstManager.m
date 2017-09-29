//
//  RoomTypeIsFirstManager.m
//  livestream
//
//  Created by randy on 2017/9/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RoomTypeIsFirstManager.h"

@implementation RoomTypeIsFirstManager

+ (instancetype)manager {
    
    static RoomTypeIsFirstManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[RoomTypeIsFirstManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.firstInDic = [[NSMutableDictionary alloc] init];
        
        RoomTypeFirst *public = [[RoomTypeFirst alloc] init];
        public.type = LiveRoomType_Public;
        public.haveComein = NO;
        [self.firstInDic setObject:public forKey:[NSString stringWithFormat:@"%d",LiveRoomType_Public]];
        
        RoomTypeFirst *publicvip = [[RoomTypeFirst alloc] init];
        publicvip.type = LiveRoomType_Public;
        publicvip.haveComein = NO;
        [self.firstInDic setObject:publicvip forKey:[NSString stringWithFormat:@"%d",LiveRoomType_Public_VIP]];
        
        RoomTypeFirst *private = [[RoomTypeFirst alloc] init];
        private.type = LiveRoomType_Public;
        private.haveComein = NO;
        [self.firstInDic setObject:private forKey:[NSString stringWithFormat:@"%d",LiveRoomType_Private]];
        
        RoomTypeFirst *privatevip = [[RoomTypeFirst alloc] init];
        privatevip.type = LiveRoomType_Public;
        privatevip.haveComein = NO;
        [self.firstInDic setObject:privatevip forKey:[NSString stringWithFormat:@"%d",LiveRoomType_Private_VIP]];
    }
    return self;
}

- (void)comeinLiveRoomWithType:(LiveRoomType)type HaveComein:(BOOL)haveComein {
    
    RoomTypeFirst *model = [self.firstInDic objectForKey:[NSString stringWithFormat:@"%d",type]];
    model.haveComein = haveComein;
    [self.firstInDic setObject:model forKey:[NSString stringWithFormat:@"%d",type]];
}

- (BOOL)getThisTypeHaveCome:(LiveRoomType)type {
    RoomTypeFirst *model = [self.firstInDic objectForKey:[NSString stringWithFormat:@"%d",type]];
    return model.haveComein;
}

@end



@implementation RoomTypeFirst

- (BOOL)isFirst {
    if ( !_haveComein ) {
        _haveComein = NO;
    }
    return _haveComein;
}

@end
