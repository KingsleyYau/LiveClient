//
//  LSPhizPageView.h
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPZPagingScrollView.h"

@class LSPhizPageView;
@protocol LSPhizPageViewDelegate <NSObject>
@optional
- (Class)pageChooseKeyboardView:(LSPhizPageView *)pageChooseKeyboardView classForIndex:(NSUInteger)index;
- (NSUInteger)pagingViewCount:(LSPhizPageView *)pageChooseKeyboardView;
- (UIView *)pageChooseKeyboardView:(LSPhizPageView *)pageChooseKeyboardView pageViewForIndex:(NSUInteger)index;
- (void)pageChooseKeyboardView:(LSPhizPageView *)pageChooseKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
- (void)pageChooseKeyboardView:(LSPhizPageView *)pageChooseKeyboardView didShowPageViewForDisplay:(NSUInteger)index;
- (void)pageChooseKeyboardViewDidSendBtn;
@end
 
@interface LSPhizPageView : UIView<LSPZPagingScrollViewDelegate>

@property (assign, nonatomic) id<LSPhizPageViewDelegate> delegate;

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



