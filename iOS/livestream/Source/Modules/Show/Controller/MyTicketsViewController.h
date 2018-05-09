//
//  MyTicketsViewController.h
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGetProgramListRequest.h"
#import "LSGoogleAnalyticsViewController.h"
@interface MyTicketsViewController : LSGoogleAnalyticsViewController
@property (nonatomic, assign) ProgramListType sortType;
@end
