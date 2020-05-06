//
//  LSScheduleListViewController.h
//  livestream
//
//  Created by Calvin on 2020/4/15.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
typedef enum ScheduleType {
    ScheduleType_Pending = 1,//待确认
    ScheduleType_Confirmed =2,//已确认
    ScheduleType_Canceled = 3,//确认后被取消
    ScheduleType_Expired = 4,//未确认
    ScheduleType_Completed = 5,//待开播
    ScheduleType_Declined = 6,//已拒绝
    ScheduleType_Missed = 7,//未成功开播
}ScheduleType;

@interface LSScheduleListViewController : LSGoogleAnalyticsViewController
@property (nonatomic, assign) ScheduleType type;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewY;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noDataImage;

@end

 
