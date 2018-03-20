//
//  PreStartNowTableViewCell.h
//  livestream_anchor
//
//  Created by test on 2018/3/1.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PreStartNowTableViewCell;
@protocol PreStartNowTableViewCellDelegate <NSObject>
@optional

- (void)preStartNowTableViewCell:(PreStartNowTableViewCell *)cell didStartBroadcast:(UIButton *)sender;

@end

@interface PreStartNowTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (nonatomic, weak) id<PreStartNowTableViewCellDelegate> startNowDelegate;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
