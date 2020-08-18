//
//  LSScheduleContentCell.h
//  livestream
//
//  Created by test on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSHttpLetterDetailItemObject.h"
#import "LSPrePaidManager.h"

NS_ASSUME_NONNULL_BEGIN
@class LSScheduleContentCell;
@protocol LSScheduleContentCellDelegate <NSObject>
@optional
- (void)lsScheduleContentCell:(LSScheduleContentCell *)cell didChooseTime:(UIButton *)btn;

@end

@interface LSScheduleContentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;

/// 已确认预约时间数
@property (weak, nonatomic) IBOutlet UILabel *minuteTime;
/// 时间选择按钮
@property (weak, nonatomic) IBOutlet UIButton *timeChoose;
/// 选择按钮标识
@property (weak, nonatomic) IBOutlet UIImageView *chooseItem;
/// 预约id
@property (weak, nonatomic) IBOutlet UILabel *scheduleBookID;
/// 预约发送时间
@property (weak, nonatomic) IBOutlet UILabel *schdeduleTimeSend;
/// 预约状态
@property (weak, nonatomic) IBOutlet UILabel *scheduleStatus;
/// 预约状态描述
@property (weak, nonatomic) IBOutlet UILabel *scheduleStatusNote;
///  开始的gtm时间
@property (weak, nonatomic) IBOutlet UILabel *scheduleGMTTime;
/// 开始的本地时间
@property (weak, nonatomic) IBOutlet UILabel *scheduleLocalTime;
/// 高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeChooseHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minutesHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewHeight;
/** 代理 */
@property (nonatomic, weak) id<LSScheduleContentCellDelegate> contentDelegate;
@property (weak, nonatomic) IBOutlet UILabel *letterContent;

@property (weak, nonatomic) IBOutlet UIView *letterBorder;
@property (weak, nonatomic) IBOutlet UIView *timeViewBorder;
@property (weak, nonatomic) IBOutlet UILabel *mailDateInfo;
@property (weak, nonatomic) IBOutlet UIButton *cancelInfoBtn;
@property (weak, nonatomic) IBOutlet UILabel *ownerMessage;

@property (weak, nonatomic) IBOutlet UIButton *cancelInfoTipNote;

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSString *)detailString;

+ (NSInteger)cellHeight;

+ (id)getUITableViewCell:(UITableView *)tableView;

+ (NSString *)cellIdentifier;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *letterContentHeight;

- (void)setupData:(LSHttpLetterDetailItemObject *)item isInbox:(BOOL)isInbox;
@end

NS_ASSUME_NONNULL_END
