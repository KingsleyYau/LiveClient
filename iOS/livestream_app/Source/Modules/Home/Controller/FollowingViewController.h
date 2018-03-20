//
//  FollowingViewController.h
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

#import "LSHomePageViewController.h"
#import "HotTableView.h"

@interface FollowingViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet HotTableView *tableView;

@property (nonatomic, weak) LSHomePageViewController* homePageVC;
@end
