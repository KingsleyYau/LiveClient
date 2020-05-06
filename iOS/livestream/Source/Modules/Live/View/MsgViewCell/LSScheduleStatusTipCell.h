//
//  LSScheduleStatusTipCell.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/17.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgItem.h"

@protocol LSScheduleStatusTipCellDelegate <NSObject>
- (void)pushScheduleInviteDetail:(MsgItem *_Nonnull)item;
@end

NS_ASSUME_NONNULL_BEGIN

@interface LSScheduleStatusTipCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *tipBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tipImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkLabel;
@property (weak, nonatomic) id<LSScheduleStatusTipCellDelegate> delegate;

+ (NSString *)cellIdentifier;
+ (CGFloat)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)updataInfo:(MsgItem *)msgItem;

@end

NS_ASSUME_NONNULL_END
