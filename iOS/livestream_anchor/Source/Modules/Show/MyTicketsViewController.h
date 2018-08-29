//
//  MyTicketsViewController.h
//  livestream_anchor
//
//  Created by Calvin on 2018/5/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSAnchorRequestManager.h"
#import "LSGoogleAnalyticsViewController.h"
@interface MyTicketsViewController : LSGoogleAnalyticsViewController
@property (nonatomic, assign) AnchorProgramListType sortType;
@end
