//
//  LSNavTitleView.m
//  livestream
//
//  Created by test on 2019/10/30.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSNavTitleView.h"

@implementation LSNavTitleView

// 用于适配ios11 titleView支持autolayout，这要求titleView必须是能够自撑开的或实现了- intrinsicContentSize
- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}
@end
