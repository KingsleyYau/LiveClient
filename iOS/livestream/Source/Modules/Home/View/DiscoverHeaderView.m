//
//  DiscoverHeaderView.m
//  livestream
//
//  Created by lance on 2017/6/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DiscoverHeaderView.h"

@implementation DiscoverHeaderView

+ (instancetype)initDiscoverHeaderViewXib {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"DiscoverHeaderView" owner:nil options:nil];
    DiscoverHeaderView* view = [nibs objectAtIndex:0];

    
    return view;
}
@end
