//
//  PronViewController.h
//  RtmpClientTest
//
//  Created by Max on 2020/10/23.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StreamBaseViewController.h"
#import "StreamWebView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PronViewControllerDelegate <NSObject>
- (void)downloadTaskPercent:(NSString *)percentString;
@end

@interface PronViewController : StreamBaseViewController <WKUIDelegate, WKNavigationDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>
@property (weak) id<PronViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
