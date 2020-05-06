//
//  LSScheduleInviteCell.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/16.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPrepaidCardView.h"
#import "LSPrepaidAcceptCardView.h"
#import "MsgItem.h"

NS_ASSUME_NONNULL_BEGIN

@class LSScheduleInviteCell;
@protocol LSScheduleInviteCellDelegate <NSObject>
- (void)liveScheduleInviteCellDidAccept:(LSScheduleInviteCell *)cell;
- (void)liveScheduleInviteCellDidDurationRow:(LSScheduleInviteCell *)cell;
- (void)liveScheduleInviteCellHidenDetalis:(LSScheduleInviteCell *)cell;
- (void)liveScheduleInviteCellShowDetalis:(LSScheduleInviteCell *)cell;
- (void)liveScheduleInviteCellDidOpenScheduleList;
- (void)liveScheduleInviteCellDidLearnHowWorks;
- (void)liveScheduleInviteCellDidMinimum:(LSScheduleInviteCell *)cell isMinimum:(BOOL)isMinimum;
@end

@interface LSScheduleInviteCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *minimumView;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UILabel *sendNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *atNameLabel;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIView *acceptView;
@property (weak, nonatomic) IBOutlet UIButton *minimumBtn;
@property (weak, nonatomic) id<LSScheduleInviteCellDelegate> delegate;

@property (nonatomic, strong) LSPrepaidCardView *cardSubView;
@property (nonatomic, strong) LSPrepaidAcceptCardView *acceptSubView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(BOOL)isMore isAcceptView:(BOOL)isAccept isMinimum:(BOOL)isMinimum;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)updateAcceptData:(MsgItem *)item;
- (void)updateCardData:(MsgItem *)item anchorName:(NSString *)anchorName;
- (void)showMinimumView:(MsgItem *)item;

@end

NS_ASSUME_NONNULL_END
