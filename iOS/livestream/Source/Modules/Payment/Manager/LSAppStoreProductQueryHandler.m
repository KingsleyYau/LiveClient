//
//  AppStoreProductQueryHandler.m
//  demo
//
//  Created by  Samson on 6/13/16.
//  Copyright © 2016 Samson. All rights reserved.
//  AppStore产品查询处理器(获取AppStore配置的产品信息)

#import "LSAppStoreProductQueryHandler.h"

@interface LSAppStoreProductQueryHandler() <SKProductsRequestDelegate>
@property (nonatomic, weak) id<LSAppStoreProductQueryHandlerDeleagte> delegate;

/** 产品请求 */
@property (nonatomic, strong)  SKProductsRequest* request;
@end

@implementation LSAppStoreProductQueryHandler

#pragma mark - 初始化
/**
 *  初始化
 *
 *  @param delegate 回调
 *
 *  @return self
 */
- (id _Nonnull)init:(id<LSAppStoreProductQueryHandlerDeleagte> _Nonnull)delegate
{
    self = [super init];
    if (nil != self) {
        self.delegate = delegate;
    }
    return self;
}


- (void)dealloc {
    [self.request cancel];
    self.request = nil;
}

#pragma mark - 查询处理
/**
 *  开始查询
 *
 *  @param productIdSet 产品ID数组
 *
 *  @return
 */
- (BOOL)query:(NSSet<NSString*>* _Nonnull)productIdSet
{
    BOOL result = NO;
    if ([productIdSet count] > 0) {
        self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdSet];
        self.request.delegate = self;
        [self.request start];
        
        result = YES;
    }
    return result;
}

/**
 *  获取产品信息回调(SKProductsRequestDelegate)
 *
 *  @param request  获取产品信息请求
 *  @param response 返回结果
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (nil != self.delegate) {
        [self.delegate getProductFinish:self products:response.products];
    }
}

@end
