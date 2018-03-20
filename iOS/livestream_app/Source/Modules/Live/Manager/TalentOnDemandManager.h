//
//  TalentOnDemandManager.h
//  livestream
//
//  Created by Calvin on 17/9/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetTalentListRequest.h"
#import "GetTalentStatusRequest.h"
@protocol TalentOnDemandManagerDelegate <NSObject>
@optional;
- (void)onGetTalentListSuccess:(BOOL)success Data:(NSArray<GetTalentItemObject *> *)array errMsg:(NSString *)errMsg errNum:(NSInteger)errnum;

- (void)onGetTalentStatus:(GetTalentStatusItemObject *)statusItemObject;

@end

@interface TalentOnDemandManager : NSObject

@property (nonatomic ,weak) id<TalentOnDemandManagerDelegate> delegate;

+ (instancetype)manager;

- (void)getTalentList:(NSString *)roomId;

- (void)getTalentStatusRoomId:(NSString *)roomId talentId:(NSString *)talentId;

@end
