//
//  GiftItemCollectionViewCell.h
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGiftManagerItem.h"

typedef enum GiftListType {
    GiftListTypeNormal,
    GiftListTypeBackpack,
} GiftListType;

@interface GiftItemCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *giftBigImageView;
@property (weak, nonatomic) IBOutlet UIView *giftCountView;
@property (weak, nonatomic) IBOutlet UILabel *giftCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *giftLockImageView;
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftCreditLabel;

@property (assign, nonatomic) BOOL selectCell;

/**
 Cell标识

 @return Cell标识
 */
+ (NSString *)cellIdentifier;

/**
 更新状态

 @param item 礼物数据
 @param manLevel 用户等级
 @param lovelLevel 亲密度等级
 @param type 类型(普通礼物/背包礼物)
 */
- (void)updateItem:(LSGiftManagerItem *)item manLevel:(NSInteger)manLevel lovelLevel:(NSInteger)lovelLevel type:(GiftListType)type;

/**
 刷新选中状态
 */
- (void)reloadSelectedItem;

@end
