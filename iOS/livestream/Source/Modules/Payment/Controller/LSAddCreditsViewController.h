//
//  addCreditsViewController.h
//  dating
//
//  Created by lance on 16/3/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"

@interface LSAddCreditsViewController : LSGoogleAnalyticsViewController

@property (nonatomic,weak) IBOutlet LSTableView *tableView;
/** 数据 */
@property (nonatomic,strong) NSArray *items;
@property (nonatomic, weak) IBOutlet UIView* loadingView;


@end
