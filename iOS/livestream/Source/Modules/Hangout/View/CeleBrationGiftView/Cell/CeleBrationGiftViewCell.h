//
//  CeleBrationGiftViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGiftManager.h"

@interface CeleBrationGiftViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;

@property (weak, nonatomic) IBOutlet UILabel *creditsLabel;

@property (nonatomic, assign) BOOL selectCell;

+ (NSString *)cellIdentifier;

- (void)reloadStyle;

- (void)updataCellViewItem:(LSGiftManagerItem *)item;

@end
