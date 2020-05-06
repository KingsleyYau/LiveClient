//
//  LSUserSetUpViewController.h
//  livestream
//
//  Created by test on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@interface LSUserSetUpViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet LSTableView *tableView;
/** 数据 */
@property (nonatomic,strong) NSArray *items;
@end
