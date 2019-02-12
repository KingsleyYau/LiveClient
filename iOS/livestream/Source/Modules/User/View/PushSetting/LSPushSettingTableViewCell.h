//
//  PushSettingTableViewCell.h
//  livestream
//
//  Created by test on 2018/9/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSPushSettingTableViewCell;
@protocol LSPushSettingTableViewCellDelegate <NSObject>
@optional;
- (void)lsPushSettingTableViewCellDelegate:(LSPushSettingTableViewCell *)cell didChangeStatus:(UISwitch *)sender;
@end

@interface LSPushSettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pushSettingTitle;
@property (weak, nonatomic) IBOutlet UISwitch *pushSwitch;

/** 代理 */
@property (nonatomic, weak) id<LSPushSettingTableViewCellDelegate> pushSettingDelegate;
//标识符
+ (NSString *)cellIdentifier;
/* 高度 */
+ (NSInteger)cellHeight;
//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView;

+ (UIEdgeInsets)defaultInsets;
@end
