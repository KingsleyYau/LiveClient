//
//  HangoutGiftCellCollectionViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/21.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGiftManager.h"

@class HangoutGiftCellCollectionViewCell;
@protocol HangoutGiftCellCollectionViewCellDelegate <NSObject>
- (void)sendGiftToAnchor:(NSInteger)index;
@end

@interface HangoutGiftCellCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;

@property (weak, nonatomic) IBOutlet UILabel *creditLabel;

@property (weak, nonatomic) IBOutlet UIImageView *signImageView;

@property (weak, nonatomic) id<HangoutGiftCellCollectionViewCellDelegate> delegate;

- (void)setHighlightButtonTag:(NSInteger)tag;

- (void)updataCellViewItem:(LSGiftManagerItem *)item;

+ (NSString *)cellIdentifier;

@end
