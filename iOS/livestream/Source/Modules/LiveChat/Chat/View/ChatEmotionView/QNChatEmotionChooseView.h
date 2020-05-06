//
//  QNChatEmotionChooseView.h
//  dating
//
//  Created by Max on 16/5/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNChatEmotion.h"
#import "QNChatSmallGradeEmotion.h"
#import "QNChatEmotionCreditsCollectionViewLayout.h"

@class QNChatEmotionChooseView;
@protocol ChatEmotionChooseViewDelegate <NSObject>
@optional

- (void)chatEmotionChooseView:(QNChatEmotionChooseView *)chatEmotionChooseView didSelectNomalItem:(NSInteger)item;
- (void)chatEmotionChooseView:(QNChatEmotionChooseView *)chatEmotionChooseView didSelectSmallItem:(QNChatSmallGradeEmotion *)item;
@end

@interface QNChatEmotionChooseView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

/**
 *  事件回调
 */
@property (weak,nonatomic) id<ChatEmotionChooseViewDelegate> delegate;

/**
 *  表情选择控件
 */
@property (weak,nonatomic) IBOutlet LSCollectionView *emotionCollectionView;
@property (weak, nonatomic) IBOutlet LSCollectionView *smallEmotionCollectionView;

/**
 *  表情数组
 */
@property (retain) NSArray<QNChatEmotion*>* emotions;
///** 默认表情界面的小高表数组 */
//@property (nonatomic,strong) NSArray<ChatSmallGradeEmotion *> *smallEmotions;
/** 默认表情界面的小高表数组 */
@property (nonatomic,strong) NSArray<QNChatSmallGradeEmotion *> *smallEmotions;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;

/**  */
@property (nonatomic,strong) QNChatEmotionCreditsCollectionViewLayout *layout;
@property (weak, nonatomic) IBOutlet UILabel *priceDescription;
@property (weak, nonatomic) IBOutlet UILabel *priceTips;


/**
 *  生成实例
 *
 *  @return <#return value description#>
 */
+ (instancetype)emotionChooseView:(id)owner;

/**
 *  刷新界面
 */
- (void)reloadData;

@end
