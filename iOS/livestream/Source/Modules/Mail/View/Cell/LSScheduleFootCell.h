//
//  LSScheduleFootCell.h
//  livestream
//
//  Created by test on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LSScheduleFootCell;
@protocol LSScheduleFootCellDelegate <NSObject>
@optional
- (void)lsScheduleFootCell:(LSScheduleFootCell *)cell didClickHowWork:(UIButton *)btn;
- (void)lsScheduleFootCellDidClickLink:(LSScheduleFootCell *)cell;
@end
@interface LSScheduleFootCell : UITableViewCell

/** 代理 */
@property (nonatomic, weak) id<LSScheduleFootCellDelegate> footCellDelegate;
+ (CGFloat)cellHeight ;

+ (id)getUITableViewCell:(UITableView *)tableView;

+ (NSString *)cellIdentifier;
@end

NS_ASSUME_NONNULL_END
