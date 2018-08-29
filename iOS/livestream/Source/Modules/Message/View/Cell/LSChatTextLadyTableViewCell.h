//
//  ChatTextLadyTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSChatTextLadyTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
