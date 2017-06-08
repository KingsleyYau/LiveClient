//
//  AgeRangeSlider.m
//  自定义UISlider
//
//  Created by lance on 16/3/31.
//  Copyright © 2016年 test. All rights reserved.
//

#import "AgeRangeSlider.h"
#import <QuartzCore/QuartzCore.h>

@interface AgeRangeSlider()<UIGestureRecognizerDelegate>


@property (strong, nonatomic) UIImageView *leftHandle;
@property (strong, nonatomic) UIImageView *rightHandle;
@property (strong, nonatomic) UIImageView *sliderBackground;
@property (strong, nonatomic) UIImageView *sliderFillBackground;


/* 是否设置 */
@property (nonatomic,assign,getter=isGetSetup) BOOL setup;
@property (nonatomic,assign, readonly) CGFloat trackWidth;


@end

@implementation AgeRangeSlider

//static CGFloat const HandleTapTargetRadius = 20.0;
//设置左边的值
- (void)setLeftValue:(CGFloat)leftValue{
    if (leftValue <= self.minValue) {
        _leftValue = self.minValue;
    }else if (leftValue >= self.minValue && leftValue <= self.rightValue - self.minimumSpacing){
        //左边的的大于最小值,并且不能超过右边的值减去间距
        _leftValue = leftValue;
    }

    
    
    [self setNeedsLayout];
}



- (void)setRightValue:(CGFloat)rightValue{
    if (rightValue >= self.maxValue) {
        _maxValue = self.maxValue;
    }else if (rightValue <= self.maxValue && rightValue > self.leftValue + self.minimumSpacing){
        //右边边的的小于最大值,并且不能超过左边的值减去间距
        _rightValue = rightValue;
    }
     [self setNeedsLayout];
}

//设置最大值
- (void)setMaxValue:(CGFloat)maxValue{
    _maxValue = maxValue;
    [self setNeedsLayout];
}

//设置最小值
- (void)setMinValue:(CGFloat)minValue{
    _minValue = minValue;
    [self setNeedsLayout];
}


#pragma mark -  view的设置 
- (void)layoutSubviews{
    if (!self.isGetSetup) {
        [self setupConfig];
        self.setup = YES;
    }
    
    self.sliderBackground.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.sliderBackground.frame));
    self.sliderBackground.center = CGPointMake((floorf(CGRectGetWidth(self.bounds) / 2)), floorf(CGRectGetHeight(self.bounds )/ 2));
    
    //Handles
    //左边handle的位置
    CGFloat oneHunderPercent = self.maxValue - self.minValue;
    CGFloat leftValuePercent = self.leftValue / oneHunderPercent;

    
    CGFloat leftXcoor = floorf((self.trackWidth - self.handleImage.size.width) * leftValuePercent);
    self.leftHandle.frame = CGRectMake(0, 0, CGRectGetWidth(self.leftHandle.frame), CGRectGetHeight(self.leftHandle.frame));
    self.leftHandle.center = CGPointMake(leftXcoor, self.sliderBackground.center.y);
    
    
    //右边handel的位置
    CGFloat rightValuePercent = self.rightValue / oneHunderPercent;
    CGFloat rightXcoor = floorf((self.trackWidth - self.handleImage.size.width) * rightValuePercent) + self.handleImage.size.width;
    
//    if (self.position) {
//        rightXcoor += self.position;
//    }
    
    
    self.rightHandle.frame = CGRectMake(0, 0, CGRectGetWidth(self.rightHandle.frame), CGRectGetHeight(self.rightHandle.frame));
    self.rightHandle.center = CGPointMake(rightXcoor, self.sliderBackground.center.y);
    
    
    //fill
    //根据左边和右边的handle位置设置背景填充的大小位置
    CGFloat fillBackgroundWidth = self.rightHandle.center.x - self.leftHandle.center.x;
    self.sliderFillBackground.frame = CGRectMake(self.leftHandle.center.x, 0, fillBackgroundWidth, CGRectGetHeight(self.sliderFillBackground.frame));
    self.sliderFillBackground.center = CGPointMake(self.sliderFillBackground.center.x, self.sliderBackground.center.y);
    
    
}

//配置
- (void)setupConfig{
    if (self.maxValue == 0) {
        self.maxValue = self.positionMaxValue;
    }
    
    if (self.rightValue == 0) {
        self.rightValue = self.positionValue;
    }

    //背景图
    UIImage *emptySliderImage = self.trackBackgroundImage;
    self.sliderBackground = [[UIImageView alloc] initWithImage:emptySliderImage];
    [self addSubview:self.sliderBackground];
    //进度条
    UIImage *sliderFillImage = self.trackFillImage;
    self.sliderFillBackground = [[UIImageView alloc] initWithImage:sliderFillImage];
    [self addSubview:self.sliderFillBackground];
    
    //左边的handle图
    self.leftHandle = [[UIImageView alloc] init];
    self.leftHandle.image = self.leftHandleImage;
    self.leftHandle.highlightedImage = self.leftHandleHighlightedImage;
    self.leftHandle.frame = CGRectMake(0, 0, self.rightHandleImage.size.width, self.rightHandleImage.size.height);
    self.leftHandle.contentMode = UIViewContentModeCenter;
    self.leftHandle.userInteractionEnabled = YES;
    //添加手势
    UIPanGestureRecognizer *leftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftHandlePanEngadged:)];
    leftPanGesture.delegate = self;
    [self.leftHandle addGestureRecognizer:leftPanGesture];
    [self addSubview:self.leftHandle];
    //右边handle图
    self.rightHandle = [[UIImageView alloc] init];
    self.rightHandle.image = self.rightHandleImage;
    self.rightHandle.highlightedImage = self.rightHandleHighlightedImage;
    self.rightHandle.frame = CGRectMake(0, 0, self.rightHandleImage.size.width, self.rightHandleImage.size.height);
    self.rightHandle.contentMode = UIViewContentModeCenter;
    self.rightHandle.userInteractionEnabled = YES;
    //添加右边图的手势
    UIPanGestureRecognizer *rightPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightHandlePanEngadged:)];
    rightPanGesture.delegate = self;
    [self.rightHandle addGestureRecognizer:rightPanGesture];
    
    [self addSubview:self.rightHandle];
    
    self.minValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
    self.minValueLabel.font = [UIFont systemFontOfSize:12];
    self.minValueLabel.textAlignment = NSTextAlignmentCenter;
    [self.leftHandle addSubview:self.minValueLabel];
    
    self.maxValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
    self.maxValueLabel.font = self.minValueLabel.font;
    self.maxValueLabel.textAlignment = NSTextAlignmentCenter;
    [self.rightHandle addSubview:self.maxValueLabel];
    
    self.minValueLabel.text = [NSString stringWithFormat:@"%0.f", self.minAgeRange];
    self.maxValueLabel.text = [NSString stringWithFormat:@"%0.f",self.positionValue + self.minAgeRange];
}


#pragma mark - 图片属性
//返回滑块图片
- (UIImage *)leftHandleImage {
    if (!_leftHandleImage) {
        return [self handleImage];
    }
    return _leftHandleImage;
}
//返回滑块图片
- (UIImage *)rightHandleImage {
    if (!_rightHandleImage) {
        return [self handleImage];
    }
    return _rightHandleImage;
}


//返回滑块高亮图片
- (UIImage *)leftHandleHighlightedImage {
    if (!_leftHandleHighlightedImage) {
        return [self handleHighlightedImage];
    }
    return _leftHandleHighlightedImage;
}
//返回滑块高亮图片
- (UIImage *)rightHandleHighlightedImage {
    if (!_rightHandleHighlightedImage) {
        return [self handleHighlightedImage];
    }
    return _rightHandleHighlightedImage;
}


//设置背景图
- (UIImage *)trackBackgroundImage {
    if(!_trackBackgroundImage) {
        UIImage *image = [_trackBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)];
        _trackBackgroundImage = image;
    }
    return _trackBackgroundImage;
}

//设置背景填充图
- (UIImage *)trackFillImage {
    if(!_trackFillImage) {
        UIImage *image = [_trackFillImage resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)];
        _trackFillImage = image;
    }
    return _trackFillImage;
}

#pragma mark - 事件传递

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    for (UIView *subView in self.subviews) {
        
        UIView *hitView = [subView hitTest:[self convertPoint:point toView:subView] withEvent:event];
        if (hitView) {
            return hitView;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - 手势

- (CGFloat)roundValueToStepValue:(CGFloat)value {
    if (self.stepValue == 0.0) {
        return value;
    }
    return self.stepValue * floor((value / self.stepValue) + 0.5);
}

- (void)leftHandlePanEngadged:(UIGestureRecognizer *)gesture {
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.leftHandle.highlighted = YES;
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint pointInView = [panGesture translationInView:self];
        CGFloat oneHundredPercentOfValues = self.maxValue - self.minValue;
        
        CGFloat trackOneHundredPercent = self.trackWidth-self.handleImage.size.width;
        CGFloat trackPercentageChange = (pointInView.x / trackOneHundredPercent) * 100;
        
        self.leftValue += (trackPercentageChange / 100) * oneHundredPercentOfValues;
        
        [panGesture setTranslation:CGPointZero inView:self];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else if (panGesture.state == UIGestureRecognizerStateFailed ||
             panGesture.state == UIGestureRecognizerStateEnded ||
             panGesture.state == UIGestureRecognizerStateCancelled) {
        self.leftHandle.highlighted = NO;
        self.leftValue = [self roundValueToStepValue:self.leftValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)rightHandlePanEngadged:(UIGestureRecognizer *)gesture {
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.rightHandle.highlighted = YES;
    }
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint pointInView = [panGesture translationInView:self];
        CGFloat oneHundredPercentOfValues = self.maxValue - self.minValue;
        
        CGFloat trackOneHundredPercent = self.trackWidth - self.handleImage.size.width;
        CGFloat trackPercentageChange = (pointInView.x / trackOneHundredPercent) * 100;
        
        self.rightValue += (trackPercentageChange / 100.0) * oneHundredPercentOfValues;
        
        [panGesture setTranslation:CGPointZero inView:self];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else if (panGesture.state == UIGestureRecognizerStateFailed ||
             panGesture.state == UIGestureRecognizerStateEnded ||
             panGesture.state == UIGestureRecognizerStateCancelled) {
        self.rightHandle.highlighted = NO;
        self.rightValue = [self roundValueToStepValue:self.rightValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


#pragma mark - Helpers

- (CGFloat)trackWidth {
    
    return self.frame.size.width;
}



@end
