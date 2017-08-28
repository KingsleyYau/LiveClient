//
//  ChatEmotionChooseView.h
//  dating
//
//  Created by Max on 16/5/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatEmotion.h"
#import "ChatEmotionChooseCollectionViewLayout.h"

@class ChatEmotionChooseView;
@protocol ChatEmotionChooseViewDelegate <NSObject>
@optional

- (void)chatEmotionChooseView:(ChatEmotionChooseView *)chatEmotionChooseView didSelectNomalItem:(NSInteger)item;
@end

@interface ChatEmotionChooseView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

/**
 *  事件回调
 */
@property (weak,nonatomic) id<ChatEmotionChooseViewDelegate> delegate;

/**
 *  表情选择控件
 */
@property (weak,nonatomic) IBOutlet UICollectionView* emotionCollectionView;

/**
 *  表情数组
 */
@property (retain) NSArray<ChatEmotion*>* emotions;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;


@property (nonatomic, weak) IBOutlet UIView *tipView;

@property (nonatomic, weak) IBOutlet UILabel *tipLabel;


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

/**
 *  是否有普通表情
 */
- (void)isHaveStandard:(BOOL)isHave tipString:(NSString *)str;

@end
