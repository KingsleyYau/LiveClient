//
//  LSChatPrepaidDeclineCell.h
//  livestream
//
//  Created by Calvin on 2020/4/1.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSChatPrepaidDeclineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *declineView;
@property (weak, nonatomic) IBOutlet UILabel *declineLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestLabel;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *labelTap;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)updateScheduleId:(NSString *)scheduleId isFormME:(BOOL)isMe;
@end

NS_ASSUME_NONNULL_END
