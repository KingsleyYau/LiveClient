//
//  VIPAudienceView.h
//  livestream
//
//  Created by randy on 2017/9/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VIPAudienceView;
@protocol VIPAudienceViewDelegate <NSObject>

- (void)vipLiveReloadAudidenceView:(VIPAudienceView *)audienceView;
- (void)vipLiveLoadingAudienceView:(VIPAudienceView *)audienceView;
- (void)vipLiveAudidenveViewDidScroll;
- (void)vipLiveAudidenveViewDidEndScrolling;

@end

@interface VIPAudienceView : UIView

@property(nonatomic, weak) id<VIPAudienceViewDelegate> delegate;
@property(nonatomic, strong) NSMutableArray *audienceArray;

@end
