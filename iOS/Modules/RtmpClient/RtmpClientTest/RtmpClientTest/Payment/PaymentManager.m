
//
//  PaymentManager.m
//  Cartoon
//
//  Created by Max on 2021/5/12.
//

#import "PaymentManager.h"
#import "AppDelegate.h"

#define VERIFY_URL_SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
#define VERIFY_URL_REAL @"https://buy.itunes.apple.com/verifyReceipt"
#define VERIFY_URL IS_SANDBOX?VERIFY_URL_SANDBOX:VERIFY_URL_REAL
#define PRODUCT_SUBSCRIBE_ID @"SL_SUB_00001"
#define PRODUCT_SUBSCRIBE_AUTHKEY @"df8f96b9730d4b21abf96081b67c5d8c"

@interface PaymentManager () <SKProductsRequestDelegate>
@property (strong) PaymentManagerSubscribeHandler restoreHandler;
@property (strong) NSMutableDictionary<NSNumber *, PaymentManagerSubscribeHandler> *handlerDict;
@end

@implementation PaymentManager
+ (PaymentManager *)manager {
    static PaymentManager *manager = nil;
    if (nil == manager) {
        manager = [[PaymentManager alloc] init];
    }
    return manager;
}

- (id)init {
    self = [super init];
    if (nil != self) {
        // 加入AppStore支付回调
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//        [self checkTransaction];
        self.restoreHandler = nil;
        self.handlerDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    // 退出AppStore支付回调
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)subscribe:(PaymentManagerSubscribeHandler)subscribeHandler {
    NSSet *set = [NSSet setWithObject:PRODUCT_SUBSCRIBE_ID];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
    
    @synchronized (self) {
        NSNumber *key = [NSNumber numberWithInteger:[request hash]];
        self.handlerDict[key] = subscribeHandler;
        NSLog(@"product: %@, request: %@", PRODUCT_SUBSCRIBE_ID, key);
    }
}

- (void)restore:(PaymentManagerSubscribeHandler)restoreHandler {
    self.restoreHandler = restoreHandler;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    NSLog(@"");
}

- (void)verify{
    NSURL *receiveUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiveData = [NSData dataWithContentsOfURL:receiveUrl];
    NSString *receiveString = [receiveData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    if (receiveString.length > 0) {
        NSURLSession *session = [NSURLSession sharedSession];
        NSString *url = VERIFY_URL;
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        req.HTTPMethod = @"POST";
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

        NSDictionary *dict = @{
            @"receipt-data" : receiveString,
            @"password" : PRODUCT_SUBSCRIBE_AUTHKEY
        };
        NSError *error;
        NSData *reqData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        [req setValue:[NSString stringWithFormat:@"%d", (int)[reqData length]] forHTTPHeaderField:@"Content-Length"];
        [req setHTTPBody:reqData];

        NSLog(@"url: %@", url);
        NSURLSessionDataTask *task = [session dataTaskWithRequest:req
                                                completionHandler:^(NSData *__nullable data, NSURLResponse *__nullable response, NSError *__nullable error) {
                                                    if (!error) {
                                                        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                                                        NSLog(@"json: %@", json);
                                                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                        NSNumber *status = dict[@"status"];
                                                        if ([status isEqualToNumber:@0]) {
                                                            NSArray *latest_receipt_info = dict[@"latest_receipt_info"];
                                                            NSDictionary *latest_receipt_info_dict = [latest_receipt_info firstObject];
                                                            NSString *expires_date_ms = latest_receipt_info_dict[@"expires_date_ms"];
                                                            NSDate *now = [NSDate date];
                                                            long long second = [expires_date_ms longLongValue] / 1000;
                                                            NSDate *expire = [NSDate dateWithTimeIntervalSince1970:second];
                                                            if (NSOrderedAscending == [now compare:expire]) {
                                                                // In Subscribe
                                                                AppShareDelegate().subscribed = YES;
                                                            } else {
                                                                AppShareDelegate().subscribed = NO;
                                                            }
                                                            NSLog(@"now: %@, expire: %@, subscribed: %@", now, expire, BOOL2YES(AppShareDelegate().subscribed));
                                                        } else {
                                                            NSLog(@"error: %@", status);
                                                        }
                                                    } else {
                                                        NSLog(@"error: %@", error);
                                                    }
                                                }];
        [task resume];
    }

}

#pragma mark - Appstore
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"products.count: %d", (int)response.products.count);
    NSNumber *key = [NSNumber numberWithInteger:[request hash]];
    NSLog(@"request: %@", key);
    
    if (response.products) {
        for (SKProduct *product in response.products) {
            NSLog(@"product: %@, %@, %@", product.localizedTitle, product.price, product.priceLocale.localeIdentifier);
            
            SKPayment *payment = [SKPayment paymentWithProduct:product];
//            SKMutablePayment *paymentNew = [[SKMutablePayment alloc] init];
            
            @synchronized (self) {
                PaymentManagerSubscribeHandler subscribeHandler = self.handlerDict[key];
                NSNumber *payKey = nil;
                if (subscribeHandler) {
                    self.handlerDict[key] = nil;
                    payKey = [NSNumber numberWithInteger:[payment hash]];
                    self.handlerDict[payKey] = subscribeHandler;
                }
                NSLog(@"payment: %@, payKey: %@, subscribeHandler: %@", payment, payKey, subscribeHandler);
            }
            
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            return;
        }
    }
    
    @synchronized (self) {
        PaymentManagerSubscribeHandler subscribeHandler = self.handlerDict[key];
        if (subscribeHandler) {
            subscribeHandler(NO, @"Get product fail. Please try again.");
            self.handlerDict[key] = nil;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    NSLog(@"transactions.count: %d", (int)transactions.count);
    BOOL bFlag = NO;
    
    for (SKPaymentTransaction *tran in transactions) {
        NSLog(@"tran: %@, state: %d", tran, (int)tran.transactionState);
        if (tran.transactionState == SKPaymentTransactionStatePurchased ||
            tran.transactionState == SKPaymentTransactionStateRestored
            ) {
            [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            bFlag = YES;
            
            @synchronized (self) {
                NSNumber *payKey = [NSNumber numberWithInteger:[tran.payment hash]];
                PaymentManagerSubscribeHandler subscribeHandler = self.handlerDict[payKey];
                NSLog(@"payment: %@, payKey: %@, subscribeHandler: %@", tran.payment, payKey, subscribeHandler);
                if (subscribeHandler) {
                    subscribeHandler(YES, @"Subscribe success.");
                    self.handlerDict[payKey] = nil;
                }
            }
            
        } else if (tran.transactionState == SKPaymentTransactionStateFailed) {
            [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            
            @synchronized (self) {
                NSNumber *payKey = [NSNumber numberWithInteger:[tran.payment hash]];
                PaymentManagerSubscribeHandler subscribeHandler = self.handlerDict[payKey];
                NSLog(@"payment: %@, payKey: %@, subscribeHandler: %@", tran.payment, payKey, subscribeHandler);
                if (subscribeHandler) {
                    subscribeHandler(NO, @"Subscribe fail.");
                    self.handlerDict[payKey] = nil;
                }
            }
        }
    }
    
    if (bFlag) {
        [self verify];
    }
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2)) {
    NSLog(@"error: %@", error);
    if (self.restoreHandler) {
        self.restoreHandler(NO, [NSString stringWithFormat:@"Restore fail. %@", error.description]);
        self.restoreHandler = nil;
    }
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2)) {
    NSLog(@"");
    if (self.restoreHandler) {
        self.restoreHandler(YES, @"Restore finish.");
        self.restoreHandler = nil;
    }
}

- (void)checkTransaction {
    NSArray *transactions = [SKPaymentQueue defaultQueue].transactions;
    NSLog(@"transactions.count: %d", (int)transactions.count);
    for (SKPaymentTransaction *tran in transactions) {
        NSLog(@"tran: %@, state: %d", tran, (int)tran.transactionState);
        if (tran.transactionState == SKPaymentTransactionStatePurchased ||
            tran.transactionState == SKPaymentTransactionStateRestored
            ) {
            [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            [self verify];
        } else if (tran.transactionState == SKPaymentTransactionStateFailed) {
            [[SKPaymentQueue defaultQueue] finishTransaction:tran];
        }
    }
}
@end
