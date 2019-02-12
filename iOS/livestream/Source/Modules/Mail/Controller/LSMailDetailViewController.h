//
//  LSMailDetailViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/17.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSSessionRequest.h"
@class LSMailDetailViewController;
@protocol LSMailDetailViewControllerrDelegate <NSObject>
@optional
- (void)lsMailDetailViewController:(LSMailDetailViewController *)vc haveReadMailDetailMail:(LSHttpLetterListItemObject *)model index:(int)index;

- (void)lsMailDetailViewController:(LSMailDetailViewController *)vc haveReplyMailDetailMail:(LSHttpLetterListItemObject *)model index:(int)index;
@end
@interface LSMailDetailViewController : LSGoogleAnalyticsViewController
/** 意向信信息 */
@property (nonatomic, strong) LSHttpLetterListItemObject *letterItem;
@property (nonatomic, assign) int mailIndex;
/** 代理 */
@property (nonatomic, weak) id<LSMailDetailViewControllerrDelegate> mailDetailDelegate;
@end
