//
//  LSUserSettingFollowCell.h
//  livestream
//
//  Created by Calvin on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSUserSettingFollowCellDelegate <NSObject>

- (void)pushFollowLadyDetails:(NSString*)userId;

@end

@interface LSUserSettingFollowCell : UITableViewCell

@property (weak, nonatomic) id<LSUserSettingFollowCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet UIView *followInfoView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView *)tableView;

- (void)loadFollowData:(NSArray *)items;
@end

