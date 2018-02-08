//
//  TalentOnDemandManager.m
//  livestream
//
//  Created by Calvin on 17/9/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TalentOnDemandManager.h"

@interface TalentOnDemandManager ()

@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@end

@implementation TalentOnDemandManager

+ (instancetype)manager{
    
    static TalentOnDemandManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TalentOnDemandManager alloc] init];
        
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessionManager = [LSSessionRequestManager manager];
   
    }
    return self;
}

- (void)getTalentList:(NSString *)roomId
{
    GetTalentListRequest * request = [[GetTalentListRequest alloc]init];
    request.roomId = roomId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * errmsg, NSArray<GetTalentItemObject *> * array)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if ([self.delegate respondsToSelector:@selector(onGetTalentListSuccess:Data:errMsg:errNum:)]) {
                [self.delegate onGetTalentListSuccess:(BOOL)success Data:array errMsg:errmsg errNum:errnum];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getTalentStatusRoomId:(NSString *)roomId talentId:(NSString *)talentId
{
    GetTalentStatusRequest * request = [[GetTalentStatusRequest alloc]init];
    request.roomId = roomId;
    request.talentInviteId = talentId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, GetTalentStatusItemObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                if ([self.delegate respondsToSelector:@selector(onGetTalentStatus:)]) {
                    [self.delegate onGetTalentStatus:item];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}
@end
