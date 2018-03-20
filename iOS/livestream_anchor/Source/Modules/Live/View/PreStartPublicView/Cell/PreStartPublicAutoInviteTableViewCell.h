//
//  PreStartPublicAutoInviteTableViewCell.h
//  livestream_anchor
//
//  Created by test on 2018/3/1.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PreStartPublicAutoInviteTableViewCell;
@protocol PreStartPublicAutoInviteTableViewCellDelegate <NSObject>
@optional

- (void)preStartPublicAutoInviteTableViewCell:(PreStartPublicAutoInviteTableViewCell *)cell didOpenAutoInvitation:(UISwitch *)sender;

@end

@interface PreStartPublicAutoInviteTableViewCell : UITableViewCell

@property (nonatomic, weak) id<PreStartPublicAutoInviteTableViewCellDelegate> startPublicAutoInviteDelegate;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
