//
//  AgeRangeSlider.h
//  自定义UISlider
//
//  Created by lance on 16/3/31.
//  Copyright © 2016年 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgeRangeSlider : UIControl

/** 最小 */
@property (nonatomic,assign) CGFloat minValue;
/** 最大 */
@property (nonatomic,assign) CGFloat maxValue;
/** 左边 */
@property (nonatomic,assign) CGFloat leftValue;
/** 右边 */
@property (nonatomic,assign) CGFloat rightValue;
/** 滑动块图片 */
@property (nonatomic,strong) UIImage *handleImage;
/** 左边标签图片,图片与滑动模块一致 */
@property (nonatomic,strong) UIImage *leftHandleImage;
/** 右边标签图片,图片与滑动模块一致 */
@property (nonatomic,strong) UIImage *rightHandleImage;
/** 高亮图片 */
@property (nonatomic,strong) UIImage *handleHighlightedImage;
/** 左边标签高亮图片 */
@property (nonatomic,strong) UIImage *leftHandleHighlightedImage;
/** 右边标签高亮图片 */
@property (nonatomic,strong) UIImage *rightHandleHighlightedImage;
/** 背景图片 */
@property (nonatomic,strong) UIImage *trackBackgroundImage;
/** 条填充图片 */
@property (nonatomic,strong) UIImage *trackFillImage;
/** 设置值 */
@property (nonatomic,assign) CGFloat stepValue;
/** 最小间隔 */
@property (nonatomic,assign) CGFloat minimumSpacing;
/** 制定位置 */
@property (nonatomic,assign) CGFloat positionValue;
/** 制定范围的最大值必须的 */
@property (nonatomic,assign) CGFloat positionMaxValue;

@property (nonatomic,strong) UILabel *minValueLabel;
@property (nonatomic,strong) UILabel *maxValueLabel;
//外部传进来的最小值
@property (nonatomic,assign) CGFloat minAgeRange;
@end
