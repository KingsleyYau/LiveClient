//
//  AnalyticsManager.m
//  dating
//
//  Created by  Samson on 6/28/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  跟踪管理器

#import "AnalyticsManager.h"
#import <Google/Analytics.h>
#import "LoginManager.h"
#import "ScreenManager.h"
#import "AppDelegate.h"
#import "ScreenItem.h"

@interface AnalyticsManager() <LoginManagerDelegate>
// 屏幕管理器
@property (nonatomic, strong) ScreenManager* screenMgr;
// 最后提交的ScreenName
@property (nonatomic, strong) NSString* lastReportScreenName;
// 默认GA跟踪器
@property (nonatomic, strong) id<GAITracker> defaultGATracker;

/**
 *  跟踪用户ID
 *
 *  @param userId 用户ID
 */
- (void)reportUserId:(NSString* _Nonnull)userId;

/**
 *  跟踪活动ID
 *
 *  @param activityId 活动ID
 */
- (void)reportActivityId:(NSString* _Nonnull)activityId;

/**
 *  跟踪屏幕显示
 */
- (void)reportShowCurScreen;

/**
 *  跟踪屏幕名称
 *
 *  @param screenName 屏幕名称
 */
- (void)reportScreenName:(NSString* _Nonnull)screenName;

/**
 *  跟踪屏幕路径
 */
- (void)reportScreenPath;
@end

@implementation AnalyticsManager
/**
 *  获取跟踪单件跟踪管理器
 *
 *  @return 跟踪管理器
 */
+ (AnalyticsManager* _Nonnull)manager
{
    static AnalyticsManager* manager = nil;
    if (nil == manager) {
        manager = [[AnalyticsManager alloc] init];
    }
    return manager;
}

#pragma mark - 初始化
/**
 *  初始化
 *
 *  @return this
 */
- (id)init
{
    self = [super init];
    if (nil != self) {
        // 初始化变量
        self.screenMgr = [[ScreenManager alloc] init];
        self.lastReportScreenName = @"";
        
        // 添加接收LoginManager回调
        [[LoginManager manager] addDelegate:self];
    }
    return self;
}

/**
 *  初始化Google跟踪
 *  @param isReal   是否真实环境(运营的站点环境)
 */
- (void)initGoogleAnalytics:(BOOL)isReal;
{
    // Configure tracker from GoogleService-Info.plist.
//    NSError *configureError;
//    [[GGLContext sharedInstance] configureWithError:&configureError];
//    if (nil != configureError) {
//        NSLog(@"AnalyticsManager::initGoogleAnalytics() Error configuring Google services: %@", configureError);
//    }
    
    // get GAI instance
    GAI *gai = [GAI sharedInstance];
    
    // Configure the default tracker with tracker id
    if (AppDelegate().demo) {
        // demo环境
        self.defaultGATracker = [gai trackerWithTrackingId:@"UA-80059715-2"];
    }
    else {
        if (isReal) {
            // 真实运营环境
            self.defaultGATracker = [gai trackerWithTrackingId:@"UA-80059715-1"];
        }
        else {
            // 上架环境
            self.defaultGATracker = [gai trackerWithTrackingId:@"UA-80059715-3"];
        }
    }
    
    // init tracker
    if (nil != self.defaultGATracker) {
        self.defaultGATracker.allowIDFACollection = YES;
    }
    
    // Optional: configure GAI options.
    gai.dispatchInterval = 30;
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelNone;  // remove before app release
}

#pragma mark - 跟踪接口
/**
 *  跟踪ViewController创建
 *
 *  @param vireController ViewController
 */
- (void)reportAllocScreen:(UIViewController* _Nonnull)viewController
{
    // 更新屏幕
    [self.screenMgr updateScreen:viewController];
}

/**
 *  跟踪ViewController析构
 *
 *  @param viewController ViewController
 */
- (void)reportDeallocScreen:(UIViewController* _Nonnull)viewController
{
    // 移除屏幕
    [self.screenMgr removeScreen:viewController];
}

/**
 *  跟踪屏幕显示
 *
 *  @param viewController ViewController
 */
- (void)reportShowScreen:(UIViewController* _Nonnull)viewController
{
    // 更新屏幕
    [self.screenMgr updateScreen:viewController];
    // 显示屏幕
    [self reportShowCurScreen];
}

/**
 *  跟踪屏幕消失
 *
 *  @param viewController ViewController
 */
- (void)reportDismissScreen:(UIViewController* _Nonnull)viewController
{

}

/**
 *  跟踪屏幕显示页
 *
 *  @param viewController   ViewController
 *  @param index            页面号
 */
- (void)reportDidShowPage:(UIViewController* _Nonnull)viewController pageIndex:(NSUInteger)pageIndex
{
    // 更新屏幕
    [self.screenMgr updateScreenWithPage:viewController pageIndex:pageIndex];
    // 显示屏幕
    [self reportShowCurScreen];
}

/**
 *  跟踪App被打开
 *
 *  @param url 被打开的URL
 */
- (void)openURL:(NSURL * _Nonnull)url
{
    NSString *urlString = [url absoluteString];
    
    id<GAITracker> tracker = self.defaultGATracker;
    
    // setCampaignParametersFromUrl: parses Google Analytics campaign ("UTM")
    // parameters from a string url into a Map that can be set on a Tracker.
    GAIDictionaryBuilder *hitParams = [[GAIDictionaryBuilder alloc] init];
    
    // Set campaign data on the map, not the tracker directly because it only
    // needs to be sent once.
    [hitParams setCampaignParametersFromUrl:urlString];
    
    // 当GA解析成功才提交
    if([hitParams get:kGAICampaignSource]) {
        NSDictionary *hitParamsDict = [hitParams build];
        
        // A screen name is required for a screen view.
        [tracker set:kGAIScreenName value:[ScreenItem getHomeScreenName]];
        
        // SDK Version 3.08 and up.
        [tracker send:[[[GAIDictionaryBuilder createScreenView] setAll:hitParamsDict] build]];
    }
}

#pragma mark - 内部跟踪方法
/**
 *  跟踪用户ID
 *
 *  @param userId 用户ID
 */
- (void)reportUserId:(NSString* _Nonnull)userId
{
    // 提交用户ID(GA)
    [self.defaultGATracker set:kGAIUserId value:userId];
    [self.defaultGATracker send:[[GAIDictionaryBuilder createEventWithCategory:@"userid"
                                                          action:@"User Sign In"
                                                           label:nil
                                                           value:nil] build]];
    
    // 提交用户ID(自定义)
    [self.defaultGATracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"userid"
                                                           action:nil
                                                            label:nil
                                                            value:nil]
                    set:userId forKey:[GAIFields customDimensionForIndex:2]] build]];
    
    // log打印
    NSLog(@"AnalyticsManager::reportUserId userId:%@"
          , userId);
}

/**
 *  跟踪活动ID
 *
 *  @param activityId 活动ID
 */
- (void)reportActivityId:(NSString* _Nonnull)activityId
{
    // 提交活动事件
    [self.defaultGATracker send:[[GAIDictionaryBuilder createEventWithCategory:@"monthGroup"
                                                           action:@"GA Activity"
                                                            label:nil
                                                            value:nil] build]];
    
    // 提交活动ID（自定义）
    [self.defaultGATracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"monthGroup"
                                                            action:nil
                                                             label:nil
                                                             value:nil]
                     set:activityId forKey:[GAIFields customDimensionForIndex:4]] build]];
    
    // log打印
    NSLog(@"AnalyticsManager::reportActivityId activityId:%@"
          , activityId);
}

/**
 *  跟踪屏幕显示
 */
- (void)reportShowCurScreen
{
    NSString* screenName = [self.screenMgr getCurScreenName];
    if ([screenName length] > 0
        && ![screenName isEqualToString:self.lastReportScreenName])
    {
        // 提交屏幕名称
        [self reportScreenName:screenName];
        
        // 提交屏幕路径
        [self reportScreenPath];
        
        // 替换最后提交的ScreenName
        self.lastReportScreenName = screenName;
    }
}

/**
 *  跟踪屏幕名称
 *
 *  @param screenName 屏幕名称
 */
- (void)reportScreenName:(NSString* _Nonnull)screenName
{
    // 获取屏幕名称
    if ([screenName length] > 0) {
        // 提交屏幕名称
        [self.defaultGATracker set:kGAIScreenName value:screenName];
        [self.defaultGATracker send:[[GAIDictionaryBuilder createScreenView] build]];
        
        // log打印
        NSLog(@"AnalyticsManager::reportScreenName screenName:%@"
              , screenName);
    }
}

/**
 *  跟踪屏幕路径
 */
- (void)reportScreenPath
{
    // 获取当前屏幕路径
    NSString* screenPath = [self.screenMgr getCurScreenPath];
    if ([screenPath length] > 0) {
        // 提交屏幕路径
        [self.defaultGATracker send:[[GAIDictionaryBuilder createEventWithCategory:@"APPActionEvent"
                                                              action:@"AppAction"
                                                               label:screenPath
                                                               value:nil] build]];
        
        // log打印
        NSLog(@"AnalyticsManager::reportScreenPath screenPath:%@"
              , screenPath);
    }
}

#pragma mark - LoginManagerDelegate
/**
 *  登录完成回调
 *
 *  @param manager   登录状态管理器实例
 *  @param success   是否登录成功
 *  @param loginItem 登录成功Item
 *  @param strErrno  登录失败错误码
 *  @param strErrmsg 登录失败错误提示
 */
- (void)manager:(LoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject * _Nullable)loginItem errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg
{
    // 登录成功
    if (success) {
        // 跟踪用户ID
        [self reportUserId:loginItem.ga_uid];
        // 跟踪活动ID
        [self reportActivityId:loginItem.ga_activity];
    }
}
@end
