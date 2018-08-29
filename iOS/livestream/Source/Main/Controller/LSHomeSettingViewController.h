//
//  LSHomeSettingViewController.h
//  livestream
//
//  Created by Calvin on 2018/7/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
#import "LSMainViewController.h"
#import "LSHomeSettingHaedView.h"
@interface LSHomeSettingViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
 
@property (strong, nonatomic) LSMainViewController* mainVC;

- (void)showSettingView;
- (void)hideSettingView;
- (void)removeHomeSettingVC;
@end
