//
//  HotTopView.h
//  livestream
//
//  Created by Calvin on 2018/6/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotTopView;
@protocol HotTopViewDelegate <NSObject>
@optional
- (void)didSelectTopViewItemWithIndex:(NSInteger)row;

@end

@interface HotTopView : UIView 

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *iconArray;
@property (strong, nonatomic) NSArray *titleArray;

@property (weak, nonatomic) id<HotTopViewDelegate> delagate;

@end
