//
//  LSAudienceViewFlowLayout.h
//  livestream
//
//  Created by test on 2019/12/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSAudienceViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) NSInteger cellCount;
@end

NS_ASSUME_NONNULL_END
