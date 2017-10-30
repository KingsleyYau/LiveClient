//
//  DiscoverHeaderView.m
//  livestream
//
//  Created by lance on 2017/6/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DiscoverHeaderView.h"
#import "LiveBundle.h"

@implementation DiscoverHeaderView

+ (instancetype)initDiscoverHeaderViewXib {
    NSBundle *bundle = [LiveBundle mainBundle];
    NSArray *nibs = [bundle loadNibNamedWithFamily:@"DiscoverHeaderView" owner:nil options:nil];
    DiscoverHeaderView* view = [nibs objectAtIndex:0];

    return view;
}
@end
