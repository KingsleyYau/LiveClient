//
//  ChatEmotionListView.h
//  dating
//
//  Created by test on 16/9/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNChatHighGradeEmotion.h"

@class QNChatEmotionListView;
@protocol ChatEmotionListViewDelegate <NSObject>

@optional
- (void)chatEmotionListView:(QNChatEmotionListView *)emotionListView didSelectLargeEmotion:(QNChatHighGradeEmotion *)item;
- (void)chatEmotionListView:(QNChatEmotionListView *)emotionListView didLongPressLargeEmotion:(QNChatHighGradeEmotion *)item;
- (void)chatEmotionListView:(QNChatEmotionListView *)emotionListView didLongPressReleaseLargeEmotion:(QNChatHighGradeEmotion *)item;

- (void)chatEmotionListView:(QNChatEmotionListView *)emotionListView currentPageNumber:(NSInteger)page;
@end

@interface QNChatEmotionListView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

+ (instancetype)emotionListView:(id)owner;
- (void)reloadData;

/** 高级表情列表 */
@property (weak, nonatomic) IBOutlet LSCollectionView *emotionCollectionView;
/** 高级表情页数 */
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
/** 价钱描述 */
@property (weak, nonatomic) IBOutlet UILabel *creditsTip;
/** 价钱 */
@property (weak, nonatomic) IBOutlet UILabel *creditPrice;

/** 代理 */
@property (nonatomic,weak) id<ChatEmotionListViewDelegate> delegate;
/** 高级表情数组 */
@property (nonatomic,strong) NSArray *largeEmotions;

@end
