//
//  LSMyCartCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMyCartItemObject.h"
#import "LSMyCartStoreCell.h"

NS_ASSUME_NONNULL_BEGIN

@class LSMyCartCell;
@protocol LSMyCartCellDelegate <NSObject>
// 点击跳转主播详情页
- (void)didSelectAnchorInfo:(LSMyCartItemObject *)item;
// 点击跳转继续购买页
- (void)didSelectContinueShop:(LSMyCartItemObject *)item;
// 点击跳转付款界面
- (void)didSelectChectOut:(LSMyCartItemObject *)item;
// 修改礼物数量
- (void)didChangeCartGiftNum:(LSMyCartStoreCell *)cell item:(LSCartGiftItem *)item num:(int)num;
// 显示修改礼物数量错误提示
- (void)disShowChangeError;
// 移除礼物
- (void)didRemoveCartGift:(LSMyCartCell *)cell item:(LSCartGiftItem *)item;
// 点击跳转礼物详情页
- (void)didCartGiftInfo:(LSCartGiftItem *)item;

- (void)didGetConvertRectToVc:(UITextField *)textField rect:(CGRect)rect;
@end

@interface LSMyCartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet LSTableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *shopBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkoutBtn;

@property (weak, nonatomic) id<LSMyCartCellDelegate> delegate;
 // 初始化界面显示
- (void)setupContent:(LSMyCartItemObject *)model;
// 移除礼物刷新界面
- (void)removeData:(LSCartGiftItem *)item;

+ (id)getUITableViewCell:(UITableView *)tableView;
+ (NSString *)cellIdentifier;

@end

NS_ASSUME_NONNULL_END
