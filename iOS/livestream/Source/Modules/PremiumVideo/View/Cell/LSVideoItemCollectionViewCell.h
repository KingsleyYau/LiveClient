//
//  LSVideoItemCollectionViewCell.h
//  livestream
//
//  Created by logan on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPremiumVideoinfoItemObject.h"

NS_ASSUME_NONNULL_BEGIN

@class LSVideoItemCollectionViewCell;
@protocol LSVideoItemCollectionViewCellDelegate <NSObject>

- (void)favoriteCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index;
- (void)toVideoDetailCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index;
- (void)toUserDetailCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index;

@end

@interface LSVideoItemCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;

- (void)setModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index;

/** 代理 */
@property (nonatomic, weak) id<LSVideoItemCollectionViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
