//
//  AnchorPersonalViewController.h
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//


#import "LSLiveWKWebViewController.h"
#import "IntroduceView.h"
#import "LSGoogleAnalyticsViewController.h"

@interface AnchorPersonalViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet IntroduceView *personalView;

@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, assign) int showInvite;

@end
