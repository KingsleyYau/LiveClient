//
//  TalentOnDemandManager.h
//  livestream
//
//  Created by Calvin on 17/9/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol TalentOnDemandManagerDelegate <NSObject>
@optional;


@end

@interface TalentOnDemandManager : NSObject

@property (nonatomic ,weak) id<TalentOnDemandManagerDelegate> delegate;

+ (instancetype)manager;

- (void)getTalentList:(NSString *)roomId;

- (void)getTalentStatusRoomId:(NSString *)roomId talentId:(NSString *)talentId;

@end
