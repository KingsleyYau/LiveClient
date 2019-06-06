//
//  DoorStreamViewController.h
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGoogleAnalyticsViewController.h"
#import "LiveRoomInfoItemObject.h"

@interface DoorStreamViewController : LSGoogleAnalyticsViewController
@property (strong) LiveRoomInfoItemObject *item;
@end

