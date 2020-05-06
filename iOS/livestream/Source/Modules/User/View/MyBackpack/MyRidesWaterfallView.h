//
//  MyRidesWaterfallView.h
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RideItemObject.h"
#import "MyRidesCell.h"

@protocol MyRidesWaterfallViewDelegate <NSObject>

- (void)myRidesWaterfallViewDidRiesId:(NSString*)riesId;

@end

@interface MyRidesWaterfallView : LSCollectionView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MyRidesCellDelegate>

@property (nonatomic, weak) id<MyRidesWaterfallViewDelegate> delegates;
@property (nonatomic, strong) NSArray *items;

@end
