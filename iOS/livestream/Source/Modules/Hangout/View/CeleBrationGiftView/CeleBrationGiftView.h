//
//  CeleBrationGiftView.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGiftManager.h"

@class CeleBrationGiftView;
@protocol CeleBrationGiftViewDelegate <NSObject>

- (void)celeBrationCollectionDidSelectItem:(LSGiftManagerItem *)item giftView:(CeleBrationGiftView *)giftView;
@end

@interface CeleBrationGiftView : UIView

@property (nonatomic, strong) NSArray <LSGiftManagerItem *> *giftArray;

@property (nonatomic, assign) BOOL isCellSelect;

@property (nonatomic, strong) LSGiftManagerItem* selectCellItem;

@property (nonatomic, weak) id<CeleBrationGiftViewDelegate> delegate;

/**
 界面显示
 */
- (void)showRetryView;
- (void)showNoGiftYetView;
- (void)showLoadingView;
- (void)hiddenMaskView;

@end
