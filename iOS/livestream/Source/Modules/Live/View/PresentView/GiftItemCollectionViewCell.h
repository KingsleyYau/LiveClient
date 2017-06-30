//
//  GiftItemCollectionViewCell.h
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftItemCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftName;
@property (weak, nonatomic) IBOutlet UIButton *giftCount;
@property (weak, nonatomic) IBOutlet UIImageView *countImage;

@property (nonatomic, assign) BOOL selectCell;


- (void)reloadStyle;


+ (NSString *)cellIdentifier;
@end
