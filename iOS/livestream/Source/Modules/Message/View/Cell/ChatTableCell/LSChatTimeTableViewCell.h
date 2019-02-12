//
//  LSChatTimeTableViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/9/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSChatTimeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

+ (NSString *)cellIdentifier;

+ (NSInteger)cellHeight;

+ (id)getUITableViewCell:(UITableView*)tableView;

@end
