//
//  ChatEmotionKeyboardView.h
//  dating
//
//  Created by Max on 16/10/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ChatEmotionListView.h"

@class LSChatEmotionKeyboardView;
@protocol LSChatEmotionKeyboardViewDelegate <NSObject>
@optional
- (Class)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView classForIndex:(NSUInteger)index;
- (NSUInteger)pagingViewCount:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView;
- (UIView *)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView pageViewForIndex:(NSUInteger)index;
- (void)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
- (void)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView didShowPageViewForDisplay:(NSUInteger)index;

- (void)chatEmotionKeyboardViewSendEmotion;
@end

@interface LSChatEmotionKeyboardView : UIView <LSPZPagingScrollViewDelegate>

@property (weak, nonatomic) id<LSChatEmotionKeyboardViewDelegate> delegate;

/**
 切换分页按钮
 */
@property (strong, nonatomic) NSArray<UIButton*>* buttons;

/**
 画廊控件
 */
@property (weak, nonatomic) IBOutlet LSPZPagingScrollView *pagingScrollView;

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
