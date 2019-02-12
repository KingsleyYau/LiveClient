//
//  LSMessageCell.h
//  livestream
//
//  Created by Calvin on 2018/6/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPrivateMessageManager.h"

@interface LSMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLbael;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onlineImage;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)setCellPattern:(LMPrivateMsgContactObject *)model;
@end
