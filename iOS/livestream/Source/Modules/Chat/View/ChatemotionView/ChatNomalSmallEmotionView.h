//
//  ChatNomalSmallEmotionView.h
//  dating
//
//  Created by test on 16/11/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatEmotionChooseView.h"
@class ChatNomalSmallEmotionView;
@protocol ChatNormalSmallEmotionViewDelegate <NSObject>

@optional
- (void)chatNormalSmallEmotionViewDidScroll:(ChatNomalSmallEmotionView *)normalSmallView ;
- (void)chatNormalSmallEmotionViewDidEndDecelerating:(ChatNomalSmallEmotionView *)normalSmallView;
- (void)chatNormalSmallEmotionView:(ChatNomalSmallEmotionView *)normalSmallView didSelectNormalItem:(NSInteger)item;
@end



@interface ChatNomalSmallEmotionView : UIView<UIScrollViewDelegate,ChatEmotionChooseViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
/** 普通和小高级表情 */
@property (nonatomic, readonly) ChatEmotionChooseView *emotionInputView;

/** 代理 */
@property (nonatomic, weak) id<ChatNormalSmallEmotionViewDelegate> delegate;
/** 普通表情 */
@property (nonatomic, strong) NSArray *defaultEmotionArray;

//创建UI
- (void)createUI;

+ (instancetype)chatNormalSmallEmotionView:(id)owner;

- (void)reloadData;

//滚回首页 用于切换表情
- (void)pageScrollViewToTop;

@end
