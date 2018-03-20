//
//  ScheduledCell.h
//  livestream_anchor
//
//  Created by Calvin on 2018/3/1.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

@protocol ScheduledCellDelegate <NSObject>
@optional;

- (void)scheduledStartNowDidForRow:(NSInteger)row;

- (void)scheduledCountdownEnd;

- (void)scheduledHeadDidForRow:(NSInteger)row;
@end
@interface ScheduledCell : UITableViewCell

@property (weak, nonatomic) id<ScheduledCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIView *redIcon;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;
@property (weak, nonatomic) IBOutlet UIView *scheduledTimeView;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *startNowTap;

@property (nonatomic, assign) NSInteger time;
@property (nonatomic, assign) NSInteger countdownTime;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *haedTap;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView forRow:(NSInteger)row;

- (void)startCountdown:(NSInteger)time;
- (NSString *)getTime:(NSInteger)time;
- (void)setTimeStr:(NSString *)time;
- (NSString *)compareCurrentTime:(NSInteger)time;
@end
