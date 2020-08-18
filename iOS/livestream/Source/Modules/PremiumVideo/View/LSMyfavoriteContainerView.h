//
//  LSMyfavoriteContainerView.h
//  livestream
//
//  Created by logan on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSVideoCollectionView.h"
#import "LSVideoCollectionViewScrollProtocol.h"
#import "LSVideoItemCellViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class LSMyfavoriteContainerView;
@protocol LSMyfavoriteContainerViewDelegate <NSObject>

- (void)favoriteContainerViewDidClickBottomEmptyTips:(LSMyfavoriteContainerView *)conView;

@end

@interface LSMyfavoriteContainerView : UIView

/** collectionview的滚动代理 */
@property (nonatomic, weak) id <LSVideoCollectionViewScrollProtocol> colVScrollDelegate;

/** 页面跳转处理代理 */
@property (nonatomic, weak) id <LSVideoItemCellViewControlProtocol> cellDelegate;

/** 代理 */
@property (nonatomic, weak) id <LSMyfavoriteContainerViewDelegate> delegate;

/** 我收藏的列表 */
@property (nonatomic, strong) LSVideoCollectionView * myFavoriteCollectionView;

/** 是否是点击切换tab触发的请求 */
@property (nonatomic, assign) BOOL isTabRequest;

- (void)setScrollToTop;

/** 开始下拉刷新 点击tab切换时触发*/
- (void)startPullDown;

@end

NS_ASSUME_NONNULL_END
