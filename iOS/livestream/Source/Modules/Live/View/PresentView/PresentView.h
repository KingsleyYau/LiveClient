//
//  PresentView.h
//  UIWidget
//
//  Created by test on 2017/6/9.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresentSendView.h"
#import "CountTimeButton.h"
#import "LiveRoomGiftItemObject.h"

@class PresentView;
@protocol PresentViewDelegate <NSObject>

- (void)presentViewdidSelectItemWithSelf:(PresentView *)presentView atIndexPath:(NSIndexPath *)indexPath;
- (void)presentViewDidScroll:(PresentView *)PresentViewView currentPageNumber:(NSInteger)page;
- (void)presentViewSendBtnClick:(PresentView *)presentView;
- (void)presentViewComboBtnInside:(PresentView *)presentView andSender:(id)sender;
- (void)presentViewComboBtnDown:(PresentView *)presentView andSender:(id)sender;

@end

@interface PresentView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
@property (weak, nonatomic) IBOutlet CountTimeButton *comboBtn;
@property (weak, nonatomic) IBOutlet PresentSendView *sendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

@property (nonatomic, strong) NSArray *giftIdArray;

@property (nonatomic, assign) BOOL isCellSelect;

@property (nonatomic, strong) LiveRoomGiftItemObject *selectCellItem;

// 多功能按钮
@property (strong) KKButtonBar* buttonBar;

/** 代理 */
@property (nonatomic, weak) id<PresentViewDelegate> presentDelegate;

// 显示多功能按钮
- (void)showButtonBar;

// 隐藏多功能按钮
- (void)hideButtonBar;

@end
