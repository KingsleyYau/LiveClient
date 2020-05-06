//
//  LSUserSettingFollowCell.h
//  livestream
//
//  Created by Calvin on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSBaseTableViewCell.h"

@protocol LSUserSettingFollowCellDelegate <NSObject>

- (void)pushFollowLadyDetails:(NSString*)userId;

@end

@interface LSUserSettingFollowCell : LSBaseTableViewCell

@property (weak, nonatomic) id<LSUserSettingFollowCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet UIView *followInfoView;
@property (weak, nonatomic) IBOutlet UILabel *followTitle;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView *)tableView;

- (void)loadFollowData:(NSArray *)items;
@end

