//
//  HangoutGiftCellCollectionViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/21.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGiftManager.h"

@interface HangoutGiftCellCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;

@property (weak, nonatomic) IBOutlet UILabel *creditLabel;

@property (weak, nonatomic) IBOutlet UIImageView *signImageView;

@property (assign, nonatomic) BOOL selectCell;

- (void)reloadStyle;

- (void)updataCellViewItem:(LSGiftManagerItem *)item;

+ (NSString *)cellIdentifier;

@end
