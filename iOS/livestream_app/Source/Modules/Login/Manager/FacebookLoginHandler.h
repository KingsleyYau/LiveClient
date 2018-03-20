//
//  FacebookLoginHandler.h
//  livestream
//
//  Created by Calvin on 2017/12/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILoginHandler.h"
#import <AccountSDK/AccountSDK.h>
#import "LiveLoginInfo.h"

@class FacebookLoginHandler;
@protocol FacebookLoginHandlerDelegate <NSObject>
@optional

- (void)facebookSDKLogin:(BOOL)success error:(NSError *)error;
- (void)facebookUserLogin:(BOOL)success sessionId:(NSString *)sessionId errnum:(HTTP_LCC_ERR_TYPE)errnum errMsg:(NSString *)errMsg;
@end

@interface FacebookLoginHandler : ILoginHandler

#pragma mark Getter
@property (nonatomic, readonly) NSString *token;
@property (nonatomic, weak) id<FacebookLoginHandlerDelegate> delegate;


- (instancetype)initWithPresentVC:(UIViewController *)vc;

- (BOOL)login:(LoginHandler)loginHandler;
- (BOOL)logout:(LogoutHandler)logoutHandler;

/**
 FackBookLoginViewController调用 (绑定邮箱)

 @param bingdingHandler 绑定回调
 @return 请求是否成功
 */
- (BOOL)bingdingHandler:(LoginHandler)bingdingHandler;

/**
 CompleteInformationViewController调用 (填写个人资料)

 @param registerHandler 填写回调
 @return 请求是否成功
 */
- (BOOL)registerHandler:(LoginHandler)registerHandler;

@end
