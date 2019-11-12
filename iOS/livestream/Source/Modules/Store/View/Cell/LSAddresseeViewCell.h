//
//  LSAddresseeViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/10/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSAddresseeItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSAddresseeViewCell : UICollectionViewCell

+ (NSString *)cellIdentifier;
+ (id)getUICollectionViewCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)setupContent:(LSAddresseeItem *)model;

@end

NS_ASSUME_NONNULL_END
