//
//  LSGiftTypeCell.h
//  livestream
//
//  Created by Calvin on 2019/9/5.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

 

@interface LSGiftTypeCell : UICollectionViewCell

+ (NSString *)cellIdentifier;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *starIcon;

@end

 
