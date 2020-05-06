//
//  LSVIPLiveGiftListCell.h
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGiftManagerItem.h"
#import "LiveRoom.h"

typedef enum GiftListType {
    GiftListTypeNormal,
    GiftListTypeBackpack,
} GiftListType;

@interface LSVIPLiveGiftListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *giftBgView;
@property (weak, nonatomic) IBOutlet UIImageView *giftBigImageView;
@property (weak, nonatomic) IBOutlet UIView *giftCountView;
@property (weak, nonatomic) IBOutlet UILabel *giftCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftCreditLabel;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (assign, nonatomic) BOOL selectCell;

/**
 Cell标识
 
 @return Cell标识
 */
+ (NSString *)cellIdentifier;

/**
 更新状态
 
 @param item 礼物数据
 @param type 类型(普通礼物/背包礼物)
 */
- (void)updateItem:(LSGiftManagerItem *)item liveRoom:(LiveRoom *)liveRoom type:(NSString *)type;

/**
 刷新选中状态
 */
- (void)reloadSelectedItem;
@end

 
