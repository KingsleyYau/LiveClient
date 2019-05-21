//
//  LSSendMailViewController.h
//  livestream
//
//  Created by test on 2018/12/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSWKWebViewController.h"
#import "LSSendMailPhotoView.h"

@class LSSendMailViewController;
@protocol LSSendMailViewControllerDelegate <NSObject>
@optional
- (void)sendMailIsSuccess:(LSSendMailViewController *)vc;
@end

@interface LSSendMailViewController : LSGoogleAnalyticsViewController

/** 主播id */
@property (nonatomic, copy) NSString *anchorId;

@property (nonatomic, copy) NSString *anchorName;

@property (nonatomic, copy) NSString * photoUrl;

@property (nonatomic, copy) NSString * loiId;//回复的意向信ID

@property (nonatomic, copy) NSString * emfId;//回复的信件ID

@property (nonatomic, copy) NSString * quickReplyStr; //快速回复内容

@property (nonatomic, weak) id<LSSendMailViewControllerDelegate> sendDelegate;

@property (nonatomic, copy) NSString * sayHiResponseId;
@end
