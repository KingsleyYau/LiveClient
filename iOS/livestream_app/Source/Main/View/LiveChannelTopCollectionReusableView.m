//
//  LiveChannelTopCollectionReusableView.m
//  livestream
//
//  Created by test on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveChannelTopCollectionReusableView.h"

@implementation LiveChannelTopCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)topBtnClickAction:(id)sender {
    if ([self.topReuableViewDelegate respondsToSelector:@selector(liveChannelTopCollectionReusableView:didClickBtn:)]) {
        [self.topReuableViewDelegate liveChannelTopCollectionReusableView:self didClickBtn:sender];
    }
    
}

@end
