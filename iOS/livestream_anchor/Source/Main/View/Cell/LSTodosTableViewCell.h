//
//  LSTodosTableViewCell.h
//  livestream_anchor
//
//  Created by test on 2018/3/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSTodosTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *settingImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadBookingCount;

+ (id)getUITableViewCell:(UITableView*)tableView;
+ (CGFloat)cellHeight;
- (void)setTextW:(NSString *)text;
- (void)setDetailTextW:(NSString *)text;
- (void)updateRedLabelW:(int)num;

@end
