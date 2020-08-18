//
//  LSVideoCollectionViewScrollProtocal.h
//  livestream
//
//  Created by logan on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LSVideoCollectionView;
@protocol LSVideoCollectionViewScrollProtocol <NSObject>

@optional
- (void)protocolVideoCollectionViewDidScroll:(LSVideoCollectionView *)collectionView;
- (void)protocolVideoCollectionViewWillBeginDragging:(LSVideoCollectionView *)collectionView;
- (void)protocolVideoCollectionViewDidEndDragging:(LSVideoCollectionView *)collectionView willDecelerate:(BOOL)decelerate;
- (void)protocolVideoCollectionViewDidEndDecelerating:(LSVideoCollectionView *)collectionView;

@end

NS_ASSUME_NONNULL_END
