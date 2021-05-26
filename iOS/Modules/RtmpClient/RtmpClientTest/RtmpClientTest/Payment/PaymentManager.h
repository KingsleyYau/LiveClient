
//
//  PaymentManager.h
//  Cartoon
//
//  Created by Max on 2021/5/12.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^PaymentManagerSubscribeHandler)(BOOL success, NSString *message);
@interface PaymentManager : NSObject <SKPaymentTransactionObserver>
+ (PaymentManager *)manager;
- (id)init;
- (void)subscribe:(PaymentManagerSubscribeHandler)finishHandler;
- (void)restore:(PaymentManagerSubscribeHandler)finishHandler;
- (void)verify;
@end
