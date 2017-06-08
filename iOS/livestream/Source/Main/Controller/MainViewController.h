//
//  MainViewController.h
//  livestream
//
//  Created by Max on 2017/5/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : KKViewController <UITabBarDelegate>

/**
 内容界面
 */
@property (weak) IBOutlet UIView* tabContainView;

/**
 底部TabBar
 */
@property (weak) IBOutlet UITabBar* tabBar;

@end
