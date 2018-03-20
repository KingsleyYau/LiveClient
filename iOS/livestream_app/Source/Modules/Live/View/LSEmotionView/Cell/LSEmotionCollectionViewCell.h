//
//  LSEmotionCollectionViewCell.h
//  dating
//
//  Created by Max on 16/5/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSEmotionCollectionViewCell : UICollectionViewCell

@property (weak) IBOutlet UIImageView* imageView;

+ (NSString *)cellIdentifier;

@end
