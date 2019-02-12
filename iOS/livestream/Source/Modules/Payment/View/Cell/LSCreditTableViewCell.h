//
//  CommonCreditTableViewCell.h
//  dating
//
//  Created by test on 16/7/1.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSCreditTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *creditBtn;

@property (weak, nonatomic) IBOutlet UIView *bgView;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
