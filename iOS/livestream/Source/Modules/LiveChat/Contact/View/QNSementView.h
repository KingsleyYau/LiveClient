//
//  LCSementView.h
//  testSegment
//
//  Created by test on 2018/11/22.
//  Copyright © 2018年 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QNSementViewDelegate <NSObject>

@optional
- (void)segmentControlSelectedTag:(NSInteger)tag;

@end

@interface QNSementView : UIView

@property (nonatomic, weak) id<QNSementViewDelegate> delegate;

@property (nonatomic, strong) UIColor * textSelectedColor;

@property (nonatomic, strong) UIColor * textNormalColor;


+ (CGFloat)getSegmentControlW:(NSArray *)titles;

- (void)selectButtonTag:(NSInteger)tag;

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame delegate:(id<QNSementViewDelegate>)delegate isSymmetry:(BOOL)isSymmetry isShowbottomLine:(BOOL)isBottom;
//是否对称 是否显示底部线

- (void)updateBtnUnreadCount:(NSArray * )countArray;
@end
