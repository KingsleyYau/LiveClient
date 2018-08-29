//
//  VIPAudienceView.h
//  livestream
//
//  Created by randy on 2017/9/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudienModel.h"

@class VIPAudienceView;
@protocol VIPAudienceViewDelegate <NSObject>

- (void)vipLiveAudidenveViewDidSelectItem:(AudienModel *)model;

@end

@interface VIPAudienceView : UIView

@property(nonatomic, weak) id<VIPAudienceViewDelegate> delegate;
@property(nonatomic, strong) NSMutableArray *audienceArray;

- (void)updateUserInfo;
@end
