//
//  GiftStatisticsView.h
//  livestream
//
//  Created by Randy_Fan on 2018/4/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GiftStatisticsView;
@protocol GiftStatisticsViewDelegate <NSObject>

- (void)vipLiveReloadAudidenceView:(GiftStatisticsView *)audienceView;
- (void)vipLiveLoadingAudienceView:(GiftStatisticsView *)audienceView;
- (void)vipLiveAudidenveViewDidScroll;
- (void)vipLiveAudidenveViewDidEndScrolling;

@end

@interface GiftStatisticsView : UIView

@property(nonatomic, weak) id<GiftStatisticsViewDelegate> delegate;
@property(nonatomic, strong) NSMutableArray *giftCountArray;

@end
