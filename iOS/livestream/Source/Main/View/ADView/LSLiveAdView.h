//
//  LiveAdView.h
//  dating
//
//  Created by test on 2018/3/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSCommonWebView.h"

// 广告URL打开方式
typedef enum {
    URLLiveAdOpenType_DEFAULT = 0,            // 当前WebView打开
    URLLiveAdOpenType_SYSTEMBROWER = 1,    // 系统浏览器打开
    URLLiveAdOpenType_APPBROWER = 2,       // APP内嵌浏览器打开
    URLLiveAdOpenType_HIDE = 3           // 隐藏WebView打开
} URLLiveAdOpenType;

@class LSLiveAdView;
@protocol LiveAdViewDelegate<NSObject>
@optional
- (void)liveAdViewDidClose:(LSLiveAdView *)adView;
- (void)liveAdView:(LSLiveAdView *)adView HandlerOpenUrl:(NSURL *)url;
//打开重定向URL
- (void)liveAdViewRedirectURL:(NSURL *)url;
@end


@interface LSLiveAdView : UIView

/** 代理 */
@property (nonatomic, weak) id<LiveAdViewDelegate> delegate;
@property (nonatomic, assign) URLLiveAdOpenType openType;
/** 网页高度 */
@property (nonatomic, assign) CGFloat height;
 
- (void)loadHTmlStr:(NSString *)string baseUrl:(NSURL *)url;
@end
