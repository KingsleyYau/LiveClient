//
//  ShowCell.h
//  livestream
//
//  Created by Calvin on 2018/4/18.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowListView.h"
#import "LSAnchorProgramItemObject.h"
@protocol ShowCellDelegate <NSObject>

//type 1是进入直播间，2是买点
- (void)showCellBtnDidFromItem:(LSAnchorProgramItemObject *)item;

@end

@interface ShowCell : UITableViewCell <ShowListViewDelegate>
@property (weak, nonatomic) IBOutlet ShowListView *showListView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) id<ShowCellDelegate> cellDelegate;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)updateUI:(LSAnchorProgramItemObject *)item;
- (void)updateHistoryUI:(LSAnchorProgramItemObject *)item;
@end
