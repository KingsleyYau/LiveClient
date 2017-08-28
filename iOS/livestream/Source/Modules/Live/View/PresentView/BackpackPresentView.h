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
#import "LiveRoomGiftItemObject.h"
#import "SelectNumButton.h"

@class BackpackPresentView;
@protocol BackpackPresentViewDelegate <NSObject>

- (void)backpackPresentViewDidSelectItemWithSelf:(BackpackPresentView *)backpackView atIndexPath:(NSIndexPath *)indexPath;
- (void)backpackPresentViewDidScroll:(BackpackPresentView *)backpackView currentPageNumber:(NSInteger)page;
- (void)backpackPresentViewSendBtnClick:(BackpackPresentView *)backpackView;
- (void)backpackPresentViewComboBtnInside:(BackpackPresentView *)backpackView andSender:(id)sender;
- (void)backpackPresentViewComboBtnDown:(BackpackPresentView *)backpackView andSender:(id)sender;

@end


@interface BackpackPresentView : UIView < UICollectionViewDelegate, UICollectionViewDataSource >

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
@property (weak, nonatomic) IBOutlet CountTimeButton *comboBtn;
@property (weak, nonatomic) IBOutlet PresentSendView *sendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *coinsNumLabel;

@property (nonatomic, strong) NSArray *giftIdArray;

@property (nonatomic, strong) NSMutableArray *giftItemArray;

@property (nonatomic, assign) BOOL isCellSelect;

@property (nonatomic, strong) LiveRoomGiftItemObject *selectCellItem;

// 多功能按钮
@property (strong) SelectNumButton* buttonBar;

/** 代理 */
@property (nonatomic, weak) id<BackpackPresentViewDelegate> backpackDelegate;

- (void)reloadData;

// 显示多功能按钮
- (void)showButtonBar;

// 隐藏多功能按钮
- (void)hideButtonBar;

@end
