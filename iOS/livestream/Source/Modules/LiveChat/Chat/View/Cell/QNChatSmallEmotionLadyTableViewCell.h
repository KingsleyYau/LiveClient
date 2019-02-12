//
//  QNChatSmallEmotionLadyTableViewCell.h
//  dating
//
//  Created by test on 16/11/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QNChatSmallEmotionLadyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *smallEmotonImageView;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;


@end
