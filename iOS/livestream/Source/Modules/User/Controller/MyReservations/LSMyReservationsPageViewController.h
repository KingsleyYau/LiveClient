//
//  LSMyReservationsPageViewController.h
//  livestream
//
//  Created by Calvin on 17/10/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "ManHandleBookingListRequest.h"
#import "CancelPrivateRequest.h"
#import "HandleBookingRequest.h"
@interface LSMyReservationsPageViewController : LSGoogleAnalyticsViewController

@property (nonatomic, strong) UIViewController * mainVC;
@property (nonatomic, assign) BookingListType type;
@end
