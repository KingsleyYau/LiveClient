//
//  UserHeadUrlManager.m
//  livestream
//
//  Created by randy on 2017/6/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "UserHeadUrlManager.h"

@implementation UserInfoItem

- (instancetype)init {

    self = [super init];
    
    if (self) {
        
        self.requestState = REQUESTNONE;
    }
    return self;
}


@end


@interface UserHeadUrlManager ()

#pragma mark - 接口管理器
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@property (nonatomic, strong) NSMutableArray* delegates;

@property (nonatomic, strong) NSMutableDictionary *userPhotoUrlDictionary;

@end


@implementation UserHeadUrlManager

+ (instancetype)manager {
    
    static UserHeadUrlManager *urlManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        urlManager = [[UserHeadUrlManager alloc]init];
        urlManager.userId = [[NSString alloc]init];
        urlManager.userPhotoUrlDictionary = [[NSMutableDictionary alloc]init];
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

#pragma mark - 请求用户图片URL
- (void)requestUserPhotoWithID:(NSString *)userId type:(PhotoType)type{
    
    UserInfoItem *item = [[UserInfoItem alloc]init];
    item.requestState = REQUESTSTART;
    item.userId = userId;
    item.userHeadUrl = nil;
    item.coverUrl = nil;
    [self.userPhotoUrlDictionary setObject:item forKey:userId];
    
    NSLog(@"UserHeadUrlManager::REQUESTSTAR item %@ %d",item.userHeadUrl ,item.requestState);
    
    GetLiveRoomUserPhotoRequest *request = [[GetLiveRoomUserPhotoRequest alloc]init];
    request.userId = userId;
    request.photoType = type;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull photoUrl){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            item.requestState = REQUESTEND;
            
            if (!photoUrl) {
                
                if (type == PHOTOTYPE_THUMB) {
                    item.userHeadUrl = photoUrl;
                }
                else{
                    item.coverUrl = photoUrl;
                }
                
            }
            // 数据存入字典
            [self.userPhotoUrlDictionary setObject:item forKey:userId];
            
            NSLog(@"UserHeadUrlManager::REQUESTEND item %@ %d",item.userHeadUrl ,item.requestState);
        });
        
    };
    [self.sessionManager sendRequest:request];
    
}


#pragma mark - 请求图片URL block回调
- (void)getLiveRoomUserPhotoRequestWithUserId:(NSString *)userId andType:(PhotoType)type requestEnd:(RequestUserPhotoEnd)requestEnd{

    UserInfoItem *item = [self.userPhotoUrlDictionary objectForKey:userId];
    
    if ( type == PHOTOTYPE_THUMB ) {

        if ( !item.userHeadUrl && item.requestState != REQUESTSTART ) {
            
            UserInfoItem *userItem = [[UserInfoItem alloc]init];
            userItem.requestState = REQUESTSTART;
            userItem.userId = userId;
            userItem.userHeadUrl = nil;
            userItem.coverUrl = nil;
            [self.userPhotoUrlDictionary setObject:userItem forKey:userId];
        
            GetLiveRoomUserPhotoRequest *request = [[GetLiveRoomUserPhotoRequest alloc]init];
            request.userId = userId;
            request.photoType = type;
            request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull photoUrl){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    userItem.requestState = REQUESTEND;
                    
                    if ( photoUrl && ![photoUrl isEqualToString:@""] ) {
                        
                        userItem.userHeadUrl = photoUrl;
                        requestEnd(userId,userItem);
                    }else{
                        
                        requestEnd(nil,nil);
                    }
                    [self.userPhotoUrlDictionary setObject:userItem forKey:userId];
                });
                
            };
            [self.sessionManager sendRequest:request];
            
        }else{
            requestEnd(userId,item);
        }

    }else if ( type == PHOTOTYPE_LARGE ){

        if ( !item.coverUrl && item.requestState != REQUESTSTART ) {

            [self getLiveRoomUserPhotoRequestWithUserId:userId andType:PHOTOTYPE_LARGE requestEnd:requestEnd];
            
        }else{
            requestEnd(userId,item);
        }
    }
}

- (void)requestUserPhotoWithID:(NSString *)userId type:(PhotoType)type requestEnd:(RequestUserPhotoEnd)requestEnd{

    UserInfoItem *item = [[UserInfoItem alloc]init];
    item.requestState = REQUESTSTART;
    item.userId = userId;
    item.userHeadUrl = nil;
    item.coverUrl = nil;
    [self.userPhotoUrlDictionary setObject:item forKey:userId];
    
    GetLiveRoomUserPhotoRequest *request = [[GetLiveRoomUserPhotoRequest alloc]init];
    request.userId = userId;
    request.photoType = type;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull photoUrl){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            item.requestState = REQUESTEND;
            
            if (!photoUrl) {
                
                if (type == PHOTOTYPE_THUMB) {
                    item.userHeadUrl = photoUrl;
                }
                else{
                    item.coverUrl = photoUrl;
                }
                requestEnd(userId,item);
                
            }else{
                
                requestEnd(nil,nil);
            }
            [self.userPhotoUrlDictionary setObject:item forKey:userId];
        });
        
    };
    [self.sessionManager sendRequest:request];
}

@end
