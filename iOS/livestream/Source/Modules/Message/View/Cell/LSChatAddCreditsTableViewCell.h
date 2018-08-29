//
//  LSChatAddCreditsTableViewCell.h
//  livestream
//
//  Created by Calvin on 2018/7/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSChatAddCreditsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
