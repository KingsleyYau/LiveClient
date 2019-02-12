//
//  QNChatMoonFeeTableViewCell.h
//  dating
//
//  Created by test on 16/8/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QNChatMoonFeeTableViewCell;
@protocol ChatMoonFeeTableViewCellDelegate <NSObject>
@optional

- (void)chatMoonFeeDidClickPremiumBtn:(QNChatMoonFeeTableViewCell *)cell;

@end



@interface QNChatMoonFeeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *premiumBtn;
/** 代理 */
@property (nonatomic,weak) id<ChatMoonFeeTableViewCellDelegate> delegate;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
