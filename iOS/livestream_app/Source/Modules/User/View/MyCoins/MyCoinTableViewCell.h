//
//  MyCoinTableViewCell.h
//  livestream
//
//  Created by test on 2017/12/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCoinTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *coinCount;
@property (weak, nonatomic) IBOutlet UIButton *coinPrice;
@property (weak, nonatomic) IBOutlet UIImageView *coinBalanceIcon;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
