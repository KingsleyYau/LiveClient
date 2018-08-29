//
//  LSHomeSettingCreditCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/7/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSHomeSettingCreditCell;
@protocol LSHomeSettingCreditCellDelegate <NSObject>
@optional;
- (void)pushToCreditsVC;
@end

@interface LSHomeSettingCreditCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *settingIcon;
@property (weak, nonatomic) IBOutlet UILabel *creditsLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (weak, nonatomic) id<LSHomeSettingCreditCellDelegate> delegate;

+ (NSInteger)cellHeight;
+ (NSString *)cellIdentifier;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)showMyCredits;

@end
