//
//  LiveChannelBottomCollectionReusableView.m
//  livestream
//
//  Created by test on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveChannelBottomCollectionReusableView.h"

@implementation LiveChannelBottomCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)goWatchBtnClickAction:(id)sender {
    
    if ([self.bottomResuableViewDelegate respondsToSelector:@selector(liveChannelBottomCollectionReusableView:didClickBtn:)]) {
        [self.bottomResuableViewDelegate liveChannelBottomCollectionReusableView:self didClickBtn:sender];
    }
}

@end
