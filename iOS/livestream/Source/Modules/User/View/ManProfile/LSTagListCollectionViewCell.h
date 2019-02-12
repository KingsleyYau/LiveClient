//
//  TagListCollectionViewCell.h
//  dating
//
//  Created by test on 2017/5/4.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSTagListCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *interestTag;


+ (NSString *)cellIdentifier;

@end
