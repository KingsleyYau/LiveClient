//
//  LSTudosViewController.h
//  livestream_anchor
//
//  Created by test on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSListViewController.h"

@interface LSTodosViewController : LSListViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) int unReadBookingCount;
@end
