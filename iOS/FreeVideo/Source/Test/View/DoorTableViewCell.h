//
//  DoorTableViewCell.h
//  livestream
//
//  Created by Max on 13-9-5.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

@class DoorTableViewCell;
@protocol DoorTableViewCellDelegate <NSObject>
@optional
- (void)DoorTableViewCell:(DoorTableViewCell *)cell didClickViewBtn:(UIButton *)sender;
@end

@interface DoorTableViewCell : UITableViewCell
@property (nonatomic, weak) id<DoorTableViewCellDelegate> hotCellDelegate;

@property (nonatomic, weak) IBOutlet LSUIImageViewTopFit *imageViewHeader;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;

@property (weak, nonatomic) IBOutlet UILabel *labelRoomTitle;
@property (weak, nonatomic) IBOutlet LSHighlightedButton *viewBtn;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)reset;

@end
