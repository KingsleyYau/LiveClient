//
//  AppStorePayHandler.m
//  demo
//
//  Created by  Samson on 6/13/16.
//  Copyright © 2016 Samson. All rights reserved.
//  AppStore支付处理器

#import "LSAppStorePayHandler.h"

@interface LSAppStorePayHandler() <LSAppStoreProductQueryHandlerDeleagte>
@property (nonatomic, weak) id<LSAppStorePayHandlerDeleagte> delegate;
@property (nonatomic, strong) LSAppStoreProductQueryHandler* queryHandler;
@property (nonatomic, strong) NSString* productId;
@property (nonatomic, strong) NSString* orderNo;
@property (nonatomic, strong) NSString* manId;

// 获取产品信息
- (void)requestProductData:(NSString* _Nonnull)productId;
// 获取request data分隔符
+ (NSString* _Nonnull)getRequestDataSeparator;
// 生成request data
+ (NSData* _Nonnull)getRequestData:(NSString* _Nonnull)manId orderNo:(NSString* _Nonnull)orderNo;
+ (NSString* _Nonnull)getRequestDataString:(NSString* _Nonnull)manId orderNo:(NSString* _Nonnull)orderNo;
@end

@implementation LSAppStorePayHandler
#pragma mark - 初始化
/**
 *  初始化
 *
 *  @param productId 产品ID
 *
 *  @return self
 */
- (id _Nonnull)initWithProductId:(NSString* _Nonnull)productId
                         orderNo:(NSString* _Nonnull)orderNo
                           manId:(NSString* _Nonnull)manId
                        delegate:(id<LSAppStorePayHandlerDeleagte> _Nonnull)delegate
{
    self = [super init];
    if (nil != self) {
        self.productId = productId;
        self.orderNo = orderNo;
        self.manId = manId;
        self.delegate = delegate;
        
        self.queryHandler = [[LSAppStoreProductQueryHandler alloc] init:self];
    }
    return self;
}

#pragma mark - 支付
/**
 *  开始支付
 *
 *  @return 支付调用是否成功
 */
- (void)pay
{
    [self requestProductData:self.productId];
}

/**
 *  获取产品信息
 *
 *  @param productId 产品ID
 */
- (void)requestProductData:(NSString* _Nonnull)productId
{
    BOOL result = NO;
    if ([productId length] > 0) {
        NSSet* productIdSet = [NSSet setWithObject:productId];
        result = [self.queryHandler query:productIdSet];
    }
    
    // 支付失败回调
    if (!result) {
        [self.delegate getProductFinish:self result:NO];
    }
}

/**
 *  产品查询完成回调(AppStoreProductQueryHandlerDeleagte)
 *
 *  @param handler  查询处理器
 *  @param products 查询结果(查询失败则返回nil)
 *
 */
- (void)getProductFinish:(LSAppStoreProductQueryHandler* _Nonnull)handler products:(NSArray<SKProduct*>* _Nullable)products
{
    BOOL result = NO;
    if ([products count] > 0)
    {
        // 查找对应product
        SKProduct* product = nil;
        for (SKProduct* proTemp in products)
        {
            if ([proTemp.productIdentifier isEqualToString:self.productId]) {
                product = proTemp;
                break;
            }
        }
        
        // 请求支付
        if (nil != product) {
            SKMutablePayment* myPayment = [[SKMutablePayment alloc] init];
            SKPayment* payment = [SKPayment paymentWithProduct:product];
            
            myPayment.applicationUsername = [LSAppStorePayHandler getRequestDataString:self.manId orderNo:self.orderNo];
            myPayment.productIdentifier = payment.productIdentifier;
            myPayment.quantity = payment.quantity;
            if( !SYSTEM_VERSION_LESS_THAN(@"8.3") ) {
                myPayment.simulatesAskToBuyInSandbox = payment.simulatesAskToBuyInSandbox;
            }
            
            [[SKPaymentQueue defaultQueue] addPayment:myPayment];
            
            result = YES;
        }
    }
    
    // 获取Product完成回调
    [self.delegate getProductFinish:self result:result];
}

#pragma mark - 其它
/**
 *  根据消费记录object获取订单号
 *
 *  @param transaction 消息记录object
 *
 *  @return 订单号
 */
+ (NSString* _Nonnull)getOrderNo:(SKPaymentTransaction* _Nonnull)transaction
{
    NSString* orderNo = @"";
    NSString* requestStr = transaction.payment.applicationUsername;
    NSArray* strings = [requestStr componentsSeparatedByString:[LSAppStorePayHandler getRequestDataSeparator]];
    
    int i = 0;
    for (NSString* temp in strings) {
        if (1 == i) {
            orderNo = temp;
        }
        i++;
    }
    return orderNo;
}

/**
 *  根据消费记录object获取男士ID
 *
 *  @param transaction 消息记录object
 *
 *  @return 男士ID
 */
+ (NSString* _Nonnull)getManId:(SKPaymentTransaction* _Nonnull)transaction
{
    NSString* manId = @"";
    NSString* requestStr = transaction.payment.applicationUsername;
    NSArray* strings = [requestStr componentsSeparatedByString:[LSAppStorePayHandler getRequestDataSeparator]];
    
    int i = 0;
    for (NSString* temp in strings) {
        if (0 == i) {
            manId = temp;
        }
        i++;
    }
    return manId;
}

// 获取request data分隔符
+ (NSString* _Nonnull)getRequestDataSeparator
{
    return @"-==-";
}

/**
 *  生成request data
 *
 *  @param manId   男士ID
 *  @param orderNo 订单号
 *
 *  @return requestData
 */
+ (NSData* _Nonnull)getRequestData:(NSString* _Nonnull)manId orderNo:(NSString* _Nonnull)orderNo
{
    NSString* requestStr = nil;
    requestStr = [NSString stringWithFormat:@"%@%@%@", manId, [LSAppStorePayHandler getRequestDataSeparator], orderNo];
    return [requestStr dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString* _Nonnull)getRequestDataString:(NSString* _Nonnull)manId orderNo:(NSString* _Nonnull)orderNo
{
    NSString* requestStr = nil;
    requestStr = [NSString stringWithFormat:@"%@%@%@", manId, [LSAppStorePayHandler getRequestDataSeparator], orderNo];
    return requestStr;
}
/**
 *  获取凭证
 *
 *  @return 凭证
 */
+ (NSString* _Nonnull)getReceipt
{
    NSString* receipt = @"";
    // 这里必须用app的目录,不能用直播的否则买点会找不到对应的路径
    NSURL* receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData* receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    return receipt;
}

/**
 *  完成支付处理
 *
 *  @param transaction 支付结果object
 */
+ (void)finish:(SKPaymentTransaction* _Nonnull)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
