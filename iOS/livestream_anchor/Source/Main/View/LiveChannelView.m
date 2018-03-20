//
//  LiveChannelView.m
//  livestream
//
//  Created by test on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveChannelView.h"

@implementation LiveChannelView


+ (instancetype)initLiveChannelViewXib {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"LiveChannelView" owner:nil options:nil];
    LiveChannelView* view = [nibs objectAtIndex:0];
    view.frame = CGRectMake(0, 0, screenSize.width, 44);
    return view;
}

@end
