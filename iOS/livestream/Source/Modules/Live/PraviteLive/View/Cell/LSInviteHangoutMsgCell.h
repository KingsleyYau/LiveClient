//
//  LSInviteHangoutMsgCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgItem.h"

NS_ASSUME_NONNULL_BEGIN

@class LSInviteHangoutMsgCell;
@protocol LSInviteHangoutMsgCellDelegate <NSObject>
- (void)inviteHangoutAnchor:(MsgItem *)item;
@end

@interface LSInviteHangoutMsgCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *backgroundColorView;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UILabel *countryLabel;

@property (weak, nonatomic) IBOutlet UIButton *hangoutBtn;

@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;

@property (strong, nonatomic) MsgItem *item;

@property (weak, nonatomic) id<LSInviteHangoutMsgCellDelegate> delagate;

+ (id)getUITableViewCell:(UITableView *)tableView;

+ (NSString *)cellIdentifier;

- (void)upDataInviteMessage:(MsgItem *)item;

@end

NS_ASSUME_NONNULL_END
