//
//  RequestManager.h
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LoginItemObject.h"
#import "ViewerFansItemObject.h"
#import "LiveRoomInfoItemObject.h"
#import "LiveRoomPersonalInfoItemObject.h"
#import "CoverPhotoItemObject.h"
#import "LiveRoomGiftItemObject.h"
#import "LiveRoomConfigItemObject.h"

#include <httpcontroller/HttpRequestEnum.h>

@interface RequestManager : NSObject
@property (nonatomic, strong) NSString* _Nonnull versionCode;
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

#pragma mark - 公共模块
/**
 *  设置是否打印日志
 *
 *  @param enable <#enable description#>
 */
- (void)setLogEnable:(BOOL)enable;

/**
 *  设置接口目录
 *
 *  @param directory 可写入目录
 */
- (void)setLogDirectory:(NSString * _Nonnull)directory;

/**
 *  设置接口服务器域名
 *
 *  @param webSite 接口服务器域名
 */
- (void)setWebSite:(NSString * _Nonnull)webSite;
- (void)setWebSiteUpload:(NSString * _Nonnull)webSite;
/**
 *  设置接口服务器用户认证
 *
 *  @param user     用户名
 *  @param password 密码
 */
- (void)setAuthorization:(NSString * _Nonnull)user password:(NSString * _Nonnull)password;

/**
 *  清除Cookies
 */
- (void)cleanCookies;

/**
 *  根据域名获取Cookies
 *
 *  @param site 域名
 */
- (void)getCookies:(NSString * _Nonnull)site;

/**
 *  停止请求接口
 *
 *  @param request 请求
 */
- (void)stopRequest:(NSInteger)request;

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
- (NSString * _Nonnull)getDeviceId;

#pragma mark - 登陆认证模块

/**
 *  2.1.验证手机是否已注册接口回调
 *
 *  @param success        成功失败
 *  @param errnum         错误码
 *  @param errmsg         错误提示
 *  @param isRegistered   是否已注册
 */
typedef void (^RegisterCheckPhoneFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, int isRegistered);

/**
 *  2.1.验证手机是否已注册接口
 *
 * @param phoneno           手机号码
 * @param areno				手机区号
 * @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)registerCheckPhone:(NSString * _Nullable)phoneno
                          areno:(NSString * _Nullable)areno
                  finishHandler:(RegisterCheckPhoneFinishHandler _Nullable)finishHandler;
/**
 *  2.2.获取手机注册短信验证码接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^RegisterGetSMSCodeFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  2.2.获取手机注册短信验证码接口
 *
 * @param phoneno           手机号码
 * @param areno				手机区号
 * @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)registerGetSMSCode:(NSString * _Nullable)phoneno
                   areno:(NSString * _Nullable)areno
           finishHandler:(RegisterGetSMSCodeFinishHandler _Nullable)finishHandler;

/**
 *  2.3.手机注册接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^RegisterPhoneFinishHandler)(BOOL success, int errnum, NSString * _Nonnull errmsg);

/**
 *  2.3.手机注册接口
 *
 * @param phoneno           手机号码（仅当type ＝ 0 时使用）
 * @param areno				手机区号（仅当type ＝ 0 时使用）
 * @param checkcode			验证码
 * @param password			登录密码
 * @param deviceid		    设备唯一标识
 * @param model				设备型号（格式：设备型号－系统版本号）
 * @param manufacturer		制造厂商
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)registerPhone:(NSString * _Nullable)phoneno
                     areno:(NSString * _Nullable)areno
                 checkcode:(NSString * _Nonnull)checkcode
                  password:(NSString * _Nonnull)password
                  deviceid:(NSString * _Nonnull)deviceid
                     model:(NSString * _Nonnull)model
              manufacturer:(NSString * _Nonnull)manufacturer
             finishHandler:(RegisterPhoneFinishHandler _Nullable)finishHandler;

/**
 *  2.4.登陆接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^LoginFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, LoginItemObject * _Nonnull item);

/**
 *  2.4.登陆接口
 *
 * @param type				登录类型（0: 手机登录 1:邮箱登录）
 * @param phoneno           手机号码（仅当type ＝ 0 时使用）
 * @param areno				手机区号（仅当type ＝ 0 时使用）
 * @param password			登录密码
 * @param deviceid		    设备唯一标识
 * @param model				设备型号（格式：设备型号－系统版本号）
 * @param manufacturer		制造厂商
 * @param autoLogin         是否自动登录
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)login:(LoginType)type
        phoneno:(NSString * _Nullable)phoneno
        areno:(NSString * _Nullable)areno
        password:(NSString * _Nonnull)password
        deviceid:(NSString * _Nonnull)deviceid
        model:(NSString * _Nonnull)model
    manufacturer:(NSString * _Nonnull)manufacturer
        autoLogin:(BOOL)autoLogin
    finishHandler:(LoginFinishHandler _Nullable)finishHandler;

/**
 *  2.5.注销接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^LogoutFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  2.5.注销接口
 *
 *  @param token           用户身份唯一标识
 *  @param finishHandler  接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)logout:(NSString * _Nonnull)token finishHandler:(LogoutFinishHandler _Nullable)finishHandler;

#pragma mark - 直播间模块
/**
 *  2.6.上传tokenid接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^UpdateLiveRoomTokenIdFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  2.6.上传tokenid接口
 *
 *  @param token			用户身份唯一标识
 *  @param tokenId			用于Push Notification的ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)updateLiveRoomTokenId:(NSString * _Nonnull)token
                           tokenId:(NSString * _Nonnull)tokenId
                     finishHandler:(UpdateLiveRoomTokenIdFinishHandler _Nullable)finishHandler;

/**
 *  3.1.新建直播间接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param roomId  直播间ID
 *  @param roomurl  直播间流媒体服务url（如 rtmp://192.168.88.17/live/samson_1）
 */
typedef void (^CreateLiveRoomFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, NSString * _Nonnull roomurl);

/**
 *  3.1.新建直播间接口
 *
 * @param token				用户身份唯一标识
 * @param roomName          直播间名称
 * @param roomPhotoId		封面图ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)createLiveRoom:(NSString * _Nonnull)token
                   roomName:(NSString * _Nonnull)roomName
                roomPhotoId:(NSString * _Nonnull)roomPhotoId
              finishHandler:(CreateLiveRoomFinishHandler _Nullable)finishHandler;

/**
 *  3.2.获取本人正在直播的直播间信息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param roomId  直播间ID
 *  @param roomurl  直播间流媒体服务url（如 rtmp://192.168.88.17/live/samson_1）
 */
typedef void (^CheckLiveRoomFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, NSString * _Nonnull roomurl);

/**
 *  3.2.获取本人正在直播的直播间信息接口
 *
 * @param token				用户身份唯一标识
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)checkLiveRoom:(NSString * _Nonnull)token
              finishHandler:(CheckLiveRoomFinishHandler _Nullable)finishHandler;

/**
 *  3.3.关闭直播间息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^CloseLiveRoomFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  3.3.关闭直播间息接口
 *
 *  @param token			用户身份唯一标识
 *  @param roomId			直播间ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)closeLiveRoom:(NSString * _Nonnull)token
                    roomId:(NSString * _Nonnull)roomId
             finishHandler:(CloseLiveRoomFinishHandler _Nullable)finishHandler;

/**
 *  3.4.获取直播间观众头像列表（限定数量）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   观众列表
 */
typedef void (^GetLiveRoomFansListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<ViewerFansItemObject *>* _Nullable array);

/**
 *  3.4.获取直播间观众头像列表（限定数量）接口
 *
 *  @param token			用户身份唯一标识
 *  @param roomId			直播间ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomFansList:(NSString * _Nonnull)token
                              roomId:(NSString * _Nonnull)roomId
                       finishHandler:(GetLiveRoomFansListFinishHandler _Nullable)finishHandler;


/**
 *  3.5.获取直播间所有观众头像列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   观众列表
 */
typedef void (^GetLiveRoomAllFansListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<ViewerFansItemObject *>* _Nullable array);

/**
 *  3.5.获取直播间所有观众头像列表接口
 *
 *  @param token			用户身份唯一标识
 *  @param roomId			直播间ID
 *  @param start			起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomAllFansList:(NSString * _Nonnull)token
                             roomId:(NSString * _Nonnull)roomId
                              start:(int)start
                               step:(int)step
                      finishHandler:(GetLiveRoomAllFansListFinishHandler _Nullable)finishHandler;

#pragma mark - 主播属性模块
/**
 *  3.6.获取Hot列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   热门列表
 */
typedef void (^GetLiveRoomHotListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomInfoItemObject *>* _Nullable array);

/**
 *  3.6.获取Hot列表接口
 *
 *  @param token			用户身份唯一标识
 *  @param start			起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomHotList:(NSString * _Nonnull)token
                              start:(int)start
                               step:(int)step
                      finishHandler:(GetLiveRoomHotListFinishHandler _Nullable)finishHandler;

/**
 *  3.7.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   封面图列表
 */
typedef void (^GetLiveRoomAllGiftListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomGiftItemObject *>* _Nullable array);

/**
 *  3.7.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)接口
 *
 *  @param token			用户身份唯一标识
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomAllGiftList:(NSString * _Nonnull)token
                      finishHandler:(GetLiveRoomAllGiftListFinishHandler _Nullable)finishHandler;

/**
 *  3.8.获取直播间可发送的礼物列表（观众端获取已进入的直播间可发送的礼物列表）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   封面图列表
 */
typedef void (^GetLiveRoomGiftListByUserIdFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<NSString *>* _Nullable array);

/**
 *  3.8.获取直播间可发送的礼物列表（观众端获取已进入的直播间可发送的礼物列表）接口
 *
 *  @param token			用户身份唯一标识
 *  @param roomId           直播间ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomGiftListByUserId:(NSString * _Nonnull)token
                                  roomId:(NSString * _Nonnull)roomId
                      finishHandler:(GetLiveRoomGiftListByUserIdFinishHandler _Nullable)finishHandler;

/**
 *  3.9.获取指定礼物详情（用于观众端／主播端在直播间收到《3.7.》没有礼物时，获取指定礼物详情来显示）
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    指定礼物详情
 */
typedef void (^GetLiveRoomGiftDetailFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, LiveRoomGiftItemObject* _Nullable item);

/**
 *  3.9.获取指定礼物详情（用于观众端／主播端在直播间收到《3.7.》没有礼物时，获取指定礼物详情来显示）
 *
 *  @param token			用户身份唯一标识
 *  @param giftId           礼物ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomGiftDetail:(NSString * _Nonnull)token
                                  giftId:(NSString * _Nonnull)giftId
                           finishHandler:(GetLiveRoomGiftDetailFinishHandler _Nullable)finishHandler;


/**
 *  3.10.获取开播封面图列表（用于主播开播前，获取封面图列表）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   封面图列表
 */
typedef void (^GetLiveRoomPhotoListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<CoverPhotoItemObject *>* _Nullable array);

/**
 *  3.10.获取开播封面图列表（用于主播开播前，获取封面图列表）接口
 *
 *  @param token			用户身份唯一标识
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomPhotoList:(NSString * _Nonnull)token
                    finishHandler:(GetLiveRoomPhotoListFinishHandler _Nullable)finishHandler;


/**
 *  3.11.添加开播封面图（用于主播添加开播封面图）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^AddLiveRoomPhotoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  3.11.添加开播封面图（用于主播添加开播封面图）接口
 *
 *  @param token			用户身份唯一标识
 *  @param photoId          封面图ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)addLiveRoomPhoto:(NSString * _Nonnull)token
                      photoId:(NSString * _Nonnull)photoId
                finishHandler:(AddLiveRoomPhotoFinishHandler _Nullable)finishHandler;

/**
 *  3.12.设置默认使用封面图（用于主播设置默认的封面图）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SetUsingLiveRoomPhotoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  3.12.设置默认使用封面图（用于主播设置默认的封面图）接口
 *
 *  @param token			用户身份唯一标识
 *  @param photoId          封面图ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)setUsingLiveRoomPhoto:(NSString * _Nonnull)token
                           photoId:(NSString * _Nonnull)photoId
                     finishHandler:(SetUsingLiveRoomPhotoFinishHandler _Nullable)finishHandler;

/**
 *  3.13.删除开播封面图（用于主播删除开播封面图）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^DelLiveRoomPhotoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  3.13.删除开播封面图（用于主播删除开播封面图）接口
 *
 *  @param token			用户身份唯一标识
 *  @param photoId          封面图ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)delLiveRoomPhoto:(NSString * _Nonnull)token
                      photoId:(NSString * _Nonnull)photoId
                finishHandler:(DelLiveRoomPhotoFinishHandler _Nullable)finishHandler;


/**
 *  4.1.获取用户头像接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @param photoUrl   头像url
 */
typedef void (^GetLiveRoomUserPhotoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull photoUrl);

/**
 *  4.1.获取用户头像接口
 *
 *  @param token			用户身份唯一标识
 *  @param userId			用户ID
 *  @param photoType		头像类型（0：小图（用于直播间显示头像） 1:大图（用于个人信息界面等显示头像））
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomUserPhoto:(NSString * _Nonnull)token
                               userId:(NSString * _Nonnull)userId
                            photoType:(PhotoType)photoType
                        finishHandler:(GetLiveRoomUserPhotoFinishHandler _Nullable)finishHandler;


/**
 *  4.2.获取可编辑的本人资料接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @param item   头像url
 */
typedef void (^GetLiveRoomModifyInfoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, LiveRoomPersonalInfoItemObject* _Nonnull item);

/**
 *  4.2.获取可编辑的本人资料接口
 *
 *  @param token			用户身份唯一标识
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomModifyInfo:(NSString * _Nonnull)token
                    finishHandler:(GetLiveRoomModifyInfoFinishHandler _Nullable)finishHandler;

/**
 *  4.3.提交本人资料接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^SetLiveRoomModifyInfoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  4.3.提交本人资料接口
 *
 *  @param token			用户身份唯一标识
 *  @param photoId			头像图片ID（可无，无则表示不修改）
 *  @param nickName			昵称
 *  @param gender			性别（0：男性 1:女性）
 *  @param birthday			出生日期（格式： 1980-01-01）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)setLiveRoomModifyInfo:(NSString * _Nonnull)token
                          photoId:(NSString * _Nonnull)photoId
                          nickName:(NSString * _Nonnull)nickName
                            gender:(Gender)gender
                          birthday:(NSString * _Nonnull)birthday
                     finishHandler:(SetLiveRoomModifyInfoFinishHandler _Nullable)finishHandler;

/**
 *  5.1.同步配置（用于客户端获取http接口服务器，IM服务器及上传图片服务器域名及端口等配置）接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @param item       同步配置
 */
typedef void (^GetLiveRoomConfigFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, LiveRoomConfigItemObject* _Nonnull item);

/**
 *  5.1.同步配置（用于客户端获取http接口服务器，IM服务器及上传图片服务器域名及端口等配置）接口回调
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveRoomConfig:(GetLiveRoomConfigFinishHandler _Nullable)finishHandler;


/**
 *  5.2.上传图片接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @param imageId    图片ID
 *  @param imageUrl   图片url
 */
typedef void (^UploadLiveRoomImgFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull imageId, NSString * _Nonnull imageUrl);

/**
 *  5.2.上传图片接口
 *
 *  @param token			用户身份唯一标识
 *  @param imageType	    图片类型（1：用户头像 2:直播间封面图）
 *  @param imageFileName    图片文件二进制数据
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)uploadLiveRoomImg:(NSString * _Nonnull)token
                     imageType:(ImageType)imageType
                 imageFileName:(NSString * _Nonnull)imageFileName
                 finishHandler:(UploadLiveRoomImgFinishHandler _Nullable)finishHandler;

@end
