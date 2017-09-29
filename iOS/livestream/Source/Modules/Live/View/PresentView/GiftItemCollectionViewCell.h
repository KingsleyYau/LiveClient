//
//  GiftItemCollectionViewCell.h
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AllGiftItem.h"
#import "RoomBackGiftItem.h"

@interface GiftItemCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftCountLabel;
@property (weak, nonatomic) IBOutlet UIView *haveNumView;
@property (weak, nonatomic) IBOutlet UILabel *haveNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *notSendImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;


@property (nonatomic, assign) BOOL selectCell;


- (void)backpackHiddenView;

- (void)reloadStyle;

+ (NSString *)cellIdentifier;

- (BOOL)updataCellViewItem:(AllGiftItem *)item manLV:(int)manLV loveLV:(int)loveLV;

- (void)updataBackpackCellViewItem:(RoomBackGiftItem *)backItem manLV:(int)manLV loveLV:(int)loveLV canSend:(BOOL)canSend;

@end
