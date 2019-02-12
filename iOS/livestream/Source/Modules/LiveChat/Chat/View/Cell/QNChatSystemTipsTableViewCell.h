//
//  QNChatSystemTipsTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface QNChatSystemTipsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
