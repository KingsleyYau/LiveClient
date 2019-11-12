//
//  LSVIPGiftPageViewController.h
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSListViewController.h"
#import "LSGiftCollectionView.h"
#import "LiveRoom.h"
#import "LSGiftManagerItem.h"

@class LSVIPGiftPageViewController;
@protocol LSVIPGiftPageViewControllerDelegate <NSObject>
@optional
- (void)showCreditView:(NSString *)tip;
- (void)didCreditAction:(LSVIPGiftPageViewController *)vc;
- (void)didUpBtnHidenGiftList:(LSVIPGiftPageViewController *)vc;
- (void)didShowGiftListInfo:(LSVIPGiftPageViewController *)vc;
@end

@interface LSVIPGiftPageViewController : LSListViewController


#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;
@property (nonatomic, weak) id<LSVIPGiftPageViewControllerDelegate> vcDelegate;
@property (nonatomic, assign) NSInteger viewHeight;

@property (nonatomic, assign) BOOL isShowView;
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
 点击发送礼物事件
 
 @param item 礼物
 */
- (void)didSendGiftAction:(LSGiftCollectionView *)view item:(LSGiftManagerItem *)item;
@end

