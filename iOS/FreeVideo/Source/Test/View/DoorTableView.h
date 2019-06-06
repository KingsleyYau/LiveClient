//
//  DoorTableView.h
//  livestream
//
//  Created by Created by Max on 16/2/15.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveRoomInfoItemObject.h"

@class DoorTableView;
@class LiveRoomInfoItemObject;
@protocol DoorTableViewDelegate <NSObject>
@optional
- (void)tableView:(DoorTableView *)tableView didShowItem:(LiveRoomInfoItemObject *)item;
- (void)tableView:(DoorTableView *)tableView didSelectItem:(LiveRoomInfoItemObject *)item;
- (void)tableView:(DoorTableView *)tableView willDeleteItem:(LiveRoomInfoItemObject *)item;
- (void)tableView:(DoorTableView *)tableView didViewItem:(LiveRoomInfoItemObject *)item;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

@interface DoorTableView : UITableView <UITableViewDataSource, UITableViewDelegate> {
}

@property (nonatomic, weak) IBOutlet id<DoorTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) BOOL canDeleteItem;

@end
