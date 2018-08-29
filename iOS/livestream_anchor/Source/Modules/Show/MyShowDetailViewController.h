//
//  MyShowDetailViewController.h
//  livestream_anchor
//
//  Created by test on 2018/5/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "IntroduceView.h"

@interface MyShowDetailViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet IntroduceView *showView;
@property (nonatomic, copy) NSString *liveShowId;

@end
