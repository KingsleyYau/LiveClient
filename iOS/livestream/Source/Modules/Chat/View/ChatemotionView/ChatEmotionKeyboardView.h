//
//  ChatEmotionKeyboardView.h
//  dating
//
//  Created by Max on 16/10/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatEmotionKeyboardView;
@protocol ChatEmotionKeyboardViewDelegate <NSObject>
@optional
- (Class)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView classForIndex:(NSUInteger)index;
- (NSUInteger)pagingViewCount:(ChatEmotionKeyboardView *)chatEmotionKeyboardView;
- (UIView *)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView pageViewForIndex:(NSUInteger)index;
- (void)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
- (void)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView didShowPageViewForDisplay:(NSUInteger)index;
@end

@interface ChatEmotionKeyboardView : UIView <PZPagingScrollViewDelegate>

@property (assign, nonatomic) IBOutlet id<ChatEmotionKeyboardViewDelegate> delegate;

/**
 切换分页按钮
 */
@property (strong, nonatomic) NSArray<UIButton*>* buttons;

/**
 画廊控件
 */
@property (weak, nonatomic) IBOutlet PZPagingScrollView *pagingScrollView;

/**
 按钮
 */
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

/**
 *  生成实例
 *
 *  @return <#return value description#>
 */
+ (instancetype)chatEmotionKeyboardView:(id)owner;

/**
 刷新
 */
- (void)reloadData;

@end
