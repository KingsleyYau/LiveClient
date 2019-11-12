//
//  RecommendCollectionViewLayout.h
//  livestream
//
//  Created by Randy_Fan on 2019/6/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecommendCollectionViewLayout : UICollectionViewFlowLayout

@property (assign, nonatomic) NSInteger pageCount;
@property (nonatomic,assign) NSInteger currentPage;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
