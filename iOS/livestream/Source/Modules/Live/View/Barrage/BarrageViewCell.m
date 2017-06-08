//
//  BarrageViewCell.m
//  BarrageDemo
//
//  Created by siping ruan on 16/9/8.
//  Copyright © 2016年 siping ruan. All rights reserved.
//

#import "BarrageViewCell.h"

@interface BarrageViewCell ()<CAAnimationDelegate>

@property (copy, nonatomic) void (^completed)(BOOL);

@end

@implementation BarrageViewCell

#pragma mark - Inital

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    if (self = [super init]) {
        self = [self reloadCustomCell];
//        self = [[[self class] alloc] init];
        _reuseIdentifier = identifier;
    }
    return self;
}

#pragma mark - Private
/**
 *  碰撞检测
 *
 *  @param cell 当前轨道上正在执行动画的最后一个cell
 *
 *  @return 检测结果 YES为会碰撞
 */
- (BOOL)examineColide:(BarrageViewCell *)cell
{
    NSTimeInterval t1 = self.duration - self.cellWidth / self.speed - 0.3;
    //如果currentCell现在就开始发送，动画执行完成时的时间
    NSDate *nowDate = [NSDate date];
    if (_stopDate) {
        nowDate = _stopDate;
    }
    NSDate *date1 = [nowDate dateByAddingTimeInterval:t1];
    NSDate *date2 = [cell.startTime dateByAddingTimeInterval:cell.duration];
    if ([date1 compare:date2] == NSOrderedDescending) {
        return NO;
    }else {
        return YES;
    }
}

#pragma mark - Public

//优化：让showCells记录每条轨道上最后一个正在执行动画的cell
- (NSInteger)examineOrbitWithNumbers:(NSInteger)numbers showCells:(NSMutableArray *)showCells
{
    NSMutableArray<NSNumber *> *orbits = [NSMutableArray array];//记录可用的轨道
    NSMutableArray<NSNumber *> *freeOrbits = [NSMutableArray array];//记录空闲轨道
    //按cell的动画开始时间进行升序排列
    [showCells sortUsingComparator:^NSComparisonResult(BarrageViewCell *obj1, BarrageViewCell *obj2) {
        return [obj1.startTime compare:obj2.startTime];
    }];
    for (int row = 0; row < numbers; row++) {
        if (showCells.count == 0) {
            [freeOrbits addObject:[NSNumber numberWithInt:row]];
        }else {
            BOOL flag = NO;//标记row轨道上是否有cell正在执行动画
            for (int index = (int)showCells.count - 1; index >= 0; index--) {
                BarrageViewCell *cell = showCells[index];
                if (cell.row == row) {//找到row轨道上正在滚动的最后一条弹幕
                    flag = YES;
                    if ([self examineColide:cell] == NO) {
                        //当前row轨道上有cell，但不会碰撞
                        [orbits addObject:[NSNumber numberWithInt:row]];
                    }
                    break;
                }
            }
            if (flag == NO) {
                //当前row轨道空闲
                [freeOrbits addObject:[NSNumber numberWithInt:row]];
            }
        }
    }
    
    if (orbits.count == 0 && freeOrbits.count == 0) {
        _row = -1;
    }else {
        //从可用轨道中随机一个
        if (freeOrbits.count > 0) {
            int index = arc4random_uniform((u_int32_t)freeOrbits.count);
            _row      = freeOrbits[index].integerValue;
        }else {
            int index = arc4random_uniform((u_int32_t)orbits.count);
            _row      = orbits[index].integerValue;
        }
    }
    return _row;
}

- (NSTimeInterval)calculateAnimationDurationWithBarrageWidth:(CGFloat)width spacing:(CGFloat)spacing cellWidth:(CGFloat)cellWidth speedBaseVlaue:(CGFloat)vlaue
{
    _cellWidth         = cellWidth;
    CGFloat wholeWidth = width + cellWidth + spacing;
    _speed             = wholeWidth / vlaue;
    _duration          = (width + spacing) / _speed;
    return _duration;
}

- (void)startBarrageAniamtionTime:(NSDate *)date duration:(NSTimeInterval)duration prepare:(void (^)(void))prepare completion:(void (^)(BOOL))completion
{
    _startTime = date;
    _duration = duration;
    if (prepare) {
        prepare();
    }
    self.completed           = completion;
    CABasicAnimation *move   = [CABasicAnimation animation];
    move.keyPath             = @"position";
    CGRect frame             = self.frame;
    CGPoint fromPoint        = CGPointMake(frame.origin.x, frame.origin.y);
    CGPoint toPoint          = CGPointMake(- CGRectGetWidth(frame), frame.origin.y);
    move.fromValue           = [NSValue valueWithCGPoint:fromPoint];
    move.toValue             = [NSValue valueWithCGPoint:toPoint];
    move.duration            = duration;
    move.delegate            = self;
    move.removedOnCompletion = YES;
    [self.layer addAnimation:move forKey:nil];
    
    //更新弹幕运动的速度
    CGFloat distance = [move.fromValue CGPointValue].x - [move.toValue CGPointValue].x;
    _speed = distance / move.duration;
}

- (void)pauseLayerAnimation
{
    //记录时间
    _stopDate                 = [NSDate date];
    //停止动画
    CFTimeInterval pausedTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.layer.speed          = 0.0;
    self.layer.timeOffset     = pausedTime;
}

- (void)resumeLayerAnimation
{
    CFTimeInterval pausedTime     = [self.layer timeOffset];
    self.layer.speed              = 1.0;
    self.layer.timeOffset         = 0.0;
    self.layer.beginTime          = 0.0;
    CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.layer.beginTime          = timeSincePause;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.completed) {
        self.completed(flag);
    }
}

@end

@implementation BarrageViewCell (ProtectedMethod)

- (instancetype)reloadCustomCell
{
    return nil;
}

@end
