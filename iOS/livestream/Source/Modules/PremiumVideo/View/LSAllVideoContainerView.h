//
//  LSAllVideoContainerView.h
//  livestream
//
//  Created by logan on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSVideoCollectionView.h"
#import "LSVideoCollectionViewScrollProtocol.h"
#import "LSPremiumVideoTypeItemObject.h"
#import "LSVideoItemCellViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSAllVideoContainerView : UIView

/** 标签数据 */
@property (nonatomic, copy) NSArray <LSPremiumVideoTypeItemObject *>* tagArr;

/** collectionview的滚动代理 */
@property (nonatomic, weak) id <LSVideoCollectionViewScrollProtocol> colVScrollDelegate;

/** 页面跳转处理代理 */
@property (nonatomic, weak) id <LSVideoItemCellViewControlProtocol> delegate;

/** 所有视频列表 */
@property (nonatomic, strong) LSVideoCollectionView * allVideoCollectionView;

/** 是否是点击按钮触发的请求 */
@property (nonatomic, assign) BOOL isClickRequest;

/** 滚动到顶部*/
- (void)setScrollToTop;
/** 是否允许下拉上拉刷新*/
- (void)setPullScrollEnable:(BOOL)isEnable;

@end

NS_ASSUME_NONNULL_END
