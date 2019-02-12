//
//  LSLiveChatRequestManager.h
//  dating
//
//  Created by Max on 18/11/10.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <httpclient/HttpRequestDefine.h>
#include <manrequesthandler/LSLiveChatRequestDefine.h>
#include <manrequesthandler/LSLiveChatRequestLadyDefine.h>

#import "LSLCOtherGetCountItemObject.h"
#import "LSLCCookiesItemObject.h"
#import "LSLCGiftItemObject.h"

@interface LSLiveChatRequestManager : NSObject
@property (nonatomic, strong) NSString *versionCode;
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype)manager;

#pragma mark - 公共模块
/**
 *  设置是否打印日志
 *
 *  @param enable enable 是否启用日志
 */
- (void)setLogEnable:(BOOL)enable;

/**
 *  设置接口目录
 *
 *  @param directory 可写入目录
 */
- (void)setLogDirectory:(NSString *)directory;

/**
 *  设置接口服务器域名
 *
 *  @param webSite Web接口服务器域名
 *  @param appSite App接口服务器域名
 */
- (void)setWebSite:(NSString *)webSite appSite:(NSString *)appSite wapSite:(NSString *)wapSite;

/**
 *  设置假服务器域名
 *
 *  @param fakeSite 假服务器域名
 */
- (void)setFakeSite:(NSString *)fakeSite;

/**
 *  设置换站域名(中心域名)
 *
 *  @param changeSite 换站域名(中心域名)
 */
- (void)setChangeSite:(NSString *)changeSite;

/**
 *  获取Web服务器域名
 */
- (NSString *)getWebSite;
/**
 *  获取app接口域名
 */
- (NSString *)getAppSite;
/**
 *  获取app接口域名
 */
- (NSString *)getWapSite;
/**
 *  获取换站域名(中心域名)
 */
- (NSString *)getChangeSite;

/**
 *  设置语音服务器域名
 *
 *  @param pubSite 语音服务器域名
 */
- (void)setVoiceSite:(NSString *)voiceSite;

/**
 *  设置接口服务器用户认证
 *
 *  @param user     用户名
 *  @param password 密码
 */
- (void)setAuthorization:(NSString *)user password:(NSString *)password;

/**
 *  清除Cookies
 */
- (void)cleanCookies;

/**
 *  根据域名获取Cookies
 *
 *  @param site 域名
 */
- (void)getCookies:(NSString *)site;

/**
 *  获取所有CookiesItem
 *
 */
- (NSArray<LSLCCookiesItemObject *> *)getCookiesItem;

- (NSArray<NSHTTPCookie *> *)getHttpCookies;
/**
 *  停止请求接口
 *
 *  @param requestId 请求Id
 */
- (void)stopRequest:(NSInteger)requestId;

/**
 *  停止所有请求接口
 *
 */
- (void)stopAllRequest;

/**
 *  获取设备Id
 *
 *  @return 设备Id
 */
- (NSString *)getDeviceId;

//#pragma mark - 真假服务器模块
///**
// *  获取服务器接口回调
// *
// *  @param success 成功失败
// *  @param item    成功Item
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^CheckServerFinishHandler)(BOOL success, CheckServerItemObject *item, NSString *errnum, NSString *errmsg);
//
///**
// *  获取服务器接口
// *
// *  @param user          用户
// *  @param finishHandler 接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)checkServer:(NSString *)user finishHandler:(CheckServerFinishHandler)finishHandler;
//
//#pragma mark - 登录认证模块
///**
// *  登录接口回调
// *
// *  @param success 成功失败
// *  @param item    成功Item
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// *  @param serverId serverid:是否真服务器帐号（1:真服务器 0:假服务器）
// */
//typedef void (^LoginFinishHandler)(BOOL success, LoginItemObject *item, NSString *errnum, NSString *errmsg, int serverId);
//
///**
// *  登录接口
// *
// *  @param user          用户
// *  @param password      密码
// *  @param checkcode     验证码
// *  @param finishHandler 接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode finishHandler:(LoginFinishHandler)finishHandler;
//
///**
// *  获取验证码接口回调
// *
// *  @param success 成功失败
// *  @param data    验证码图片二进制流
// *  @param len     验证码图片二进制流长度
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^GetCheckCodeFinishHandler)(BOOL success, const char *data, int len, NSString *errnum, NSString *errmsg);
//
///**
// *  获取验证码接口
// *
// *  @param isUseCode    是否需要验证码
// *  @param finishHandler 接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getCheckCode:(BOOL)isUseCode
//            finishHandler:(GetCheckCodeFinishHandler)finishHandler;
//
///**
// *  2.5.找回接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//
//typedef void (^FindPasswordFinishHandler)(BOOL success, NSString *tip, NSString *errnum, NSString *errmsg);
//
///**
// *  2.5.找回接口
// *
// *  @param mail             用户注册的邮箱
// *  @param checkCode        验证码
// *  @param finishHandler    接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)findPassword:(NSString *)mail
//                checkCode:(NSString *)checkCode
//            finishHandler:(FindPasswordFinishHandler)finishHandler;
//
///**
// *  2.6.手机获取认证短信接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//
//typedef void (^GetSmsFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///**
// *  2.6.手机获取认证短信接口
// *
// *  @param telephone     手机号码
// *  @param telephone_cc  国家区号
// *  @param finishHandler 接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getSms:(NSString *)telephone
//       telephone_cc:(int)telephone_cc
//      finishHandler:(GetSmsFinishHandler)finishHandler;
//
///**
// *  2.7.手机短信认证接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//
//typedef void (^VerifySmsFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///**
// *  2.7.手机短信认证接口
// *
// *  @param verifyCode 验证码
// *  @param vType      验证类型（1：首次验证， 3:下单验证） （可无，默认：1）
// *  @param finishHandler 接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)verifySms:(NSString *)verifyCode
//                 vType:(int)vType
//         finishHandler:(VerifySmsFinishHandler)finishHandler;
//
///**
// *  2.8.固定电话获取认证短信接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//
//typedef void (^GetFixedPhoneFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///**
// *  2.8.固定电话获取认证短信接口
// *
// *  @param landline     电话号码
// *  @param landline_cc  国家区号
// *  @param landline_ac  区号
// *  @param finishHandler 接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getFixedPhone:(NSString *)landline
//               landline_cc:(int)landline_cc
//               landline_ac:(NSString *)landline_ac
//             finishHandler:(GetFixedPhoneFinishHandler)finishHandler;
//
///**
// *  2.9.固定电话短信认证接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//
//typedef void (^VerifyFixedPhoneFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///**
// *  2.9.固定电话短信认证接口
// *
// *  @param verifyCode 验证码
// *  @param finishHandler 接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)verifyFixedPhone:(NSString *)verifyCode
//                finishHandler:(VerifyFixedPhoneFinishHandler)finishHandler;
//
///**
// *  2.10.获取token接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// *  @param token   用于登录其他站点的加密串
// */
//
//typedef void (^GetWebsiteUrlTokenFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSString *token);
//
///**
// *  2.10.获取token接口
// *
// *  @param siteId
// *  @param finishHandler 接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getWebsiteUrlToken:(OTHER_SITE_TYPE)siteId
//                  finishHandler:(GetWebsiteUrlTokenFinishHandler)finishHandler;
//
//typedef void (^SummitApptokenFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///**
//  提交apptoken
// @param tokenId appToken值
// @param appId   app唯一标识（App包名或IOSAppID）
//
// @param finishHandler 接口回调
//
// @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)summitAppTokenDeviced:(NSString *)tokenId appId:(NSString *)appId finishHandler:(SummitApptokenFinishHandler)finishHandler;
//
//typedef void (^UnbindAppTokenFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///**
//  销毁apptoken
//
// @param finishHandler 接口回调
//
// @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)unbindAppToken:(UnbindAppTokenFinishHandler)finishHandler;
//
///**
// *  2.14.token登录接口回调
// *
// *  @param success 成功失败
// *  @param item    成功Item
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^TokenLoginFinishHandler)(BOOL success, LoginItemObject *item, NSString *errnum, NSString *errmsg);
//
///**
// *  2.14.token登录接口
// *  @param token            用于登录其他站点的加密串
// *  @param memberId         用户
// *  @param finishHandler    接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)tokenLogin:(NSString *)token
//               memberId:(NSString *)memberId
//          finishHandler:(TokenLoginFinishHandler)finishHandler;
//
///**
// *  2.15.可登录的站点列表接口回调
// *
// *  @param success 成功失败
// *  @param item    成功Item
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^GetValidSiteIdFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSArray<ValidSiteIdItemObject *> *list);
//
///**
// *  2.15.可登录的站点列表登录接口
// *  @param token            用于登录其他站点的加密串
// *  @param memberId         用户
// *  @param finishHandler    接口回调
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getValidSiteId:(NSString *)email
//                   password:(NSString *)password
//              finishHandler:(GetValidSiteIdFinishHandler)finishHandler;
//
//#pragma mark - 注册模块
///**
// *  注册接口回调
// *
// *  @param success 成功失败
// *  @param item    成功Item
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^registerFinishHandler)(BOOL success, RegisterItemObject *item, NSString *errnum, NSString *errmsg);
///* 注册接口
// * @param user                账号
// * @param password            密码
// * @param male                性别, true:男性/false:女性
// * @param firstname         用户firstname
// * @param lastname            用户lastname
// * @param country            国家区号,参考数组<CountryArray>
// * @param birthday_y        生日的年
// * @param birthday_m        生日的月
// * @param birthday_d        生日的日
// * @param weeklymail        是否接收订阅
// * @param model                移动设备型号
// * @param deviceId            设备唯一标识
// * @param manufacturer        制造厂商
// * @param referrer            app推广参数（安装成功app第一次运行时GooglePlay返回）
// * @param finishHandler     接口回调
// *
// * @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)registerUser:(NSString *)user
//                 password:(NSString *)password
//                      sex:(BOOL)isMale
//                firstname:(NSString *)firstname
//                 lastname:(NSString *)lastname
//                  country:(int)country
//               birthday_y:(NSString *)birthday_y
//               birthday_m:(NSString *)birthday_m
//               birthday_d:(NSString *)birthday_d
//               weeklymail:(BOOL)isWeeklymail
//            finishHandler:(registerFinishHandler)finishHandler;
//
//#pragma mark - 个人资料模块
//
///**
// *  获取男士个人资料回调
// *
// *  @param success 成功
// *  @param item    男士资料
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^getMyProfileFinishHandler)(BOOL success, PersonalProfile *item, NSString *errnum, NSString *errmsg);
//
///**
// *  获取男士个人资料
// *
// *  @param finishHandler 接口回调
// *
// * @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getMyProfileFinishHandler:(getMyProfileFinishHandler)finishHandler;
//
///**
// *  更新男士个人资料回调
// *
// *  @param success 成功
// *  @param motify  是否修改
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^updateMyProfileFinishHandler)(BOOL success, BOOL motify, NSString *errnum, NSString *errmsg);
//
///**
// *  更新男士资料
// *
// *  @param weight        体重
// *  @param height        高度
// *  @param language      语言
// *  @param ethnicity     人种
// *  @param religion      宗教
// *  @param education     教育程度
// *  @param profession    职业
// *  @param income        收入
// *  @param children      孩子
// *  @param smoke         吸烟
// *  @param drink         喝酒
// *  @param resume        详情
// *  @param interests     兴趣爱好
// *  @param finishHandler 接口回调
// *
// * @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)updateMyProfileWeight:(int)weight
//                            height:(int)height
//                          language:(int)language
//                         ethnicity:(int)ethnicity
//                          religion:(int)religion
//                         education:(int)education
//                        profession:(int)profession
//                            income:(int)income
//                          children:(int)children
//                             smoke:(int)smoke
//                             drink:(int)drink
//                            resume:(NSString *)resume
//                         interests:(NSArray *)interests
//                            zodiac:(int)zodiac
//                            finish:(updateMyProfileFinishHandler)finishHandler;
//
///**
// *  开始编辑男士资料详情
// *
// *  @param success 成功
// *  @param errnum  错误编码
// *  @param errmsg  错误信息
// */
//typedef void (^startEditResumeFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
///**
// *  开始编辑男士详情
// *
// *  @param finishHandler 接口回调
// *
// * @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)startEditResumeFinishHandler:(startEditResumeFinishHandler)finishHandler;
//
///**
// *  上传接口回调
// *
// *  @param success 成功失败
// *  @param
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^uploadHeaderPhotoFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///* 上传接口
// * @param fileName 文件名称
// *
// */
//- (NSInteger)uploadHeaderPhoto:(NSString *)fileName finishHandler:(uploadHeaderPhotoFinishHandler)finishHandler;
//
//#pragma mark - 女士模块
///**
// *  获取最近联系人接口回调
// *
// *  @param success 成功失败
// *  @param items   最近联系人列表 LadyRecentContactObject
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^RecentContactListFinishHandler)(BOOL success, NSArray *items, NSString *errnum, NSString *errmsg);
//
///**
// *  获取最近联系人接口
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getRecentContactList:(RecentContactListFinishHandler)finishHandler;
//
///**
// *  移除联系人接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^removeContactLishFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///**
// *  移除联系人列表接口
// *
// *  @param womanIdArray  移除联系人的id
// *
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)removeContactListWithWomanId:(NSArray *)womanIdArray finishHandler:(removeContactLishFinishHandler)finishHandler;
//
//typedef void (^addFavouritesLadyFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///**
// *  添加收藏女士
// *
// *  @param womanId       女士id
// *
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)addFavouritesLadyWithWomanId:(NSString *)womanId finishHandler:(addFavouritesLadyFinishHandler)finishHandler;
//
//typedef void (^removeFavouritesLadyFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
///**
// *  移除收藏女士
// *
// *  @param womanId       女士id
// *
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//
//- (NSInteger)removeFavouritesLadyWithWomanId:(NSString *)womanId finishHandler:(removeFavouritesLadyFinishHandler)finishHandler;
//
///**
// *  5.7.获取女士Direct Call TokenID接口回调
// *
// *  @param womanId       女士id
// *
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//typedef void (^QueryLadyCallFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, LadyCallItemObject *obj);
//
///**
// *  5.7.获取女士Direct Call TokenID接口
// *
// *  @param womanId       女士id
// *
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//
//- (NSInteger)queryLadyCall:(NSString *)womanId finishHandler:(QueryLadyCallFinishHandler)finishHandler;
//
//typedef void (^reportLadyFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
///**
// *  举报女士
// *
// *  @param womanId 女士id
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)reportLady:(NSString *)womanId finishHandler:(reportLadyFinishHandler)finishHandler;
//
//typedef void (^GetFavoriteListFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSArray<QueryLadyListItemObject *> *itemArray, int totalCount);
///**
// *  5.13.获取收藏女士列表
// *
// *  @param pageIndex 当前页数
// *  @param pageSize  每页行数
// *  @param womanId    女士ID或name
// *  @param onLineType 在线状态(FINDLADYONLINETYPE_NOLIMIT:不限 FINDLADYONLINETYPE_Online:在线)
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getFavoriteList:(int)pageIndex
//                    pageSize:(int)pageSize
//                     womanId:(NSString *)womanId
//                  onLineType:(FindLadyOnLineType)onLineType
//               finishHandler:(GetFavoriteListFinishHandler)finishHandler;
//
//#pragma mark - online列表
//typedef void (^onlineListFinishHandler)(BOOL success, NSMutableArray *itemArray, int totalCount, NSString *errnum, NSString *errmsg);
//
//- (NSInteger)getQueryLadyListPageIndex:(int)pageIndex
//                              pageSize:(int)pageSize
//                            searchType:(int)searchType
//                               womanId:(NSString *)womanId
//                              isOnline:(int)isOnline
//                          ageRangeFrom:(int)ageRangeFrom
//                            ageRangeTo:(int)ageRangeTo
//                               country:(NSString *)country
//                               orderBy:(int)orderBy
//                            genderType:(LadyGenderType)genderType
//                         finishHandler:(onlineListFinishHandler)finishHandler;
//
//#pragma mark - 女士详细列表
//typedef void (^LadyDetailFinishHandler)(BOOL success, LadyDetailItemObject *item, NSString *errnum, NSString *errmsg);
//
//- (NSInteger)getLadyDetailWithWomanId:(NSString *)womanId finishHandler:(LadyDetailFinishHandler)finishHandler;

#pragma mark - 其他模块
///**
// *  同步配置接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^SynConfigFinishHandler)(BOOL success, SynConfigItemObject *item, NSString *errnum, NSString *errmsg);
//
//- (NSInteger)synConfig:(SynConfigFinishHandler)finishHandler;

/**
 *  统计男士数据接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetCountFinishHandler)(BOOL success, LSLCOtherGetCountItemObject *item, NSString *errnum, NSString *errmsg);

- (NSInteger)getCount:(GetCountFinishHandler)finishHandler;

///**
// *  收集手机硬件信息接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^PhoneInfoFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
//- (NSInteger)phoneInfo:(PhoneInfoObject *)phoneInfo finishHandler:(PhoneInfoFinishHandler)finishHandler;
//
///**
// *  查询可否对某女士使用积分接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^CheckIntegralFinishHandler)(BOOL success, int integral, NSString *errnum, NSString *errmsg);
//
//- (NSInteger)checkIntegral:(NSString *)womanId finishHandler:(CheckIntegralFinishHandler)finishHandler;
//
///**
// *  14.5.检查客户端更新（接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^VersionCheckFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, VersionItemObject *versionItem);
//
//- (NSInteger)versionCheck:(int)currVersion
//                    appId:(NSString *)appId
//            finishHandler:(VersionCheckFinishHandler )finishHandler;
//
///**
// *  收集程序崩溃数据
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^UploadCrashLogFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
//- (NSInteger)uploadCrashLogWithFile:(NSString *)srcDirectory tmpDirectory:(NSString *)tmpDirectory finishHandler:(UploadCrashLogFinishHandler)finishHandler;
//
///**
// *  提交APP安装记录接口回调
// *
// *  @param success 成功失败
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^InstallLogsFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
//
//- (NSInteger)installLog:(InstallLogObject *)installLog finishHandler:(InstallLogsFinishHandler)finishHandler;
//
//#pragma mark - 支付
///**
// *  获取订单信息接口回调
// *
// *  @param success   成功失败
// *  @param code      错误码
// *  @param orderNo   订单号
// *  @param productId 产品号
// */
//typedef void (^GetPaymentOrderFinishHandler)(BOOL success, NSString *code, NSString *orderNo, NSString *productId);
//
//- (NSInteger)getPaymentOrder:(NSString *)manId sid:(NSString *)sid number:(NSString *)number finishHandler:(GetPaymentOrderFinishHandler)finishHandler;
//
///**
// *  验证订单信息
// *
// *  @param success 成功失败
// *  @param code    错误码
// */
//typedef void (^CheckPaymentFinishHandler)(BOOL success, NSString *code);
//
//- (NSInteger)checkPayment:(NSString *)manId sid:(NSString *)sid receipt:(NSString *)receipt orderNo:(NSString *)orderNo code:(NSInteger)code finishHandler:(CheckPaymentFinishHandler)finishHandler;
//
//#pragma mark - 月费
///**
// *  获取月费状态
// *
// *  @param success    成功失败
// *  @param errnum     编码信息
// *  @param errmsg     信息
// *  @param memberType 月费状态
// */
//typedef void (^GetQueryMemberTypeFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, int memberType);
//
//- (NSInteger)getQueryMemberType:(GetQueryMemberTypeFinishHandler)finishHandler;
///**
// *  获取月费的提示
// *
// *  @param success   成功失败
// *  @param errnum    编码信息
// *  @param errmsg    信息
// *  @param tipsArray 提示内容
// */
//typedef void (^GetMonthlyFeeTipsFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSArray *tipsArray);
//
//- (NSInteger)getMonthlyFee:(GetMonthlyFeeTipsFinishHandler)finishHandler;
//
///**
// *  获取买点送月费的文字说明
// *
// *  @param success   成功失败
// *  @param errnum    编码信息
// *  @param errmsg    信息
// *  @param tipsArray 提示内容
// */
//typedef void (^GetPremiumMemberShipFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, PremiumMemberShipItemObject *item);
//- (NSInteger)getPremiumMemberShip:(GetPremiumMemberShipFinishHandler)finishHandler;
//
//#pragma mark - EMF模块
///**
// *  7.5.获取EMF邮件数
// *
// *  @param success  成功失败
// *  @param code     错误码
// *  @param orderNo
// */
///**
// *  7.5.统计男士数据接口回调
// *
// *  @param success 成功失败
// *  @param total   邮件数
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^GetEMFCountFinishHandler)(BOOL success, int total, NSString *errnum, NSString *errmsg);
//
//- (NSInteger)getEMFCount:(GetEMFCountFinishHandler)finishHandler;
//
///**
// *  7.1.查询收件箱列表接口回调
// *
// *  @param success 成功失败
// *  @param total   邮件数
// *  @param errnum  错误码
// *  @param errmsg  错误提示
// */
//typedef void (^GetEMFInboxListFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, EMFInboxListItemObject *item);
///**
// *  7.1.获取查询收件箱列表
// *
// *  @param pageIndex               当前页数
// *  @param pageSize                每页行数
// *  @param sortType                筛选条件（1:未读 2:已读回复 3:已回复）
// *  @param womanId                 只显示某女士邮件（可无）
// *  @param finishHandler           回调
// */
//- (NSInteger)getEMFInboxList:(int)pageIndex
//                    pageSize:(int)pageSize
//                    sortType:(int)sortType
//                     womanId:(NSString *)womanId
//                      finish:(GetEMFInboxListFinishHandler)finishHandler;
///**
// *  7.2.查询已收邮件详情接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^GetEMFInboxMsgFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, int memberType, EMFInboxMsgItemObject *item);
///**
// *  7.2.获取查询已收邮件详情
// *
// *  @param messageId         邮件ID
// *  @param finishHandler     回调
// */
//- (NSInteger)getEMFInboxMsg:(NSString *)messageId
//                     finish:(GetEMFInboxMsgFinishHandler)finishHandler;
//
///**
// *  7.3.查询发件箱列表接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^GetEMFOutboxListFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, EMFOutboxListItemObject *item);
///**
// *  7.3.获取查询发件箱列表详情
// *
// *  @param pageIndex               当前页数
// *  @param pageSize                每页行数
// *  @param progressType                筛选条件（U:Unread P:Pending D:De;overed 无：ALL）（可无）
// *  @param womanId                 只显示某女士邮件（可无）
// *  @param finishHandler           回调
// */
//- (NSInteger)getEMFOutboxList:(int)pageIndex
//                     pageSize:(int)pageSize
//                 progressType:(int)progressType
//                      womanId:(NSString *)womanId
//                       finish:(GetEMFOutboxListFinishHandler)finishHandler;
//
///**
// *  7.4.查询已发邮件详情接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^GetEMFOutboxMsgFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, EMFOutboxMsgItemObject *item);
///**
// *  7.4.获取查询已发邮件详情
// *
// *  @param messageId         邮件ID
// *  @param finishHandler     回调
// */
//- (NSInteger)getEMFOutboxMsg:(NSString *)messageId
//                      finish:(GetEMFOutboxMsgFinishHandler)finishHandler;
//
///**
// *  7.6.发送邮件接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^SendEMFMsgFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, EMFSendMsgItemObject *item, EMFSendMsgErrorItemObject *errorItem);
///**
// *  7.6.发送邮件接口
// *
// *  @param womanId          女士ID
// *  @param body             邮件内容
// *  @param useIntegral      是否使用积分（1:是 0:否）
// *  @param replyType        回复类型（adr：意向信 emf：EMF）
// *  @param mtab             表后（仅意向信回复）
// *  @param gifts            虚拟礼物ID（数组）
// *  @param attachs          附件数组（数组）
// *  @param isLovecall       emf来源（lovecall邀请：invite）
// *  @messageId              邮件ID
// *  @param finishHandler
// */
//- (NSInteger)sendEMFMsg:(NSString *)womanId
//                   body:(NSString *)body
//            useIntegral:(BOOL)useIntegral
//              replyType:(int)replyType
//                   mtab:(NSString *)mtab
//                  gifts:(NSArray<NSString *> *)gifts
//                attachs:(NSArray<NSString *> *)attachs
//             isLovecall:(BOOL)isLovecall
//              messageId:(NSString *)messageId
//                 finish:(SendEMFMsgFinishHandler)finishHandler;
//
///**
// *  7.7.追加邮件附件接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^UploadEMFImageFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
///**
// *  7.7.追加邮件附件接口
// *
// *  @param messageId       邮件ID
// *  @param fileList        附件数组的文件名
// *  @param finishHandler   回调
// */
//- (NSInteger)uploadEMFImage:(NSString *)messageId
//                   fileList:(NSArray<NSString *> *)fileList
//                     finish:(UploadEMFImageFinishHandler)finishHandler;
//
///**
// *  7.8.上传邮件附件接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^UploadEMFAttachFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSString *attachId);
///**
// *  7.8.上传邮件附件接口
// *
// *  @param filePath         文件名的KEY值，例如本参数可设为private_photo_file
// *  @param attachType       附件类型（1:图片）
// *  @param finishHandler    回调
// */
//- (NSInteger)UploadEMFAttach:(NSString *)filePath
//                  attachType:(int)attachType
//                      finish:(UploadEMFAttachFinishHandler)finishHandler;
//
///**
// *  7.9.删除邮件接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^DeleteEMFMsgFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
///**
// *  7.9.删除邮件接口
// *
// *  @param messageId       邮件ID
// *  @param mailType        邮件类型（1:收件箱邮件 2:发件箱邮件 3:意向信邮件）
// *  @param finishHandler   回调
// */
//- (NSInteger)deleteEMFMsg:(NSString *)messageId
//                 mailType:(int)mailType
//                   finish:(DeleteEMFMsgFinishHandler)finishHandler;
//
///**
// *  7.10.查询意向信收件箱列表接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^GetEMFAdmirerListFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, EMFAdmirerListItemObject *item);
///**
// *  7.10.查询意向信收件箱列表接口
// *
// *  @param pageIndex               当前页数
// *  @param pageSize                每页行数
// *  @param sortType                筛选条件（1:未读 2:已读）
// *  @param womanId                 只显示某女士邮件（可无）
// *  @param finishHandler           回调
// */
//- (NSInteger)getEMFAdmirerList:(int)pageIndex
//                      pageSize:(int)pageSize
//                      sortType:(int)sortType
//                       womanId:(NSString *)womanId
//                        finish:(GetEMFAdmirerListFinishHandler)finishHandler;
//
///**
// *  7.11.查询意向信详细信息接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^GetEMFAdmirerViewerFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, EMFAdmirerViewerItemObject *item);
///**
// *  7.11.查询意向信详细信息接口
// *
// *  @param messageId         意向信ID
// *  @param finishHandler     回调
// */
//- (NSInteger)getEMFAdmirerViewer:(NSString *)messageId
//                          finish:(GetEMFAdmirerViewerFinishHandler)finishHandler;
//
///**
// *  7.12.查询黑名单列表接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^GetEMFBlockListFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, EMFBlockListItemObject *item);
///**
// *  7.12.查询黑名单列表接口
// *
// *  @param pageIndex               当前页数
// *  @param pageSize                每页行数
// *  @param womanId                 只显示某女士邮件（可无）
// *  @param finishHandler           回调
// */
//- (NSInteger)getEMFBlockList:(int)pageIndex
//                    pageSize:(int)pageSize
//                     womanId:(NSString *)womanId
//                      finish:(GetEMFBlockListFinishHandler)finishHandler;
//
///**
// *  7.13.添加黑名单接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^AddEMFBlockFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
///**
// *  7.13.添加黑名单接口
// *
// *  @param womanId           女士ID
// *  @param blockreason       加入黑名单原因（1:原因A 2:原因B 3:原因C）
// *  @param finishHandler     回调
// */
//- (NSInteger)addEMFBlock:(NSString *)womanId
//             blockreason:(int)blockreason
//                  finish:(AddEMFBlockFinishHandler)finishHandler;
//
///**
// *  7.14.删除黑名单接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^DeleteEMFBlockFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
///**
// *  7.14.删除黑名单接口
// *
// *  @param fileList          女士ID（可多个，多个使用逗号“，”隔开）
// *  @param finishHandler     回调
// */
//- (NSInteger)deleteEMFBlock:(NSArray<NSString *> *)fileList
//                     finish:(DeleteEMFBlockFinishHandler)finishHandler;
//
///**
// *  7.15.男士付费获取EMF私密照片接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^GetEMFInboxPhotoFeeFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
///**
// *  7.15.男士付费获取EMF私密照片接口
// *
// *  @param womanId          女士ID
// *  @param sendId           发送ID
// *  @param photoId          图片ID
// *  @param messageId        邮件ID
// *  @param finishHandler    回调
// */
//- (NSInteger)getEMFInboxPhotoFee:(NSString *)womanId
//                         photoId:(NSString *)photoId
//                          sendId:(NSString *)sendId
//                       messageId:(NSString *)messageId
//                          finish:(GetEMFInboxPhotoFeeFinishHandler)finishHandler;
//
///**
// * 7.16. 获取对方或自己的EMF私密照片接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^GetEMFPrivatePhotoViewFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSString *filePath);
///**
// *  7.16.获取对方或自己的EMF私密照片接口
// *  @param womanId          女士ID
// *  @param sendId           发送ID
// *  @param photoId          图片ID
// *  @param messageId        邮件ID
// *  @param filePath         文件路径？
// *  @param type             照片尺寸（1:大 m：中 s：小 o：原始）
// *  @param mode             照片清晰度（0:模糊 1:清晰）（付费成功才使用清晰，否则使用模糊）
// *  @param finishHandler    回调
// */
//- (NSInteger)getEMFPrivatePhotoView:(NSString *)womanId
//                             sendId:(NSString *)sendId
//                            photoId:(NSString *)photoId
//                          messageId:(NSString *)messageId
//                           filePath:(NSString *)filePath
//                               type:(int)type
//                               mode:(int)mode
//                             finish:(GetEMFPrivatePhotoViewFinishHandler)finishHandler;
//
///**
// *  7.17.返回EMF微视频的图片流接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^GetEMFShortVideoPhotoFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSString *filePath);
///**
// *  7.17.返回EMF微视频的图片流接口
// *
// *  @param womanId          女士ID
// *  @param sendId           发送ID
// *  @param videoId          视频ID
// *  @param messageId        邮件ID
// *  @param size             照片尺寸（0:小图 1:大图）ß
// *  @param filePath         文件？
// *  @param finishHandler    回调
// */
//- (NSInteger)getEMFShortVideoPhoto:(NSString *)womanId
//                            sendId:(NSString *)sendId
//                           videoId:(NSString *)videoId
//                         messageId:(NSString *)messageId
//                              size:(int)size
//                          filePath:(NSString *)filePath
//                            finish:(GetEMFShortVideoPhotoFinishHandler)finishHandler;
//
///**
// *  7.18.EMF微视频扣费/播放接口回调
// *
// *  @param success      成功失败
// *  @param total        邮件数
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//typedef void (^PlayEMFShortVideoUrlFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSString *url);
///**
// *  7.18.EMF微视频扣费/播放接口
// *
// *  @param womanId          女士ID
// *  @param sendId           发送ID
// *  @param videoId          视频ID
// *  @param messageId        邮件ID
// *  @param finishHandler    回调
// */
//- (NSInteger)playEMFShortVideoUrl:(NSString *)womanId
//                           sendId:(NSString *)sendId
//                          videoId:(NSString *)videoId
//                        messageId:(NSString *)messageId
//                           finish:(PlayEMFShortVideoUrlFinishHandler)finishHandler;
#pragma mark - licvChat
/**
 *  6.3.获取虚拟礼物列表接口回调
 *
 *  @param success      成功失败
 *  @param total        邮件数
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param memberType   会员类型
 */

typedef void (^QueryChatVirtualGiftFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSMutableArray *itemArray, int totolCount, NSString *path, NSString *version);
/**
 *  6.3.获取虚拟礼物列表接口
 *
 *  @param userSid          登录成功返回的sessionid
 *  @param userId           登录成功返回的manid
 *  @param finishHandler    回调
 */
- (NSInteger)queryChatVirtualGift:(NSString *)userSid
                           userId:(NSString *)userId
                           finish:(QueryChatVirtualGiftFinishHandler)finishHandler;

/**
 *  6.12.发送虚拟礼物接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */

typedef void (^SendGiftFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
/**
 *  6.12.发送虚拟礼物接口
 *
 *  @param womanId          女士ID
 *  @param vg_id            虚拟礼物
 *  @param chat_id          livechat邀请ID或者EMF邮件ID
 *  @param use_type         模块类型（emf：邮件 chat:LiveChat）
 *  @param user_sid          登录成功返回的sessionid
 *  @param user_id           登录成功返回的manid
 *  @param finishHandler    回调
 */
- (NSInteger)sendGift:(NSString *)womanId
                vg_id:(NSString *)vg_id
              chat_id:(NSString *)chat_id
             use_type:(int)use_type
             user_sid:(NSString *)user_sid
              user_id:(NSString *)user_id
               finish:(SendGiftFinishHandler)finishHandler;

//#pragma mark - 设置模块
//
///**
// *  4.1.修改密码接口回调
// *
// *  @param success      成功失败
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// */
//
//typedef void (^ChangePasswordFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg);
///**
// *  4.1.修改密码接口
// *
// *  @param oldPassword      旧密码
// *  @param newPassword      新密码
// *  @param finishHandler    回调
// */
//- (NSInteger)changePassword:(NSString *)oldPassword
//                newPassword:(NSString *)newPassword
//                     finish:(ChangePasswordFinishHandler)finishHandler;
//
//#pragma mark - 视频显示模块
//
///**
// *  8.2.查询指定女士的视频信息接口回调
// *
// *  @param success      成功失败
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// */
//
//typedef void (^VideoDetailFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, NSArray<VSVideoDetailItemObject *> *list);
///**
// *  8.2.查询指定女士的视频信息接口
// *
// *  @param womanId          女士ID
// *  @param finishHandler    回调
// */
//- (NSInteger)videoDetail:(NSString * )womanId
//                  finish:(VideoDetailFinishHandler )finishHandler;
//
///**
// *  8.3.查询视频相惜信息接口回调
// *
// *  @param success      成功失败
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// */
//
//typedef void (^PlayVideoFinishHandler)(BOOL success, NSString*  errnum, NSString *  errmsg, VSPlayVideoItemObject*  item);
///**
// *  8.3.查询视频相惜信息接口
// *
// *  @param womanId          女士
// *  @param videoId          视频ID
// *  @param finishHandler    回调
// */
//- (NSInteger)playVideo:(NSString * )womanId
//               videoId:(NSString * )videoId
//                finish:(PlayVideoFinishHandler )finishHandler;
//
//#pragma mark - LoveCall模块回调
///**
// *  11.1.获取Love Call列表接口回调
// *
// *  @param success      成功失败
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// */
//
//typedef void (^QueryLoveCallListFinishHandler)(BOOL success, NSString*  errnum, NSString *  errmsg, LoveCallListItemObject*  item);
///**
// *  11.1.获取Love Call列表接口
// *
// *  @param pageIndex          当前页数
// *  @param pageSize           每页行数
// *  @param type               Love Call类型（0:Request， 1:Scheduled）
// *  @param finishHandler      回调
// */
//- (NSInteger)queryLoveCallList:(int)pageIndex
//                      pageSize:(int)pageSize
//                          Type:(int)type
//                finish:(QueryLoveCallListFinishHandler )finishHandler;
//
///**
// *  11.2.确定LoveCall接口回调
// *
// *  @param success      成功失败
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param memberType   会员类型
// */
//
//typedef void (^ConfirmLoveCallFinishHandler)(BOOL success, NSString*  errnum, NSString *  errmsg, int memberType);
///**
// *  11.2.确定LoveCall接口
// *
// *  @param orderId          订单ID
// *  @param confirmType      确定类型（1：接受，0：拒绝）
// *  @param finishHandler    回调
// */
//- (NSInteger)confirmLoveCall:(NSString * )orderId
//                 confirmType:(int)confirmType
//                      finish:(ConfirmLoveCallFinishHandler )finishHandler;
//
///**
// *  11.3 获取LoveCall未处理数接口回调
// *
// *  @param success      成功失败
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param num          LoveCall未处理数量
// */
//
//typedef void (^QueryLoveCallRequestCountFinishHandler)(BOOL success, NSString*  errnum, NSString *  errmsg, int num);
///**
// *  11.3 获取LoveCall未处理数接口
// *
// *  @param type             Love Call类型（0:Request， 1:Scheduled, 默认： 0， 可无）
// *  @param finishHandler    回调
// */
//- (NSInteger)queryLoveCallRequestCount:(int)type
//                                finish:(QueryLoveCallRequestCountFinishHandler )finishHandler;
//
//
//#pragma mark - 广告模块回调
//
///**
// *  9.2.查询女士列表广告接口回调
// *
// *  @param success      成功失败
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param advertId     广告Id
// *  @param htmlCode     html页面代码
// *  @param advertTitle  广告标题
// */
//
//typedef void (^WonmanListAdvertFinishHandler)(BOOL success, NSString*  errnum, NSString *  errmsg, WomanListAdItemObject*   item);
///**
// *  9.2.查询女士列表广告接口
// *
// *  @param advertId         广告Id（可无）
// *  @param adspaceId        广告位ID（AD_SPACE_TYPE_A:相当于广告位A 在 10 - 20位， AD_SPACE_TYPE_B:相当于广告位A 在 40 - 50位，AD_SPACE_TYPE_C:相当于广告位A 在 80 - 90位，）
// *  @param showTimes        客户端显示广告次数（可无）
// *  @param clickTimes       客户端点击广告次数（可无）
// *  @param finishHandler    回调
// */
//- (NSInteger)wonmanListAdvert:(NSString * )advertId
//                    showTimes:(int)showTimes
//                   clickTimes:(int)clickTimes
//                    adspaceId:(AdvertSpaceType)adspaceId
//                       finish:(WonmanListAdvertFinishHandler )finishHandler;
//
///**
// *  9.7.查询意向信列表广告接口回调
// *
// *  @param success      成功失败
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param advertId     广告Id
// *  @param htmlCode     html页面代码
// *  @param advertTitle  广告标题
// */
//
//typedef void (^AdmirerListAdvertFinishHandler)(BOOL success, NSString*  errnum, NSString *  errmsg, NSString *  advertId, NSString *  htmlCode, NSString *  advertTitle);
///**
// *  9.7.查询意向信列表广告接口
// *
// *  @param advertId         广告Id（可无）
// *  @param firstGottime     首次获取的客户端本地时间（Unix Timestamp）（可无）
// *  @param showTimes        客户端显示广告次数（可无）
// *  @param clickTimes       客户端点击广告次数（可无）
// *  @param finishHandler    回调
// */
//- (NSInteger)admirerListAdvert:(NSString * )advertId
//                  firstGottime:(long)firstGottime
//                     showTimes:(int)showTimes
//                    clickTimes:(int)clickTimes
//                        finish:(AdmirerListAdvertFinishHandler )finishHandler;
//
///**
// *  9.8.查询HTML5广告接口回调
// *
// *  @param success      成功失败
// *  @param errnum       错误码
// *  @param errmsg       错误提示
// *  @param advertId     广告Id
// *  @param htmlCode     html页面代码
// *  @param advertTitle  广告标题
// *  @param height       广告高度
// */
//
//typedef void (^Html5AdvertFinishHandler)(BOOL success, NSString*  errnum, NSString *  errmsg, Html5AdItemObject *  item);
///**
// *  9.8.查询HTML5广告接口
// *
// *  @param advertId         广告Id（可无）
// *  @param firstGottime     首次获取的客户端本地时间（Unix Timestamp）（可无）
// *  @param showTimes        客户端显示广告次数（可无）
// *  @param clickTimes       客户端点击广告次数（可无）
// *  @param adspaceId        广告位ID（AD_HTML_SPACE_TYPE_ANDROID_LOI：Android意向信列表广告 AD_HTML_SPACE_TYPE_IOS_LOI：ios意向信列表广告 AD_HTML_SPACE_TYPE_ANDROID_INVITE：  Android LiveChat 邀请列表广告 AD_HTML_SPACE_TYPE_IOS_INVITE：  ios LiveChat 邀请列表广告   AD_HTML_SPACE_TYPE_ANDROID_MAIN ：android主界面弹窗广告,
// AD_HTML_SPACE_TYPE_IOS_MAIN ：ios主界面弹窗广告）
// *  @param adOverview       登录成功返回的主界面弹窗参数（可无）
// *  @param finishHandler    回调
// */
//- (NSInteger)html5Advert:(NSString * )advertId
//                firstGottime:(long)firstGottime
//               showTimes:(int)showTimes
//              clickTimes:(int)clickTimes
//               adspaceId:(AdvertHtmlSpaceType)adspaceId
//              adOverview:(NSString *)adOverview
//                  finish:(Html5AdvertFinishHandler )finishHandler;

@end
