//
//  LSVIPLivePhizCell.h
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSVIPLivePhizCell : UICollectionViewCell

@property (weak) IBOutlet UIImageView* imageView;

+ (NSString *)cellIdentifier;

@end

NS_ASSUME_NONNULL_END
