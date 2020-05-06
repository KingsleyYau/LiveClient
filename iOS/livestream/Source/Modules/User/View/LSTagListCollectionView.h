//
//  TagListCollectionView.h
//  dating
//
//  Created by test on 2017/5/4.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSTagListCollectionViewCell.h"
#import "LSTagListCollectionViewFlowLayout.h"
#import "LSManInterestItem.h"

@class LSTagListCollectionView;
@protocol LSTagListCollectionViewDelegate <NSObject>

@optional
- (void)lsTagListCollectionViewUpdateHeight:(CGFloat)height;

@end



@interface LSTagListCollectionView : UIView

/** 所有标签 */
@property (nonatomic, strong) NSArray* allTags;
/** 选择的标签 */
@property (nonatomic, strong) NSArray* selectTags;
@property (nonatomic, strong) LSCollectionView* collectionView;
/** 代理 */
@property (nonatomic, weak) id<LSTagListCollectionViewDelegate> tagDelegate;
/** view高度 */
@property (nonatomic, assign) CGFloat interestHeight;


@end
