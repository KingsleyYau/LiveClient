//
//  LSFollowingViewController.h
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

//#import "LSGoogleAnalyticsViewController.h"
#import "LSViewController.h"
#import "HotTableView.h"

@protocol LSFollowingViewControllerDelegate
- (void)followingVCBrowseToHot;
@end

@interface LSFollowingViewController : LSListViewController
@property (weak, nonatomic) IBOutlet HotTableView *tableView;
@property (weak, nonatomic) id<LSFollowingViewControllerDelegate> followVCDelegate;

@end
