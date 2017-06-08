//
//  MsgTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgTableViewCell : UITableViewCell

@property (weak) IBOutlet UIView* viewLevelBackground;

@property (weak) IBOutlet UILabel* labelLevel;
@property (weak) IBOutlet UILabel* label;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString;
+ (id)getUITableViewCell:(UITableView *)tableView;
+ (NSString *)textPreDetail;

@end
