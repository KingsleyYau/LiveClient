//
//  LSPhizCollectionView.h
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPZPagingScrollView.h"

@class LSPhizCollectionView;
@protocol LSPhizCollectionViewDelegate <NSObject>
@optional
- (Class)pageChooseKeyboardView:(LSPhizCollectionView *)pageChooseKeyboardView classForIndex:(NSUInteger)index;
- (NSUInteger)pagingViewCount:(LSPhizCollectionView *)LSPageChooseKeyboardView;
- (UIView *)pageChooseKeyboardView:(LSPhizCollectionView *)pageChooseKeyboardView pageViewForIndex:(NSUInteger)index;
- (void)pageChooseKeyboardView:(LSPhizCollectionView *)pageChooseKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
- (void)pageChooseKeyboardView:(LSPhizCollectionView *)pageChooseKeyboardView didShowPageViewForDisplay:(NSUInteger)index;
@end

@interface LSPhizCollectionView : UIView <LSPZPagingScrollViewDelegate>

@property (assign, nonatomic) id<LSPhizCollectionViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet LSPZPagingScrollView * pagingScrollView;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (strong, nonatomic) NSArray<UIButton *> *buttons;

/**
 *  生成实例
 */
+ (instancetype)LSPageChooseKeyboardView:(id)owner;

/**
 刷新
 */
- (void)reloadData;


/**
 切换选中按钮及相应界面
 */
- (void)toggleButtonSelect:(NSInteger)index;
@end


