//
//  LSSayHiRecommendView.h
//  livestream
//
//  Created by test on 2019/4/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSayHiAnchorItemObject.h"
NS_ASSUME_NONNULL_BEGIN
@class LSSayHiRecommendView;

@protocol LSSayHiRecommendViewDelegate <NSObject>
@optional
- (void)lsSayHiRecommendView:(LSSayHiRecommendView*)view didSelectAchor:(LSSayHiAnchorItemObject *)lady;
@end

@interface LSSayHiRecommendView : LSCollectionView <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) id<LSSayHiRecommendViewDelegate> recommendDelegate;
@property (nonatomic, strong) NSArray *items;
@end

NS_ASSUME_NONNULL_END
