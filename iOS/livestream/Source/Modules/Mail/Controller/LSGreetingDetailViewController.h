//
//  LSGreetingDetailViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/11/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSHttpLetterListItemObject.h"
@class LSGreetingDetailViewController;
@protocol LSGreetingDetailViewControllerDelegate <NSObject>
@optional
- (void)lsGreetingDetailViewController:(LSGreetingDetailViewController *)vc haveReadGreetingDetailMail:(LSHttpLetterListItemObject *)model index:(int)index;
- (void)lsGreetingDetailViewController:(LSGreetingDetailViewController *)vc haveReplyGreetingDetailMail:(LSHttpLetterListItemObject *)model index:(int)index;
@end
#import "LSSessionRequest.h"

@interface LSGreetingDetailViewController : LSGoogleAnalyticsViewController
/** 代理 */
@property (nonatomic, weak) id<LSGreetingDetailViewControllerDelegate> greetingDetailDelegate;
/** 意向信信息 */
@property (nonatomic, strong) LSHttpLetterListItemObject *letterItem;

/**  */
@property (nonatomic, assign) int greetingMailIndex;
@end
