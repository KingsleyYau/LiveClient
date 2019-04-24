//
//  LSIMLoginManager.m
//  livestream
//
//  Created by Calvin on 2018/11/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSIMLoginManager.h"
#import "LSLoginManager.h"
#import "LSImManager.h"
static LSIMLoginManager *imLoginManager = nil;


@interface LSIMLoginManager ()<IMLiveRoomManagerDelegate,LoginManagerDelegate>
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, copy) AppLoginFinishHandler loginBlock;
@property (nonatomic, assign) BOOL isFirstLogin;
@end

@implementation LSIMLoginManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!imLoginManager) {
            imLoginManager = [[[self class] alloc] init];
        }
    });
    return imLoginManager;
}

- (id)init {
    if (self = [super init]) {
        
        self.delegates = [NSMutableArray array];
        
        [[LSLoginManager manager] addDelegate:self];
        [[LSImManager manager].client addDelegate:self];
        
        _status = NONE;
    }
    return self;
}

- (void)addDelegate:(id<LSIMLoginManagerDelegate>)delegate {
    @synchronized(self) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<LSIMLoginManagerDelegate>)delegate {
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LSIMLoginManagerDelegate> item = (id<LSIMLoginManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}

- (LoginStatus)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode userId:(NSString *)userId token:(NSString *)token handler:(AppLoginFinishHandler)handler {
    self.loginBlock = handler;
    self.isFirstLogin = YES;
    _status = LOGINING;
    return [[LSLoginManager manager]login:user password:password checkcode:checkcode userId:userId token:token];
}

- (void)logout:(LogoutType)type {
    _status = NONE;
    [[LSLoginManager manager]logout:type];
}

- (void)getCheckCodeIsMust:(BOOL)isMust handler:(AppGetCheckCodeFinishHandler)handler {
    [[LSLoginManager manager]getCheckCodeIsMust:isMust handler:handler];
}

- (BOOL)loginCheck:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode handler:(AppLoginFinishHandler)handler {
    
    return [[LSLoginManager manager]loginCheck:user password:password checkcode:checkcode handler:handler];
}

- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!success) {
            _status = NONE;
            if (self.loginBlock) {
                ErrorType errType = success ? ErrorType_Success : ErrorType_UnknowError;
                if (!success) {
                    if (errnum == HTTP_LCC_ERR_CONNECTFAIL) {
                        // TODO:网络错误
                        errType = ErrorType_NetworkError;
                    } else if (errnum == HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION || errnum == HTTP_LCC_ERR_PLOGIN_VERIFICATION_WRONG) {
                        // TODO:验证码错误
                        errType = ErrorType_CheckCodeError;
                    } else if (errnum == HTTP_LCC_ERR_PLOGIN_PASSWORD_INCORRECT) {
                        // TODO:密码错误
                        errType = ErrorType_PasswordError;
                    } else {
                        // TODO:其他错误
                        errType = ErrorType_UnknowError;
                    }
                }
                self.loginBlock(success, errType, errmsg, [LSLoginManager manager].manId);
            }
        }
    });
}

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isFirstLogin) {
            self.isFirstLogin = NO;
            BOOL isIMLogin = errType==LCC_ERR_SUCCESS?YES:NO;
            NSLog(@"LSIMLoginManager::IM onLogin( [IM登录, %@], manId : %@, token : %@, errType : %d, errmsg : %@ )", BOOL2SUCCESS(isIMLogin), [LSLoginManager manager].manId, [LSLoginManager manager].token, errType, errmsg);
            if (isIMLogin) {
                _status = LOGINED;
                if (self.loginBlock) {
                    self.loginBlock(isIMLogin, ErrorType_Success, @"",  [LSLoginManager manager].manId);
                }
            }
            else{
                [self logout:LogoutTypeActive];
                if (self.loginBlock) {
                    ErrorType errnum = ErrorType_UnknowError;
                    if (errType == LCC_ERR_CONNECTFAIL) {
                        // TODO:网络错误
                        errnum = ErrorType_NetworkError;
                        
                    }  else {
                        // TODO:其他错误
                        errnum = ErrorType_UnknowError;
                    }
                    self.loginBlock(isIMLogin, errnum, errmsg.length > 0?errmsg:NSLocalizedString(@"NetworkError", nil),  [LSLoginManager manager].manId);
                }
            }
        }
    });

}

@end
