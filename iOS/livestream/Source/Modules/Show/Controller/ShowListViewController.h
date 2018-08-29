//
//  ShowListViewController.h
//  livestream
//
//  Created by Calvin on 2018/4/18.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"

@class ShowListViewController;
@protocol ShowListViewControllerDelegate <NSObject>
@optional
- (void)reloadNowShowList;
@end

@interface ShowListViewController : LSGoogleAnalyticsViewController

@property (nonatomic, weak) id<ShowListViewControllerDelegate> showDelegate;

- (void)setupLoadData:(BOOL)isLoadData;
- (void)setupFirstLogin:(BOOL)isFirstLogin;
- (void)viewDidAppearGetList:(BOOL)isSwitchSite;
@end
