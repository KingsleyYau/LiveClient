//
//  GSSortView.h
//  GSSortView
//
//  Created by 帅高 on 2017/11/11.
//  Copyright © 2017年 gersces. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GSSortView;
@protocol GSSortViewDelegate <NSObject>

/** 点击分选框标题
 *  index 下标
 */
- (void)gsSortViewDidScroll:(NSInteger)index;
@end

@interface GSSortView : UIView

@property (nonatomic, weak)id <GSSortViewDelegate>delegate;

/** 标题框是否等分，默认NO(设置为YES之后，markLineWidth的长度也就定了为最长的标题长，但可以修改的) */
@property (nonatomic, assign)BOOL isBarEqualParts;
/** 下标线的宽度，如果为0，那么就跟标题文字一样宽 */
@property (nonatomic, assign)CGFloat markLineWidth;
/** 标题框item的字体大小 */
@property (nonatomic, assign) CGFloat itemFont;
/** 标题框item之间的间隙 */
@property (nonatomic, assign) CGFloat itemBetween;
/** 标题框item的字体颜色 */
@property (nonatomic, strong) UIColor *textColor;
/** 标题框item的字体选中颜色 */
@property (nonatomic, strong) UIColor *textSelectColor;
/** 下标线的高度 */
@property (nonatomic, assign) CGFloat lineHeight;
/** 下标线图片 */
@property (nonatomic, strong) UIImage *lineImage;
/** 标题数组 */
@property (nonatomic,strong)NSArray *barTitles;

// 更新数据源
- (void)reloadData;

// 更新选中下标
- (void)scrollMarkLineAndSelectedItem:(CGFloat)off_X;

@end
