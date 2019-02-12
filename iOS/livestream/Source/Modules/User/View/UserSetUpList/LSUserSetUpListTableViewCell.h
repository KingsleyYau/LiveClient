//
//  LSUserSetUpListTableViewCell.h
//  livestream
//
//  Created by test on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSUserSetUpListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *settingTitle;
@property (weak, nonatomic) IBOutlet UILabel *settingDetail;
//标识符
+ (NSString *)cellIdentifier;
/* 高度 */
+ (NSInteger)cellHeight;
//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView;

+ (UIEdgeInsets)defaultInsets;
@end
