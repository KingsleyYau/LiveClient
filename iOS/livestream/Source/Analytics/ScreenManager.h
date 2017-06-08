//
//  ScreenManager.h
//  dating
//
//  Created by  Samson on 6/29/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  屏幕管理器(包括屏幕名称，屏幕路径等)

#import <Foundation/Foundation.h>

#define PATH_SEPARATOR  @"-"
#define PAGE_SEPARATOR  @"_"

@interface ScreenManager : NSObject
/**
 *  获取当前屏幕名称
 *
 *  @return 当前屏幕名称
 */
- (NSString* _Nonnull)getCurScreenName;

/**
 *  获取当前屏幕路径
 *
 *  @return 当前屏幕路径
 */
- (NSString* _Nonnull)getCurScreenPath;

/**
 *  更新当前屏幕
 *
 *  @param viewController UIViewController
 */
- (void)updateScreen:(UIViewController* _Nonnull)viewController;

/**
 *  更新当前屏幕(带页)
 *
 *  @param viewController ViewController
 *  @param pageIndex      页码
 */
- (void)updateScreenWithPage:(UIViewController* _Nonnull)viewController pageIndex:(NSUInteger)pageIndex;

/**
 *  移除屏幕
 *
 *  @param viewController ViewController
 */
- (void)removeScreen:(UIViewController* _Nonnull)viewController;
@end
