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
#import "AllGiftItem.h"
#import "SelectNumButton.h"

@class PresentView;
@protocol PresentViewDelegate <NSObject>

- (void)presentViewShowBalance:(PresentView *) backpackView;
- (void)presentViewdidSelectItemWithSelf:(PresentView *)presentView numberList:(NSMutableArray *)list atIndexPath:(NSIndexPath *)indexPath;
- (void)presentViewdidSelectGiftLevel:(int)level loveLevel:(int)loveLevel;
- (void)presentViewDidScroll:(PresentView *)PresentViewView currentPageNumber:(NSInteger)page;
- (void)presentViewSendBtnClick:(PresentView *)presentView andSender:(id)sender;
- (void)presentViewComboBtnInside:(PresentView *)presentView andSender:(id)sender;
- (void)presentViewComboBtnDown:(PresentView *)presentView andSender:(id)sender;
- (void)presentViewReloadList:(PresentView *)presentView;

@end

@interface PresentView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
@property (weak, nonatomic) IBOutlet CountTimeButton *comboBtn;
@property (weak, nonatomic) IBOutlet PresentSendView *sendView;
@property (weak, nonatomic) IBOutlet UIView *requestFailView;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property (weak, nonatomic) IBOutlet UILabel *failTipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipImageViewTop;

@property (assign, nonatomic) int manLevel;
@property (assign, nonatomic) int loveLevel;

// 随机可发送礼物下标数组 (NSNumber)
@property (nonatomic, strong) NSMutableArray *isPromoIndexArray;
@property (nonatomic, strong) NSArray *giftIdArray;

@property (nonatomic, assign) BOOL isCellSelect;

@property (nonatomic, strong) AllGiftItem* selectCellItem;

// 多功能按钮
@property (strong) SelectNumButton* buttonBar;

/** 代理 */
@property (nonatomic, weak) id<PresentViewDelegate> presentDelegate;


- (IBAction)showMyBalance:(id)sender;

- (void)reloadData;

// 显示多功能按钮
- (void)showButtonBar;

// 隐藏多功能按钮
- (void)hideButtonBar;

// 设置可选按钮数组
- (void)setupButtonBar:(NSArray *)sendNumList;

// 随机选中礼物
- (void)randomSelect:(NSInteger)integer;

// 显示没有礼物列表界面
- (void)showNoListView;

// 显示请求礼物列表失败界面
- (void)showRequestFailView;

// 显示礼物列表
- (void)showGiftListView;

// 发送按钮不可用
- (void)sendViewNotUserEnabled;

// 发送按钮可用
- (void)sendViewCanUserEnabled;

// 重新请求礼物列表
- (IBAction)reloadGiftList:(id)sender;


@end
