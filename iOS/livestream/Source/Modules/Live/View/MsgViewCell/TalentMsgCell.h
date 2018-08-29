//
//  TalentMsgCell.h
//  livestream
//
//  Created by Calvin on 2018/5/29.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgItem.h"

@class TalentMsgCell;
@protocol TalentMsgCellDelegate <NSObject>

- (void)talentMsgCellDid;
@end

@interface TalentMsgCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (nonatomic, weak) id<TalentMsgCellDelegate> talentCellDelegate;
@property (weak, nonatomic) IBOutlet UIView *bgView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)updateMsg:(MsgItem *)msg;
@end
