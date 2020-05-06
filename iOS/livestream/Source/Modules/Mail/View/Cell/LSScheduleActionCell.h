//
//  LSScheduleActionCell.h
//  livestream
//
//  Created by test on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSHttpLetterDetailItemObject.h"
#import "LSScheduleInviteDetailItemObject.h"
NS_ASSUME_NONNULL_BEGIN
@class LSScheduleActionCell;
@protocol LSScheduleActionCellDelegate <NSObject>
@optional
- (void)lsScheduleActionCell:(LSScheduleActionCell *)cell didClickOther:(UIButton *)btn;
- (void)lsScheduleActionCell:(LSScheduleActionCell *)cell didAcceptSchedule:(UIButton *)btn;
- (void)lsScheduleActionCell:(LSScheduleActionCell *)cell didAcceptScheduleByReplyMail:(UIButton *)btn;

@end

@interface LSScheduleActionCell : UITableViewCell
@property (nonatomic, weak) id<LSScheduleActionCellDelegate> actionDelegate;
@property (weak, nonatomic) IBOutlet UIButton *oneOnOneBtn;
/** 用户昵称 */
@property (nonatomic, copy) NSString *anchorName;

- (void)updateMailScheduelUI:(LSHttpLetterDetailItemObject *)item;
- (void)updateScheduelDetailUI:(LSScheduleInviteDetailItemObject *)item;

+ (CGFloat)cellTotalHeight;
+ (CGFloat)cellOneBtnHeight;

+ (id)getUITableViewCell:(UITableView *)tableView;

+ (NSString *)cellIdentifier;
@end

NS_ASSUME_NONNULL_END
