//
//  LSGiftCollectionView.h
//  livestream
//
//  Created by Calvin on 2019/9/20.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSVIPLiveGiftListCell.h"
#import "LSGiftManagerItem.h"
#import "LiveRoom.h"

@class LSGiftCollectionView;
@protocol LSGiftCollectionViewDelegate <NSObject>
@optional
- (void)didChangeGiftItem:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item;
- (void)didSendGiftItem:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item;
@end


@interface LSGiftCollectionView : UIView

#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;
// 选择礼物的委托
@property (nonatomic, weak) id<LSGiftCollectionViewDelegate> delegate;
// 当前选中的礼物
@property (nonatomic, strong) LSGiftManagerItem* selectGiftItem;
// 类型
@property (nonatomic, assign) GiftListType type;
// 当前选中的礼物下标
@property (nonatomic, assign) NSInteger selectedIndexPath;

//礼物类型id
@property (nonatomic, copy) NSString * giftTypeId;
/**
 刷新数据
 */
- (void)reloadData;

/**
 选中指定礼物
 
 @param item 礼物
 */
- (void)selectItem:(LSGiftManagerItem *)item;

@end
 
