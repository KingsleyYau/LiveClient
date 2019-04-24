//
//  CeleBrationGiftViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGiftManager.h"

@class CeleBrationGiftViewCell;
@protocol CeleBrationGiftViewCellDelegate <NSObject>
- (void)sendGiftToAnchor:(NSInteger)index;
@end

@interface CeleBrationGiftViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;

@property (weak, nonatomic) IBOutlet UILabel *creditsLabel;

@property (weak, nonatomic) id<CeleBrationGiftViewCellDelegate> delegate;

+ (NSString *)cellIdentifier;

- (void)setHighlightButtonTag:(NSInteger)tag;

- (void)updataCellViewItem:(LSGiftManagerItem *)item;

@end
