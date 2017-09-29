//
//  LiveUrlHandler.h
//  livestream
//
//  Created by test on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LiveUrlTypeNone = 0,
    LiveUrlTypeQuickmatch,
    LiveUrlTypeEmf,
    LiveUrlTypeSetting,
    LiveUrlTypeLadyDetail,
    LiveUrlTypeChatLady,
    LiveUrlTypeLoveCall,
    LiveUrlTypeAdmirer,
    LiveUrlTypeContact,
    LiveUrlTypeHelps,
    LiveUrlTypeOverview,
    LiveUrlTypeChatlist,
    LiveUrlTypeBuycredit,
    LiveUrlTypeMyprofile,
    LiveUrlTypeChatinvite,
    LiveUrlTypeSendEMF
}LiveUrlType;


@class LiveUrlHandler;
@protocol LiveUrlHandlerDelegate <NSObject>
@optional

/**
 处理后台的链接跳转
 @param handler 链接管理器
 @param type    链接的类型
 */
- (void)liveUrlHandler:(LiveUrlHandler * _Nonnull)handler openWithModule:(LiveUrlType)type;

/**
 处理前台的链接跳转
 
 @param handler 链接管理器
 @param type 链接的类型
 */
- (void)liveUrlHandlerActive:(LiveUrlHandler * _Nonnull)handler openWithModule:(LiveUrlType)type;
@end
@interface LiveUrlHandler : NSObject
+ (instancetype _Nonnull)shareInstance;

/**
 委托
 */
@property (weak) id<LiveUrlHandlerDelegate> _Nullable delegate;

/**
 当前调用类型
 */
@property (assign, atomic, readonly) LiveUrlType type;

/**
 当前调用的参数
 */
@property (nonatomic,strong,readonly) NSString * _Nullable urlParameter;
/**
 是不是QN模块
 */
@property (nonatomic,assign) BOOL isQNModule;

/**
 解析调用过来的URL
 
 @param url 原始链接
 
 @return 处理结果[YES:成功/NO:失败]
 */
- (BOOL)handleOpenURL:(NSURL * _Nonnull)url;

/**
 处理调用过来的URL
 
 @return 处理结果[YES:成功/NO:不需要处理]
 */
- (BOOL)dealWithURL;

/**
 *  增加监听器
 *
 *  @param delegate 监听器
 */
- (void)addDelegate:(id<LiveUrlHandlerDelegate> _Nonnull)delegate;

/**
 *  移除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<LiveUrlHandlerDelegate> _Nonnull)delegate;
@end
