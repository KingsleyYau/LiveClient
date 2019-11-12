//
//  VouChersListTableViewCell.h
//  livestream
//
//  Created by test on 2019/6/14.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
NS_ASSUME_NONNULL_BEGIN

@interface VouchersListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *voucherTime;
@property (weak, nonatomic) IBOutlet UILabel *voucherType;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *voucherCondition;
@property (weak, nonatomic) IBOutlet UILabel *voucherValidty;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageV;
@property (weak, nonatomic) IBOutlet UIImageView *unreadIcon;
@property (weak, nonatomic) IBOutlet UILabel *expiringNote;
+ (NSString *)cellIdentifier;
+ (id)getUITableViewCell:(UITableView *)tableView;
+ (NSInteger)cellHeight;

/**
 更新有效时间

 @param startTime 开始时间
 @param expTime 到期时间
 */
- (void)updateValidTime:(NSInteger)startTime expTime:(NSInteger)expTime;

/**
 更新指定用户
 
 @param anchorId 绑定主播
 @param voucherType 试用卷类型
 */
- (void)updatelimitedVoucherType:(NSString *)voucherType withAchor:(NSString *)anchorId;
@end

NS_ASSUME_NONNULL_END
