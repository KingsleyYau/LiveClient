//
//  UserInfoListCell.h
//  livestream
//
//  Created by Calvin on 17/10/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleIcon;
@property (weak, nonatomic) IBOutlet UILabel *unread;
@property (weak, nonatomic) IBOutlet UILabel *unIcon;
@property (weak, nonatomic) IBOutlet UILabel *coinsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)updateCount:(NSInteger)count;
@end
