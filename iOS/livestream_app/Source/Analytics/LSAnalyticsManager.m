//
//  AnalyticsManager.m
//  dating
//
//  Created by  Samson on 6/28/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  跟踪管理器

#import "LSAnalyticsManager.h"



@interface LSAnalyticsManager()
@property (nonatomic, strong) ScreenManager* screenMgr;
// 最后提交的ScreenName
@property (nonatomic, strong) NSString* lastReportScreenName;
// 直播GA跟踪器
@property (nonatomic, strong) id<GAITracker> tracker;


/**
**
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

@implementation LSAnalyticsManager
///**
// *  获取跟踪单件跟踪管理器
// *
// *  @return 跟踪管理器
// */
+ (LSAnalyticsManager* _Nonnull)manager
{
    static LSAnalyticsManager* manager = nil;
    if (nil == manager) {
        manager = [[LSAnalyticsManager alloc] init];
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
        [[LSLoginManager manager] addDelegate:self];
    }
    return self;
}

- (void)initGoogleAnalytics:(BOOL)isReal {
    
    // get GAI instance
    GAI *gai = [GAI sharedInstance];
    
    // Configure the default tracker with tracker id
    if (AppDelegate().demo) {
        // demo环境
        self.tracker = [gai trackerWithTrackingId:@"UA-62455061-1"];
    }
    else {
        // 正式环境
        self.tracker = [gai trackerWithTrackingId:@"UA-108405018-1"];
    }
    
    
    
    // init tracker
    if (nil != self.tracker) {
        self.tracker.allowIDFACollection = YES;
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
 *  @param viewController ViewController
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
 *  @param pageIndex            页面号
 */
- (void)reportDidShowPage:(UIViewController* _Nonnull)viewController pageIndex:(NSUInteger)pageIndex
{
    // 更新屏幕
    [self.screenMgr updateScreenWithPage:viewController pageIndex:pageIndex];
    // 显示屏幕
    [self reportShowCurScreen];
}


- (void)openURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    
    id<GAITracker> tracker = self.tracker;
    
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


/**
 *  跟踪用户ID
 *
 *  @param userId 用户ID
 */
- (void)reportUserId:(NSString* _Nonnull)userId
{
    // 提交用户ID(GA)
    [self.tracker set:kGAIUserId value:userId];
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"userid"
                                                                           action:@"User Sign In"
                                                                            label:nil
                                                                            value:nil] build]];
    
    // 提交用户ID(自定义)
    [self.tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"userid"
                                                                            action:nil
                                                                             label:nil
                                                                             value:nil]
                                     set:userId forKey:[GAIFields customDimensionForIndex:2]] build]];
    
    // log打印
    NSLog(@"LSAnalyticsManager ::reportUserId userId:%@"
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
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"monthGroup"
                                                                           action:@"GA Activity"
                                                                            label:nil
                                                                            value:nil] build]];
    
    // 提交活动ID（自定义）
    [self.tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"monthGroup"
                                                                            action:nil
                                                                             label:nil
                                                                             value:nil]
                                     set:activityId forKey:[GAIFields customDimensionForIndex:4]] build]];
    
    // log打印
    NSLog(@"LSAnalyticsManager::reportActivityId activityId:%@"
          , activityId);
}

- (void)reportActionEvent:(NSString *)action eventCategory:(NSString *)category {
    
    
    // 提交活动事件
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                                           action:action
                                                                            label:nil
                                                                            value:nil] build]];
}

- (void)reportActionEvent:(NSString *)action eventCategory:(NSString *)category label:(NSString *)label{
    // 提交活动事件
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                               action:action
                                                                label:label
                                                                value:nil] build]];
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
        [self.tracker set:kGAIScreenName value:screenName];
        [self.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        
        // log打印
        NSLog(@"LSAnalyticsManager::reportScreenName screenName:%@"
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
        [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"APPActionEvent"
                                                                               action:@"AppAction"
                                                                                label:screenPath
                                                                                value:nil] build]];
        
        // log打印
        NSLog(@"LSAnalyticsManager::reportScreenPath screenPath:%@"
              , screenPath);
    }
}


#pragma mark - LoginManagerDelegate

- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSManBaseInfoItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            [self reportUserId:loginItem.gaUid];
        }

    });
}


@end
