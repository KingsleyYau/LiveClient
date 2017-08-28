//
//  ChatFriendlyEmotionView.h
//  livestream
//
//  Created by randy on 2017/8/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatEmotion.h"
#import "ChatEmotionChooseCollectionViewLayout.h"

@class ChatFriendlyEmotionView;
@protocol ChatFriendlyEmotionViewDelegate <NSObject>
@optional

- (void)chatFriendlyEmotionView:(ChatFriendlyEmotionView *)chatFriendlyEmotionView didSelectNomalItem:(NSInteger)item;
@end

@interface ChatFriendlyEmotionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

/**
 *  事件回调
 */
@property (weak,nonatomic) id<ChatFriendlyEmotionViewDelegate> delegate;

/**
 *  表情选择控件
 */
@property (weak,nonatomic) IBOutlet UICollectionView* emotionCollectionView;

/**
 *  表情数组
 */
@property (retain) NSArray<ChatEmotion*>* emotions;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;

/**
 *  遮挡view
 */
@property (weak, nonatomic) IBOutlet UIView *tipView;


@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

/**
 *  生成实例
 *
 *  @return <#return value description#>
 */
+ (instancetype)friendlyEmotionView:(id)owner;

// 亲密度是否提升
- (void)friendlyIsImpove:(BOOL)isImpove;


/**
 *  刷新界面
 */
- (void)reloadData;

@end
