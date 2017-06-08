//
//  ScreenItem.m
//  dating
//
//  Created by  Samson on 6/30/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import "ScreenItem.h"
#import "ScreenManager.h"

@interface ScreenItem()
/**
 *  获取屏幕名称
 *
 *  @param viewController controller
 *
 *  @return 屏幕名称
 */
+ (NSString* _Nonnull)getScreenName:(UIViewController* _Nonnull)viewController;

/**
 *  获取屏幕名称
 *
 *  @param name 别名
 *
 *  @return 屏幕名称
 */
+ (NSString* _Nonnull)getScreenNameWithName:(NSString* _Nonnull)name;

/**
 *  获取屏幕页名称
 *
 *  @param viewController controller
 *  @param pageIndex      页号
 *
 *  @return 页屏幕名称
 */
+ (NSString* _Nonnull)getPageName:(UIViewController* _Nonnull)viewController pageIndex:(NSUInteger)pageIndex;
@end

@implementation ScreenItem
- (id)init
{
    self = [super init];
    if (nil != self) {
        self.viewController = nil;
        self.isPage = NO;
        self.curPageIndex = 0;
    }
    return self;
}

#pragma mark - 接口
/**
 *  判断是否符合ScreenItem生成条件
 *
 *  @param viewController ViewController
 *
 *  @return 结果
 */
+ (BOOL)isScreenItem:(UIViewController* _Nonnull)viewController
{
    NSString* className = [[viewController class] description];
    NSString* screenName = [ScreenItem getScreenNameWithName:className];
    return [screenName length] > 0;
}

/**
 *  获取屏幕名称
 *
 *  @return 屏幕名称
 */
- (NSString* _Nonnull)getScreenName
{
    NSString* screenName = @"";
    if (self.isPage) {
        screenName = [ScreenItem getPageName:self.viewController pageIndex:self.curPageIndex];
    }
    else {
        screenName = [ScreenItem getScreenName:self.viewController];
    }
    return screenName;
}

#pragma mark - 私有
/**
 *  获取屏幕名称
 *
 *  @param viewController controller
 *
 *  @return 屏幕名称
 */
+ (NSString* _Nonnull)getScreenName:(UIViewController* _Nonnull)viewController
{
    // 获取屏幕名称
    NSString* className = [[viewController class] description];
    return [ScreenItem getScreenNameWithName:className];
}

/**
 *  获取屏幕名称
 *
 *  @param name 别名
 *
 *  @return 屏幕名称
 */
+ (NSString* _Nonnull)getScreenNameWithName:(NSString* _Nonnull)name
{
    NSString* result = @"";
    
    // 获取屏幕名称
    NSString* screenName = NSLocalizedStringFromTable(name, @"AnalyticsScreenName", nil);
    
    // 判断是否获取成功
    if (![name isEqualToString:screenName]) {
        result = screenName;
    }
    
    return result;
}

/**
 *  获取Home屏幕名称
 *
 *  @return 屏幕名称
 */
+ (NSString* _Nonnull)getHomeScreenName {
    // 获取屏幕名称
    NSString* screenName = NSLocalizedStringFromTable(@"MainViewController_1", @"AnalyticsScreenName", nil);
    return screenName;
}

/**
 *  获取屏幕页名称
 *
 *  @param viewController controller
 *  @param pageIndex      页号
 *
 *  @return 页屏幕名称
 */
+ (NSString* _Nonnull)getPageName:(UIViewController* _Nonnull)viewController pageIndex:(NSUInteger)pageIndex
{
    // 获取屏幕名称（没有则使用类名）
    NSString* className = [[viewController class] description];
    NSString* mainName = NSLocalizedStringFromTable(className, @"AnalyticsScreenName", nil);
    // 组成带页号的屏幕名称
    NSString* pageName = [NSString stringWithFormat:@"%@%@%lu", mainName, PAGE_SEPARATOR, (unsigned long)pageIndex];
    
    return [ScreenItem getScreenNameWithName:pageName];
}
@end
