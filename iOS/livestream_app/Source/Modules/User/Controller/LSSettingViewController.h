//
//  LSSettingViewController.h
//  livestream
//
//  Created by test on 2017/12/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@interface LSSettingViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/** 数据 */
@property (nonatomic,strong) NSArray *titleArray;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@end
