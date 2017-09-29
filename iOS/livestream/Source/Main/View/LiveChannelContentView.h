//
//  LiveChannelContentView.h
//  livestream
//
//  Created by test on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveRoomInfoItemObject.h"
@class LiveChannelContentView;
@protocol LiveChannelContentViewDelegate <NSObject>
@optional
- (void)liveChannelContentView:(LiveChannelContentView *)contentView didSelectLady:(NSInteger)item;


- (void)liveChannelContentView:(LiveChannelContentView *)contentView didClickTop:(UIButton *)btn;
- (void)liveChannelContentView:(LiveChannelContentView *)contentView didClickGoWatch:(UIButton *)btn;
- (void)liveChannelContentView:(LiveChannelContentView *)contentView didBackPlaceholer:(UIButton *)btn;
- (void)liveChannelContentView:(LiveChannelContentView *)contentView didSelecRoom:(NSIndexPath *)room;
@end

@interface LiveChannelContentView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,KKCheckButtonDelegate>

@property (nonatomic, weak) id <LiveChannelContentViewDelegate> liveChannelDelegate;
@property (nonatomic, copy) NSArray *items;
/** 展开状态 */
@property (nonatomic, assign) BOOL spreadOut;
@end
