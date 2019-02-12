//
//  QNChatLargeEmotionLadyTableViewCell.h
//  dating
//
//  Created by test on 16/9/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNLargeEmotionShowView.h"

@interface QNChatLargeEmotionLadyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet QNLargeEmotionShowView *largeEmotionImageView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
