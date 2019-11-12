//
//  LiveFinshViewController.h
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsPageViewController.h"
#import "LiveRoom.h"
#import "ShowListView.h"

@interface LiveFinshViewController : LSGoogleAnalyticsPageViewController

@property (nonatomic, assign) LCC_ERR_TYPE errType;
@property (nonatomic, copy) NSString *errMsg;

@property (nonatomic, strong) LiveRoom *liveRoom;

- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg;

@end
