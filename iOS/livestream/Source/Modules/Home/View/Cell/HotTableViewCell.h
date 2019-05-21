//
//  HotTableViewCell.h
//  livestream
//
//  Created by Max on 13-9-5.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

@class HotTableViewCell;
@protocol HotTableViewCellDelegate <NSObject>
@optional

/** 预约私密直播间 */
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickViewPublicFreeBtn:(UIButton *)sender;
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickBookPrivateBtn:(UIButton *)sender;
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickVipPrivateBtn:(UIButton *)sender;
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickViewPublicFeeBtn:(UIButton *)sender;
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickViewChatNowBtn:(UIButton *)sender;
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickViewSendMailBtn:(UIButton *)sender;
//关注按钮点击回调
- (void)hotTableViewCell:(HotTableViewCell *)cell
    didClickViewFocusBtn:(UIButton *)sender;
//SayHi按钮点击回调
- (void)hotTableViewCell:(HotTableViewCell *)cell
    didClickViewSayHiBtn:(UIButton *)sender;
@end

@interface HotTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet LSUIImageViewTopFit *imageViewHeader;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;

@property (weak, nonatomic) IBOutlet UILabel *labelRoomTitle;
@property (weak, nonatomic) IBOutlet UIImageView *liveStatus;

/** 免费公开直播间 */
@property (weak, nonatomic) IBOutlet LSHighlightedButton *viewPublicFreeBtn;
/** 预约私密直播间 */
@property (weak, nonatomic) IBOutlet LSHighlightedButton *bookPrivateBtn;
/** 高级私密直播间 */
@property (weak, nonatomic) IBOutlet LSHighlightedButton *vipPrivateBtn;
/** 付费私密直播间 */
@property (weak, nonatomic) IBOutlet LSHighlightedButton *viewPublicFeeBtn;
@property (weak, nonatomic) IBOutlet LSHighlightedButton *chatNowBtn;
@property (weak, nonatomic) IBOutlet LSHighlightedButton *sendMailBtn;
/** 播放数组 */
@property (nonatomic, strong) NSMutableArray *animationArray;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBtnTopDistance;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIButton *onlineStatus;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (nonatomic, strong) TXScrollLabelView *scrollLabelView;
@property (weak, nonatomic) IBOutlet UIImageView *freeIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollShowTitleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shadowHeight;
/** 代理 */
@property (nonatomic, weak) id<HotTableViewCellDelegate> hotCellDelegate;
@property (weak, nonatomic) IBOutlet UIButton *focusBtn;
@property (weak, nonatomic) IBOutlet LSHighlightedButton *sayhiBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorNameCenterX;
@property (weak, nonatomic) IBOutlet UIView *liveStatusView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)setScrollLabelViewText:(NSString *)text;
@end
