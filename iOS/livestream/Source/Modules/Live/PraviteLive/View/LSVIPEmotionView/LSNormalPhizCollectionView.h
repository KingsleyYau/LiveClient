//
//  LSPhizCollectionView.h
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSChatEmotion.h"
#import "LSEmotionCollectionViewLayout.h"
#import "LSChatEmotionManager.h"

@class LSNormalPhizCollectionView;
@protocol LSNormalPhizCollectionViewDelegate <NSObject>
@optional

- (void)liveStandardEmotionView:(LSNormalPhizCollectionView *)liveStandardEmotionView didSelectNomalItem:(NSInteger)item;
@end

@interface LSNormalPhizCollectionView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>

/**
 *  事件回调
 */
@property (weak,nonatomic) id<LSNormalPhizCollectionViewDelegate> delegate;

/**
 *  表情选择控件
 */
@property (weak,nonatomic) IBOutlet UICollectionView* emotionCollectionView;

/**
 *  表情数组
 */
@property (nonatomic, retain) ChatEmotionListItem *stanListItem;


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


