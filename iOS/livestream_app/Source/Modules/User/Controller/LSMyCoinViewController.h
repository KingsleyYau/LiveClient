//
//  LSMyCoinViewController.h
//  livestream
//
//  Created by test on 2017/12/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@interface LSMyCoinViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/** 数据 */
@property (nonatomic,strong) NSArray *items;
@end
