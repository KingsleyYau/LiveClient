//
//  LSHomeSchedueleCell.h
//  livestream
//
//  Created by test on 2020/3/25.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoomInfoItemObject.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum {
    ScheduleNoteTypeStart = 0,
    ScheduleNoteTypeWillStart
}ScheduleNoteType;


@protocol LSHomeSchedueleCellDelegate <NSObject>

- (void)lsHomeSchedueleCellDidRemove:(NSInteger)row;


@end

@interface LSHomeSchedueleCell : UICollectionViewCell
/** 代理 */
@property (nonatomic, weak) id<LSHomeSchedueleCellDelegate> schedueleDelegate;
- (void)updateUI:(ScheduleNoteType)type withItem:(LiveRoomInfoItemObject *)item;
@end

NS_ASSUME_NONNULL_END
