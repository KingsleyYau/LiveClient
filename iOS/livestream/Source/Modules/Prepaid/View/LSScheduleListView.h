//
//  LSScheduleListView.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSScheduleLiveInviteItemObject.h"
#import "LSScheduleInviteItem.h"

NS_ASSUME_NONNULL_BEGIN

@class LSScheduleListView;
@protocol LSScheduleListViewDelegate <NSObject>
- (void)changeDurationForItem:(LSScheduleLiveInviteItemObject *)item;
- (void)sendAcceptSchedule:(NSString *)inviteId duration:(int)duration item:(LSScheduleInviteItem *)item;
- (void)closeScheduleListView;
-(void)howWorkScheduleListView;
@end

typedef enum InvitedStatus {
    INVITEDSTATUS_NONE,
    INVITEDSTATUS_CONFIRM,
    INVITEDSTATUS_PENDING,
    INVITEDSTATUS_PENDING_HER,
    INVITEDSTATUS_PENDING_ME
}InvitedStatus;

@interface LSScheduleListView : UIView

@property (nonatomic, assign) InvitedStatus invitedStatus;

@property (nonatomic, weak) id<LSScheduleListViewDelegate> delegate;

- (void)setListData:(NSMutableArray *)scheduleList;

- (void)reloadSelectTime:(LSScheduleDurationItemObject *)item;

@end

NS_ASSUME_NONNULL_END
