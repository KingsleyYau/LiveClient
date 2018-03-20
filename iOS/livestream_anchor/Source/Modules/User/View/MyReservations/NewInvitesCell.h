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
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (weak, nonatomic) IBOutlet UIView *giftsView;
@property (weak, nonatomic) IBOutlet UIImageView *giftIcon;
@property (weak, nonatomic) IBOutlet UILabel *giftNum;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *haedTap;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView forRow:(NSInteger)row;
- (void)updateNameFrame;
- (NSString *)getTime:(NSInteger)time;
@end
