//
//  LSScheduleRequestCell.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSScheduleLiveInviteItemObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSScheduleRequestCell : UITableViewCell

+ (NSString *)cellIdentifier;

+ (NSInteger)cellHeight;

+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)setupData:(LSScheduleLiveInviteItemObject *)item;

@end

NS_ASSUME_NONNULL_END
