//
//  LSDeliveryListViewController.h
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSViewController.h"
#import "LSDeliveryTableView.h"

NS_ASSUME_NONNULL_BEGIN
@class LSDeliveryListViewController;
@protocol LSDeliveryListViewControllerDelegate <NSObject>
@optional
- (void)lsDeliveryListViewControllerDidShowGiftStore:(LSDeliveryListViewController *)vc;
@end

@interface LSDeliveryListViewController : LSListViewController
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet LSDeliveryTableView *tableView;
/** 代理 */
@property (nonatomic, weak) id<LSDeliveryListViewControllerDelegate> deliveryDelegate;

@end

NS_ASSUME_NONNULL_END
