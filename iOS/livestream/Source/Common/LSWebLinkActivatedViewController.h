//
//  LSWebLinkActivatedViewController.h
//  livestream
//
//  Created by test on 2018/5/17.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSLiveWKWebViewManager.h"
#import "IntroduceView.h"
@interface LSWebLinkActivatedViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet IntroduceView *commonWeb;
@property (nonatomic, strong) NSString* linkActivatedUrl;
@end
