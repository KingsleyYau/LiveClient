//
//  LSSlidingCell.h
//  calvinTest
//
//  Created by Calvin on 2018/10/17.
//  Copyright © 2018年 dating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSlidingView.h"
NS_ASSUME_NONNULL_BEGIN

@interface LSSlidingCell : UITableViewCell
@property (strong, nonatomic)  LSSlidingView *slidingView;
@property (assign, nonatomic) BOOL isShowMoreBtn;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
- (void)showMoreView:(NSArray *)array;
- (void)showMoreBtns;
- (void)hideMoreBtns;
- (void)restMoreBtnView;
- (void)showMoreBtnView;
@end

NS_ASSUME_NONNULL_END
