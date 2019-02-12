//
//  QNChatSmallEmotionCollectionViewCell.h
//  dating
//
//  Created by test on 16/11/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QNChatSmallEmotionCollectionViewCell : UICollectionViewCell
@property (weak,nonatomic) IBOutlet UIImageView* imageView;

+ (NSString *)cellIdentifier;
@end
