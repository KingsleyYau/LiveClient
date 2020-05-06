//
//  LSChatSmallEmotionView.h
//  dating
//
//  Created by test on 16/11/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ChatSmallGradeEmotion.h"
#import "ChatEmotionCreditsCollectionViewLayout.h"
@class LSChatSmallEmotionView;
@protocol LSChatSmallEmotionViewDelegate <NSObject>

@optional
//- (void)LSChatSmallEmotionView:(LSChatSmallEmotionView *)emotionListView didSelectSmallEmotion:(ChatSmallGradeEmotion *)item;

- (void)chatSmallEmotionView:(LSChatSmallEmotionView *)emotionListView currentPageNumber:(NSInteger)page;
@end

@interface LSChatSmallEmotionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>


+ (instancetype)chatSmallEmotionView:(id)owner;
- (void)reloadData;

/** 小高级表情列表 */
@property (weak, nonatomic) IBOutlet LSCollectionView *emotionCollectionView;
/** 小高级表情页数 */
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
/** 价钱描述 */
@property (weak, nonatomic) IBOutlet UILabel *creditsTip;
/** 价钱 */
@property (weak, nonatomic) IBOutlet UILabel *creditPrice;


/** 代理 */
@property (nonatomic,weak) id<LSChatSmallEmotionViewDelegate> delegate;
/** 小高级表情数组 */
@property (nonatomic,strong) NSArray *smallEmotions;

@end
