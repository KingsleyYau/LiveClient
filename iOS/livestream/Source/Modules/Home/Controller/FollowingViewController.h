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

/**
 * Add by Max 2018/01/25
 */
@protocol FollowingViewControllerDelegate
- (void)followingVCBrowseToHot;
@end

@interface FollowingViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet HotTableView *tableView;
@property (weak, nonatomic) id<FollowingViewControllerDelegate> followVCDelegate;
@end
