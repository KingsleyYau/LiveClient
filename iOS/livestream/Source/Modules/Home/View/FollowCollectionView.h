//
//  FollowCollectionView.h
//  Hot
//
//  Created by lance on 2017/5/27.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FollowCollectionViewDelegate <NSObject>
@optional
- (void)followCollectionView:(UICollectionView *)followView didSelectLady:(NSInteger)item;

@end


@interface FollowCollectionView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>



@property (nonatomic, weak) id <FollowCollectionViewDelegate> followViewDelegate;
@property (nonatomic, copy) NSArray *items;

@end
