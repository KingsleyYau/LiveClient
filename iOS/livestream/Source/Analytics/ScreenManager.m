//
//  ScreenManager.m
//  dating
//
//  Created by  Samson on 6/29/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  屏幕管理器(包括屏幕名称，屏幕路径等)

#import "ScreenManager.h"
#import "ScreenItem.h"

@interface ScreenManager()
/**
 *  屏幕路径
 */
@property (nonatomic, strong) NSMutableArray<ScreenItem*>* screens;

/**
 *  移除ViewController之后的所有屏幕
 *
 *  @param viewController ViewController
 *
 *  @return ViewController对应的ScreenItem
 */
- (ScreenItem* _Nullable)removeAfterScreen:(UIViewController* _Nonnull)viewController;
@end

@implementation ScreenManager
- (id)init
{
    self = [super init];
    if (nil != self) {
        self.screens = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 接口
/**
 *  获取当前屏幕名称
 *
 *  @return 当前屏幕名称
 */
- (NSString* _Nonnull)getCurScreenName
{
    NSString* screenName = @"";
    ScreenItem* item = [self.screens lastObject];
    if (nil != item) {
        screenName = [item getScreenName];
    }
    
    return screenName;
}

/**
 *  获取当前屏幕路径
 *
 *  @return 当前屏幕路径
 */
- (NSString* _Nonnull)getCurScreenPath
{
    NSMutableString* screenPath = [NSMutableString string];
    for (ScreenItem* item in self.screens) {
        if ([screenPath length] > 0) {
            [screenPath appendString:PATH_SEPARATOR];
        }
        [screenPath appendString:[item getScreenName]];
    }
    return screenPath;
}

/**
 *  更新当前屏幕
 *
 *  @param viewController UIViewController
 */
- (void)updateScreen:(UIViewController* _Nonnull)viewController
{
    // 移除当前屏幕后的所有屏幕
    if (nil == [self removeAfterScreen:viewController]) {
        // 屏幕不存在，判断是否创建screen item
        if ([ScreenItem isScreenItem:viewController]) {
            ScreenItem* item = [[ScreenItem alloc] init];
            if (nil != item) {
                item.viewController = viewController;
                // 添加到array
                [self.screens addObject:item];
            }
        }
    }
}

/**
 *  更新当前屏幕(带页)
 *
 *  @param viewController ViewController
 *  @param pageIndex      页码
 */
- (void)updateScreenWithPage:(UIViewController* _Nonnull)viewController pageIndex:(NSUInteger)pageIndex
{
    // 移除当前屏幕后的所有屏幕
    ScreenItem* theItem = [self removeAfterScreen:viewController];
    if (nil == theItem) {
        // 屏幕不存在，创建screen item
        ScreenItem* item = [[ScreenItem alloc] init];
        if (nil != item) {
            item.viewController = viewController;
            item.isPage = YES;
            item.curPageIndex = pageIndex;
            // 添加到array
            [self.screens addObject:item];
        }
    }
    else {
        // 屏幕已存在，更新数据
        theItem.curPageIndex = pageIndex;
    }
}

/**
 *  移除屏幕
 *
 *  @param viewController ViewController
 */
- (void)removeScreen:(UIViewController* _Nonnull)viewController
{
    // 查找指定屏幕的screen item
    BOOL isFound = NO;
    NSUInteger theIndex = 0;
    for (ScreenItem* screenItem in self.screens) {
        // 找到指定屏幕的screen item
        if (screenItem.viewController == viewController) {
            isFound = YES;
            break;
        }
        theIndex++;
    }
    
    // 移除
    if (isFound && [self.screens count] > theIndex) {
        [self.screens removeObjectsInRange:NSMakeRange(theIndex, [self.screens count] - theIndex)];
    }
}

#pragma mark - 私有
/**
 *  移除ViewController之后的所有屏幕
 *
 *  @param viewController ViewController
 *
 *  @return ViewController对应的ScreenItem
 */
- (ScreenItem* _Nullable)removeAfterScreen:(UIViewController* _Nonnull)viewController
{
    ScreenItem* item = nil;
    
    // 查找指定屏幕的下一个screen item
    BOOL isFound = NO;
    NSUInteger theNextIndex = 0;
    for (ScreenItem* screenItem in self.screens) {
        // 找到指定屏幕的screen item
        if (screenItem.viewController == viewController) {
            item = screenItem;
            isFound = YES;
        }
        theNextIndex++;
        
        // 已经找到退出循环
        if (isFound) {
            break;
        }
    }
    
    // 移除
    if (isFound && [self.screens count] > theNextIndex) {
        [self.screens removeObjectsInRange:NSMakeRange(theNextIndex, [self.screens count] - theNextIndex)];
    }
    
    return item;
}

@end
