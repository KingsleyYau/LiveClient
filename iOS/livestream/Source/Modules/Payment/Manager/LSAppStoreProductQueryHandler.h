//
//  AppStoreProductQueryHandler.h
//  demo
//
//  Created by  Samson on 6/13/16.
//  Copyright © 2016 Samson. All rights reserved.
//  AppStore产品查询处理器(获取AppStore配置的产品信息)

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol LSAppStoreProductQueryHandlerDeleagte;

@interface LSAppStoreProductQueryHandler : NSObject
#pragma mark - 初始化
/**
 *  初始化
 *
 *  @param delegate 回调
 *
 *  @return self
 */
- (id _Nonnull)init:(id<LSAppStoreProductQueryHandlerDeleagte> _Nonnull)delegate;

#pragma mark - 查询处理
/**
 *  开始查询
 *
 *  @param productIdSet 产品ID数组
 *
 *  @return 是否请求成功
 */
- (BOOL)query:(NSSet<NSString*>* _Nonnull)productIdSet;
@end

@protocol LSAppStoreProductQueryHandlerDeleagte <NSObject>
@required
/**
 *  查询完成回调
 *
 *  @param handler  查询处理器
 *  @param products 查询结果(查询失败则返回nil)
 */
- (void)getProductFinish:(LSAppStoreProductQueryHandler* _Nonnull)handler products:(NSArray<SKProduct*>* _Nullable)products;
@end
