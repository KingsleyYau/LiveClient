//
//  LSInviteListTableView.h
//  livestream
//
//  Created by test on 2018/11/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNIniviteListTableViewCell.h"

@class QNInviteListTableView;
@protocol QNInviteListTableViewDelegate <NSObject>
@optional
//cell点击回调
- (void)tableView:(QNInviteListTableView *)tableView didSelectContact:(LSLadyRecentContactObject *)item;

@end
@interface QNInviteListTableView : LSTableView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak)  id<QNInviteListTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;
@end
