//
//  LiveHeadView.m
//  livestream_anchor
//
//  Created by randy on 2018/2/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LiveHeadView.h"

@implementation LiveHeadView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];

    if (self) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        [self addSubview:containerView];
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (IBAction)closeLiveRoomAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(liveHeadCloseAction:)]) {
        [self.delegate liveHeadCloseAction:self];
    }
}

- (IBAction)changeCameraAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(liveHeadChangeCameraAction:)]) {
        [self.delegate liveHeadChangeCameraAction:self];
    }
}



@end
