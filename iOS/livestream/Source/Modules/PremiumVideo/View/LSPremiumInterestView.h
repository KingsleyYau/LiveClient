//
//  LSPremiumInterestView.h
//  livestream
//
//  Created by Albert on 2020/7/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPremiumVideoinfoItemObject.h"
#import "LSImageViewLoader.h"

@class LSPremiumInterestView;
@protocol LSPremiumInterestViewDelegate <NSObject>

@optional
- (void)didSelectInterestHeadViewItemWithIndex:(NSInteger)row;
- (void)didSelectInterestItemWithIndex:(NSInteger)row;
@end

@interface LSPremiumInterestView : UIView

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewW;
@property (strong, nonatomic) NSArray <LSPremiumVideoinfoItemObject *>*itemsArray;

@property (weak, nonatomic) id<LSPremiumInterestViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) LSImageViewLoader * imageLoader;

//- (void)setItemsArray:(NSArray<LSPremiumVideoinfoItemObject *> *)itemsArray;
-(void)reloadData;

-(void)setTitleAlignment:(NSTextAlignment)alignment;

@end

