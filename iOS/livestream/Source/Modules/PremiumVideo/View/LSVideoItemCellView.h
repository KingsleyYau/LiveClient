//
//  LSVideoItemCellView.h
//  livestream
//
//  Created by logan on 2020/7/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSVideoItemCellViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class LSVideoItemCellView;
@protocol LSVideoItemCellViewDelegate <NSObject>

- (void)itemCellView:(LSVideoItemCellView *)cellView favoriteCheckModel:(id<LSVideoItemCellViewModelProtocol>)model;
- (void)itemCellView:(LSVideoItemCellView *)cellView toVideoDetailCheckModel:(id<LSVideoItemCellViewModelProtocol>)model;
- (void)itemCellView:(LSVideoItemCellView *)cellView toUserDetailCheckModel:(id<LSVideoItemCellViewModelProtocol>)model;

@end

@interface LSVideoItemCellView : UIView

- (void)setViewWithModel:(id<LSVideoItemCellViewModelProtocol>)model;

/** 代理 */
@property (nonatomic, weak) id<LSVideoItemCellViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
