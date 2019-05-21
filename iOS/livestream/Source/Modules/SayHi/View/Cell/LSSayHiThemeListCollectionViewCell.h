//
//  LSSayHiThemeListCollectionViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/4/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSSayHiThemeListCollectionViewCell : UICollectionViewCell

+ (NSString *)cellIdentifier;

+ (id)getUICollectionViewCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (void)setupTheme:(NSString *)img;

@end

