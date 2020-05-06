//
//  LSStoreListCell.h
//  livestream
//
//  Created by Calvin on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSFlowerGiftItemObject.h"
#import "LSImageViewLoader.h"

@protocol LSStoreListCellDelegate <NSObject>

- (void)stroeListCellAddCartBtnDid:(NSString *)giftId forImageView:(UIImageView *)imageView;

@end

@interface LSStoreListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceLabelW;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountLabelW;
@property (weak, nonatomic) IBOutlet UIImageView *stroeNewIcon;
@property (weak, nonatomic) IBOutlet UIView * offView;
@property (weak, nonatomic) IBOutlet UILabel * offLabel;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (weak, nonatomic) id<LSStoreListCellDelegate> cellDelegate;
+ (NSString *)cellIdentifier;

- (void)uploadUI:(LSFlowerGiftItemObject *)item;
@end


