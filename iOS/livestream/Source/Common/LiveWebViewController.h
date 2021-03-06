//
//  LiveWebViewController.h
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSWKWebViewController.h"

@interface LiveWebViewController : LSWKWebViewController

@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) BOOL isIntimacy;

@property (nonatomic, copy) NSString *anchorId;

/** 是否协议 */
@property (nonatomic, assign) BOOL isUserProtocol;

@end
