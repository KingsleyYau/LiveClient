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
/**
 设置表情页个数

 @return 表情页个数
 */
- (NSUInteger)pagingViewCount:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView;
/**
 设置表情对应个数的表情组件

 @param index 下标
 @return 组件类
 */
- (Class)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView classForIndex:(NSUInteger)index;
/**
 显示表情分页组件
 
 @param index 下标
 @return 返回组件视图
 */
- (UIView *)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView pageViewForIndex:(NSUInteger)index;
/**
 刷新组建数据
 */
- (void)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
/**
 点击发送按钮回调
 */
- (void)chatEmotionKeyboardViewSendEmotion;

- (void)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView didShowPageViewForDisplay:(NSUInteger)index;
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
