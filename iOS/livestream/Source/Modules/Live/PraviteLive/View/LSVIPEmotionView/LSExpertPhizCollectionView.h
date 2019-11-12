//
//  LSExpertPhizCollectionView.h
//  livestream
//
//  Created by Calvin on 2019/9/3.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSChatEmotion.h"
#import "LSEmotionCollectionViewLayout.h"
#import "LSChatEmotionManager.h"

@class LSExpertPhizCollectionView;
@protocol LSExpertPhizCollectionViewDelegate <NSObject>
@optional

- (void)liveAdvancedEmotionView:(LSExpertPhizCollectionView *)liveAdvancedEmotionView didSelectNomalItem:(NSInteger)item;
@end

@interface LSExpertPhizCollectionView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>

/**
 *  事件回调
 */
@property (weak,nonatomic) id<LSExpertPhizCollectionViewDelegate> delegate;

/**
 *  表情选择控件
 */
@property (weak,nonatomic) IBOutlet UICollectionView* emotionCollectionView;

/**
 *  表情数组
 */
@property (nonatomic, retain) ChatEmotionListItem *advanListItem;


/**
 *  遮挡view
 */
@property (weak, nonatomic) IBOutlet UIView *tipBGView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic, assign) BOOL isCanSend;
/**
 *  生成实例
 *
 */
+ (instancetype)friendlyEmotionView:(id)owner;


/**
 *  刷新界面
 */
- (void)reloadData;

@end


