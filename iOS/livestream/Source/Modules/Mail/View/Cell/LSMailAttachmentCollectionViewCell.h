//
//  LSMailAttachmentCollectionViewCell.h
//  livestream
//
//  Created by test on 2018/12/26.
//  Copyright © 2018 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

@interface LSMailAttachmentCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
+ (NSString *)cellIdentifier;
@end
