//
//  BarrageView.m
//  BarrageDemo
//
//  Created by siping ruan on 16/9/8.
//  Copyright © 2016年 siping ruan. All rights reserved.
//

#import "BarrageView.h"

#define W self.frame.size.width
#define H self.frame.size.height
#define spaceing 0 //动画缓冲间隙
#define margin 10 //row间的间隙

@interface BarrageView ()

/**
 *  cell缓存池(用于回收展示完成的cell)
 */
@property (strong, nonatomic) NSMutableArray<BarrageViewCell *> *cellCaches;
/**
 *  记录界面正在展示的cell
 */
@property (strong, nonatomic) NSMutableArray<BarrageViewCell *> *showCells;
/**
 *  数据源
 */
@property (strong, nonatomic) NSMutableArray *dataArray;
/**
 当前插入的数组
 */
@property (strong, nonatomic) NSArray *currentArray;
/**
 *  高优先级数据源
 */
@property (strong, nonatomic) NSMutableArray *highPrioritys;
/**
 *  中优先级数据源
 */
@property (strong, nonatomic) NSMutableArray *mediumPrioritys;
/**
 *  低优先级数据源
 */
@property (strong, nonatomic) NSMutableArray *lowPrioritys;
/**
 *  记录轨道位置
 */
@property (strong, nonatomic) NSMutableArray<NSValue *> *orbitPoints;
/**
 *  记录轨道总数
 */
@property (assign, nonatomic) NSInteger numbers;

@end

@implementation BarrageView

#pragma mark - Setter/Getter

- (NSMutableArray *)cellCaches
{
    if (!_cellCaches) {
        _cellCaches = [NSMutableArray array];
    }
    return _cellCaches;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)highPrioritys
{
    if (!_highPrioritys) {
        _highPrioritys = [NSMutableArray array];
    }
    return _highPrioritys;
}

- (NSMutableArray *)mediumPrioritys
{
    if (!_mediumPrioritys) {
        _mediumPrioritys = [NSMutableArray array];
    }
    return _mediumPrioritys;
}

- (NSMutableArray *)lowPrioritys
{
    if (!_lowPrioritys) {
        _lowPrioritys = [NSMutableArray array];
    }
    return _lowPrioritys;
}

- (NSMutableArray<BarrageViewCell *> *)showCells
{
    if (!_showCells) {
        _showCells = [NSMutableArray array];
    }
    return _showCells;
}

- (NSInteger)numbers
{
    if (!_numbers) {
        _numbers = [self.dataSouce numberOfRowsInTableView:self];
    }
    return _numbers;
}

- (CGFloat)cellHeight
{
    if (_cellHeight == 0) {
        //_cellHeight = (H - margin * (self.numbers - 1)) / self.numbers;
        _cellHeight = 44;
    }
    return _cellHeight;
}

- (NSMutableArray<NSValue *> *)orbitPoints
{
    if (!_orbitPoints) {
        _orbitPoints  = [NSMutableArray array];
        for (int row  = 0; row < self.numbers; row ++) {
            CGFloat x     = 0;
            CGFloat inset = (H - (self.cellHeight + margin) * self.numbers + margin) * 0.5;
            inset         = MAX(0, inset);
            CGFloat y     = inset + (self.cellHeight + margin) * row;
            CGPoint point = CGPointMake(x, y);
                [_orbitPoints addObject:[NSValue valueWithCGPoint:point]];
        }
    }
    return _orbitPoints;
}

#pragma mark - Initial

- (instancetype)init
{
    if (self = [super init]) {
        [self addOwnViews];
    }
    return self;
}

- (void)dealloc {
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addOwnViews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self configOwnView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //因为视图在动画过程中不能响应手势，所以只能通过计算来响应用户的手势点击事件
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self];
    NSInteger row  = [self rowCalculatorOfPoint:point];
    point.y += self.cellHeight * 0.5;
    for (NSInteger index = self.showCells.count - 1; index >= 0; index--) {
        BarrageViewCell *cell = self.showCells[index];
        if (cell.row == row) {
            NSDate *nowDate       = [NSDate date];
            if (cell.stopDate) {
                nowDate               = cell.stopDate;
            }
            CGFloat offsetX       = [nowDate timeIntervalSinceDate:cell.startTime] * cell.speed;
            CGRect currentFrame   = cell.frame;
            currentFrame.origin.x = cell.frame.origin.x - offsetX - cell.frame.size.width * 0.5;
            if (CGRectContainsPoint(currentFrame, point)) {
                if ([self.delegate respondsToSelector:@selector(barrageView:didSelectedCell:)]) {
                    [self.delegate barrageView:self didSelectedCell:cell];
                }
                break;
            }
        }
    }
}

#pragma mark - Private

//轨道检测(具体的计算应该交给cell)
- (NSInteger)examineOrbit:(BarrageViewCell *)currentCell
{
    return [currentCell examineOrbitWithNumbers:self.numbers showCells:self.showCells];
}

//计算cell的初始位置
- (CGRect)FrameWithRow:(NSInteger )row width:(CGFloat)width
{
    CGPoint point = self.orbitPoints[row].CGPointValue;
    return CGRectMake(W + width, point.y + self.cellHeight * 0.5, width, self.cellHeight);
}

//根据cell的width确定动画的时间
- (NSTimeInterval)animationDurationWithCell:(BarrageViewCell *)cell width:(CGFloat)cellWdith
{
    return [cell calculateAnimationDurationWithBarrageWidth:W spacing:spaceing cellWidth:cellWdith speedBaseVlaue:self.speedBaseVlaue];
}

//检测cell是否实现了BarrageViewCellAble协议
+ (void)checkElementOfBarrages:(NSArray<id<BarrageModelAble>> *)barrages
{
    for (id<BarrageModelAble> obj in barrages) {
        if (![obj conformsToProtocol:@protocol(BarrageModelAble)]) {
            //(@"为了保证cell动画速度的正确，cell的模型必须要实现BarrageViewCellAble协议");
            NSException *e = [NSException exceptionWithName:@"BarrageModelVailed" reason:@"必须实现BarrageModelAble协议" userInfo:nil];
            @throw e;
        }
    }
}

//对数据源进行分类
- (void)assortDataArray:(NSArray *)dataArray
{
    [self.dataArray addObjectsFromArray:dataArray];
    for (id<BarrageModelAble> obj in dataArray) {
        [self addModel:obj];
    }
}

//从数据源中取出number个model用于轨道检测
- (NSArray *)subArrayWithNumber:(NSInteger)number
{
    NSMutableArray *array = [NSMutableArray array];
    if (self.highPrioritys.count) {
        [array addObjectsFromArray:self.highPrioritys];
    }
    if (self.mediumPrioritys.count) {
        [array addObjectsFromArray:self.mediumPrioritys];
    }
    if (self.lowPrioritys.count) {
        [array addObjectsFromArray:self.lowPrioritys];
    }
    if (array.count >= number) {
        NSArray *subArray = [array subarrayWithRange:NSMakeRange(0, number)];
        [self removeModels:subArray];
        return subArray;
    }else {
        [self removeModels:array];
        return array;
    }
}

//将obj添加到数据源中
- (void)addModel:(id<BarrageModelAble>)obj
{
    switch ([obj level]) {
        case PriorityLevelLow:
            [self.lowPrioritys addObject:obj];
            break;
        case PriorityLevelMedium:
            [self.mediumPrioritys addObject:obj];
            break;
        case PriorityLevelHigh:
            [self.highPrioritys addObject:obj];
            break;
    }
}

//从数据源中删除obj
- (void)removeModel:(id<BarrageModelAble>)obj
{
    switch ([obj level]) {
        case PriorityLevelLow:
            [self.lowPrioritys removeObject:obj];
            break;
        case PriorityLevelMedium:
            [self.mediumPrioritys removeObject:obj];
            break;
        case PriorityLevelHigh:
            [self.highPrioritys removeObject:obj];
            break;
    }
}

//从数据源中删除objs
- (void)removeModels:(NSArray *)objs
{
    for (id<BarrageModelAble> obj in objs) {
        if ([self.lowPrioritys containsObject:obj]) {
            [self.lowPrioritys removeObject:obj];
            continue;
        }
        if ([self.mediumPrioritys containsObject:obj]) {
            [self.mediumPrioritys removeObject:obj];
            continue;
        }
        if ([self.highPrioritys containsObject:obj]) {
            [self.highPrioritys removeObject:obj];
            continue;
        }
    }
}

//判断数据源是否为空
- (BOOL)dataArrayIsNil
{
    if (self.highPrioritys.count > 0 || self.mediumPrioritys.count > 0 || self.lowPrioritys.count > 0) {
        return NO;
    }
    return YES;
}

//计算point点所在的轨道
- (NSInteger)rowCalculatorOfPoint:(CGPoint)point
{
    //内边距
    CGFloat inset = (H - (self.cellHeight + margin) * self.numbers + margin) * 0.5;
    inset         = MAX(0, inset);
    return (point.y - inset) / (self.cellHeight + margin);
}

#pragma mark - Publick

- (BarrageViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    BarrageViewCell *availableCell = nil;
//    for (int index = 0; index < self.cellCaches.count; index++) {
//        BarrageViewCell *cell = self.cellCaches[index];
//        if ([cell.reuseIdentifier isEqualToString:identifier]) {
//            availableCell = cell;
//            break;
//        }
//    }
//    if (availableCell) {
//        [availableCell removeFromSuperview];
//        [self.cellCaches removeObject:availableCell];
//    }
    if (self.cellCaches.count) {
        availableCell = self.cellCaches.firstObject;
        [availableCell removeFromSuperview];
        [self.cellCaches removeObjectAtIndex:0];
    }
    return availableCell;
}

- (void)insertBarrages:(NSArray<id<BarrageModelAble>> *)barrages immediatelyShow:(BOOL)flag
{
    [BarrageView checkElementOfBarrages:barrages];
    if (barrages.count) {
        [self assortDataArray:barrages];
    }
    self.currentArray = barrages;
    if (flag == YES) {
        [self startAnimation];
    }
    
}

- (void)deleteBarrages:(NSArray<id<BarrageModelAble>> *)barrages
{
    for (id<BarrageModelAble> obj in barrages) {
        [self removeModel:obj];
    }
}

- (void)startAnimation
{
    NSArray *subArray = [self subArrayWithNumber:self.numbers];//需要展示的models
    for (id<BarrageModelAble> obj in subArray) {
        if (![self.dataArray containsObject:obj]) continue;
        //1.谁来展示
        BarrageViewCell *currentCell = [self.dataSouce barrageView:self cellForModel:obj];
        
        //2.在哪展示
        NSTimeInterval duration = [self animationDurationWithCell:currentCell width:[obj cellWidth]];
        NSInteger row = [self examineOrbit:currentCell];
        if (row == -1) {
            [self addModel:obj];
        } else {
            
            //3.如何展示
            currentCell.frame = [self FrameWithRow:row width:[obj cellWidth]];
            if (![self.subviews containsObject:currentCell]) {
                [self addSubview:currentCell];
            }
            __weak typeof(self) ws = self;
            [currentCell startBarrageAniamtionTime:[NSDate date] duration:duration prepare:^{
                [ws.showCells addObject:currentCell];
                if ([ws.delegate respondsToSelector:@selector(barrageView:willDisplayCell:)]) {
                    [ws.delegate barrageView:self willDisplayCell:currentCell];
                }
            } completion:^(BOOL finished) {
                [ws.cellCaches addObject:currentCell];
                [ws.showCells removeObject:currentCell];
                [ws.dataArray removeObject:obj];
                if ([ws.delegate respondsToSelector:@selector(barrageView:didEndDisplayingCell:)]) {
                    [ws.delegate barrageView:ws didEndDisplayingCell:currentCell];
                }
                if (!ws.dataArray.count) {
                    ws.currentArray = nil;
                }
            }];
        }
    }
    if (![self dataArrayIsNil]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(startAnimation) withObject:nil afterDelay:1.0];
    }
}

- (void)pauseAnimation
{
    //停止当前动画
    if (self.showCells.count) {
        [self.showCells makeObjectsPerformSelector:@selector(pauseLayerAnimation)];
    }
    //取消缓存动画
    if ([self dataArrayIsNil] == NO) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)resumeAnimation
{
    if (self.showCells.count) {
        [self.showCells makeObjectsPerformSelector:@selector(resumeLayerAnimation)];
    }
    //恢复缓存动画
    if ([self dataArrayIsNil] == NO) {
        [self performSelector:@selector(startAnimation) withObject:nil afterDelay:0.0];
    }
}

- (void)stopAnimation
{
    //暂停动画
    [self pauseAnimation];
    
    //清除缓存
    [self.showCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.showCells removeAllObjects];
    [self.cellCaches removeAllObjects];
    [self.dataArray removeAllObjects];
    [self.highPrioritys removeAllObjects];
    [self.mediumPrioritys removeAllObjects];
    [self.lowPrioritys removeAllObjects];
    [self.orbitPoints removeAllObjects];
    
    self.numbers = 0;
}

@end

@implementation BarrageView (ProtectedMethod)

- (void)addOwnViews
{
    //初始值
    self.speedBaseVlaue = 15.0;
}

- (void)configOwnView
{
    
}

@end
