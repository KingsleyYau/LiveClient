//
//  LSDeliveryTableView.h
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSDeliveryListTableViewCell.h"
#import "LSDeliveryItemObject.h"

NS_ASSUME_NONNULL_BEGIN

@class LSDeliveryTableView;
@protocol LSDeliveryTableViewDelegate <NSObject>
@optional
- (void)lsDeliveryTableView:(LSDeliveryTableView *)tableView didClickGiftInfo:(LSFlowerGiftBaseInfoItemObject *)item;
- (void)lsDeliveryTableViewDidClickStatusAction:(LSDeliveryTableView *)tableView;
- (void)lsDeliveryTableView:(LSDeliveryTableView *)tableView DidClickAchorIcon:(LSDeliveryItemObject *)item;
@end

@interface LSDeliveryTableView : LSTableView<UITableViewDataSource,UITableViewDelegate,LSDeliveryListTableViewCellDelegate>
@property (nonatomic, weak)  id <LSDeliveryTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;
@end

NS_ASSUME_NONNULL_END
