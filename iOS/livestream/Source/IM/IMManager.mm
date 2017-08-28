//
//  IMManager.m
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "IMManager.h"
#import "LoginManager.h"

@interface IMManager() <IMLiveRoomManagerDelegate, LoginManagerDelegate>
@property (strong) LoginManager* loginManager;
@end

static IMManager* gManager = nil;
@implementation IMManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        self.client = [[ImClientOC alloc] init];
        [self.client addDelegate:self];
        NSMutableArray<NSString*>* urls = [NSMutableArray array];
        [urls addObject:@"ws://172.25.32.17:3006"];
        [self.client initClient:urls];
        
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [self.client removeDelegate:self];
    self.client = nil;
    
    [self.loginManager removeDelegate:self];
}

#pragma mark - IM回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"IMManager::onLogin( errType : %d, errmsg : %@ )", errType, errmsg);
    
    if ( errType == LCC_ERR_SUCCESS ) {
        self.isIMLogin = YES;
    }
    
    if( errType == LCC_ERR_CONNECTFAIL ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.client login:self.loginManager.loginItem.userId token:self.loginManager.loginItem.token];
        });
    }
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"IMManager::onLogout( errType : %d, errmsg : %@ )", errType, errmsg);
    
    if ( errType != LCC_ERR_SUCCESS ) {
        self.isIMLogin = NO;
    }
    
    if( errType != LCC_ERR_SVRBREAK ) {
        // 不是被服务器踢下线, 需要重新登录
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.client login:self.loginManager.loginItem.userId token:self.loginManager.loginItem.token];
        });
    }

}

- (void)onFansRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl country:(NSString* _Nonnull)country videoUrls:(NSArray<NSString*>* _Nonnull)videoUrls fansNum:(int)fansNum contribute:(int)contribute fansList:(NSArray<RoomTopFanItemObject*>* _Nonnull)fansList {
    NSLog(@"IMManager::onFansRoomIn( errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onFansRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"IMManager::onFansRoomOut( errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onGetRoomInfo:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg fansNum:(int)fansNum contribute:(int)contribute {
    NSLog(@"IMManager::onGetRoomInfo( errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onRecvRoomCloseFans:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName fansNum:(int)fansNum {
    NSLog(@"IMManager::onRecvRoomCloseFans( roomId : %@, userId : %@ )", roomId, userId);
}

- (void)onRecvRoomCloseBroad:(NSString* _Nonnull)roomId fansNum:(int)fansNum income:(int)income newFans:(int)newFans shares:(int)shares duration:(int)duration {
    NSLog(@"IMManager::onRecvRoomCloseBroad( roomId : %@, fansNum : %d )", roomId, fansNum);
}

- (void)onRecvFansRoomIn:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl {
    NSLog(@"IMManager::onRecvFansRoomIn( roomId : %@, userId : %@ )", roomId, userId);
}

- (void)onSendRoomMsg:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"IMManager::onSendRoomMsg( errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onRecvRoomMsg:(NSString* _Nonnull)roomId level:(int)level fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg {
    NSLog(@"IMManager::onRecvRoomMsg( roomId : %@, fromId : %@ )", roomId, fromId);
}

#pragma mark - HTTP登录回调
- (void)manager:(LoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject * _Nullable)loginItem errnum:(NSInteger)errnum errmsg:(NSString * _Nonnull)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"IMManager::onLogin( [HTTP %@], errnum : %ld )", success?@"Success":@"Fail", (long)errnum);
        if( success ) {
            // 开始登录IM
            [self.client login:loginItem.userId token:loginItem.token];
        }
    });
}

- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"IMManager::onLogout( [HTTP %@] )", kick?@"手动注销/被踢":@"Session超时");

        // 注销IM
        [self.client logout];
        
    });
}

#pragma mark - IM请求
- (void)sendRoomToastWithRoomID:(NSString *)roomId message:(NSString *)msg {
    
    SEQ_T reqId = [self.client getReqId];
    [self.client sendRoomToast:roomId token:self.loginManager.loginItem.token
                      nickName:self.loginManager.loginItem.nickName msg:msg reqId:reqId];
}

- (void)sendRoomMsgWithRoomID:(NSString *)roomId message:(NSString *)msg {
    
    SEQ_T reqId = [self.client getReqId];
    [self.client sendRoomMsg:self.loginManager.loginItem.token roomId:roomId
                    nickName:self.loginManager.loginItem.nickName msg:msg reqId:reqId];
}

- (void)sendFansRoomInWithRoomId:(NSString *)roomId {
    
    SEQ_T reqId = [self.client getReqId];
    [self.client fansRoomIn:self.loginManager.loginItem.token roomId:roomId reqId:reqId];
}

- (void)sendFansRoomoutWithRoomId:(NSString *)roomId {
    
    SEQ_T reqId = [self.client getReqId];
    [self.client fansRoomout:self.loginManager.loginItem.token roomId:roomId reqId:reqId];
}

- (void)sendRoomGiftWithRoomId:(NSString *)roomId giftId:(NSString *)giftId giftName:(NSString *)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)starNum multi_click_end:(int)endNum multi_click_id:(int)multi_click_id {
    
    SEQ_T reqId = [self.client getReqId];
    [self.client sendRoomGift:roomId token:self.loginManager.loginItem.token nickName:self.loginManager.loginItem.nickName giftId:giftId giftName:giftName giftNum:giftNum multi_click:multi_click multi_click_start:starNum multi_click_end:endNum multi_click_id:multi_click_id reqId:reqId];
}

- (void)sendRoomFavWithRoomId:(NSString *)roomId {
    
    SEQ_T reqId = [self.client getReqId];
    [self.client sendRoomFav:roomId token:self.loginManager.loginItem.token nickName:self.loginManager.loginItem.nickName reqId:reqId];
}

@end
