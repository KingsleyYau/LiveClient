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
#import "HangoutListFriendCollectionViewCell.h"
@class HangoutListCell;
@protocol HangoutListCellDelegate <NSObject>
@optional
- (void)hangoutListCellDidHangout:(NSInteger)row;
- (void)hangoutListCellDidAchorPhoto:(NSInteger)row;
- (void)hangoutListCell:(HangoutListCell *)cell didClickAchorFriendPhoto:(NSInteger)row;
@end
@interface HangoutListCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate,HangoutListFriendCollectionViewCellDelegate>

@property (nonatomic, weak) IBOutlet LSUIImageViewTopFit *imageViewHeader;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong) NSMutableArray *animationArray;
@property (weak, nonatomic) IBOutlet UIButton *hangoutButton;
@property (nonatomic, weak) id<HangoutListCellDelegate> hangoutDelegate;
@property (weak, nonatomic) IBOutlet UIView *friendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friendWidth;
@property (weak, nonatomic) IBOutlet UIView *hangoutContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteMsgHeight;
@property (weak, nonatomic) IBOutlet UILabel *inviteMsg;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UILabel *anchorName;
@property (nonatomic, strong) NSMutableArray *friendArray;
@property (weak, nonatomic) IBOutlet LSCollectionView *collectionView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;


- (void)loadInviteMsg:(NSString *)msg;

- (void)loadFriendData:(NSArray *)items;
@end

 
