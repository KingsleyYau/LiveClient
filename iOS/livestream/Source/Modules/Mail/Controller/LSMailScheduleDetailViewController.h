//
//  LSScheduleDetailViewController.h
//  livestream
//
//  Created by test on 2020/3/24.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSListViewController.h"
#import "LSHttpLetterDetailItemObject.h"
#import "LSHttpLetterListItemObject.h"

NS_ASSUME_NONNULL_BEGIN
@class LSMailScheduleDetailViewController;
@protocol LSMailScheduleDetailViewControllerDelegate <NSObject>
@optional
- (void)lsMailScheduleDetailViewController:(LSMailScheduleDetailViewController *)vc haveReadScheduleDetailMail:(LSHttpLetterListItemObject *)model index:(int)index;

@end
@interface LSMailScheduleDetailViewController : LSListViewController
@property (nonatomic, assign) BOOL isInBoxSheduleDetail;
@property (nonatomic, assign) int mailIndex;
@property (nonatomic, strong) LSHttpLetterListItemObject *letterItem;
/** 代理 */
@property (nonatomic, weak) id<LSMailScheduleDetailViewControllerDelegate> scheduleDetailDelegate;
@end

NS_ASSUME_NONNULL_END
