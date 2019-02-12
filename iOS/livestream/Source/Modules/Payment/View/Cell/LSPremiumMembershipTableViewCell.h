//
//  PremiumMembershipTableViewCell.h
//  dating
//
//  Created by Calvin on 17/4/11.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSPremiumMembershipTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

//标识符
+ (NSString *)cellIdentifier;
/* 高度 */
+ (NSInteger)cellHeight;
//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView;
@end
