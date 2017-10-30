//
//  LSLiveAdvancedEmotionView.h
//  livestream
//
//  Created by randy on 2017/8/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSChatEmotion.h"
#import "LSEmotionCollectionViewLayout.h"
#import "LSChatEmotionManager.h"

@class LSLiveAdvancedEmotionView;
@protocol LSLiveAdvancedEmotionViewDelegate <NSObject>
@optional

- (void)LSLiveAdvancedEmotionView:(LSLiveAdvancedEmotionView *)LSLiveAdvancedEmotionView didSelectNomalItem:(NSInteger)item;
@end

@interface LSLiveAdvancedEmotionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

/**
 *  事件回调
 */
@property (weak,nonatomic) id<LSLiveAdvancedEmotionViewDelegate> delegate;

/**
 *  表情选择控件
 */
@property (weak,nonatomic) IBOutlet UICollectionView* emotionCollectionView;

/**
 *  表情数组
 */
@property (nonatomic, retain) ChatEmotionListItem *advanListItem;
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
