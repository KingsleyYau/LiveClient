//
//  CommonDetailAndAccessoryTableViewCell.h
//  dating
//
//  Created by lance on 16/3/8.
//   cell包含标题和辅助视图,上下使用自己的分割线
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSCreditDetailTableViewCell : UITableViewCell
/** 标题视图 */
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
/** 辅助视图 */
@property (weak, nonatomic) IBOutlet UILabel *accessoryLabel;

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;

@property (weak, nonatomic) IBOutlet UIView *bgView;

//标识符
+ (NSString *)cellIdentifier;
/* 高度 */
+ (NSInteger)cellHeight;
//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView;
@end
