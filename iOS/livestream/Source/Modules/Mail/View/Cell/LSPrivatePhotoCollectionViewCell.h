//
//  LSPrivatePhotoCollectionViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailAttachmentModel.h"

@interface LSPrivatePhotoCollectionViewCell : UICollectionViewCell

+ (NSString *)cellIdentifier;

- (void)setupImageDetail:(LSMailAttachmentModel *)model;

@end
