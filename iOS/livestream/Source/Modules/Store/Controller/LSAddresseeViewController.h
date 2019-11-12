//
//  LSAddresseeViewController.h
//  livestream
//
//  Created by Randy_Fan on 2019/10/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSListViewController.h"
#import "LSAddresseeOrderManager.h"

NS_ASSUME_NONNULL_BEGIN

@class LSAddresseeViewController;
@protocol LSAddresseeViewControllerDelegate <NSObject>

- (void)addCarGiftSuccess:(LSAddresseeViewController *)controller item:(LSAddresseeItem *)item;
- (void)checkoutTopage:(LSAddresseeViewController *)controller item:(LSAddresseeItem *)item errmsg:(NSString *)errmsg isDialog:(BOOL)isDialog;

@end

@interface LSAddresseeViewController : LSListViewController

@property (nonatomic, weak) id<LSAddresseeViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *giftID;
@property (nonatomic, strong) LSListViewController *superVC;

- (void)removeFromeView;

@end

NS_ASSUME_NONNULL_END
