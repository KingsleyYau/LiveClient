//
//  LSScheduleInvitedCell.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSScheduleLiveInviteItemObject.h"
#import "LSScheduleInviteItem.h"

NS_ASSUME_NONNULL_BEGIN

@class LSScheduleInvitedCell;
@protocol LSScheduleInvitedCellDelegate <NSObject>
- (void)selectDurationWithRow:(LSScheduleInvitedCell *)cell;
- (void)acceptScheduleInvite:(NSString *)inviteId duration:(int)duration item:(LSScheduleInviteItem *)item;
@end

@interface LSScheduleInvitedCell : UITableViewCell

@property (nonatomic, weak) id<LSScheduleInvitedCellDelegate> delegate;

+ (NSString *)cellIdentifier;

+ (NSInteger)cellHeight;

+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)setupData:(LSScheduleLiveInviteItemObject *)item;

@end

NS_ASSUME_NONNULL_END
