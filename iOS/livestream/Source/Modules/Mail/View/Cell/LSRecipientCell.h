//
//  LSRecipientCell.h
//  livestream
//
//  Created by test on 2020/4/7.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSRecepientItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface LSRecipientCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *anchorPhoto;
@property (weak, nonatomic) IBOutlet UILabel *anchorName;

+ (NSInteger)cellWidth;
+ (NSString *)cellIdentifier;
- (void)setupUI:(LSRecepientItem *)item;
@end

NS_ASSUME_NONNULL_END
