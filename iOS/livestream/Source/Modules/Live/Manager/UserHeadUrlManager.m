//
//  UserHeadUrlManager.m
//  livestream
//
//  Created by randy on 2017/6/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "UserHeadUrlManager.h"

@interface UserHeadUrlManager ()

#pragma mark - 接口管理器
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@end


@implementation UserHeadUrlManager

+ (instancetype)manager {
    
    static UserHeadUrlManager *urlManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        urlManager = [[UserHeadUrlManager alloc]init];
        
    });
    return urlManager;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        _userId = nil;
        _photoUrl = nil;
        
        self.sessionManager = [SessionRequestManager manager];
    }
    
    return self;
}

- (NSString *)getLiveRoomUserPhotoRequestWithUserId:(NSString *)userId andType:(PhotoType)type {
    
    if (![self.userId isEqualToString:userId]) {
        
        GetLiveRoomUserPhotoRequest *request = [[GetLiveRoomUserPhotoRequest alloc]init];
        request.userId = userId;
        request.photoType = type;
        request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull photoUrl){
            
            dispatch_sync(dispatch_get_main_queue(), ^{
               
                if (success) {
                    
                    self.photoUrl = photoUrl;
                    self.userId = userId;
                    
                }else{
                    
                    _photoUrl = nil;
                    _userId = nil;
                }
                
            });
            
        };
        [self.sessionManager sendRequest:request];
    }
    return _photoUrl;
}

@end
