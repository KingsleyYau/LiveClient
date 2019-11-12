//
//  LSPullRefreshObserve.m
//  UIWidget
//
//  Created by test on 2019/7/24.
//  Copyright © 2019 drcom. All rights reserved.
//

#import "LSPullRefreshObserve.h"
#import "UIScrollView+LSPullRefresh.h"

@implementation LSPullRefreshObserve


- (void)addObserve {
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString *, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self.scrollView lsScrollViewDidScroll];
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        [self.scrollView lsScrollViewDidChangeContentSize];
    }
}


- (void)removeObserve {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}
@end
