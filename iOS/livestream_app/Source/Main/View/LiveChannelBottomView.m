//
//  LiveChannelBottomView.m
//  livestream
//
//  Created by test on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveChannelBottomView.h"

@implementation LiveChannelBottomView
+ (instancetype)LiveChannelBottomViewXib {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"LiveChannelBottomView" owner:nil options:nil];
    LiveChannelBottomView* view = [nibs objectAtIndex:0];
    view.frame = CGRectMake(0, 0, screenSize.width, 44);
    
    return view;
}


@end
