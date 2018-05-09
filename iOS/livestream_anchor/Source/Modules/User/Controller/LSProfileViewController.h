//
//  LSProfileViewController.h
//  livestream_anchor
//
//  Created by test on 2018/3/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSLiveWKWebViewController.h"
#import "IntroduceView.h"
#import "LSMainViewController.h"
@interface LSProfileViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet IntroduceView *profileView;
@property (nonatomic, strong) NSString* profileUrl;

@end
