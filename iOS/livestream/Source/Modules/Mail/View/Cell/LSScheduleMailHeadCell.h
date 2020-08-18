//
//  LSScheduleMailHeadCell.h
//  livestream
//
//  Created by test on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSScheduleMailHeadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *onlineView;

+ (CGFloat)cellHeight ;

+ (id)getUITableViewCell:(UITableView *)tableView;

+ (NSString *)cellIdentifier;
@end

NS_ASSUME_NONNULL_END
