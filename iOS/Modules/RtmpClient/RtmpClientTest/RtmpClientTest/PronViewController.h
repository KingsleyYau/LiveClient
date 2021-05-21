//
//  PronViewController.h
//  RtmpClientTest
//
//  Created by Max on 2020/10/23.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseAdViewController.h"
#import "StreamBaseViewController.h"
#import "StreamWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PronViewController : BaseAdViewController <WKUIDelegate, WKNavigationDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>
@property (strong) NSString *baseUrl;
@end

NS_ASSUME_NONNULL_END
