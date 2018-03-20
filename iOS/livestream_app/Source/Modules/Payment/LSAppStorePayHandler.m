//
//  AppStorePayHandler.m
//  demo
//
//  Created by  Samson on 6/13/16.
//  Copyright © 2016 Samson. All rights reserved.
//  AppStore支付处理器

#import "LSAppStorePayHandler.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
@interface LSAppStorePayHandler()
@property (nonatomic, weak) id<AppStorePayHandlerDeleagte> delegate;
@property (nonatomic, strong) NSString* productId;
@property (nonatomic, strong) NSString* orderNo;
@property (nonatomic, strong) NSString* manId;

// 获取产品信息
- (void)requestProductData:(NSString* _Nonnull)productId;
// 获取request data分隔符
+ (NSString* _Nonnull)getRequestDataSeparator;
// 生成request data
+ (NSData* _Nonnull)getRequestData:(NSString* _Nonnull)manId orderNo:(NSString* _Nonnull)orderNo;
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
                        delegate:(id<AppStorePayHandlerDeleagte> _Nonnull)delegate
{
    self = [super init];
    if (nil != self) {
        self.productId = productId;
        self.orderNo = orderNo;
        self.manId = manId;
        self.delegate = delegate;
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
        NSSet* productSet = [NSSet setWithObject:productId];
        SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
        request.delegate = self;
        [request start];
        
        result = YES;
    }
    
    // 支付失败回调
    if (!result) {
        [self.delegate getProductFinish:self result:NO];
    }
}

/**
 *  获取产品信息回调(SKProductsRequestDelegate)
 *
 *  @param request  获取产品信息请求
 *  @param response 返回结果
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    BOOL result = NO;
    if ([response.products count] > 0)
    {
        // 查找对应product
        SKProduct* product = nil;
        for (SKProduct* proTemp in response.products)
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
            
            myPayment.applicationUsername = payment.applicationUsername;
            myPayment.productIdentifier = payment.productIdentifier;
            myPayment.quantity = payment.quantity;
            if( !SYSTEM_VERSION_LESS_THAN(@"8.3") ) {
                myPayment.simulatesAskToBuyInSandbox = payment.simulatesAskToBuyInSandbox;
            }
            myPayment.requestData = [LSAppStorePayHandler getRequestData:self.manId orderNo:self.orderNo];
            
            [[SKPaymentQueue defaultQueue] addPayment:myPayment];
            
            result = YES;
        }
    }
    
    // 获取Product完成回调
    [self.delegate getProductFinish:self result:result];
}

//查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    //菊花消失
    NSLog(@"请求苹果服务器失败%@",[error localizedDescription]);
}


/**
 *  交易完成回调(SKPaymentTransactionObserver)
 *
 *  @param queue        交易处理队列
 *  @param transactions 交易信息
 */
//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
//{
//    for (SKPaymentTransaction* tran in transactions)
//    {
//        NSString* receipt = nil;
//        NSString* orderNo = [[NSString alloc] initWithData:tran.payment.requestData encoding:NSUTF8StringEncoding];
//        switch (tran.transactionState) {
//            case SKPaymentTransactionStatePurchased: {
////                    receipt = [self getReceipt];
//                    NSLog(@"success, product:%@, orderNo:%@, receipt:%@", tran.payment.productIdentifier, orderNo, receipt);
//                }
//                break;
//            case SKPaymentTransactionStatePurchasing:
//                NSLog(@"purchasing, product:%@, orderNo:%@", tran.payment.productIdentifier, orderNo);
//                break;
//            case SKPaymentTransactionStateRestored:
//                NSLog(@"restored, product:%@, orderNo:%@", tran.payment.productIdentifier, orderNo);
//            case SKPaymentTransactionStateFailed:
//                NSLog(@"fail, product:%@, orderNo:%@", tran.payment.productIdentifier, orderNo);
//            case SKPaymentTransactionStateDeferred:
//                NSLog(@"deferred, product:%@, orderNo:%@", tran.payment.productIdentifier, orderNo);
//                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                break;
//
//            default:
//                break;
//        }
//
////        [self.delegate payFinish:self transaction:tran state:tran.transactionState receipt:receipt orderNo:orderNo];
//    }
//}

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
    NSString* requestStr = [[NSString alloc] initWithData:transaction.payment.requestData encoding:NSUTF8StringEncoding];
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
    NSString* requestStr = [[NSString alloc] initWithData:transaction.payment.requestData encoding:NSUTF8StringEncoding];
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

/**
 *  获取凭证
 *
 *  @return 凭证
 */
+ (NSString* _Nonnull)getReceipt
{
    NSString* receipt = @"";
    
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
