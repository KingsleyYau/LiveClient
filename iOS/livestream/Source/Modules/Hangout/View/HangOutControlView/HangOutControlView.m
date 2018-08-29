//
//  HangOutControlView.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/11.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangOutControlView.h"
#import "LiveBundle.h"

@implementation HangOutControlView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

+ (instancetype)controlView {
    NSBundle *bundle = [LiveBundle mainBundle];
    NSArray *nib = [bundle loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    HangOutControlView *view = [nib objectAtIndex:0];
    [view.silentButton setSelected:YES];
    [view.muteButton setSelected:YES];
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)closeAction:(id)sender {
    if ([self.delagate respondsToSelector:@selector(closeControlView:)]) {
        [self.delagate closeControlView:self];
    }
}

- (IBAction)muteAction:(id)sender {
    if ([self.delagate respondsToSelector:@selector(muteOrOpenMicrophone:)]) {
        [self.delagate muteOrOpenMicrophone:self];
    }
}

- (IBAction)silentAction:(id)sender {
    if ([self.delagate respondsToSelector:@selector(silentOrLoudSound:)]) {
        [self.delagate silentOrLoudSound:self];
    }
}

- (IBAction)endAction:(id)sender {
    if ([self.delagate respondsToSelector:@selector(endHangOutLiveRoom:)]) {
        [self.delagate endHangOutLiveRoom:self];
    }
}

@end
