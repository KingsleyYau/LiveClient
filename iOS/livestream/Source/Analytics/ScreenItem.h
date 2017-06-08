//
//  ScreenItem.h
//  dating
//
//  Created by  Samson on 6/30/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  屏幕item(每个需要处理的UIViewController都会有一个item)

#import <Foundation/Foundation.h>

@interface ScreenItem : NSObject
@property (nonatomic, weak) UIViewController* _Nullable viewController;
@property (nonatomic, assign) BOOL isPage;
@property (nonatomic, assign) NSUInteger curPageIndex;
//@property (nonatomic, strong) NSMutableArray* tag

/**
 *  判断是否符合ScreenItem生成条件
 *
 *  @param viewController ViewController
 *
 *  @return 结果
 */
+ (BOOL)isScreenItem:(UIViewController* _Nonnull)viewController;

/**
 *  获取屏幕名称
 *
 *  @return 屏幕名称
 */
- (NSString* _Nonnull)getScreenName;

/**
 *  获取Home屏幕名称
 *
 *  @return 屏幕名称
 */
+ (NSString* _Nonnull)getHomeScreenName;

@end
