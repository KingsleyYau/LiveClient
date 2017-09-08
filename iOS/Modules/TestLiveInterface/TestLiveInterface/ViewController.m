//
//  ViewController.m
//  TestLiveInterface
//
//  Created by alex shum on 17/9/4.
//  Copyright © 2017年 alex shum. All rights reserved.
//

#import "ViewController.h"
#import "LoginManager.h"
#import "RequestManager.h"
#import "SessionRequestManager.h"
#import "IMManager.h"
#import "GetAnchorListRequest.h"
#import "GetFollowListRequest.h"
#import "GetRoomInfoRequest.h"
#import "LiveFansListRequest.h"
#import "GetAllGiftListRequest.h"
#import "GetGiftListByUserIdRequest.h"
#import "GetGiftDetailRequest.h"
#import "GetEmoticonListRequest.h"
#import "GetInviteInfoRequest.h"

#define ALEX_TOKEN @"Alex_Jd4i0p5A30aH"

@interface ViewController () <LoginManagerDelegate>

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) SessionRequestManager* sessionManager;
@property (nonatomic, strong) LoginManager *loginManager;
@property (nonatomic, strong) IMManager *imManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 初始化Http登陆管理器
    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];
    
    // 初始化IM管理器
    self.imManager = [IMManager manager];

    // 设置接口管理类属性
    
    RequestManager* manager = [RequestManager manager];
    //[manager setWebSite:@"http://172.25.32.17:3107"];
    [manager setWebSite:@"http://192.168.88.17:3107"];
    
    self.sessionManager = [SessionRequestManager manager];
    //[self getFollowListRequest];
    
    self.token = ALEX_TOKEN;
    [self start:self.token];
    
    
}

- (BOOL)start:(NSString *)token {
    BOOL bFlag = YES;
    
    NSLog(@"LiveModule::start( token : %@ )", token);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.token = token;
        [self.loginManager login:self.token];
    });
    
    return bFlag;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HTTP登录回调
- (void)manager:(LoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject *_Nullable)loginItem errnum:(NSInteger)errnum errmsg:(NSString *_Nonnull)errmsg {
    if (success) {
        [self getListRequest];
        [self getFollowListRequest];
        [self getroomInfoRequest];
        
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 继续登陆
            if( self.token ) {
                [self.loginManager login:self.token];
            }
        });
    }
}

- (void)manager:(LoginManager *_Nonnull)manager onLogout:(BOOL)kick {
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

- (BOOL)getListRequest {
    
    BOOL bFlag = NO;
    
    GetAnchorListRequest *request = [[GetAnchorListRequest alloc] init];

    // 每页最大纪录数
    request.start = 1;
    request.step = 30;
    
    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                //LiveRoomInfoItemObject * item = [array objectAtIndex:0];
                [self liveFansListRequest:@"3"];
                [self getGiftListByUserIdRequest:@"3"];
                
            } else {

            }
            
        });
        
    };
    
    bFlag = [self.sessionManager sendRequest:request];
    
    return bFlag;
}

- (BOOL)getFollowListRequest {
    
    BOOL bFlag = NO;
    
    GetFollowListRequest *request = [[GetFollowListRequest alloc] init];
    
    // 每页最大纪录数
    request.start = 1;
    request.step = 10;
    
    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<FollowItemObject *>* _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                
                
            } else {
                
            }
            
        });
        
    };
    
    bFlag = [self.sessionManager sendRequest:request];
    
    return bFlag;
}

- (BOOL)getroomInfoRequest {
    
    BOOL bFlag = NO;
    
    GetRoomInfoRequest *request = [[GetRoomInfoRequest alloc] init];
    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, RoomInfoItemObject* _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                
                
            } else {
                
            }
            
        });
        
    };
    
    bFlag = [self.sessionManager sendRequest:request];
    
    return bFlag;
}

- (BOOL)liveFansListRequest:(NSString *)roomId {
    
    BOOL bFlag = NO;
    
    LiveFansListRequest *request = [[LiveFansListRequest alloc] init];
    request.roomId = roomId;
    request.page = 0;
    request.number = 10;
    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<ViewerFansItemObject *>* _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                [self getAllGiftListRequest];
                
            } else {
                
            }
            
        });
        
    };
    
    bFlag = [self.sessionManager sendRequest:request];
    
    return bFlag;
}

- (BOOL)getAllGiftListRequest {
    
    BOOL bFlag = NO;
    
    GetAllGiftListRequest *request = [[GetAllGiftListRequest alloc] init];
    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<GiftInfoItemObject *>* _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                
                
            } else {
                
            }
            
        });
        
    };
    
    bFlag = [self.sessionManager sendRequest:request];
    
    return bFlag;
}

- (BOOL)getGiftListByUserIdRequest:(NSString*)roomId {
    
    BOOL bFlag = NO;
    
    GetGiftListByUserIdRequest *request = [[GetGiftListByUserIdRequest alloc] init];
    request.roomId = roomId;
    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<GiftWithIdItemObject *>* _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                [self getGiftDetailRequest:@"1001"];
                [self getEmoticonListRequest];
                
            } else {
                
            }
            
        });
        
    };
    
    bFlag = [self.sessionManager sendRequest:request];
    
    return bFlag;
}

- (BOOL)getGiftDetailRequest:(NSString*)roomId {
    
    BOOL bFlag = NO;
    
    GetGiftDetailRequest *request = [[GetGiftDetailRequest alloc] init];
    request.giftId = roomId;
    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, GiftInfoItemObject * _Nullable item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                
                
            } else {
                
            }
            
        });
        
    };
    
    bFlag = [self.sessionManager sendRequest:request];
    
    return bFlag;
}

- (BOOL)getEmoticonListRequest {
    
    BOOL bFlag = NO;
    
    GetEmoticonListRequest *request = [[GetEmoticonListRequest alloc] init];
    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<EmoticonItemObject*>* _Nullable item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                [self getInviteInfoRequest:@"1"];
                
            } else {
                
            }
            
        });
        
    };
    
    bFlag = [self.sessionManager sendRequest:request];
    
    return bFlag;
}

- (BOOL)getInviteInfoRequest:(NSString*)invitationId {
    
    BOOL bFlag = NO;
    
    GetInviteInfoRequest *request = [[GetInviteInfoRequest alloc] init];
    request.inviteId = invitationId;
    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, InviteIdItemObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                
                
            } else {
                
            }
            
        });
        
    };
    
    bFlag = [self.sessionManager sendRequest:request];
    
    return bFlag;
}

@end
