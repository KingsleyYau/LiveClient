//
//  AllTagListCollectionView.h
//  dating
//
//  Created by test on 2017/5/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSTagListCollectionViewCell.h"
#import "LSTagListCollectionViewFlowLayout.h"
#import "LSManInterestItem.h"
@class LSAllTagListCollectionView;

@protocol LSAllTagListCollectionViewDelegate <NSObject>

@optional
- (void)lsAllTagListCollectionView:(LSAllTagListCollectionView *)cell didClickViewItem:(LSManInterestItem *)item;
- (void)lsAllTagListCollectionViewUpdateHeight:(CGFloat)height;

@end
@interface LSAllTagListCollectionView : UIView

/** 所有标签 */
@property (nonatomic, strong) NSArray* allTags;

/** 选择的标签 */
@property (nonatomic, strong) NSArray* selectTags;

@property (nonatomic, strong) LSCollectionView* collectionView;


/** 代理 */
@property (nonatomic, weak) id<LSAllTagListCollectionViewDelegate> allTagDelegate;

/** view高度 */
@property (nonatomic, assign) CGFloat interestHeight;
@end
