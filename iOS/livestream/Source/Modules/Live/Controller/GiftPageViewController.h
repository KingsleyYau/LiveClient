//
//  GiftPageViewController.h
//  livestream
//
//  Created by Max on 2018/5/29.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSListViewController.h"

#import "LiveRoom.h"
#import "LSGiftManagerItem.h"

@class GiftPageViewController;
@protocol GiftPageViewControllerDelegate <NSObject>
@optional
- (void)didBalanceAction:(GiftPageViewController *)vc;
- (void)didCreditAction:(GiftPageViewController *)vc;
- (void)didChangeGiftList:(GiftPageViewController *)vc;
@end

@interface GiftPageViewController : LSListViewController
#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;
@property (nonatomic, weak) id<GiftPageViewControllerDelegate> vcDelegate;
@property (nonatomic, assign) NSInteger viewHeight;

/**
 刷新数据
 */
- (void)reloadData;

/**
 选中指定礼物

 @param item 礼物
 */
- (void)selectItem:(LSGiftManagerItem *)item;

/**
 重置界面
 */
- (void)reset;

@end
