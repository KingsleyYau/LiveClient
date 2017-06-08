//
//  HotTableView.h
//  livestream
//
//  Created by Created by Max on 16/2/15.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveRoomInfoItemObject.h"

@class HotTableView;
@class LiveRoomInfoItemObject;
@protocol HotTableViewDelegate <NSObject>
@optional
- (void)tableView:(HotTableView *)tableView didShowItem:(LiveRoomInfoItemObject *)item;
- (void)tableView:(HotTableView *)tableView didSelectItem:(LiveRoomInfoItemObject *)item;
- (void)tableView:(HotTableView *)tableView willDeleteItem:(LiveRoomInfoItemObject *)item;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

@interface HotTableView : UITableView <UITableViewDataSource, UITableViewDelegate>{
    
}

@property (nonatomic, weak) IBOutlet id <HotTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) BOOL canDeleteItem;

@end
