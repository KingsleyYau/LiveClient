//
//  LSScheduleTipsCell.h
//  livestream
//
//  Created by test on 2020/4/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSScheduleTipsCell : UITableViewCell
+ (CGFloat)cellHeight ;

+ (id)getUITableViewCell:(UITableView *)tableView;

+ (NSString *)cellIdentifier;
@end

NS_ASSUME_NONNULL_END
