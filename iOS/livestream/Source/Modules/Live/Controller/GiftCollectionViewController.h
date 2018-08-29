//
//  GiftCollectionViewController.h
//  livestream
//
//  Created by Max on 2018/5/29.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGoogleAnalyticsViewController.h"

#import "GiftItemCollectionViewCell.h"

#import "LSGiftManagerItem.h"
#import "LiveRoom.h"

@class GiftCollectionViewController;
@protocol GiftCollectionViewControllerDelegate <NSObject>
@optional
- (void)didChangeGiftItem:(GiftCollectionViewController *)vc item:(LSGiftManagerItem *)item;
- (void)didChangeGiftList:(GiftCollectionViewController *)vc;
@end

@interface GiftCollectionViewController : LSGoogleAnalyticsViewController
#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;
// 选择礼物的委托
@property (nonatomic, weak) id<GiftCollectionViewControllerDelegate> vcDelegate;
// 当前选中的礼物
@property (nonatomic, strong) LSGiftManagerItem* selectGiftItem;
// 类型
@property (nonatomic, assign) GiftListType type;
// 当前选中的礼物下标
@property (nonatomic, assign) NSInteger selectedIndexPath;

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
