//
//  LSMainViewController.h
//  livestream
//
//  Created by Max on 2017/5/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGoogleAnalyticsPageViewController.h"
#import "LiveRoom.h"
#import "LSHomeSettingViewController.h"
@interface LSMainViewController : LSGoogleAnalyticsPageViewController

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;
@property (nonatomic, weak) LSHomeSettingViewController *settingVC;
@end
