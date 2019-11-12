//
//  LSMyCartStoreCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSCartGiftItem.h"

NS_ASSUME_NONNULL_BEGIN

@class LSMyCartStoreCell;
@protocol LSMyCartStoreCellDelegate <NSObject>
// 修改礼物数量
-(void)didSelectChangeGiftNum:(LSMyCartStoreCell *)cell item:(LSCartGiftItem *)item num:(int)num;
// 手动输入错误数量
- (void)showChangeError;
// 移除礼物
- (void)didSelectRemoveGift:(LSCartGiftItem *)item;
// 点击跳转礼物详情
- (void)didSelectGiftInfo:(LSCartGiftItem *)item;

- (void)getConvertRectToVc:(UITextField *)textField rect:(CGRect)rect;
@end

@interface LSMyCartStoreCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *storeImageView;
@property (weak, nonatomic) IBOutlet UILabel *stroeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UITextField *numTextField;

@property (weak, nonatomic) id<LSMyCartStoreCellDelegate> delagate;

// 初始化界面显示
- (void)setupContent:(LSCartGiftItem *)model;
// 修改礼物数量显示
- (void)changeGiftNum:(int)num success:(BOOL)success;

+ (NSString *)cellIdentifier;
+ (id)getUITableViewCell:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
