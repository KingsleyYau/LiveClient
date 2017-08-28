//
//  ChatListTableViewCell.h
//  livestream
//
//  Created by randy on 2017/8/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatListModel.h"

@interface ChatListTableViewCell : UITableViewCell

// 头像
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

// 未读
@property (weak, nonatomic) IBOutlet UIImageView *unreadNumView;

// 用户名
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

// 最新消息
@property (weak, nonatomic) IBOutlet UILabel *lasterMsgLabel;

- (void)setListCellModel:(ChatListModel *)model;

+ (NSString *)cellIdentifier;

@end
