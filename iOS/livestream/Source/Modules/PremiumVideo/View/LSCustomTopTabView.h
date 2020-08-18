//
//  LSCustomTopTabView.h
//  TestDarkDemo
//
//  Created by logan on 2020/7/29.
//  Copyright © 2020 test. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LSCustomTopTabView;
@protocol LSCustomTopTabViewDelegate <NSObject>

- (void)tabView:(LSCustomTopTabView *)tabView currentSelectIndex:(NSInteger)index;

@end

@interface LSCustomTopTabView : UIView

- (instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray <NSString *> *)titleArr;

- (void)tabScrollToIndex:(NSInteger)index;

/** 默认index */
@property (nonatomic, assign) NSInteger currentIndex;

/** 是否屏幕等分 */
@property (nonatomic, assign) BOOL isSameWidth;

/** 字体颜色 */
@property (nonatomic, strong) UIColor * titleNormalColor;

/** 选中的字体颜色 */
@property (nonatomic, strong) UIColor * titleSelectedColor;

/** 下划线颜色 */
@property (nonatomic, strong) UIColor * lineColor;

/** 标签之间的间距 默认5*/
@property (nonatomic, assign) CGFloat spaceX;

/** 下划线是否跟文本一样宽 ,默认跟标签一样宽度*/
@property (nonatomic, assign) BOOL lineSameTitleWidth;

/** 代理 */
@property (nonatomic, weak) id<LSCustomTopTabViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
