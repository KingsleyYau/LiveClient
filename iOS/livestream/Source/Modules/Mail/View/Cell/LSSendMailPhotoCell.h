//
//  LSSendMailPhotoCell.h
//  livestream
//
//  Created by Calvin on 2018/12/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailFileItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface LSSendMailPhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *removeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;

+ (NSString *)cellIdentifier;

- (void)updateMailPhotoStatus:(LSMailFileItem *)item;
@end

NS_ASSUME_NONNULL_END
