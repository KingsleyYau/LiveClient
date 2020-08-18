//
//  LSPremiumVideoDetailUnlockCell.h
//  livestream
//
//  Created by Calvin on 2020/8/11.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSPremiumVideoDetailUnlockCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contentBGView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
+ (NSInteger)cellHeight;
+ (NSString *)cellIdentifier;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end

NS_ASSUME_NONNULL_END
