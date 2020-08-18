//
//  LSMyContactsListCell.h
//  livestream
//
//  Created by Calvin on 2019/6/20.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSlidingCell.h"
#import "LSRecommendAnchorItemObject.h"
#import "LSImageViewLoader.h"
NS_ASSUME_NONNULL_BEGIN
@class LSMyContactsListCell;
@protocol LSMyContactsListCellDelegate <NSObject>

- (void)myContactsListCellWillShowSlidingView:(NSInteger)row;

- (void)myContactListTableViewCellDidClickInviteBtn:
(LSMyContactsListCell *)cell;
- (void)myContactListTableViewCellDidClickBookBtn:
(LSMyContactsListCell *)cell;
- (void)myContactListTableViewCellDidClickMailBtn:
(LSMyContactsListCell *)cell;
- (void)myContactListTableViewCellDidClickChatBtn:
(LSMyContactsListCell *)cell;
@end

@interface LSMyContactsListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *ladyHead;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveIcon;
@property (weak, nonatomic) IBOutlet UIImageView *onlineIcon;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstBtnWidth;

@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (weak, nonatomic) id <LSMyContactsListCellDelegate> cellDelegate;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)setFavoitesCellMoreView:(LSRecommendAnchorItemObject *)item;
@end

NS_ASSUME_NONNULL_END
