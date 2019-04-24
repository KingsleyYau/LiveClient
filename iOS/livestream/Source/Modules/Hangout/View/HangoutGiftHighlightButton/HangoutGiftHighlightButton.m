//
//  HangoutGiftHighlightButton.m
//  livestream
//
//  Created by Randy_Fan on 2019/3/7.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "HangoutGiftHighlightButton.h"

@implementation HangoutGiftHighlightButton

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"highlighted"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString *, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"highlighted"]) {
        if (self.highlighted) {
            if ([self.delegate respondsToSelector:@selector(HangoutGiftHighlightButtonIsHighlight)]) {
                [self.delegate HangoutGiftHighlightButtonIsHighlight];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(HangoutGiftHighlightButtonCancleHighlight)]) {
                [self.delegate HangoutGiftHighlightButtonCancleHighlight];
            }
        }
    }
}

@end
