//
//  AnchorPersonalViewController.h
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoomInfoItemObject.h"
#import "LSLiveWKWebViewController.h"
#import "IntroduceView.h"
#import "LSGoogleAnalyticsViewController.h"

@interface AnchorPersonalViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet IntroduceView *personalView;

@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, assign) int enterRoom;
//0:Album 1:MyCalender 2:Profile
@property (nonatomic, assign) NSInteger tabType;
@end
