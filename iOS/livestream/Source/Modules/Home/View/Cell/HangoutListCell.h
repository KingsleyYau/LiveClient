//
//  HangoutListCell.h
//  livestream
//
//  Created by Calvin on 2019/1/16.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSHangoutListItemObject.h"
@class HangoutListCell;
@protocol HangoutListCellDelegate <NSObject>
@optional
- (void)hangoutListCellDidHangout:(NSInteger)row;
@end
@interface HangoutListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet LSUIImageViewTopFit *imageViewHeader;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (nonatomic, strong) TXScrollLabelView *scrollLabelView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong) NSMutableArray *animationArray;
@property (weak, nonatomic) IBOutlet UIButton *hangoutButton;
/** 代理 */
@property (nonatomic, weak) id<HangoutListCellDelegate> hangoutDelegate;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)setScrollLabelViewText:(NSString *)text;
- (void)setHangoutHeadList:(NSArray *)list;
@end

 
