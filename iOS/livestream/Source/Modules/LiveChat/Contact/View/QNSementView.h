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


@property (nonatomic, strong) NSArray * titleArray;

@property (nonatomic, assign) BOOL isShowbottomLine;

//设置标题默认颜色和选中颜色
- (void)setTextNormalColor:(UIColor *)textNormalColor andSelectedColor:(UIColor *)textSelectedColor;
//设置横线默认颜色和选择颜色
- (void)setLineNormalColor:(UIColor *)lineNormalColor andelectedColor:(UIColor *)lineSelectedColor;

//生成按钮 是否对称
- (void)newTitleBtnIsSymmetry:(BOOL)isSymmetry;

+ (CGFloat)getSegmentControlW:(NSArray *)titles;

- (void)selectButtonTag:(NSInteger)tag;

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame delegate:(id<QNSementViewDelegate>)delegate isSymmetry:(BOOL)isSymmetry isShowbottomLine:(BOOL)isBottom;
//是否对称 是否显示底部线

- (void)updateBtnUnreadCount:(NSArray * )countArray;
@end
