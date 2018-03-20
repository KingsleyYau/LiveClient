//
//  BackpackPresentView.h
//  livestream
//
//  Created by randy on 2017/8/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresentSendView.h"
#import "CountTimeButton.h"
#import "SelectNumButton.h"
#import "RoomBackGiftItem.h"
#import "LiveGiftListManager.h"

@class BackpackPresentView;
@protocol BackpackPresentViewDelegate <NSObject>
- (void)backpackPresentViewDidSelectItemWithSelf:(BackpackPresentView *)backpackView numberList:(NSMutableArray *)list atIndexPath:(NSIndexPath *)indexPath;
- (void)backpackPresentViewDidScroll:(BackpackPresentView *)backpackView currentPageNumber:(NSInteger)page;
- (void)backpackPresentViewSendBtnClick:(BackpackPresentView *)backpackView andSender:(id)sender;
- (void)backpackPresentViewComboBtnInside:(BackpackPresentView *)backpackView andSender:(id)sender;
- (void)backpackPresentViewComboBtnDown:(BackpackPresentView *)backpackView andSender:(id)sender;
- (void)backpackPresentViewReloadList:(BackpackPresentView *)presentView;

@end


@interface BackpackPresentView : UIView < UICollectionViewDelegate, UICollectionViewDataSource >

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
@property (weak, nonatomic) IBOutlet CountTimeButton *comboBtn;
@property (weak, nonatomic) IBOutlet PresentSendView *sendView;
@property (weak, nonatomic) IBOutlet UIView *requestFailView;
@property (weak, nonatomic) IBOutlet UILabel *failTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipImageViewTop;

@property (nonatomic, strong) NSArray *giftIdArray;

@property (nonatomic, assign) BOOL isCellSelect;

@property (nonatomic, strong) AllGiftItem *selectCellItem;

// 多功能按钮
@property (strong) SelectNumButton* buttonBar;

/** 代理 */
@property (nonatomic, weak) id<BackpackPresentViewDelegate> backpackDelegate;

- (void)reloadData;

// 显示多功能按钮
- (void)showButtonBar;

// 隐藏多功能按钮
- (void)hideButtonBar;

// 设置可选按钮
- (void)setupButtonBar:(NSArray *)sendNumList;

// 显示没有礼物列表界面
- (void)showNoListView;

// 显示请求礼物列表失败界面
- (void)showRequestFailView;

// 显示礼物列表
- (void)showGiftListView;

// 重新请求礼物列表
- (IBAction)reloadGiftList:(id)sender;

@end
