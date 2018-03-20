//
//  BarrageView.h
//  BarrageDemo
//
//  Created by siping ruan on 16/9/8.
//  Copyright © 2016年 siping ruan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarrageViewCell.h"
#import "BarrageModelAble.h"

@protocol BarrageViewDataSouce, BarrageViewDelegate;

@interface BarrageView : UIView

/**
 *  样式协议
 */
@property (weak, nonatomic) id<BarrageViewDataSouce> dataSouce;
/**
 *  事件交互协议
 */
@property (weak, nonatomic) id<BarrageViewDelegate> delegate;
/**
 *  cell的行数
 */
@property (assign, nonatomic, readonly) NSUInteger rows;
/**
 *  弹幕滚动速度的基值，值越大滚动越慢,默认为5
 */
@property (assign, nonatomic) CGFloat speedBaseVlaue;
/**
 *  cell的高度
 */
@property (assign, nonatomic) CGFloat cellHeight;
/**
 *  取缓存中的cell
 *
 *  @param identifier 缓存标识符
 *
 *  @return 可用的cell
 */
- (__kindof BarrageViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
/**
 *  插入新的数据源
 *
 *  @param barrages cell的模型数组，模型必须要遵守BarrageModelAble协议
 *  @param flag     标记插入的新数据是否需要立即显示，如果flag为NO，后面需要主动调用startAnimation方法，插入的数据才会显示
 */
- (void)insertBarrages:(NSArray<id<BarrageModelAble> > *)barrages immediatelyShow:(BOOL)flag;
/**
 *  从数据源中删除，只能删除还未展示的cell模型，只能根据对象删除
 *
 *  @param barrages cell的模型数组
 */
- (void)deleteBarrages:(NSArray<id<BarrageModelAble> > *)barrages;
/**
 *  开始动画
 */
- (void)startAnimation;
/**
 *  暂停动画
 */
- (void)pauseAnimation;
/**
 *  继续动画
 */
- (void)resumeAnimation;
/**
 *  停止动画,所有的缓存数据都会被清空
 */
- (void)stopAnimation;

@end

//供子类重写的接口
@interface BarrageView (ProtectedMethod)

/**
 *  添加子控件
 */
- (void)addOwnViews;
/**
 *  设置子控件尺寸
 */
- (void)configOwnView;

@end

@protocol BarrageViewDataSouce <NSObject>

@required

/**
 *  设置BarrageView中展示BarrageViewCell的行数
 */
- (NSUInteger)numberOfRowsInTableView:(BarrageView *)barrageView;

/**
 *  返回弹幕的样式
 */
- (BarrageViewCell *)barrageView:(BarrageView *)barrageView cellForModel:(id<BarrageModelAble>)model;

@end

@protocol BarrageViewDelegate <NSObject, UITableViewDelegate>

@optional
/**
 *  弹幕点击事件回调
 */
- (void)barrageView:(BarrageView *)barrageView didSelectedCell:(BarrageViewCell *)cell;
/**
 *  弹幕即将显示时调用
 */
- (void)barrageView:(BarrageView *)barrageView willDisplayCell:(BarrageViewCell *)cell;
/**
 *  弹幕显示完成调用
 */
- (void)barrageView:(BarrageView *)barrageView didEndDisplayingCell:(BarrageViewCell *)cell;

@end
