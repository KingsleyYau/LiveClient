//
//  FollowTableViewCell.h
//  livestream
//
//  Created by test on 2017/9/8.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
@class FollowTableViewCell;
@protocol FollowTableViewCellDelegate <NSObject>
@optional

- (void)followTableViewCell:(FollowTableViewCell *)cell didClickNormalPrivateBtn:(UIButton *)sender;
- (void)followTableViewCell:(FollowTableViewCell *)cell didClickViewPublicFreeBtn:(UIButton *)sender;
- (void)followTableViewCell:(FollowTableViewCell *)cell didClickBookPrivateBtn:(UIButton *)sender;
- (void)followTableViewCell:(FollowTableViewCell *)cell didClickVipPrivateBtn:(UIButton *)sender;
- (void)followTableViewCell:(FollowTableViewCell *)cell didClickViewPublicFeeBtn:(UIButton *)sender;

@end
@interface FollowTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet LSUIImageViewTopFit *imageViewHeader;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;


@property (weak, nonatomic) IBOutlet UILabel *labelRoomTitle;
@property (weak, nonatomic) IBOutlet UIImageView *roomType;
@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet UIImageView *interest1;
@property (weak, nonatomic) IBOutlet UIImageView *interest2;
@property (weak, nonatomic) IBOutlet UIImageView *interest3;
/** 普通私密直播间  */
@property (weak, nonatomic) IBOutlet UIButton *normalPrivateBtn;
/** 免费公开直播间 */
@property (weak, nonatomic) IBOutlet UIButton *viewPublicFreeBtn;
/** 预约私密直播间 */
@property (weak, nonatomic) IBOutlet UIButton *bookPrivateBtn;
/** 高级私密直播间 */
@property (weak, nonatomic) IBOutlet UIButton *vipPrivateBtn;
/** 付费私密直播间 */
@property (weak, nonatomic) IBOutlet UIButton *viewPublicFeeBtn;
/** 播放数组 */
@property (nonatomic, strong) NSMutableArray* animationArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *normalPrivateCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vipPrivateCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vipPublicCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *normalPublicCenterX;

/** 代理 */
@property (nonatomic, weak) id<FollowTableViewCellDelegate> followCellDelegate;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
