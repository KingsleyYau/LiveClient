//
//  LSHomeSettingCell.h
//  livestream
//
//  Created by Calvin on 2018/6/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
@interface LSHomeSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *settingIcon;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;
@property (weak, nonatomic) IBOutlet UIImageView * offIcon;
@property (nonatomic, strong) LSImageViewLoader * imageLoader;
@property (weak, nonatomic) IBOutlet UIImageView *logoIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offIconW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offIconH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offIconY;
+ (id)getUITableViewCell:(UITableView*)tableView;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
- (void)showUnreadNum:(int)num;
- (void)showUnreadPoint:(int)num;
- (void)showChatListUnreadNum:(int)num;
- (void)showWillShowSoon:(BOOL)isSoon;
@end
