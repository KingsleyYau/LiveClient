//
//  HangoutInviteTableViewCell.h
//  livestream
//
//  Created by Max on 18-5-15.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSHighlightedButton.h"
#import "LSImageViewLoader.h"

@interface HangoutInviteTableViewCell : UITableViewCell
#pragma mark - 头像
@property (nonatomic, weak) IBOutlet UIImageView *imageViewHeader;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
#pragma mark - 名字/简介
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDesc;
#pragma mark - 邀请操作
@property (weak, nonatomic) IBOutlet LSHighlightedButton *buttonInvite;

+ (NSString *)identifier;
+ (NSInteger)height;
+ (id)cell:(UITableView*)tableView;

@end
