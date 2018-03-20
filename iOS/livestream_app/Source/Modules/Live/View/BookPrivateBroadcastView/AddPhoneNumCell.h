//
//  AddPhoneNumCell.h
//  testDemo
//
//  Created by Calvin on 17/9/25.
//  Copyright © 2017年 dating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddPhoneNumCellDelegate <NSObject>

- (void)addPhoneNumCellSwitchOn:(BOOL)isOn;

- (void)addPhoneNumCellAddBtnDid;

- (void)addPhoneNumCellChangeBtnDid;
@end

@interface AddPhoneNumCell : UITableViewCell

@property (weak, nonatomic) id <AddPhoneNumCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *switchBGView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
// isHaveNumber是否有增加过电话
+ (id)getUITableViewCell:(UITableView*)tableView isOpen:(BOOL)isOpen isHaveNumber:(BOOL)isHaveNumber;
@end
