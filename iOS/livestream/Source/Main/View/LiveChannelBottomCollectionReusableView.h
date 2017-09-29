//
//  LiveChannelBottomCollectionReusableView.h
//  livestream
//
//  Created by test on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LiveChannelBottomCollectionReusableView;
@protocol LiveChannelBottomCollectionReusableViewDelegate <NSObject>

@optional

- (void)liveChannelBottomCollectionReusableView:(LiveChannelBottomCollectionReusableView *)bottomResuableView didClickBtn:(UIButton *)sender;

@end


@interface LiveChannelBottomCollectionReusableView : UICollectionReusableView


/** 代理 */
@property (nonatomic, weak) id<LiveChannelBottomCollectionReusableViewDelegate> bottomResuableViewDelegate;
@end
