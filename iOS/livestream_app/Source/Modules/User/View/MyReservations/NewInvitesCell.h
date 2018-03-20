//
//  NewInvitesCell.h
//  livestream
//
//  Created by Calvin on 17/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
@protocol NewInvitesCellDelegate <NSObject>
@optional;

- (void)myReservationsComfirmBtnDidForRow:(NSInteger)row;

- (void)myReservationsDeclineBtnDidForRow:(NSInteger)row;

- (void)myReservationsCancelBtnDidForRow:(NSInteger)row;

- (void)myReservationsStartNowDidForRow:(NSInteger)row;

- (void)myReservationsCountdownEnd;

- (void)myReservationsHeadDidForRow:(NSInteger)row;
@end

@interface NewInvitesCell : UITableViewCell

@property (weak, nonatomic) id<NewInvitesCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIButton *comfirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *declineBtn;
@property (weak, nonatomic) IBOutlet UIView *redIcon;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
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
