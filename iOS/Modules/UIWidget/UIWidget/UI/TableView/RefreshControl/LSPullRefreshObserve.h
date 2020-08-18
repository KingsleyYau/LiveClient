//
//  LSPullRefreshObserve.h
//  UIWidget
//
//  Created by test on 2019/7/24.
//  Copyright © 2019 drcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSPullRefreshObserve : NSObject

@property (nonatomic, weak) UIScrollView *scrollView;
- (void)addObserve;
- (void)removeObserve;
@end

NS_ASSUME_NONNULL_END
