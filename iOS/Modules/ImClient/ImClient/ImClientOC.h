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

/**
 *  获取一个请求seq
 *
 *
 *  @return 请求序列号
 */
- (SEQ_T)getReqId;

- (BOOL)initClient:(NSArray<NSString*>* _Nonnull)urls;
- (BOOL)login:(NSString* _Nonnull)userId token:(NSString* _Nonnull)token;
- (BOOL)logout;
- (BOOL)fansRoomIn:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId reqId:(SEQ_T)reqId;
- (BOOL)fansRoomout:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId reqId:(SEQ_T)reqId;
- (BOOL)getRoomInfo:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId reqId:(SEQ_T)reqId;
- (BOOL)fansShutUp:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId timeOut:(int)timeOut reqId:(SEQ_T)reqId;
- (BOOL)fansKickOffRoom:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId reqId:(SEQ_T)reqId;
- (BOOL)sendRoomMsg:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg reqId:(SEQ_T)reqId;

- (BOOL)sendRoomFav:(NSString* _Nonnull)roomId token:(NSString* _Nonnull)token nickName:(NSString* _Nonnull)nickName reqId:(SEQ_T)reqId;
- (BOOL)sendRoomGift:(NSString* _Nonnull)roomId token:(NSString* _Nonnull)token nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id reqId:(SEQ_T)reqId;
- (BOOL)sendRoomToast:(NSString* _Nonnull)roomId token:(NSString* _Nonnull)token nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg reqId:(SEQ_T)reqId;

@end
