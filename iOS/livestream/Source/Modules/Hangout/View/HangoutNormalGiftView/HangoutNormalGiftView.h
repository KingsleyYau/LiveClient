//
//  HangoutNormalGiftView.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/21.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGiftManager.h"

@class HangoutNormalGiftView;
@protocol HangoutNormalGiftViewDelegate <NSObject>
- (void)hangoutNormalCollectionDidSelectItem:(LSGiftManagerItem *)item giftView:(HangoutNormalGiftView *)giftView;
@end

@interface HangoutNormalGiftView : UIView

@property (nonatomic, strong) NSArray <LSGiftManagerItem *> *giftArray;

@property (nonatomic, assign) BOOL isCellSelect;

@property (nonatomic, strong) LSGiftManagerItem* selectCellItem;

@property (nonatomic, weak) id<HangoutNormalGiftViewDelegate> delegate;

/**
 界面显示
 */
- (void)showRetryView;
- (void)showNoGiftYetView;
- (void)showLoadingView;
- (void)hiddenMaskView;

@end
