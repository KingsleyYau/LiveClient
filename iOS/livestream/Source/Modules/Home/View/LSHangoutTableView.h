//
//  LSHangoutTableView.h
//  livestream
//
//  Created by Calvin on 2019/1/16.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSHangoutListItemObject.h"
NS_ASSUME_NONNULL_BEGIN
@class LSHangoutTableView;
@protocol LSHangoutTableViewDelegate <NSObject>
@optional
//- (void)tableView:(HotTableView *)tableView didShowItem:(LiveRoomInfoItemObject *)item;
- (void)tableView:(LSHangoutTableView *)tableView didShowItem:(NSIndexPath *)index;
- (void)tableView:(LSHangoutTableView *)tableView didClickHangout:(LSHangoutListItemObject *)item;
- (void)tableView:(LSHangoutTableView *)tableView didClickHangoutFriendCardMsg:(LSFriendsInfoItemObject *)item;
@end

@interface LSHangoutTableView : UITableView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet id <LSHangoutTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;

@end

NS_ASSUME_NONNULL_END
