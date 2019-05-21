//
//  LSSayHiDialogViewController.h
//  livestream
//
//  Created by Randy_Fan on 2019/4/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsPageViewController.h"
#import "LiveUrlHandler.h"

typedef enum {
    SAYHIERROR_NONE = 0,
    SAYHIERROR_HAS_SEND,
    SAYHIERROR_HAS_CALL,
    SAYHIERROR_DAY_SEND_MAX,
    SAYHIERROR_SEND_MAX_ISREPLRY,
    SAYHIERROR_SEND_MAX_NOREPLRY,
} SAYHIERROR;

@class LSSayHiDialogViewController;
@protocol LSSayHiDialogViewControllerDelegate <NSObject>
- (void)didCloseCurrentView:(LSSayHiDialogViewController *)vc;
- (void)didCloseCilck:(LSSayHiDialogViewController *)vc;
- (void)didViewSayHiClick:(NSString *)sayHiId;
- (void)didViewSayHiList:(LiveUrlSayHiListType)type;
- (void)didFollowClick:(LSSayHiDialogViewController *)vc;
- (void)didChatClick:(LSSayHiDialogViewController *)vc;
- (void)didStartOneOnOneClick:(LSSayHiDialogViewController *)vc;
- (void)didSendMailClick:(LSSayHiDialogViewController *)vc;
@end

@interface LSSayHiDialogViewController : LSGoogleAnalyticsPageViewController

@property (nonatomic, copy) NSString *anchorName;
@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic,copy) NSString *sayHiId;

@property (nonatomic, assign) SAYHIERROR errorType;

@property (nonatomic, weak) id<LSSayHiDialogViewControllerDelegate> delegate;

- (void)showIsFollowBtn;
- (void)showDiaLogView:(BOOL)success hasFollow:(BOOL)hasFollow isOnline:(BOOL)isOnline errMsg:(NSString *)errMsg;

@end

