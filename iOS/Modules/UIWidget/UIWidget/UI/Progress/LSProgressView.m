//
//  LSProgressView.m
//  
//
//  Created by lance on 2018/2/26.
//  Copyright © 2018年 net.qdating.. All rights reserved.
//

#import "LSProgressView.h"

@interface LSProgressView()


/**
 *  progressView Rect
 */
@property (nonatomic, assign) CGRect progressViewRect;

/**
 *  限制高度大小
 *
 *  @param rect self.height
 */
- (void)setHeightRestrictionOfFrame:(CGFloat)height;

@end


@implementation LSProgressView

// 进度条懒加载
- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectZero];
        // 设置默认的进度条颜色
        _progressView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.progressView];
    }
    return _progressView;
}

#pragma mark -  初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 设置默认的进度条背景颜色
        self.backgroundColor = [UIColor colorWithRed:192 / 255.0 green:217 / 255.0 blue:255 / 255.0 alpha:0.77];
        [self setHeightRestrictionOfFrame:frame.size.height];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // 设置默认的进度条背景颜色
    self.backgroundColor = [UIColor colorWithRed:192 / 255.0 green:217 / 255.0 blue:255 / 255.0 alpha:0.77];
    [self setHeightRestrictionOfFrame:self.frame.size.height];
}

#pragma mark - Privite Method
// 设置进度条高度和进度条圆角
- (void)setHeightRestrictionOfFrame:(CGFloat)height {
    CGRect rect = self.frame;
    _progressHeight = MIN(height, 100.0);
    _progressHeight = MAX(_progressHeight, 5.0);
    self.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, _progressHeight);
    self.progressViewRect = CGRectZero;
    _progressViewRect.size.height = _progressHeight;
    self.progressView.frame = _progressViewRect;
    self.layer.cornerRadius = self.progressView.layer.cornerRadius =  _progressHeight / 2.0;

}

#pragma mark - Setter
// 设置进度条位置
- (void)setProgressValue:(CGFloat)progressValue {
    _progressValue = progressValue;
    _progressValue = MIN(progressValue, self.bounds.size.width);
    _progressViewRect.size.width = _progressValue;
    CGFloat maxValue = self.bounds.size.width;
    double durationValue = (_progressValue / 2.0) / maxValue + 0.5;
//    [UIView animateWithDuration:durationValue animations:^{
        self.progressView.frame = _progressViewRect;
//    }];
}

@end
