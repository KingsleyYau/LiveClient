//
//  LSScheduleNoteCell.h
//  livestream
//
//  Created by test on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSScheduleNoteCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSString *)detailString;


+ (id)getUITableViewCell:(UITableView *)tableView;

+ (NSString *)cellIdentifier;
@end

NS_ASSUME_NONNULL_END
