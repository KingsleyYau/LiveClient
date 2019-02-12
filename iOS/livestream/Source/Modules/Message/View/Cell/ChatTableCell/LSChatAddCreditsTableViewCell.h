//
//  LSChatAddCreditsTableViewCell.h
//  livestream
//
//  Created by Calvin on 2018/7/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@class LSChatAddCreditsTableViewCell;
@protocol LSChatAddCreditsTableViewCellDelegate <NSObject>
@optional
- (void)pushToAddCredites;
@end

@interface LSChatAddCreditsTableViewCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) id<LSChatAddCreditsTableViewCellDelegate> delegate;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
