//
//  GiftItemCollectionViewCell.h
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoomGiftItemObject.h"
#import "BackpackGiftItem.h"

@interface GiftItemCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftName;
@property (weak, nonatomic) IBOutlet UIButton *giftCount;
@property (weak, nonatomic) IBOutlet UIView *haveNumView;
@property (weak, nonatomic) IBOutlet UILabel *haveNumLabel;



@property (nonatomic, assign) BOOL selectCell;


- (void)backpackHiddenView;

- (void)reloadStyle;

+ (NSString *)cellIdentifier;

- (void)updataCellViewItem:(LiveRoomGiftItemObject *)item;

- (void)updataBackpackCellViewItem:(BackpackGiftItem *)backItem;

@end
