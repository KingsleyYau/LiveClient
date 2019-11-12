//
//  LSSlidingView.h
//  calvinTest
//
//  Created by Calvin on 2018/10/17.
//  Copyright © 2018年 dating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@protocol LSSlidingViewDelegate <NSObject>

- (void)slidingViewBtnDidRow:(NSString *)row;

- (void)slidingViewMoreBtnDid;
@end

@interface LSSlidingView : UIView

@property (nonatomic, weak) id<LSSlidingViewDelegate> delegate;
- (void)setMoreBtns:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
