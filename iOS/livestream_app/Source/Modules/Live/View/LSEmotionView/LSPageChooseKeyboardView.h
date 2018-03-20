//
//  LSPageChooseKeyboardView.h
//  dating
//
//  Created by Max on 16/10/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSPageChooseKeyboardView;
@protocol LSPageChooseKeyboardViewDelegate <NSObject>
@optional
- (Class)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView classForIndex:(NSUInteger)index;
- (NSUInteger)pagingViewCount:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView;
- (UIView *)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView pageViewForIndex:(NSUInteger)index;
- (void)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
- (void)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView didShowPageViewForDisplay:(NSUInteger)index;
@end

@interface LSPageChooseKeyboardView : UIView <LSPZPagingScrollViewDelegate>

@property (assign, nonatomic) IBOutlet id<LSPageChooseKeyboardViewDelegate> delegate;

/**
 切换分页按钮
 */
@property (strong, nonatomic) NSArray<UIButton *> *buttons;

/**
 画廊控件
 */
@property (weak, nonatomic) IBOutlet LSPZPagingScrollView * pagingScrollView;

/**
 按钮
 */
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

/**
 *  生成实例
 *
 *  @return <#return value description#>
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
