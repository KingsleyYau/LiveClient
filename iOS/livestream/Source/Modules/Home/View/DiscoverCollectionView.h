//
//  DiscoverCollectionView.h
//  livestream
//
//  Created by lance on 2017/5/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DiscoverCollectionViewDelegate <NSObject>
@optional
- (void)discoverCollectionView:(UICollectionView *)followView didSelectLady:(NSInteger)item;

@end

@interface DiscoverCollectionView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id <DiscoverCollectionViewDelegate> followViewDelegate;
@property (nonatomic, copy) NSArray *items;
@end
