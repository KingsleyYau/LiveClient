//
//  LSSayHiAllTableViewCell.h
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSSayHiAllTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *anchorName;
@property (weak, nonatomic) IBOutlet UILabel *unreadCount;
@property (weak, nonatomic) IBOutlet UILabel *totalCount;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end

NS_ASSUME_NONNULL_END
