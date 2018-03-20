//
//  LiveChannelTopCollectionReusableView.h
//  livestream
//
//  Created by test on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LiveChannelTopCollectionReusableView;
@protocol LiveChannelTopCollectionReusableViewDelegate <NSObject>
@optional
- (void)liveChannelTopCollectionReusableView:(LiveChannelTopCollectionReusableView *)reusableView didClickBtn:(UIButton *)sender;
@end

@interface LiveChannelTopCollectionReusableView : UICollectionReusableView

/** 代理 */
@property (nonatomic, weak) id<LiveChannelTopCollectionReusableViewDelegate> topReuableViewDelegate;

@end
