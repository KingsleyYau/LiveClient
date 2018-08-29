//
//  LSNavWebViewController.h
//  livestream
//
//  Created by test on 2018/6/11.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "IntroduceView.h"

@interface LSNavWebViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet IntroduceView *webView;
/** 顶部title */
@property (nonatomic, copy) NSString *navTitle;

/** 导航栏透明 */
@property (nonatomic, assign) BOOL alphaType;

/** 回到前台是否调用js **/
@property (nonatomic, assign) BOOL isResume;

@property (nonatomic, copy) NSString *url;
@end
