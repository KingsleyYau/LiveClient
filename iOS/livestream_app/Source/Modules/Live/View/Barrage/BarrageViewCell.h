//
//  BarrageViewCell.h
//  BarrageDemo
//
//  Created by siping ruan on 16/9/8.
//  Copyright © 2016年 siping ruan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarrageViewCell : UIView
/**
 *  展示cell动画持续时间
 */
@property (assign, nonatomic, readonly) NSTimeInterval duration;
/**
 *  展示cell动画开始时间
 */
@property (strong, nonatomic, readonly) NSDate *startTime;
/**
 *  cell动画暂停时间
 */
@property (strong, nonatomic, readonly) NSDate *stopDate;
/**
 *  弹幕所在的轨道
 */
@property (assign, nonatomic, readonly) NSInteger row;
/**
 *  cell的宽度
 */
@property (assign, nonatomic, readonly) CGFloat cellWidth;
/**
 *  弹幕滚动速度
 */
@property (assign, nonatomic, readonly) CGFloat speed;
/**
 *  缓存标识符
 */
@property (copy, nonatomic, readonly) NSString *reuseIdentifier;
/**
 *  根据标识符创建cell
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;
/**
 *  暂停layer上的动画
 */
- (void)pauseLayerAnimation;
/**
 *  继续layer上的动画
 */
- (void)resumeLayerAnimation;
/**
 *  轨道检测
 *
 *  @param numbers   轨道总数
 *  @param showCells 当前正在轨道上显示的cell集合
 *
 *  @return 返回当前最合适展示弹幕的轨道，-1代表找不到用于展示的轨道
 */
- (NSInteger)examineOrbitWithNumbers:(NSInteger)numbers
                           showCells:(NSMutableArray *)showCells;

/**
 *  计算动画时间
 *
 *  @param width     barrageView的宽度
 *  @param spacing   动画缓冲间距
 *  @param cellWidth 当前弹幕的宽度
 *  @param vlaue     速度基值
 *
 *  @return 动画时间
 */
- (NSTimeInterval)calculateAnimationDurationWithBarrageWidth:(CGFloat)width
                                                     spacing:(CGFloat)spacing
                                                   cellWidth:(CGFloat)cellWidth
                                              speedBaseVlaue:(CGFloat)vlaue;

/**
 *  开始弹幕动画
 *
 *  @param date       开始时间
 *  @param duration   持续时间
 *  @param prepare    准备回调
 *  @param completion 完成回调
 */
- (void)startBarrageAniamtionTime:(NSDate *)date
                         duration:(NSTimeInterval)duration
                          prepare:(void(^)(void))prepare
                       completion:(void(^)(BOOL finished))completion;


@end

//供子类重写的接口
@interface BarrageViewCell (ProtectedMethod)

/**
 *  从加载自定义cell
 */
- (instancetype)reloadCustomCell;

@end
