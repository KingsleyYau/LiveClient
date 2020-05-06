//
//  HotHeadView.h
//  livestream
//
//  Created by Calvin on 2018/6/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotHeadView;
@protocol HotHeadViewDelegate <NSObject>
@optional
- (void)didSelectHeadViewItemWithIndex:(NSInteger)row;

@end

@interface HotHeadView : UIView

@property (weak, nonatomic) IBOutlet LSCollectionView *collectionView;

@property (strong, nonatomic) NSArray *iconArray;
@property (strong, nonatomic) NSArray *titleArray;

@property (weak, nonatomic) id<HotHeadViewDelegate> delagate;

@end
