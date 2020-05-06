//
//  LSHomeSettingViewController.h
//  livestream
//
//  Created by Calvin on 2018/7/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
#import "LSHomeSettingHaedView.h"

@class LSHomeSettingViewController;
@protocol LSHomeSettingViewControllerDelegate <NSObject>

- (void)lsHomeSettingViewControllerDidRemoveVC:(LSHomeSettingViewController *)homeSettingVc;

@end

@interface LSHomeSettingViewController : LSListViewController

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet LSTableView *tableView;
/** 代理 */
@property (nonatomic, weak) id<LSHomeSettingViewControllerDelegate> homeDelegate;
- (void)showSettingView;
- (void)hideSettingView;
- (void)removeHomeSettingVC;
@end
