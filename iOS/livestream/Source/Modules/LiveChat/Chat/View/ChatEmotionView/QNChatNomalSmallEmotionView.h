//
//  ChatNomalSmallEmotionView.h
//  dating
//
//  Created by test on 16/11/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNChatSmallGradeEmotion.h"
#import "QNChatEmotionChooseView.h"
#import "QNChatSmallEmotionView.h"
@class QNChatNomalSmallEmotionView;
@protocol ChatNormalSmallEmotionViewDelegate <NSObject>

@optional
- (void)chatNormalSmallEmotionViewDidScroll:(QNChatNomalSmallEmotionView *)normalSmallView ;
- (void)chatNormalSmallEmotionViewDidEndDecelerating:(QNChatNomalSmallEmotionView *)normalSmallView;
- (void)chatNormalSmallEmotionView:(QNChatNomalSmallEmotionView *)normalSmallView didSelectNormalItem:(NSInteger)item;
- (void)chatNormalSmallEmotionView:(QNChatNomalSmallEmotionView *)normalSmallView didSelectSmallItem:(QNChatSmallGradeEmotion *)item;
@end



@interface QNChatNomalSmallEmotionView : UIView<UIScrollViewDelegate,ChatSmallEmotionViewDelegate,ChatEmotionChooseViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
/** 小高表 */
@property (nonatomic, readonly) QNChatSmallEmotionView *smallEmotionView;
/** 普通和小高级表情 */
@property (nonatomic, readonly) QNChatEmotionChooseView *emotionInputView;


/** 代理 */
@property (nonatomic, weak) id<ChatNormalSmallEmotionViewDelegate> delegate;
/** 普通小高级表情 */
@property (nonatomic, strong) NSArray *smallEmotionArray;
/** 普通表情 */
@property (nonatomic, strong) NSArray *defaultEmotionArray;

//创建UI
- (void)createUI;

+ (instancetype)chatNormalSmallEmotionView:(id)owner;

- (void)reloadData;

//滚回首页 用于切换表情
- (void)pageScrollViewToTop;

@end
