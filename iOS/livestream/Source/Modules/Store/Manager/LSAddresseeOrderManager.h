//
//  LSAddresseeOrderManager.h
//  livestream
//
//  Created by Randy_Fan on 2019/10/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSAddresseeItem.h"
#import "LSRequestManager.h"

NS_ASSUME_NONNULL_BEGIN

@class LSAddresseeOrderManager;
typedef void (^GetAddresseeFinshtHandler)(BOOL success, NSArray<LSAddresseeItem *> *anchorList, NSString *errmsg);
typedef void (^AddCartGiftFinshtHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

@interface LSAddresseeOrderManager : NSObject

+ (instancetype)manager;

- (void)removeAddressee;

- (void)getAddresseeList:(GetAddresseeFinshtHandler)finish;

- (void)addCartGift:(NSString *)giftId anchorId:(NSString *)anchorId finish:(AddCartGiftFinshtHandler)finish;

@end

NS_ASSUME_NONNULL_END
