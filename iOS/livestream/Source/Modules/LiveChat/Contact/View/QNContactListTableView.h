//
//  LSContactListTableView.h
//  livestream
//
//  Created by test on 2018/11/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNContactListTableViewCell.h"

@class QNContactListTableView;
@protocol QNContactListTableViewDelegate <NSObject>
@optional
//cell点击回调
- (void)tableView:(QNContactListTableView *)tableView didSelectContact:(LSLadyRecentContactObject *)item;

@end

@interface QNContactListTableView : LSTableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak)  id<QNContactListTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) BOOL canDeleteItem;

@end
