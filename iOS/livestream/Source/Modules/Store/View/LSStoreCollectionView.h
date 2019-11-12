//
//  LSStoreCollectionView.h
//  livestream
//
//  Created by Calvin on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSStoreFlowerGiftItemObject.h"

@class LSStoreCollectionView;
@protocol LSStoreCollectionViewDelegate <NSObject>

- (void)waterfallView:(LSStoreCollectionView *)view didSelectItem:(LSFlowerGiftItemObject*)item;
- (void)waterfallView:(LSStoreCollectionView *)view addCart:(NSString *)giftId forImageView:(UIImageView *)imageView;

- (void)waterfallView:(LSStoreCollectionView *)view willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)waterfallView:(LSStoreCollectionView *)view didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)waterfallViewLoadHeadViw;
@end

@interface LSStoreCollectionView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *noDataTip;
@property (nonatomic, strong) NSArray * items;
@property (weak, nonatomic) id<LSStoreCollectionViewDelegate> collectionViewDelegate;
//添加此属性的作用，根据差值，判断ScrollView是上滑还是下拉
@property (nonatomic, assign) BOOL isUpScroll;
- (void)reloadData;
@end

