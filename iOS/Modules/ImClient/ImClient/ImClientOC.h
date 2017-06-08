//
//  ImClientOC.h
//  ImClient_iOS_t
//
//  Created by  Samson on 27/05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMLiveRoomManagerListener.h"

@interface ImClientOC : NSObject
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;
#pragma mark - 委托
/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<IMLiveRoomManagerDelegate> _Nonnull)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<IMLiveRoomManagerDelegate> _Nonnull)delegate;

- (BOOL)initClient:(NSArray<NSString*>* _Nonnull)urls;
- (BOOL)login:(NSString* _Nonnull)userId token:(NSString* _Nonnull)token;
- (BOOL)logout;
- (BOOL)fansRoomIn:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId;
- (BOOL)fansRoomout:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId;
- (BOOL)getRoomInfo:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId;
- (BOOL)sendRoomMsg:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg;

@end
