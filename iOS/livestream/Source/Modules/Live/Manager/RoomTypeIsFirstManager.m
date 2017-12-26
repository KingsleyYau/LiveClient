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
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (![userDefaults boolForKey:@"firstJoin"]) {
            [userDefaults setBool:YES forKey:@"firstJoin"];
            [userDefaults synchronize];
            
            [userDefaults setBool:NO forKey:@"Public_Join"];
            [userDefaults synchronize];
            
            [userDefaults setBool:NO forKey:@"Public_VIP_Join"];
            [userDefaults synchronize];
            
            [userDefaults setBool:NO forKey:@"Private_Join"];
            [userDefaults synchronize];
            
            [userDefaults setBool:NO forKey:@"Private_VIP_Join"];
            [userDefaults synchronize];
        }
    }
    return self;
}

- (void)comeinLiveRoomWithType:(NSString *)type HaveComein:(BOOL)haveComein {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:haveComein forKey:type];
    [userDefaults synchronize];
}

- (BOOL)getThisTypeHaveCome:(NSString *)type {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:type];
}

@end
