//
//  LSHomeSettingCell.h
//  livestream
//
//  Created by Calvin on 2018/6/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSHomeSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *settingIcon;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;


+ (id)getUITableViewCell:(UITableView*)tableView;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
- (void)showUnreadNum:(int)num;
- (void)showUnreadPoint:(int)num;
@end
