//
//  FollowTableView.h
//  livestream
//
//  Created by test on 2017/9/8.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowItemObject.h"
@class FollowTableView;
@class FollowItemObject;
@protocol FollowViewDelegate <NSObject>
@optional
- (void)followTableView:(FollowTableView *)tableView didShowItem:(FollowItemObject *)item;
- (void)followTableView:(FollowTableView *)tableView didSelectItem:(FollowItemObject *)item;
- (void)followTableView:(FollowTableView *)tableView willDeleteItem:(FollowItemObject *)item;

/** 免费的公开直播间 */
- (void)tableView:(FollowTableView *)tableView didPublicViewFreeBroadcast:(NSInteger)index;
/** 付费的公开直播间 */
- (void)tableView:(FollowTableView *)tableView didPublicViewVipFeeBroadcast:(NSInteger)index;
/** 普通的私密直播间 */
- (void)tableView:(FollowTableView *)tableView didPrivateStartBroadcast:(NSInteger)index;
/** 豪华的私密直播间 */
- (void)tableView:(FollowTableView *)tableView didStartVipPrivteBroadcast:(NSInteger)index;


/** 预约的私密直播间 */
- (void)tableView:(FollowTableView *)tableView didBookPrivateBroadcast:(NSInteger)index;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

@interface FollowTableView : UITableView<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet id <FollowViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) BOOL canDeleteItem;
@end
