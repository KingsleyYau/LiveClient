//
//  LSRequestManager.m
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSRequestManager.h"

#include <common/CommonFunc.h>
#include <common/KZip.h>

#include <httpclient/HttpRequestManager.h>

#include <httpcontroller/HttpRequestController.h>

#include <httpcontroller/HttpRequestDefine.h>


/*直播间状态转换*/
static const int HTTPErrorTypeArray[] = {
    HTTP_LCC_ERR_SUCCESS,           // 成功
    HTTP_LCC_ERR_FAIL,                 // 服务器返回失败结果
    
    // 客户端定义的错误
    HTTP_LCC_ERR_PROTOCOLFAIL,       // 协议解析失败（服务器返回的格式不正确）
    HTTP_LCC_ERR_CONNECTFAIL,        // 连接服务器失败/断开连接
//    HTTP_LCC_ERR_CHECKVERFAIL,       // 检测版本号失败（可能由于版本过低导致）
//
//    HTTP_LCC_ERR_SVRBREAK,           // 服务器踢下线
//    HTTP_LCC_ERR_INVITE_TIMEOUT,     // 邀请超时
    
    // 服务器返回错误
    HTTP_LCC_ERR_ROOM_FULL,           // 房间人满
    HTTP_LCC_ERR_NO_CREDIT,           // 信用点不足
    
    /* IM公用错误码 */
    HTTP_LCC_ERR_NO_LOGIN,           // 未登录
    HTTP_LCC_ERR_SYSTEM,             // 系统错误
    HTTP_LCC_ERR_TOKEN_EXPIRE,         // Token 过期了
    HTTP_LCC_ERR_NOT_FOUND_ROOM,     // 进入房间失败 找不到房间信息or房间关闭
    HTTP_LCC_ERR_CREDIT_FAIL,         // 远程扣费接口调用失败
    
    HTTP_LCC_ERR_ROOM_CLOSE,          // 房间已经关闭
    HTTP_LCC_ERR_KICKOFF,             // 被挤掉线 默认通知内容
    HTTP_LCC_ERR_NO_AUTHORIZED,     // 不能操作 不是对应的userid
    HTTP_LCC_ERR_LIVEROOM_NO_EXIST, // 直播间不存在
    HTTP_LCC_ERR_LIVEROOM_CLOSED,     // 直播间已关闭
    
    HTTP_LCC_ERR_ANCHORID_INCONSISTENT,     // 主播id与直播场次的主播id不合
    HTTP_LCC_ERR_CLOSELIVE_DATA_FAIL,         // 关闭直播场次,数据表操作出错
    HTTP_LCC_ERR_CLOSELIVE_LACK_CODITION,     // 主播立即关闭私密直播间, 不满足关闭条件
    
    /* 其它错误码*/
    HTTP_LCC_ERR_USED_OUTLOG,                 // 退出登录 (用户主动退出登录)
    HTTP_LCC_ERR_NOTCAN_CANCEL_INVITATION,     // 取消立即私密邀请失败 状态不是带确认 /*important*/
    HTTP_LCC_ERR_NOT_FIND_ANCHOR,             // 主播机构信息找不到
    HTTP_LCC_ERR_NOTCAN_REFUND,             // 立即私密退点失败，已经定时扣费不能退点
    HTTP_LCC_ERR_NOT_FIND_PRICE_INFO,         // 找不到price_setting表信息
    
    HTTP_LCC_ERR_ANCHOR_BUSY,                  // 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
    HTTP_LCC_ERR_CHOOSE_TIME_ERR,             // 预约时间错误 /*important*/
    HTTP_LCC_ERR_BOOK_EXIST,                 // 用户预约时间段已经存在预约 /*important*/
    HTTP_LCC_ERR_BIND_PHONE,                 // 手机号码已绑定
    HTTP_LCC_ERR_RETRY_PHONE,                 // 请稍后再重试
    
    HTTP_LCC_ERR_MORE_TWENTY_PHONE,         // 60分钟内验证超过20次，请24小时后再试
    HTTP_LCC_ERR_UPDATE_PHONE_FAIL,         // 更新失败
    HTTP_LCC_ERR_ANCHOR_OFFLIVE,            // 主播不在线，不能操作
    HTTP_LCC_ERR_VIEWER_AGREEED_BOOKING,     // 观众已同意预约
    HTTP_LCC_ERR_OUTTIME_REJECT_BOOKING,     // 预约邀请已超时（当观众拒绝时）
    
    HTTP_LCC_ERR_OUTTIME_AGREE_BOOKING,       // 预约邀请已超时（当观众同意时）
    
    /* 独立的错误码*/
    HTTP_LCC_ERR_FACEBOOK_NO_MAILBOX,     // Facebook没有邮箱（需要提交邮箱）
    HTTP_LCC_ERR_FACEBOOK_EXIST_QN_MAILBOX, // Facebook邮箱已在QN注册（需要换邮箱）
    HTTP_LCC_ERR_FACEBOOK_EXIST_LS_MAILBOX,  // Facebook邮箱已在直播独立站注册（需要输入密码）
    HTTP_LCC_ERR_FACEBOOK_TOKEN_INVALID,     // Facebook token无效登录失败
    HTTP_LCC_ERR_FACEBOOK_PARAMETER_FAIL,    // 参数错误
    
    HTTP_LCC_ERR_FACEBOOK_ALREADY_REGISTER,  // Facebook帐号已在QN注册（提示错误）
    HTTP_LCC_ERR_MAILREGISTER_EXIST_QN_MAILBOX,          // 邮箱已在QN注册
    HTTP_LCC_ERR_MAILREGISTER_EXIST_LS_MAILBOX,          // 邮箱已在直播独立站注册
    HTTP_LCC_ERR_MAILREGISTER_LESS_THAN_EIGHTEEN,        // 年龄小于18岁
    HTTP_LCC_ERR_MAILREGISTER_PARAMETER_FAIL,            // 参数错误
    
    HTTP_LCC_ERR_MAILLOGIN_PASSWORD_INCORRECT,           // 密码不正确
    HTTP_LCC_ERR_MAILLOGIN_NOREGISTER_MAIL,              // 邮箱未注册
    HTTP_LCC_ERR_FINDPASSWORD_NOREGISTER_MAIL,           // 邮箱未注册
    HTTP_LCC_ERR_FINDPASSWORD_VERIFICATION_WRONG,        // 验证码错误
    
    HTTP_LCC_ERR_PLOGIN_PASSWORD_INCORRECT,      // 帐号或密码不正确
    HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION,      // 需要验证码 和 MBCE21002: Please enter the verification code.
    HTTP_LCC_ERR_PLOGIN_VERIFICATION_WRONG,      // 验证码不正确 和 MBCE21003:The verification code is wrong
    HTTP_LCC_ERR_TLOGIN_SID_NULL,                // sid无效
    HTTP_LCC_ERR_TLOGIN_SID_OUTTIME,             // sid超时
    
    HTTP_LCC_ERR_DEMAIN_NO_FIND_MAIL,            // MBCE21001：(没有找到匹配的邮箱。)
    HTTP_LCC_ERR_DEMAIN_CURRENT_PASSWORD_WRONG,  // MBCE13001：Sorry, the current password you entered is wrong!
    HTTP_LCC_ERR_DEMAIN_ALL_FIELDS_WRONG,       // MBCE13002：Please check if all fields are filled and correct!
    HTTP_LCC_ERR_DEMAIN_THE_OPERATION_FAILED,       // MBCE13003：The operation failed  /mobile/changepwd.ph
    HTTP_LCC_ERR_DEMAIN_PASSWORD_FORMAT_WRONG,      // MBCE13004：Password format error
    
    HTTP_LCC_ERR_DEMAIN_NO_FIND_USERID,         // MBCE11001：(QpidNetWork男士会员ID未找到) /mobile/myprofile.php
    HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_ERR,        // MBCE12001：Data update error. ( 数据更新失败)  /mobile/updatepro.php
    HTTP_LCC_ERR_DEMAIN_DATA_NO_EXIST_KEY,            // MBCE12002:( 更新失败：Key不存在。)  /mobile/updatepro.php
    HTTP_LCC_ERR_DEMAIN_DATA_UNCHANGE_VALUE,            // MBCE12003：( 更新失败：Value值没有改变。)
    HTTP_LCC_ERR_DEMAIN_DATA_UNPASS_VALUE,            // MBCE12004：( 更新失败：Value值检测没通过。)
    
    HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFO_DESC_LOG,            // MBCE12005：update info_desc_log
    HTTP_LCC_ERR_DEMAIN_DATA_INSERT_INFO_DESC_LOG,            // MBCE12006：insert into info_desc_log
    HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFODESCLOG_SETGROUPID,   // MBCE12007：update info_desc_log set group_id
    HTTP_LCC_ERR_DEMAIN_APP_EXIST_LOGS,                       // MBCE22001：(APP安装记录已存在。912008)
    HTTP_LCC_ERR_PRIVTE_INVITE_AUTHORITY,                   // 主播无立即私密邀请权限(17002)
    
    /* 信件*/
    HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_HASCREDIT,          // 购买图片使用邮票支付时，邮票不足，但信用点可用(17213)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_NOCREDIT,          // 购买图片使用邮票支付时，邮票不足，且信用点不足(17214)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOCREDIT_HASSTAMP,          // 购买图片使用信用点支付时，信用点不足，但邮票可用(17215)(调用13.7.购买信件附件接口)
    
    HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOSTAMP_NOCREDIT,          // 购买图片使用信用点支付时，信用点不足，且邮票不足(17216)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_PHOTO_OVERTIME,                     // 照片已过期(17217)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_HASCREDIT,          // 购买视频使用邮票支付时，邮票不足，但信用点可用(17218)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_NOCREDIT,          // 购买视频使用邮票支付时，邮票不足，且信用点不足(17219)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOCREDIT_HASSTAMP,          // 购买视频使用信用点支付时，信用点不足，但邮票可用(17220)(调用13.7.购买信件附件接口)
    
    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOSTAMP_NOCREDIT,          // 购买视频使用信用点支付时，信用点不足，且邮票不足(17221)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_VIDEO_OVERTIME,                                // 视频已过期(17222)(调用13.7.购买信件附件接口)
    HTTP_LCC_ERR_LETTER_NO_CREDIT_OR_NO_STAMP,                         // 信用点或者邮票不足(17208):(调用13.4.信件详情接口, 调用13.5.发送信件接口)
    HTTP_LCC_ERR_EXIST_HANGOUT,                                // 当前会员已在hangout直播间（调用8.11.获取当前会员Hangout直播状态接口）
    
    /* SayHi */
    HTTP_LCC_ERR_SAYHI_MAN_NO_PRIV,                     // 男士无权限(17401)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_LADY_NO_PRIV,                    // 女士无权限(174012)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_ANCHOR_ALREADY_SEND_LOI,         // 主播发过意向信（返回值补充"errdata":{"id":"意向信ID"}）(17403)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_MAN_ALREADY_SEND_SAYHI,          // 男士发过SayHi（返回值补充"errdata":{"id":"sayHi ID"}）(17404)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_ALREADY_CONTACT,                 // 男士主播已建立联系(17405)(调用14.4.发送SayHi接口)
    
    HTTP_LCC_ERR_SAYHI_MAN_LIMIT_NUM_DAY,               // 男士每日数量限制(17406)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_REPLY,    // 男士总数量限制-有主播回复(17407)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_UNREPLY,  // 男士总数量限制-无主播回复(17408)(调用14.4.发送SayHi接口)
    HTTP_LCC_ERR_SAYHI_NO_EXIST,                        // sayHi不存在（17409）（调用14.8.获取SayHi回复详情）
    HTTP_LCC_ERR_SAYHI_RESPONSE_NO_EXIST,               // sayHi回复不存在（17410）（调用14.8.获取SayHi回复详情）
    
    HTTP_LCC_ERR_SAYHI_READ_NO_CREDIT,                  // sayHi购买阅读信用点或邮票不足（17411）（调用14.8.获取SayHi回复详情）
    HTTP_LCC_ERR_INVITATION_IS_INVLID,                  // 主播发送私密邀请ID无效（10057）（调用4.7.观众处理立即私密邀请）
    HTTP_LCC_ERR_INVITATION_HAS_EXPIRED,                // 主播发送私密邀请过期（10058）（调用4.7.观众处理立即私密邀请）
    HTTP_LCC_ERR_INVITATION_HAS_CANCELED,               // 主播发送私密邀请被取消了（10070）（调用4.7.观众处理立即私密邀请）
    HTTP_LCC_ERR_SHOW_HAS_ENDED,                        // 节目已经结束了（13017）（调用9.5.获取可进入的节目信息）
    
    HTTP_LCC_ERR_SHOW_HAS_CANCELLED,                    // 节目已经取消了（13024）（调用9.5.获取可进入的节目信息）
    HTTP_LCC_ERR_ANCHOR_NOCOME_SHOW_HAS_CLOSE,          // 主播没有来关闭节目（13010）（调用9.5.获取可进入的节目信息）
    HTTP_LCC_ERR_NO_BUY_SHOW_HAS_CANCELLED,             // 对于没买票用户节目取消了（13023）（调用9.5.获取可进入的节目信息）
    HTTP_LCC_ERR_HANGOUT_EXIST_COUNTDOWN_PRIVITEROOM,   // 多人视频流程 主播存在开始倒数私密直播间（Sorry, the broadcaster is busy at the moment. Please try again later.(10114)）
    HTTP_LCC_ERR_HANGOUT_EXIST_COUNTDOWN_HANGOUTROOM,   // 多人视频流程 主播存在开始倒数多人视频直播间（Sorry, the broadcaster is busy at the moment. Please try again later.(10115)）
    
    HTTP_LCC_ERR_HANGOUT_EXIST_FOUR_MIN_SHOW,           // 多人视频流程 主播存在4分钟内开始的预约（Sorry, the broadcaster is busy at the moment. Please try again later.(10116)）
    HTTP_LCC_ERR_KNOCK_EXIST_ROOM,                      // 男士同意敲门请求，主播存在在线的直播间（Sorry, the broadcaster is busy at the moment. Please try again later.(10136)）
    HTTP_LCC_ERR_INVITE_FAIL_SHOWING,                   // 发送立即邀请失败 主播正在节目中（Sorry, the broadcaster is busy at the moment. Please try again later.(13020)）
    HTTP_LCC_ERR_INVITE_FAIL_BUSY,                      // 发送立即邀请 用户收到主播繁忙通知（Sorry, the broadcaster is busy at the moment. Please try again later.(13021)）
    HTTP_LCC_ERR_SEND_RECOMMEND_HAS_SHOWING,            // 主播发送推荐好友请求：好友4分钟后有节目开播（Sorry, the broadcaster is busy at the moment. Please try again later.(16318)）
    
    HTTP_LCC_ERR_SEND_RECOMMEND_EXIT_HANGOUTROOM,       // 主播发送推荐好友请求：好友跟其他男士hangout中（Sorry, the broadcaster is busy at the moment. Please try again later.(16320)）
    /*鲜花礼品*/
    HTTP_LCC_ERR_MAN_NO_FLOWERGIFT_PRIV,                // 男士无鲜花礼品权限（21111）Sorry, we can not process your request at the moment. Please try again later.（用于15.8.添加购物车商品 15.9.修改购物车商品数量 15.12.生成订单） 15.9.修改购物车商品数量 15.12.生成订单）
    HTTP_LCC_ERR_EMPTY_CART,                            // 购物车为空（22112）Empty cart.（ 用于15.11.Checkout商品 15.12.生成订单）
    HTTP_LCC_ERR_FULL_CART,                             // 当前购物车内准备赠送给该主播的礼品种类已满（达到10），不可再添加（弹层引导如下，与上述不同，该处按钮为Later/Checkout） （22113）Your cart is full. Please proceed to checkout before adding more!（用于15.8.添加购物车商品 15.9.修改购物车商品数量）
    HTTP_LCC_ERR_NO_EXIST_CART,                         // 购物车商品不存在（22114）'Sorry, this item does not exist. Please remove it or try again later.（用于15.8.添加购物车商品 15.9.修改购物车商品数量）
    
    HTTP_LCC_ERR_NO_SUPPOSE_DELIVERY,                   // 主播国家不配送（22115）Sorry, this item is out of stock in the broadcaster's country.（用于15.8.添加购物车商品 15.9.修改购物车商品数量）
    HTTP_LCC_ERR_NO_AVAILABLE_CART,                     // 购物车的商品不可用（22116）'Sorry, some of the items you chose have been removed from the list. Please choose other items.'（用于15.8.添加购物车商品 15.9.修改购物车商品数量 15.11.Checkout商品 15.12.生成订单）
    HTTP_LCC_ERR_ONLY_GREETING_CARD,                    // 添加屬於賀卡的礼品，但當前主播購物車內無其他非賀卡礼品（22117）Please add a gift item to the cart before adding a greeting card!（用于15.8.添加购物车商品 15.9.修改购物车商品数量 15.12.生成订单）
    HTTP_LCC_ERR_FLOWERGIFT_ANCHORID_INVALID,           // 主播不存在（22118）'ID invalid'（用于15.8.添加购物车商品 15.9.修改购物车商品数量
    HTTP_LCC_ERR_NO_RECEPTION_FLOWERGIFT,               // 主播无接收礼物权限（22119）Sorry, this broadcaster does not wish to receive gifts, or gift delivery service does not cover this broadcaster's area.（用于15.8.添加购物车商品 15.9.修改购物车商品数量）
    
    HTTP_LCC_ERR_GREETINGMESSAGE_TOO_LONG,              // 订单备注太长（22120）Sorry, the greeting message can not exceed 250 characters.'（15.12.生成订单）
    HTTP_LCC_ERR_ITEM_TOO_MUCH,                         // 当前购物车内准备赠送给该主播的该礼品数量已满（达到99），不可再添加（22121）ou can only add 1-99 items.（用于15.8.添加购物车商品 15.9.修改购物车商品数量 15.12.生成订单）
    /*预付费直播*/
    HTTP_LCC_ERR_SCHEDULE_ANCHOR_NO_PRIV,          // 发送预付费直播:主播无权限（17501）（用于17.3.发送预付费直播邀请）
    HTTP_LCC_ERR_SCHEDULE_NOTENOUGH_OR_OVER_TIEM,          // 发送预付费直播:开始时间离现在不足24小时或超过14天（17502）（用于17.3.发送预付费直播邀请）
    HTTP_LCC_ERR_SCHEDULE_NO_CREDIT,          // 发送预付费直播:男士信用点不足（17302）（用于17.3.发送预付费直播邀请 用于17.4.接受预付费直播邀请
    
    HTTP_LCC_ERR_SCHEDULE_ACCEPTED_LESS_OR_EXPIRED,          // 接受预付费直播:开始时间离现在不足6小时或已过期（17503）（用于17.4.接受预付费直播邀请）
    HTTP_LCC_ERR_SCHEDULE_HAS_ACCEPTED,          // 接受预付费直播:该邀请已接受（17505）（用于17.4.接受预付费直播邀请）
    HTTP_LCC_ERR_SCHEDULE_HAS_DECLINED,          // 接受预付费直播:该邀请已拒绝（17506）（用于17.4.接受预付费直播邀请）
    HTTP_LCC_ERR_SCHEDULE_CANCEL_LESS_OR_EXPIRED,          // // 没有阅读前不能接受或拒绝（This request was sent by mail.Please read this mail before accept or decline this request）（17507）（用于17.4.接受预付费直播邀请 用于17.5.拒绝预付费直播邀请
    HTTP_LCC_ERR_SCHEDULE_NO_READ_BEFORE,                // 没有阅读前不能接受或拒绝（This request was sent by mail.Please read this mail before accept or decline this request）（17507）（用于17.4.接受预付费直播邀请 用于17.5.拒绝预付费直播邀请）
    
    /* 付费视频 */
    HTTP_LCC_ERR_PREMIUMVIDEO_MAN_NO_PRIV,          // 男士无权限（Sorry, we can not process your request at the moment. Please try again later.）（17600）（用于18.4.发送解码锁请求 用于18.5.发送解码锁请求提醒 用于18.14.视频解锁）
    HTTP_LCC_ERR_PREMIUMVIDEO_VIDEO_DELETE_OR_EXIST,          // 视频删除或不存在（The video you are looking for is already deleted or suspended due to certain reasons）（17601）（用于18.4.发送解码锁请求 用于18.5.发送解码锁请求提醒 用于18.10.添加感兴趣的视频 用于18.13.获取视频详情 用于18.14.视频解锁）
    HTTP_LCC_ERR_PREMIUMVIDEO_LIMIT_NUM_DAY,               // 每天发送数量限制（Can not send the request because you have already reached the daily quota）(17611)(用于18.4.发送解码锁请求)
    HTTP_LCC_ERR_PREMIUMVIDEO_REQUEST_ALREADY_SEND,               // 已发送过-客户端当发送成功处理 (17612)(用于18.4.发送解码锁请求)
    HTTP_LCC_ERR_PREMIUMVIDEO_REQUEST_ALREADY_REPLY,               // 请求已回复 （This request has been granted. Please view your Access Key Granted list and get the access key by reading the mail）(17613)(用于18.4.发送解码锁请求 用于18.5.发送解码锁请求提醒)
    
    HTTP_LCC_ERR_PREMIUMVIDEO_REQUEST_OUTTIME,               // 请求已过期 （This request has expired. Please try to resend a new request to the broadcaster.）(17614)(用于18.5.发送解码锁请求提醒)
    HTTP_LCC_ERR_PREMIUMVIDEO_REQUEST_LESS_ONEDAY_SEND,               // 24小时内已发送过-客户端当发送成功处理 (17615)(用于18.5.发送解码锁请求提醒)
    HTTP_LCC_ERR_PREMIUMVIDEO_ACCESSKEY_INVLID,               // 解锁码无效 （Oops, the access key you entered is incorrect or has expired. Please confirm .）(17621)(用于18.14.视频解锁)
    
    /* IOS本地 */
    HTTP_LCC_ERR_FORCED_TO_UPDATE,                       // 强制更新，这里时本地返回的，仅用于ios
    HTTP_LCC_ERR_LOGIN_BY_OTHER_DEVICE,                 // 其他设备登录，这里时本地返回的，仅用于ios
    HTTP_LCC_ERR_SESSION_REQUEST_WITHOUT_LOGIN,         // 其他设备登录，这里时本地返回的，仅用于ios
};

static LSRequestManager *gManager = nil;
@interface LSRequestManager () {
    HttpRequestManager mHttpRequestManager;
    HttpRequestManager mConfigHttpRequestManager;
    HttpRequestManager mNewHttpRequestManager;
    HttpRequestController mHttpRequestController;
}

@property (nonatomic, strong) NSMutableDictionary *delegateDictionary;

@end

@implementation LSRequestManager

#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if (self = [super init]) {
        self.delegateDictionary = [NSMutableDictionary dictionary];
        self.versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Version"];
        
        mHttpRequestManager.SetVersionCode(COMMON_VERSION_CODE, [self.versionCode UTF8String]);
        mConfigHttpRequestManager.SetVersionCode(COMMON_VERSION_CODE, [self.versionCode UTF8String]);
        mNewHttpRequestManager.SetVersionCode(COMMON_VERSION_CODE, [self.versionCode UTF8String]);
        
        NSString *appId = [[NSBundle mainBundle] bundleIdentifier];
        if (appId != nil) {
            mHttpRequestManager.SetAppId([appId UTF8String]);
            mConfigHttpRequestManager.SetAppId([appId UTF8String]);
            mNewHttpRequestManager.SetAppId([appId UTF8String]);
        }

        
    }
    return self;
}

#pragma mark - 公共模块
+ (void)setLogEnable:(BOOL)enable {
    KLog::SetLogEnable(enable);
    KLog::SetLogFileEnable(YES);
    KLog::SetLogLevel(KLog::LOG_WARNING);
}

+ (void)setLogDirectory:(NSString *)directory {
    KLog::SetLogDirectory(directory?[directory UTF8String]:"");
    HttpClient::SetCookiesDirectory(directory?[directory UTF8String]:"");
    //    CleanDir([directory UTF8String]);
}

+ (void)setProxy:(NSString * _Nullable)proxyUrl {
    HttpClient::SetProxy(proxyUrl?[proxyUrl UTF8String]:"");
}

- (void)setConfigWebSite:(NSString * _Nonnull)webSite {
    mConfigHttpRequestManager.SetWebSite(webSite ? [webSite UTF8String] : "");
}

- (void)setWebSite:(NSString *_Nonnull)webSite {
    mHttpRequestManager.SetWebSite(webSite ? [webSite UTF8String] : "");
}

- (void)setDomainWebSite:(NSString *_Nonnull)webSite {
    mNewHttpRequestManager.SetWebSite(webSite ? [webSite UTF8String] : "");
}

- (void)setAuthorization:(NSString *)user password:(NSString *)password {
    mHttpRequestManager.SetAuthorization((user ? [user UTF8String] : ""), (password ? [password UTF8String] : ""));
    mConfigHttpRequestManager.SetAuthorization((user ? [user UTF8String] : ""), (password ? [password UTF8String] : "" ));
    mNewHttpRequestManager.SetAuthorization((user ? [user UTF8String] : ""), (password ? [password UTF8String] : "" ));
}

- (void)cleanCookies {
    HttpClient::CleanCookies();
}

- (NSArray<NSHTTPCookie *> *)getCookies {
    NSMutableArray *cookies = [NSMutableArray array];
    
    list<CookiesItem> cookiesList = HttpClient::GetCookiesItem();
    for(list<CookiesItem>::const_iterator itr = cookiesList.begin(); itr != cookiesList.end(); itr++) {
        NSMutableDictionary<NSHTTPCookiePropertyKey, id> *properties = [NSMutableDictionary dictionary];
        
        CookiesItem item = *itr;
        [properties setObject:[NSString stringWithUTF8String:item.m_domain.c_str()] forKey:NSHTTPCookieDomain];
        [properties setObject:[NSString stringWithUTF8String:item.m_symbol.c_str()] forKey:NSHTTPCookiePath];
        [properties setObject:[NSString stringWithUTF8String:item.m_cName.c_str()] forKey:NSHTTPCookieName];
        [properties setObject:[NSString stringWithUTF8String:item.m_value.c_str()] forKey:NSHTTPCookieValue];
        
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
        [cookies addObject:cookie];
    }
    
    return cookies;
}

- (void)stopRequest:(NSInteger)request {
    mHttpRequestController.Stop(request);
}

- (void)stopAllRequest {
    mHttpRequestManager.StopAllRequest();
    mConfigHttpRequestManager.StopAllRequest();
    mNewHttpRequestManager.StopAllRequest();
}

- (NSString *)getDeviceId {
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

- (HTTP_OTHER_SITE_TYPE)getHttpSiteTypeByServerSiteId:(NSString * _Nonnull)siteId  {
    
    string strSiteId = "";
    if (nil != siteId) {
        strSiteId = [siteId UTF8String];
    }
    return GetHttpSiteTypeByServerSiteId(strSiteId);
}

- (HTTP_LCC_ERR_TYPE)getStringToHttpErrorType:(NSString * _Nonnull)errnum {
    string strErrnum = "";
    if (nil != errnum) {
        strErrnum = [errnum UTF8String];
    }
    return GetStringToHttpErrorType(strErrnum);
}

- (NSInteger)invalidRequestId {
    return LS_HTTPREQUEST_INVALIDREQUESTID;
}

//oc层转底层枚举
-(HTTP_LCC_ERR_TYPE)intToHttpLccErrType:(int)errType {
    // 默认是HTTP_LCC_ERR_FAIL，当服务器返回未知的错误码时
    HTTP_LCC_ERR_TYPE value = HTTP_LCC_ERR_FAIL;
    int i = 0;
    for (i = 0; i < _countof(HTTPErrorTypeArray); i++)
    {
        if (errType == HTTPErrorTypeArray[i]) {
            value = (HTTP_LCC_ERR_TYPE)HTTPErrorTypeArray[i];
            break;
        }
    }
    return value;
}


#pragma mark - 登陆认证模块

class RequestLoginCallbackImp : public IRequestLoginCallback {
public:
    RequestLoginCallbackImp(){};
    ~RequestLoginCallbackImp(){};
    void OnLogin(HttpLoginTask *task, bool success, int errnum, const string &errmsg, const HttpLoginItem &item) {
        NSLog(@"LSRequestManager::onLogin( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LoginFinishHandler handler = nil;
        LSLoginItemObject *obj = [[LSLoginItemObject alloc] init];
        obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
        obj.token = [NSString stringWithUTF8String:item.token.c_str()];
        obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        obj.level = item.level;
        obj.experience = item.experience;
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        obj.isPushAd = item.isPushAd;
        NSMutableArray *array = [NSMutableArray array];
        for (HttpLoginItem::SvrList::const_iterator iter = item.svrList.begin(); iter != item.svrList.end(); iter++) {
            LSSvrItemObject *svrItem = [[LSSvrItemObject alloc] init];
            svrItem.svrId = [NSString stringWithUTF8String:(*iter).svrId.c_str()];
            svrItem.tUrl = [NSString stringWithUTF8String:(*iter).tUrl.c_str()];
            [array addObject:svrItem];
        }
        obj.svrList = array;
        obj.userType = item.userType;
//        obj.qnMainAdUrl = [NSString stringWithUTF8String:item.qnMainAdUrl.c_str()];
//        obj.qnMainAdTitle = [NSString stringWithUTF8String:item.qnMainAdTitle.c_str()];
//        obj.qnMainAdId = [NSString stringWithUTF8String:item.qnMainAdId.c_str()];
        obj.gaUid = [NSString stringWithUTF8String:item.gaUid.c_str()];
        
        obj.sessionId = [NSString stringWithUTF8String:item.sessionId.c_str()];
        obj.isLiveChatRisk = item.isLiveChatRisk;
//        obj.isHangoutRisk = item.isHangoutRisk;
//        obj.liveChatInviteRiskType = item.liveChatInviteRiskType;
        
        LSUserPrivItemObject* userPriv = [[LSUserPrivItemObject alloc] init];
        LSLiveChatPrivItemObject* liveChatPriv = [[LSLiveChatPrivItemObject alloc] init];
        liveChatPriv.isLiveChatPriv = item.userPriv.liveChatPriv.isLiveChatPriv;
        liveChatPriv.liveChatInviteRiskType = item.userPriv.liveChatPriv.liveChatInviteRiskType;
        liveChatPriv.isSendLiveChatPhotoPriv = item.userPriv.liveChatPriv.isSendLiveChatPhotoPriv;
        liveChatPriv.isSendLiveChatVoicePriv = item.userPriv.liveChatPriv.isSendLiveChatVoicePriv;
        userPriv.liveChatPriv = liveChatPriv;
        LSMailPrivItemObject* mailPriv = [[LSMailPrivItemObject alloc] init];
        mailPriv.userSendMailPriv = item.userPriv.mailPriv.userSendMailPriv;
        LSUserSendMailPrivItemObject * userSendMailImgPriv = [[LSUserSendMailPrivItemObject alloc] init];
        userSendMailImgPriv.mailSendPriv = item.userPriv.mailPriv.userSendMailImgPriv.isPriv;
        userSendMailImgPriv.maxImg = item.userPriv.mailPriv.userSendMailImgPriv.maxImg;
        userSendMailImgPriv.postStampMsg =  [NSString stringWithUTF8String:item.userPriv.mailPriv.userSendMailImgPriv.postStampMsg.c_str()];
        userSendMailImgPriv.coinMsg =  [NSString stringWithUTF8String:item.userPriv.mailPriv.userSendMailImgPriv.coinMsg.c_str()];
        userSendMailImgPriv.quickPostStampMsg =  [NSString stringWithUTF8String:item.userPriv.mailPriv.userSendMailImgPriv.quickPostStampMsg.c_str()];
        userSendMailImgPriv.quickCoinMsg =  [NSString stringWithUTF8String:item.userPriv.mailPriv.userSendMailImgPriv.quickCoinMsg.c_str()];
        mailPriv.userSendMailImgPriv = userSendMailImgPriv;
        userPriv.mailPriv = mailPriv;
        LSHangoutPrivItemObject* hangoutPriv = [[LSHangoutPrivItemObject alloc] init];
        hangoutPriv.isHangoutPriv = item.userPriv.hangoutPriv.isHangoutPriv;
        userPriv.hangoutPriv = hangoutPriv;
        userPriv.isSayHiPriv = item.userPriv.isSayHiPriv;
        userPriv.isGiftFlowerPriv = item.userPriv.isGiftFlowerPriv;
        userPriv.isPublicRoomPriv = item.userPriv.isPublicRoomPriv;
        
        obj.userPriv = userPriv;
//        LSMailPrivItemObject * mailPriv = [[LSMailPrivItemObject alloc] init];
//        mailPriv.userSendMailPriv = item.mailPriv.userSendMailPriv;
//        LSUserSendMailPrivItemObject * userSendMailImgPriv = [[LSUserSendMailPrivItemObject alloc] init];
//        userSendMailImgPriv.mailSendPriv = item.mailPriv.userSendMailImgPriv.isPriv;
//        userSendMailImgPriv.maxImg = item.mailPriv.userSendMailImgPriv.maxImg;
//        userSendMailImgPriv.postStampMsg =  [NSString stringWithUTF8String:item.mailPriv.userSendMailImgPriv.postStampMsg.c_str()];
//        userSendMailImgPriv.coinMsg =  [NSString stringWithUTF8String:item.mailPriv.userSendMailImgPriv.coinMsg.c_str()];
//        userSendMailImgPriv.quickPostStampMsg =  [NSString stringWithUTF8String:item.mailPriv.userSendMailImgPriv.quickPostStampMsg.c_str()];
//        userSendMailImgPriv.quickCoinMsg =  [NSString stringWithUTF8String:item.mailPriv.userSendMailImgPriv.quickCoinMsg.c_str()];
//        mailPriv.userSendMailImgPriv = userSendMailImgPriv;
//        obj.mailPriv = mailPriv;
      obj.isGiftFlowerSwitch = item.isGiftFlowerSwitch;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestLoginCallbackImp gRequestLoginCallbackImp;

- (NSInteger)login:(NSString *_Nonnull)manId
           userSid:(NSString *_Nonnull)userSid
          deviceid:(NSString *_Nonnull)deviceid
             model:(NSString *_Nonnull)model
      manufacturer:(NSString *_Nonnull)manufacturer
     finishHandler:(LoginFinishHandler _Nullable)finishHandler {
    
    string strManId = "";
    if (nil != manId) {
        strManId = [manId UTF8String];
    }
    
    string strUserSid = "";
    if (nil != userSid) {
        strUserSid = [userSid UTF8String];
    }
    
    string strDeviceid = "";
    if (nil != deviceid) {
        strDeviceid = [deviceid UTF8String];
    }
    
    string strModel = "";
    if (nil != model) {
        strModel = [model UTF8String];
    }
    
    string strManufacturer = "";
    if (nil != manufacturer) {
        strManufacturer = [manufacturer UTF8String];
    }
    
    NSInteger request = (NSInteger)mHttpRequestController.Login(&mHttpRequestManager, strManId, strUserSid, strDeviceid, strModel, strManufacturer, LSLOGINSIDTYPE_LSLOGIN, &gRequestLoginCallbackImp);
    
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestLogoutCallbackImp : public IRequestLogoutCallback {
public:
    RequestLogoutCallbackImp(){};
    ~RequestLogoutCallbackImp(){};
    
    void OnLogout(HttpLogoutTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::onLogout( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LogoutFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestLogoutCallbackImp gRequestLogoutCallbackImp;

- (NSInteger)logout:(LogoutFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.Logout(&mHttpRequestManager, &gRequestLogoutCallbackImp);
    
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestUpdateTokenIdCallbackImp : public IRequestUpdateTokenIdCallback {
public:
    RequestUpdateTokenIdCallbackImp(){};
    ~RequestUpdateTokenIdCallbackImp(){};
    
    void OnUpdateTokenId(HttpUpdateTokenIdTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::onLogout( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        UpdateTokenIdFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestUpdateTokenIdCallbackImp gRequestUpdateTokenIdCallbackImp;

- (NSInteger)updateTokenId:(NSString *_Nonnull)tokenId
             finishHandler:(UpdateTokenIdFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.UpdateTokenId(&mHttpRequestManager, (tokenId ? [tokenId UTF8String] : ""), &gRequestUpdateTokenIdCallbackImp);
    
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetValidsiteIdCallbackImp : public IRequestGetValidsiteIdCallback {
public:
    RequestGetValidsiteIdCallbackImp(){};
    ~RequestGetValidsiteIdCallbackImp(){};
    
    void OnGetValidsiteId(HttpGetValidsiteIdTask* task, bool success, const string& errnum, const string& errmsg, const HttpValidSiteIdList& SiteIdList) {
        NSLog(@"LSRequestManager::OnGetValidsiteId( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HttpValidSiteIdList::const_iterator iter = SiteIdList.begin(); iter != SiteIdList.end(); iter++) {
            LSValidSiteIdItemObject *item = [[LSValidSiteIdItemObject alloc] init];
            item.siteId = (*iter).siteId;
            item.isLive = (*iter).isLive;
            [array addObject:item];
            //            NSLog(@"LSRequestManager::OnGetAnchorList( task : %p, userId : %@, nickName : %@, onlineStatus : %d, roomType : %d )", task, item.userId, item.nickName, item.onlineStatus, item.roomType);
        }
        
        GetValidsiteIdFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetValidsiteIdCallbackImp gRequestGetValidsiteIdCallbackImp;

- (NSInteger)getValidSiteId:(NSString * _Nonnull)email
                   password:(NSString * _Nonnull)password
              finishHandler:(GetValidsiteIdFinishHandler _Nullable)finishHandler {
    string strEmail = "";
    if (nil != email) {
        strEmail = [email UTF8String];
    }
    string strPassword = "";
    if (nil != password) {
        strPassword = [password UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetValidsiteId(&mNewHttpRequestManager, strEmail, strPassword, &gRequestGetValidsiteIdCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAddTokenCallbackImp : public IRequestAddTokenCallback {
public:
    RequestAddTokenCallbackImp(){};
    ~RequestAddTokenCallbackImp(){};
    
    void OnAddToken(HttpAddTokenTask* task, bool success, const string& errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnAddToken( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        AddTokenFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestAddTokenCallbackImp gRequestAddTokenCallbackImp;

- (NSInteger)addToken:(NSString * _Nonnull)token
                appId:(NSString * _Nonnull)appId
             deviceId:(NSString * _Nonnull)deviceId
        finishHandler:(AddTokenFinishHandler _Nullable)finishHandler {
    string strToken = "";
    if (nil != token) {
        strToken = [token UTF8String];
    }
    string strAppId = "";
    if (nil != appId) {
        strAppId = [appId UTF8String];
    }
    string strDeviceId = "";
    if (nil != deviceId) {
        strDeviceId = [deviceId UTF8String];
    }
    
    NSInteger request = (NSInteger)mHttpRequestController.AddToken(&mNewHttpRequestManager, strToken, strAppId, strDeviceId, &gRequestAddTokenCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestDestroyTokenCallbackImp : public IRequestDestroyTokenCallback {
public:
    RequestDestroyTokenCallbackImp(){};
    ~RequestDestroyTokenCallbackImp(){};
    
    void OnDestroyToken(HttpDestroyTokenTask* task, bool success, const string& errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnDestroyToken( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        DestroyTokenFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestDestroyTokenCallbackImp gRequestDestroyTokenCallbackImp;

- (NSInteger)destroyToken:(DestroyTokenFinishHandler _Nullable)finishHandler {
    
    NSInteger request = (NSInteger)mHttpRequestController.DestroyToken(&mNewHttpRequestManager, &gRequestDestroyTokenCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    return request;
}

class RequestFindPasswordCallbackImp : public IRequestFindPasswordCallback {
public:
    RequestFindPasswordCallbackImp(){};
    ~RequestFindPasswordCallbackImp(){};
    
    void OnFindPassword(HttpFindPasswordTask* task, bool success, const string& errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnFindPassword( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        FindPasswordFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestFindPasswordCallbackImp gRequestFindPasswordCallbackImp;

- (NSInteger)findPassword:(NSString * _Nonnull)sendMail
                checkCode:(NSString * _Nonnull)checkCode
            finishHandler:(FindPasswordFinishHandler _Nullable)finishHandler {
    string strSendMail = "";
    if (nil != sendMail) {
        strSendMail = [sendMail UTF8String];
    }
    string strCheckCode = "";
    if (nil != checkCode) {
        strCheckCode = [checkCode UTF8String];
    }
    
    
    NSInteger request = (NSInteger)mHttpRequestController.FindPassword(&mHttpRequestManager, strSendMail, strCheckCode, &gRequestFindPasswordCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestChangePasswordCallbackImp : public IRequestChangePasswordCallback {
public:
    RequestChangePasswordCallbackImp(){};
    ~RequestChangePasswordCallbackImp(){};
    
    void OnChangePassword(HttpChangePasswordTask* task, bool success, const string& errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnChangePassword( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        ChangePasswordFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestChangePasswordCallbackImp gRequestChangePasswordCallbackImp;

- (NSInteger)changePassword:(NSString * _Nonnull)passwordNew
                passwordOld:(NSString * _Nonnull)passwordOld
              finishHandler:(ChangePasswordFinishHandler _Nullable)finishHandler {
    string strPasswordNew = "";
    if (nil != passwordNew) {
        strPasswordNew = [passwordNew UTF8String];
    }
    string strPasswordOld = "";
    if (nil != passwordOld) {
        strPasswordOld = [passwordOld UTF8String];
    }
    
    
    NSInteger request = (NSInteger)mHttpRequestController.ChangePassword(&mNewHttpRequestManager, strPasswordNew, strPasswordOld, &gRequestChangePasswordCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestDoLoginCallbackImp : public IRequestDoLoginCallback {
public:
    RequestDoLoginCallbackImp(){};
    ~RequestDoLoginCallbackImp(){};
    
    void OnDoLogin(HttpDoLoginTask* task, bool success, const string& errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnDoLogin( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        
        LoginWithTokenAuthFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestDoLoginCallbackImp gRequestDoLoginCallbackImp;

- (NSInteger)loginWithTokenAuth:(NSString *_Nonnull)token
                       memberId:(NSString *_Nonnull)memberId
                       deviceid:(NSString * _Nonnull)deviceid
                    versionCode:(NSString * _Nonnull)versionCode
                          model:(NSString * _Nonnull)model
                   manufacturer:(NSString * _Nonnull)manufacturer
                  finishHandler:(LoginWithTokenAuthFinishHandler _Nullable)finishHandler {
    string strToken = "";
    if (nil != token) {
        strToken = [token UTF8String];
    }
    string strMemberId = "";
    if (nil != memberId) {
        strMemberId = [memberId UTF8String];
    }
    string strDeviceid = "";
    if (nil != deviceid) {
        strDeviceid = [deviceid UTF8String];
    }
    string strVersionCode = "";
    if (nil != versionCode) {
        strVersionCode = [versionCode UTF8String];
    }
    string strModel = "";
    if (nil != model) {
        strModel = [model UTF8String];
    }
    string strManufacturer = "";
    if (nil != manufacturer) {
        strManufacturer = [manufacturer UTF8String];
    }
    
    NSInteger request = (NSInteger)mHttpRequestController.DoLogin(&mNewHttpRequestManager, strToken, strMemberId, strDeviceid, strVersionCode, strModel, strManufacturer, &gRequestDoLoginCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetTokenCallbackImp : public IRequestGetTokenCallback {
public:
    RequestGetTokenCallbackImp(){};
    ~RequestGetTokenCallbackImp(){};
    
    void OnGetToken(HttpGetTokenTask* task, bool success, int errnum, const string& errmsg, const string& memberId, const string& sid) {
        NSLog(@"LSRequestManager::OnGetToken( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        GetTokenFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:memberId.c_str()], [NSString stringWithUTF8String:sid.c_str()]);
        }
    }
};
RequestGetTokenCallbackImp gRequestGetTokenCallbackImp;

- (NSInteger)getToken:(HTTP_OTHER_SITE_TYPE)siteId
        finishHandler:(GetTokenFinishHandler _Nullable)finishHandler {
    
    string strUrl = "/app?siteid=";
    NSInteger request = (NSInteger)mHttpRequestController.GetToken(&mHttpRequestManager, strUrl, siteId, &gRequestGetTokenCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestPasswordLoginCallbackImp : public IRequestPasswordLoginCallback {
public:
    RequestPasswordLoginCallbackImp(){};
    ~RequestPasswordLoginCallbackImp(){};
    
    void OnPasswordLogin(HttpPasswordLoginTask* task, bool success, int errnum, const string& errmsg, const string& memberId, const string& sid) {
        NSLog(@"LSRequestManager::OnPasswordLogin( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        LoginWithPasswordFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:memberId.c_str()], [NSString stringWithUTF8String:sid.c_str()]);
        }
    }
};
RequestPasswordLoginCallbackImp gRequestPasswordLoginCallbackImp;

- (NSInteger)loginWithPassword:(NSString * _Nonnull)email
                      password:(NSString * _Nonnull)password
                      authCode:(NSString * _Nonnull)authCode
                 finishHandler:(LoginWithPasswordFinishHandler _Nullable)finishHandler {
    string strEmail = "";
    if (nil != email) {
        strEmail = [email UTF8String];
    }
    string strPassword = "";
    if (nil != password) {
        strPassword = [password UTF8String];
    }
    string strAuthCode = "";
    if (nil != authCode) {
        strAuthCode = [authCode UTF8String];
    }
    
    string deviceId = "";
    if ([self getDeviceId] != nil) {
        deviceId = [[self getDeviceId] UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.PasswordLogin(&mHttpRequestManager, strEmail, strPassword, strAuthCode, HTTP_OTHER_SITE_LIVE, "", "", deviceId,  &gRequestPasswordLoginCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestTokenLoginCallbackImp : public IRequestTokenLoginCallback {
public:
    RequestTokenLoginCallbackImp(){};
    ~RequestTokenLoginCallbackImp(){};
    
    void OnTokenLogin(HttpTokenLoginTask* task, bool success, int errnum, const string& errmsg, const string& memberId, const string& sid) {
        NSLog(@"LSRequestManager::OnTokenLogin( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        LoginWithTokenFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:memberId.c_str()], [NSString stringWithUTF8String:sid.c_str()]);
        }
    }
};
RequestTokenLoginCallbackImp gRequestTokenLoginCallbackImp;
- (NSInteger)loginWithToken:(NSString * _Nonnull)memberId
                 otherToken:(NSString * _Nonnull)otherToken
              finishHandler:(LoginWithTokenFinishHandler _Nullable)finishHandler {
    string strMemberId = "";
    if (nil != memberId) {
        strMemberId = [memberId UTF8String];
    }
    string strOtherToken = "";
    if (nil != otherToken) {
        strOtherToken = [otherToken UTF8String];
    }
    
    
    NSInteger request = (NSInteger)mHttpRequestController.TokenLogin(&mHttpRequestManager, strMemberId, strOtherToken, &gRequestTokenLoginCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetValidateCodeCallbackImp : public IRequestGetValidateCodeCallback {
public:
    RequestGetValidateCodeCallbackImp(){};
    ~RequestGetValidateCodeCallbackImp(){};
    
    void OnGetValidateCode(HttpGetValidateCodeTask* task, bool success, int errnum, const string& errmsg, const char* data, int len) {
        NSLog(@"LSRequestManager::OnGetValidateCode( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        GetValidateCodeFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], data, len);
        }
    }
};
RequestGetValidateCodeCallbackImp gRequestGetValidateCodeCallbackImp;
- (NSInteger)getValidateCode:(LSValidateCodeType)validateCodeType
               finishHandler:(GetValidateCodeFinishHandler _Nullable)finishHandler {
    
    NSInteger request = (NSInteger)mHttpRequestController.GetValidateCode(&mHttpRequestManager, validateCodeType, &gRequestGetValidateCodeCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestUploadUserPhotoCallbackImp : public IRequestUploadUserPhotoCallback {
public:
    RequestUploadUserPhotoCallbackImp(){};
    ~RequestUploadUserPhotoCallbackImp(){};
    
    void OnUploadUserPhoto(HttpUploadUserPhotoTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnUploadUserPhoto( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        UploadUserPhotoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestUploadUserPhotoCallbackImp gRequestUploadUserPhotoCallbackImp;

- (NSInteger)uploadUserPhoto:(NSString*)file
               finishHandler:(UploadUserPhotoFinishHandler)finishHandler {
    string strFile = "";
    if (nil != file) {
        strFile = [file UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.UploadUserPhoto(&mHttpRequestManager, strFile, &gRequestUploadUserPhotoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 直播间模块
class RequestGetAnchorListCallbackImp : public IRequestGetAnchorListCallback {
public:
    RequestGetAnchorListCallbackImp(){};
    ~RequestGetAnchorListCallbackImp(){};
    void OnGetAnchorList(HttpGetAnchorListTask *task, bool success, int errnum, const string &errmsg, const HotItemList &listItem) {
        NSLog(@"LSRequestManager::OnGetAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s, count : %lu )", task, success ? "true" : "false", errnum, errmsg.c_str(), listItem.size());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HotItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter)->userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter)->nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter)->photoUrl.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter)->roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter)->onlineStatus;
            item.roomType = (*iter)->roomType;
            NSMutableArray *nsInterest = [NSMutableArray array];
            //int i = 0;
            for (InterestList::const_iterator itr = (*iter)->interest.begin(); itr != (*iter)->interest.end(); itr++) {
                //NSString* strInterest = [NSString stringWithUTF8String:(*itr).c_str()];
                int num = (*itr);
                NSNumber *numInterest = [NSNumber numberWithInt:num];
                [nsInterest addObject:numInterest];
                //item->interest[i] = (*itr);
                //i++;
            }
            item.interest = nsInterest;
            item.anchorType = (*iter)->anchorType;
            
            if ((*iter)->showInfo != NULL) {
                LSProgramItemObject* programItem = [[LSProgramItemObject alloc] init];
                programItem.showLiveId = [NSString stringWithUTF8String:(*iter)->showInfo->showLiveId.c_str()];
                programItem.anchorId = [NSString stringWithUTF8String:(*iter)->showInfo->anchorId.c_str()];
                programItem.anchorNickName = [NSString stringWithUTF8String:(*iter)->showInfo->anchorNickName.c_str()];
                programItem.anchorAvatar = [NSString stringWithUTF8String:(*iter)->showInfo->anchorAvatar.c_str()];
                programItem.showTitle = [NSString stringWithUTF8String:(*iter)->showInfo->showTitle.c_str()];
                programItem.showIntroduce = [NSString stringWithUTF8String:(*iter)->showInfo->showIntroduce.c_str()];
                programItem.cover = [NSString stringWithUTF8String:(*iter)->showInfo->cover.c_str()];
                programItem.approveTime = (*iter)->showInfo->approveTime;
                programItem.startTime = (*iter)->showInfo->startTime;
                programItem.duration = (*iter)->showInfo->duration;
                programItem.leftSecToStart = (*iter)->showInfo->leftSecToStart;
                programItem.leftSecToEnter = (*iter)->showInfo->leftSecToEnter;
                programItem.price = (*iter)->showInfo->price;
                programItem.status = (*iter)->showInfo->status;
                programItem.ticketStatus = (*iter)->showInfo->ticketStatus;
                programItem.isHasFollow = (*iter)->showInfo->isHasFollow;
                programItem.isTicketFull = (*iter)->showInfo->isTicketFull;
                
                item.showInfo = programItem;
            }
            LSHttpAuthorityItemObject* priv = [[LSHttpAuthorityItemObject alloc] init];
            
            priv.isHasOneOnOneAuth = (*iter)->priv.privteLiveAuth;
            priv.isHasBookingAuth = (*iter)->priv.bookingPriLiveAuth;
            
            item.priv = priv;
            item.chatOnlineStatus = (*iter)->chatOnlineStatus;
            item.isFollow = (*iter)->isFollow;
            
            [array addObject:item];
            //            NSLog(@"LSRequestManager::OnGetAnchorList( task : %p, userId : %@, nickName : %@, onlineStatus : %d, roomType : %d )", task, item.userId, item.nickName, item.onlineStatus, item.roomType);
        }
        GetAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetAnchorListCallbackImp gRequestGetAnchorListCallbackImp;
- (NSInteger)getAnchorList:(int)start
                      step:(int)step
                  hasWatch:(BOOL)hasWatch
                 isForTest:(BOOL)isForTest
             finishHandler:(GetAnchorListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetAnchorList(&mHttpRequestManager, start, step, hasWatch, isForTest, &gRequestGetAnchorListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetFollowListCallbackImp : public IRequestGetFollowListCallback {
public:
    RequestGetFollowListCallbackImp(){};
    ~RequestGetFollowListCallbackImp(){};
    void OnGetFollowList(HttpGetFollowListTask *task, bool success, int errnum, const string &errmsg, const FollowItemList &listItem) {
        NSLog(@"LSRequestManager::OnGetFollowList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (FollowItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            FollowItemObject *item = [[FollowItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter)->userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter)->nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter)->photoUrl.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter)->roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter)->onlineStatus;
            item.roomType = (*iter)->roomType;
            item.loveLevel = (*iter)->loveLevel;
            item.addDate = (*iter)->addDate;
            NSMutableArray *nsInterest = [NSMutableArray array];
            for (FollowInterestList::const_iterator itr = (*iter)->interest.begin(); itr != (*iter)->interest.end(); itr++) {
                int num = (*itr);
                NSNumber *numInterest = [NSNumber numberWithInt:num];
                [nsInterest addObject:numInterest];
            }
            item.interest = nsInterest;
            item.anchorType = (*iter)->anchorType;
            if ((*iter)->showInfo != NULL) {
                LSProgramItemObject* programItem = [[LSProgramItemObject alloc] init];
                programItem.showLiveId = [NSString stringWithUTF8String:(*iter)->showInfo->showLiveId.c_str()];
                programItem.anchorId = [NSString stringWithUTF8String:(*iter)->showInfo->anchorId.c_str()];
                programItem.anchorNickName = [NSString stringWithUTF8String:(*iter)->showInfo->anchorNickName.c_str()];
                programItem.anchorAvatar = [NSString stringWithUTF8String:(*iter)->showInfo->anchorAvatar.c_str()];
                programItem.showTitle = [NSString stringWithUTF8String:(*iter)->showInfo->showTitle.c_str()];
                programItem.showIntroduce = [NSString stringWithUTF8String:(*iter)->showInfo->showIntroduce.c_str()];
                programItem.cover = [NSString stringWithUTF8String:(*iter)->showInfo->cover.c_str()];
                programItem.approveTime = (*iter)->showInfo->approveTime;
                programItem.startTime = (*iter)->showInfo->startTime;
                programItem.duration = (*iter)->showInfo->duration;
                programItem.leftSecToStart = (*iter)->showInfo->leftSecToStart;
                programItem.leftSecToEnter = (*iter)->showInfo->leftSecToEnter;
                programItem.price = (*iter)->showInfo->price;
                programItem.status = (*iter)->showInfo->status;
                programItem.ticketStatus = (*iter)->showInfo->ticketStatus;
                programItem.isHasFollow = (*iter)->showInfo->isHasFollow;
                programItem.isTicketFull = (*iter)->showInfo->isTicketFull;
                item.showInfo = programItem;
            }
            LSHttpAuthorityItemObject* priv = [[LSHttpAuthorityItemObject alloc] init];
            
            priv.isHasOneOnOneAuth = (*iter)->priv.privteLiveAuth;
            priv.isHasBookingAuth = (*iter)->priv.bookingPriLiveAuth;
            item.priv = priv;
            item.chatOnlineStatus = (*iter)->chatOnlineStatus;
            item.isFollow = (*iter)->isFollow;
            
            [array addObject:item];
            //            NSLog(@"LSRequestManager::OnGetFollowList( task : %p, userId : %@, nickName : %@, onlineStatus : %d, roomType : %d )", task, item.userId, item.nickName, item.onlineStatus, item.roomType);
        }
        GetFollowListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetFollowListCallbackImp gRequestGetFollowListCallbackImp;
- (NSInteger)getFollowList:(int)start
                      step:(int)step
             finishHandler:(GetFollowListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetFollowList(&mHttpRequestManager, start, step, &gRequestGetFollowListCallbackImp);
    
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetRoomInfoCallbackImp : public IRequestGetRoomInfoCallback {
public:
    RequestGetRoomInfoCallbackImp(){};
    ~RequestGetRoomInfoCallbackImp(){};
    void OnGetRoomInfo(HttpGetRoomInfoTask *task, bool success, int errnum, const string &errmsg, const HttpGetRoomInfoItem &Item) {
        NSLog(@"LSRequestManager::OnGetRoomInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        RoomInfoItemObject *Obj = [[RoomInfoItemObject alloc] init];
        NSMutableArray *array = [NSMutableArray array];
        for (HttpGetRoomInfoItem::RoomItemList::const_iterator iter = Item.roomList.begin(); iter != Item.roomList.end(); iter++) {
            RoomItemObject *item = [[RoomItemObject alloc] init];
            item.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
            item.roomUrl = [NSString stringWithUTF8String:(*iter).roomUrl.c_str()];
            [array addObject:item];
        }
        Obj.roomList = array;
        
        NSMutableArray *array1 = [NSMutableArray array];
        for (InviteItemList::const_iterator iter = Item.inviteList.begin(); iter != Item.inviteList.end(); iter++) {
            InviteIdItemObject *item = [[InviteIdItemObject alloc] init];
            item.invitationId = [NSString stringWithUTF8String:(*iter).invitationId.c_str()];
            item.oppositeId = [NSString stringWithUTF8String:(*iter).oppositeId.c_str()];
            item.oppositeNickName = [NSString stringWithUTF8String:(*iter).oppositeNickName.c_str()];
            item.oppositePhotoUrl = [NSString stringWithUTF8String:(*iter).oppositePhotoUrl.c_str()];
            item.oppositeLevel = (*iter).oppositeLevel;
            item.oppositeAge = (*iter).oppositeAge;
            item.oppositeCountry = [NSString stringWithUTF8String:(*iter).oppositeCountry.c_str()];
            item.read = (*iter).read;
            item.inviTime = (*iter).inviTime;
            item.replyType = (*iter).replyType;
            item.validTime = (*iter).validTime;
            item.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
            [array1 addObject:item];
        }
        Obj.inviteList = array1;
        
        GetRoomInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], Obj);
        }
    }
};
RequestGetRoomInfoCallbackImp gGetRoomInfoCallbackImp;
- (NSInteger)getRoomInfo:(GetRoomInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetRoomInfo(&mHttpRequestManager, &gGetRoomInfoCallbackImp);
    
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestLiveFansListCallbackImp : public IRequestLiveFansListCallback {
public:
    RequestLiveFansListCallbackImp(){};
    ~RequestLiveFansListCallbackImp(){};
    void OnLiveFansList(HttpLiveFansListTask *task, bool success, int errnum, const string &errmsg, const HttpLiveFansList &listItem) {
        NSLog(@"LSRequestManager::OnLiveFansList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HttpLiveFansList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            ViewerFansItemObject *item = [[ViewerFansItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.mountId = [NSString stringWithUTF8String:(*iter).mountId.c_str()];
            item.mountUrl = [NSString stringWithUTF8String:(*iter).mountUrl.c_str()];
            item.level = (*iter).level;
            item.isHasTicket = (*iter).isHasTicket;
            [array addObject:item];
            NSLog(@"LSRequestManager::OnGetLiveRoomFansList( task : %p, userId : %@, nickName : %@, photoUrl : %@ )", task, item.userId, item.nickName, item.photoUrl);
        }
        LiveFansListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestLiveFansListCallbackImp gLiveFansListCallbackImp;

- (NSInteger)liveFansList:(NSString *_Nonnull)roomId
                    start:(int)start
                     step:(int)step
            finishHandler:(LiveFansListFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.LiveFansList(&mHttpRequestManager, strRoomId, start, step, &gLiveFansListCallbackImp);
    
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetAllGiftListCallbackImp : public IRequestGetAllGiftListCallback {
public:
    RequestGetAllGiftListCallbackImp(){};
    ~RequestGetAllGiftListCallbackImp(){};
    void OnGetAllGiftList(HttpGetAllGiftListTask *task, bool success, int errnum, const string &errmsg, const GiftItemList &itemList) {
        NSLog(@"LSRequestManager::OnGetLiveRoomAllGiftList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (GiftItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            GiftInfoItemObject *gift = [[GiftInfoItemObject alloc] init];
            gift.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            gift.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            gift.smallImgUrl = [NSString stringWithUTF8String:(*iter).smallImgUrl.c_str()];
            gift.middleImgUrl = [NSString stringWithUTF8String:(*iter).middleImgUrl.c_str()];
            gift.bigImgUrl = [NSString stringWithUTF8String:(*iter).bigImgUrl.c_str()];
            gift.srcFlashUrl = [NSString stringWithUTF8String:(*iter).srcFlashUrl.c_str()];
            gift.srcwebpUrl = [NSString stringWithUTF8String:(*iter).srcwebpUrl.c_str()];
            gift.credit = (*iter).credit;
            gift.multiClick = (*iter).multiClick;
            gift.type = (*iter).type;
            gift.level = (*iter).level;
            gift.loveLevel = (*iter).loveLevel;
            gift.updateTime = (*iter).updateTime;
            gift.playTime = (*iter).playTime;
            NSMutableArray *arrayNum = [NSMutableArray array];
            for (SendNumList::const_iterator iterNum = (*iter).sendNumList.begin(); iterNum != (*iter).sendNumList.end(); iterNum++) {
                NSNumber *nsNum = [NSNumber numberWithInt:(*iterNum)];
                [arrayNum addObject:nsNum];
            }
            gift.sendNumList = arrayNum;
            [array addObject:gift];
        }
        GetAllGiftListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetAllGiftListCallbackImp gRequestGetAllGiftListCallbackImp;
- (NSInteger)getAllGiftList:(GetAllGiftListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetAllGiftList(&mHttpRequestManager, &gRequestGetAllGiftListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetGiftListByUserIdCallbackImp : public IRequestGetGiftListByUserIdCallback {
public:
    RequestGetGiftListByUserIdCallbackImp(){};
    ~RequestGetGiftListByUserIdCallbackImp(){};
    void OnGetGiftListByUserId(HttpGetGiftListByUserIdTask *task, bool success, int errnum, const string &errmsg, const GiftWithIdItemList &itemList) {
        NSLog(@"LSRequestManager::OnGetAllGiftList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (GiftWithIdItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            GiftWithIdItemObject *item = [[GiftWithIdItemObject alloc] init];
            item.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            item.isShow = (*iter).isShow;
            item.isPromo = (*iter).isPromo;
            item.isFree = (*iter).isFree;
            NSMutableArray *typeArray = [NSMutableArray array];
            for (GiftTypeIdList::const_iterator typeIter = (*iter).typeIdList.begin(); typeIter != (*iter).typeIdList.end(); typeIter++) {
                NSString* typeId = [NSString stringWithUTF8String:(*typeIter).c_str()];
                [typeArray addObject:typeId];
            }
            item.typeIdList = typeArray;
            
            [array addObject:item];
            //            NSLog(@"LSRequestManager::OnGetLiveRoomGiftListByUserId( task : %p, giftId : %@ )", task, item.giftId);
        }
        GetGiftListByUserIdFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetGiftListByUserIdCallbackImp gRequestGetGiftListByUserIdCallbackImp;
- (NSInteger)getGiftListByUserId:(NSString *_Nonnull)roomId
                   finishHandler:(GetGiftListByUserIdFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetGiftListByUserId(&mHttpRequestManager, strRoomId, &gRequestGetGiftListByUserIdCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetGiftDetailCallbackImp : public IRequestGetGiftDetailCallback {
public:
    RequestGetGiftDetailCallbackImp(){};
    ~RequestGetGiftDetailCallbackImp(){};
    void OnGetGiftDetail(HttpGetGiftDetailTask *task, bool success, int errnum, const string &errmsg, const HttpGiftInfoItem &item) {
        NSLog(@"LSRequestManager::OnGetGiftDetail( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GiftInfoItemObject *gift = [[GiftInfoItemObject alloc] init];
        gift.giftId = [NSString stringWithUTF8String:item.giftId.c_str()];
        gift.name = [NSString stringWithUTF8String:item.name.c_str()];
        gift.smallImgUrl = [NSString stringWithUTF8String:item.smallImgUrl.c_str()];
        gift.middleImgUrl = [NSString stringWithUTF8String:item.middleImgUrl.c_str()];
        gift.bigImgUrl = [NSString stringWithUTF8String:item.bigImgUrl.c_str()];
        gift.srcFlashUrl = [NSString stringWithUTF8String:item.srcFlashUrl.c_str()];
        gift.srcwebpUrl = [NSString stringWithUTF8String:item.srcwebpUrl.c_str()];
        gift.credit = item.credit;
        gift.multiClick = item.multiClick;
        gift.type = item.type;
        gift.level = item.level;
        gift.loveLevel = item.loveLevel;
        gift.updateTime = item.updateTime;
        gift.playTime = item.playTime;
        NSMutableArray *arrayNum = [NSMutableArray array];
        for (SendNumList::const_iterator iterNum = item.sendNumList.begin(); iterNum != item.sendNumList.end(); iterNum++) {
            NSNumber *nsNum = [NSNumber numberWithInt:(*iterNum)];
            [arrayNum addObject:nsNum];
        }
        gift.sendNumList = arrayNum;
        
        GetGiftDetailFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], gift);
        }
    }
};
RequestGetGiftDetailCallbackImp gRequestGetGiftDetailCallbackImp;
- (NSInteger)getGiftDetail:(NSString *_Nonnull)giftId
             finishHandler:(GetGiftDetailFinishHandler _Nullable)finishHandler {
    string strGiftId = "";
    if (nil != giftId) {
        strGiftId = [giftId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetGiftDetail(&mHttpRequestManager, strGiftId, &gRequestGetGiftDetailCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetEmoticonListCallbackImp : public IRequestGetEmoticonListCallback {
public:
    RequestGetEmoticonListCallbackImp(){};
    ~RequestGetEmoticonListCallbackImp(){};
    void OnGetEmoticonList(HttpGetEmoticonListTask *task, bool success, int errnum, const string &errmsg, const EmoticonItemList &listItem) {
        NSLog(@"LSRequestManager::OnGetEmoticonList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (EmoticonItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            EmoticonItemObject *item = [[EmoticonItemObject alloc] init];
            item.type = (*iter).type;
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.errMsg = [NSString stringWithUTF8String:(*iter).errMsg.c_str()];
            item.emoUrl = [NSString stringWithUTF8String:(*iter).emoUrl.c_str()];
            NSMutableArray *arrayEmo = [NSMutableArray array];
            for (EmoticonInfoItemList::const_iterator iterEmo = (*iter).emoList.begin(); iterEmo != (*iter).emoList.end(); iterEmo++) {
                EmoticonInfoItemObject *Emo = [[EmoticonInfoItemObject alloc] init];
                Emo.emoId = [NSString stringWithUTF8String:(*iterEmo).emoId.c_str()];
                Emo.emoSign = [NSString stringWithUTF8String:(*iterEmo).emoSign.c_str()];
                Emo.emoUrl = [NSString stringWithUTF8String:(*iterEmo).emoUrl.c_str()];
                Emo.emoType = (*iterEmo).emoType;
                Emo.emoIconUrl = [NSString stringWithUTF8String:(*iterEmo).emoIconUrl.c_str()];
                [arrayEmo addObject:Emo];
            }
            item.emoList = arrayEmo;
            [array addObject:item];
        }
        
        GetEmoticonListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetEmoticonListCallbackImp gRequestGetEmoticonListCallbackImp;
- (NSInteger)getEmoticonList:(GetEmoticonListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetEmoticonList(&mHttpRequestManager, &gRequestGetEmoticonListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetInviteInfoCallbackImp : public IRequestGetInviteInfoCallback {
public:
    RequestGetInviteInfoCallbackImp(){};
    ~RequestGetInviteInfoCallbackImp(){};
    void OnGetInviteInfo(HttpGetInviteInfoTask *task, bool success, int errnum, const string &errmsg, const HttpInviteInfoItem &inviteItem) {
        NSLog(@"LSRequestManager::OnGetInviteInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        InviteIdItemObject *item = [[InviteIdItemObject alloc] init];
        item.invitationId = [NSString stringWithUTF8String:inviteItem.invitationId.c_str()];
        item.oppositeId = [NSString stringWithUTF8String:inviteItem.oppositeId.c_str()];
        item.oppositeNickName = [NSString stringWithUTF8String:inviteItem.oppositeNickName.c_str()];
        item.oppositePhotoUrl = [NSString stringWithUTF8String:inviteItem.oppositePhotoUrl.c_str()];
        item.oppositeLevel = inviteItem.oppositeLevel;
        item.oppositeAge = inviteItem.oppositeAge;
        item.oppositeCountry = [NSString stringWithUTF8String:inviteItem.oppositeCountry.c_str()];
        item.read = inviteItem.read;
        item.inviTime = inviteItem.inviTime;
        item.replyType = inviteItem.replyType;
        item.validTime = inviteItem.validTime;
        item.roomId = [NSString stringWithUTF8String:inviteItem.roomId.c_str()];
        
        GetInviteInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};
RequestGetInviteInfoCallbackImp gRequestGetInviteInfoCallbackImp;
- (NSInteger)getInviteInfo:(NSString *_Nonnull)inviteId
             finishHandler:(GetInviteInfoFinishHandler _Nullable)finishHandler {
    string strInviteId = "";
    if (nil != inviteId) {
        strInviteId = [inviteId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetInviteInfo(&mHttpRequestManager, strInviteId, &gRequestGetInviteInfoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetTalentListCallbackImp : public IRequestGetTalentListCallback {
public:
    RequestGetTalentListCallbackImp(){};
    ~RequestGetTalentListCallbackImp(){};
    void OnGetTalentList(HttpGetTalentListTask *task, bool success, int errnum, const string &errmsg, const TalentItemList &list) {
        NSLog(@"LSRequestManager::OnGetTalentList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        NSMutableArray *array = [NSMutableArray array];
        for (TalentItemList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            GetTalentItemObject *item = [[GetTalentItemObject alloc] init];
            item.talentId = [NSString stringWithUTF8String:(*iter).talentId.c_str()];
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.credit = (*iter).credit;
            item.decription = [NSString stringWithUTF8String:(*iter).decription.c_str()];
            item.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            item.giftName = [NSString stringWithUTF8String:(*iter).giftName.c_str()];
            item.giftNum = (*iter).giftNum;
            [array addObject:item];
        }
        
        GetTalentListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetTalentListCallbackImp gRequestGetTalentListCallbackImp;
- (NSInteger)getTalentList:(NSString *_Nonnull)roomId
             finishHandler:(GetTalentListFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetTalentList(&mHttpRequestManager, strRoomId, &gRequestGetTalentListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetTalentStatusCallbackImp : public IRequestGetTalentStatusCallback {
public:
    RequestGetTalentStatusCallbackImp(){};
    ~RequestGetTalentStatusCallbackImp(){};
    void OnGetTalentStatus(HttpGetTalentStatusTask *task, bool success, int errnum, const string &errmsg, const HttpGetTalentStatusItem &item) {
        NSLog(@"LSRequestManager::OnGetTalentStatus( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GetTalentStatusItemObject *obj = [[GetTalentStatusItemObject alloc] init];
        obj.talentInviteId = [NSString stringWithUTF8String:item.talentInviteId.c_str()];
        obj.talentId = [NSString stringWithUTF8String:item.talentId.c_str()];
        obj.name = [NSString stringWithUTF8String:item.name.c_str()];
        obj.credit = item.credit;
        obj.status = item.status;
        obj.giftId = [NSString stringWithUTF8String:item.giftId.c_str()];
        obj.giftName = [NSString stringWithUTF8String:item.giftName.c_str()];
        obj.giftNum = item.giftNum;
        
        GetTalentStatusFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetTalentStatusCallbackImp gRequestGetTalentStatusCallbackImp;
- (NSInteger)getTalentStatus:(NSString *_Nonnull)roomId
              talentInviteId:(NSString *_Nonnull)talentInviteId
               finishHandler:(GetTalentStatusFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetTalentStatus(&mHttpRequestManager, strRoomId, [talentInviteId UTF8String], &gRequestGetTalentStatusCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetNewFansBaseInfoCallbackImp : public IRequestGetNewFansBaseInfoCallback {
public:
    RequestGetNewFansBaseInfoCallbackImp(){};
    ~RequestGetNewFansBaseInfoCallbackImp(){};
    void OnGetNewFansBaseInfo(HttpGetNewFansBaseInfoTask *task, bool success, int errnum, const string &errmsg, const HttpLiveFansInfoItem &item) {
        NSLog(@"LSRequestManager::OnGetNewFansBaseInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GetNewFansBaseInfoItemObject *obj = [[GetNewFansBaseInfoItemObject alloc] init];
        obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        obj.riderId = [NSString stringWithUTF8String:item.riderId.c_str()];
        obj.riderName = [NSString stringWithUTF8String:item.riderName.c_str()];
        obj.riderUrl = [NSString stringWithUTF8String:item.riderUrl.c_str()];
        
        GetNewFansBaseInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetNewFansBaseInfoCallbackImp gRequestGetNewFansBaseInfoCallbackImp;
- (NSInteger)getNewFansBaseInfo:(NSString *_Nonnull)userId
                  finishHandler:(GetNewFansBaseInfoFinishHandler _Nullable)finishHandler {
    string strUserId = "";
    if (nil != userId) {
        strUserId = [userId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetNewFansBaseInfo(&mHttpRequestManager, strUserId, &gRequestGetNewFansBaseInfoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestControlManPushCallbackImp : public IRequestControlManPushCallback {
public:
    RequestControlManPushCallbackImp(){};
    ~RequestControlManPushCallbackImp(){};
    void OnControlManPush(HttpControlManPushTask *task, bool success, int errnum, const string &errmsg, const list<string> &uploadUrls) {
        NSLog(@"LSRequestManager::OnControlManPush( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *nsUploadUrls = [NSMutableArray array];
        for (list<string>::const_iterator itr = uploadUrls.begin(); itr != uploadUrls.end(); itr++) {
            NSString *strUploadUrl = [NSString stringWithUTF8String:(*itr).c_str()];
            [nsUploadUrls addObject:strUploadUrl];
        }
        
        ControlManPushFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], nsUploadUrls);
        }
    }
};
RequestControlManPushCallbackImp gRequestControlManPushCallbackImp;
- (NSInteger)controlManPush:(NSString *_Nonnull)roomId
                    control:(ControlType)control
              finishHandler:(ControlManPushFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ControlManPush(&mHttpRequestManager, strRoomId, control, &gRequestControlManPushCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetPromoAnchorListCallbackImp : public IRequestGetPromoAnchorListCallback {
public:
    RequestGetPromoAnchorListCallbackImp(){};
    ~RequestGetPromoAnchorListCallbackImp(){};
    void OnGetPromoAnchorList(HttpGetPromoAnchorListTask *task, bool success, int errnum, const string &errmsg, const AdItemList &listItem) {
        NSLog(@"LSRequestManager::OnGetPromoAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (AdItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            //            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            item.roomType = (*iter).roomType;
            //            NSMutableArray* nsInterest = [NSMutableArray array];
            //            for (InterestList::const_iterator itr = (*iter).interest.begin(); itr != (*iter).interest.end(); itr++) {
            //                int num = (*itr);
            //                NSNumber *numInterest = [NSNumber numberWithInt:num];
            //                [nsInterest addObject:numInterest];
            //            }
            //            item.interest = nsInterest;
            item.anchorType = (*iter).anchorType;

            [array addObject:item];
        }
        
        GetPromoAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetPromoAnchorListCallbackImp gRequestGetPromoAnchorListCallbackImp;
- (NSInteger)getPromoAnchorList:(int)number
                           type:(PromoAnchorType)type
                         userId:(NSString *_Nonnull)userId
                  finishHandler:(GetPromoAnchorListFinishHandler _Nullable)finishHandler {
    string strUserId = "";
    if (nil != userId) {
        strUserId = [userId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetPromoAnchorList(&mHttpRequestManager, number, type, strUserId, &gRequestGetPromoAnchorListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetLiveEndRecommendAnchorListCallbackImp : public IRequestGetLiveEndRecommendAnchorListCallback {
public:
    RequestGetLiveEndRecommendAnchorListCallbackImp(){};
    ~RequestGetLiveEndRecommendAnchorListCallbackImp(){};
    void OnGetLiveEndRecommendAnchorList(HttpGetLiveEndRecommendAnchorListTask* task, bool success, int errnum, const string& errmsg, const RecommendAnchorList& listItem) {
        NSLog(@"LSRequestManager::OnGetLiveEndRecommendAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (RecommendAnchorList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LSRecommendAnchorItemObject *item = [[LSRecommendAnchorItemObject alloc] init];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNickName = [NSString stringWithUTF8String:(*iter).anchorNickName.c_str()];
            item.anchorCover = [NSString stringWithUTF8String:(*iter).anchorCover.c_str()];
            item.anchorAvatar = [NSString stringWithUTF8String:(*iter).anchorAvatar.c_str()];
            item.isFollow = (*iter).isFollow;
            item.onlineStatus = (*iter).onlineStatus;
            item.publicRoomId = [NSString stringWithUTF8String:(*iter).publicRoomId.c_str()];
            item.lastCountactTime = (*iter).lastCountactTime;
            [array addObject:item];
        }
        
        GetLiveEndRecommendAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetLiveEndRecommendAnchorListCallbackImp gRequestGetLiveEndRecommendAnchorListCallbackImp;
- (NSInteger)getLiveEndRecommendAnchorList:(GetLiveEndRecommendAnchorListFinishHandler)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetLiveEndRecommendAnchorList(&mHttpRequestManager,  &gRequestGetLiveEndRecommendAnchorListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetContactListCallbackImp : public IRequestGetContactListCallback {
public:
    RequestGetContactListCallbackImp(){};
    ~RequestGetContactListCallbackImp(){};
    void OnGetContactList(HttpGetContactListTask* task, bool success, int errnum, const string& errmsg, const RecommendAnchorList& listItem, int totalCount) {
        NSLog(@"LSRequestManager::OnGetContactList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (RecommendAnchorList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LSRecommendAnchorItemObject *item = [[LSRecommendAnchorItemObject alloc] init];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNickName = [NSString stringWithUTF8String:(*iter).anchorNickName.c_str()];
            item.anchorAge = (*iter).anchorAge;
            item.anchorCover = [NSString stringWithUTF8String:(*iter).anchorCover.c_str()];
            item.anchorAvatar = [NSString stringWithUTF8String:(*iter).anchorAvatar.c_str()];
            item.isFollow = (*iter).isFollow;
            item.onlineStatus = (*iter).onlineStatus;
            item.publicRoomId = [NSString stringWithUTF8String:(*iter).publicRoomId.c_str()];
            item.roomType = (*iter).roomType;
            LSHttpAuthorityItemObject* privObject = [[LSHttpAuthorityItemObject alloc] init];
            privObject.isHasOneOnOneAuth = (*iter).priv.privteLiveAuth;
            privObject.isHasBookingAuth = (*iter).priv.bookingPriLiveAuth;
            item.priv = privObject;
            item.lastCountactTime = (*iter).lastCountactTime;
            
            [array addObject:item];
        }
        
        GetContactListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array, totalCount);
        }
    }
};
RequestGetContactListCallbackImp gRequestGetContactListCallbackImp;
- (NSInteger)getContactList:(int)start
                       step:(int)step
              finishHandler:(GetContactListFinishHandler)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetContactList(&mHttpRequestManager, start, step, &gRequestGetContactListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetGiftTypeListtCallbackImp : public IRequestGetGiftTypeListtCallback {
public:
    RequestGetGiftTypeListtCallbackImp(){};
    ~RequestGetGiftTypeListtCallbackImp(){};
    void OnGetGiftTypeList(HttpGetGiftTypeListTask* task, bool success, int errnum, const string& errmsg, const GiftTypeList typeList) {
        NSLog(@"LSRequestManager::OnGetGiftTypeList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (GiftTypeList::const_iterator iter = typeList.begin(); iter != typeList.end(); iter++) {
            LSGiftTypeItemObject *item = [[LSGiftTypeItemObject alloc] init];
            item.typeId = [NSString stringWithUTF8String:(*iter).typeId.c_str()];
            item.typeName = [NSString stringWithUTF8String:(*iter).typeName.c_str()];
            
            [array addObject:item];
        }
        
        GetGiftTypeListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetGiftTypeListtCallbackImp gRequestGetGiftTypeListtCallbackImp;
- (NSInteger)getGiftTypeList:(LSGiftRoomType)roomType
               finishHandler:(GetGiftTypeListFinishHandler)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetGiftTypeList(&mHttpRequestManager, roomType, &gRequestGetGiftTypeListtCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetFeaturedAnchorListCallbackImp : public IRequestGetFeaturedAnchorListCallback {
public:
    RequestGetFeaturedAnchorListCallbackImp(){};
    ~RequestGetFeaturedAnchorListCallbackImp(){};
    void OnGetFeaturedAnchorList(HttpGetFeaturedAnchorListTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem) {
        NSLog(@"LSRequestManager::OnGetFeaturedAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s, count : %lu )", task, success ? "true" : "false", errnum, errmsg.c_str(), listItem.size());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HotItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter)->userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter)->nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter)->photoUrl.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter)->roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter)->onlineStatus;
            item.roomType = (*iter)->roomType;
            NSMutableArray *nsInterest = [NSMutableArray array];
            //int i = 0;
            for (InterestList::const_iterator itr = (*iter)->interest.begin(); itr != (*iter)->interest.end(); itr++) {
                //NSString* strInterest = [NSString stringWithUTF8String:(*itr).c_str()];
                int num = (*itr);
                NSNumber *numInterest = [NSNumber numberWithInt:num];
                [nsInterest addObject:numInterest];
                //item->interest[i] = (*itr);
                //i++;
            }
            item.interest = nsInterest;
            item.anchorType = (*iter)->anchorType;
            
            if ((*iter)->showInfo != NULL) {
                LSProgramItemObject* programItem = [[LSProgramItemObject alloc] init];
                programItem.showLiveId = [NSString stringWithUTF8String:(*iter)->showInfo->showLiveId.c_str()];
                programItem.anchorId = [NSString stringWithUTF8String:(*iter)->showInfo->anchorId.c_str()];
                programItem.anchorNickName = [NSString stringWithUTF8String:(*iter)->showInfo->anchorNickName.c_str()];
                programItem.anchorAvatar = [NSString stringWithUTF8String:(*iter)->showInfo->anchorAvatar.c_str()];
                programItem.showTitle = [NSString stringWithUTF8String:(*iter)->showInfo->showTitle.c_str()];
                programItem.showIntroduce = [NSString stringWithUTF8String:(*iter)->showInfo->showIntroduce.c_str()];
                programItem.cover = [NSString stringWithUTF8String:(*iter)->showInfo->cover.c_str()];
                programItem.approveTime = (*iter)->showInfo->approveTime;
                programItem.startTime = (*iter)->showInfo->startTime;
                programItem.duration = (*iter)->showInfo->duration;
                programItem.leftSecToStart = (*iter)->showInfo->leftSecToStart;
                programItem.leftSecToEnter = (*iter)->showInfo->leftSecToEnter;
                programItem.price = (*iter)->showInfo->price;
                programItem.status = (*iter)->showInfo->status;
                programItem.ticketStatus = (*iter)->showInfo->ticketStatus;
                programItem.isHasFollow = (*iter)->showInfo->isHasFollow;
                programItem.isTicketFull = (*iter)->showInfo->isTicketFull;
                
                item.showInfo = programItem;
            }
            LSHttpAuthorityItemObject* priv = [[LSHttpAuthorityItemObject alloc] init];
            
            priv.isHasOneOnOneAuth = (*iter)->priv.privteLiveAuth;
            priv.isHasBookingAuth = (*iter)->priv.bookingPriLiveAuth;
            
            item.priv = priv;
            item.chatOnlineStatus = (*iter)->chatOnlineStatus;
            item.isFollow = (*iter)->isFollow;
            
            [array addObject:item];
            //            NSLog(@"LSRequestManager::OnGetAnchorList( task : %p, userId : %@, nickName : %@, onlineStatus : %d, roomType : %d )", task, item.userId, item.nickName, item.onlineStatus, item.roomType);
        }
        GetFeaturedAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetFeaturedAnchorListCallbackImp gRequestGetFeaturedAnchorListCallbackImp;
- (NSInteger)getFeaturedAnchorList:(int)start
                              step:(int)step
                     finishHandler:(GetFeaturedAnchorListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetFeaturedAnchorList(&mHttpRequestManager, start, step, &gRequestGetFeaturedAnchorListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 预约私密

class RequestManHandleBookingListCallbackImp : public IRequestManHandleBookingListCallback {
public:
    RequestManHandleBookingListCallbackImp(){};
    ~RequestManHandleBookingListCallbackImp(){};
    void OnManHandleBookingList(HttpManHandleBookingListTask *task, bool success, int errnum, const string &errmsg, const HttpBookingInviteListItem &BookingListItem) {
        NSLog(@"LSRequestManager::OnManHandleBookingList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        BookingPrivateInviteListObject *item = [[BookingPrivateInviteListObject alloc] init];
        item.total = BookingListItem.total;
        item.noReadCount = BookingListItem.noReadCount;
        NSMutableArray *array = [NSMutableArray array];
        for (BookingPrivateInviteItemList::const_iterator iter = BookingListItem.list.begin(); iter != BookingListItem.list.end(); iter++) {
            BookingPrivateInviteItemObject *obj = [[BookingPrivateInviteItemObject alloc] init];
            obj.invitationId = [NSString stringWithUTF8String:(*iter).invitationId.c_str()];
            obj.toId = [NSString stringWithUTF8String:(*iter).toId.c_str()];
            obj.fromId = [NSString stringWithUTF8String:(*iter).fromId.c_str()];
            obj.oppositePhotoUrl = [NSString stringWithUTF8String:(*iter).oppositePhotoUrl.c_str()];
            obj.oppositeNickName = [NSString stringWithUTF8String:(*iter).oppositeNickName.c_str()];
            obj.read = (*iter).read;
            obj.intimacy = (*iter).intimacy;
            obj.replyType = (*iter).replyType;
            obj.bookTime = (*iter).bookTime;
            obj.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            obj.giftName = [NSString stringWithUTF8String:(*iter).giftName.c_str()];
            obj.giftBigImgUrl = [NSString stringWithUTF8String:(*iter).giftBigImgUrl.c_str()];
            obj.giftSmallImgUrl = [NSString stringWithUTF8String:(*iter).giftSmallImgUrl.c_str()];
            obj.giftNum = (*iter).giftNum;
            obj.validTime = (*iter).validTime;
            obj.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
            [array addObject:obj];
        }
        item.list = array;
        
        ManHandleBookingListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};
RequestManHandleBookingListCallbackImp gRequestManHandleBookingListCallbackImp;
- (NSInteger)manHandleBookingList:(BookingListType)type
                            start:(int)start
                             step:(int)step
                    finishHandler:(ManHandleBookingListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ManHandleBookingList(&mHttpRequestManager, type, start, step, &gRequestManHandleBookingListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestHandleBookingCallbackImp : public IRequestHandleBookingCallback {
public:
    RequestHandleBookingCallbackImp(){};
    ~RequestHandleBookingCallbackImp(){};
    void OnHandleBooking(HttpHandleBookingTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnHandleBooking( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        HandleBookingFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestHandleBookingCallbackImp gRequestHandleBookingCallbackImp;
- (NSInteger)handleBooking:(NSString *_Nonnull)inviteId
                 isConfirm:(BOOL)isConfirm
             finishHandler:(HandleBookingFinishHandler _Nullable)finishHandler {
    string strInviteId = "";
    if (nil != inviteId) {
        strInviteId = [inviteId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.HandleBooking(&mHttpRequestManager, strInviteId, isConfirm, &gRequestHandleBookingCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSendCancelPrivateLiveInviteCallbackImp : public IRequestSendCancelPrivateLiveInviteCallback {
public:
    RequestSendCancelPrivateLiveInviteCallbackImp(){};
    ~RequestSendCancelPrivateLiveInviteCallbackImp(){};
    void OnSendCancelPrivateLiveInvite(HttpSendCancelPrivateLiveInviteTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSendCancelPrivateLiveInvite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SendCancelPrivateLiveInviteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSendCancelPrivateLiveInviteCallbackImp gRequestSendCancelPrivateLiveInviteCallbackImp;
- (NSInteger)sendCancelPrivateLiveInvite:(NSString *_Nonnull)invitationId
                           finishHandler:(SendCancelPrivateLiveInviteFinishHandler _Nullable)finishHandler {
    string strInvitationId = "";
    if (nil != invitationId) {
        strInvitationId = [invitationId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.SendCancelPrivateLiveInvite(&mHttpRequestManager, strInvitationId, &gRequestSendCancelPrivateLiveInviteCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestManBookingUnreadUnhandleNumCallbackImp : public IRequestManBookingUnreadUnhandleNumCallback {
public:
    RequestManBookingUnreadUnhandleNumCallbackImp(){};
    ~RequestManBookingUnreadUnhandleNumCallbackImp(){};
    void OnManBookingUnreadUnhandleNum(HttpManBookingUnreadUnhandleNumTask *task, bool success, int errnum, const string &errmsg, const HttpBookingUnreadUnhandleNumItem &item) {
        NSLog(@"LSRequestManager::OnManBookingUnreadUnhandleNum( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        BookingUnreadUnhandleNumItemObject *obj = [[BookingUnreadUnhandleNumItemObject alloc] init];
        obj.totalNoReadNum = item.totalNoReadNum;
        obj.pendingNoReadNum = item.pendingNoReadNum;
        obj.scheduledNoReadNum = item.scheduledNoReadNum;
        obj.historyNoReadNum = item.historyNoReadNum;
        
        ManBookingUnreadUnhandleNumFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestManBookingUnreadUnhandleNumCallbackImp gRequestManBookingUnreadUnhandleNumCallbackImp;
- (NSInteger)manBookingUnreadUnhandleNum:(ManBookingUnreadUnhandleNumFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ManBookingUnreadUnhandleNum(&mHttpRequestManager, &gRequestManBookingUnreadUnhandleNumCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetCreateBookingInfoCallbackImp : public IRequestGetCreateBookingInfoCallback {
public:
    RequestGetCreateBookingInfoCallbackImp(){};
    ~RequestGetCreateBookingInfoCallbackImp(){};
    void OnGetCreateBookingInfo(HttpGetCreateBookingInfoTask *task, bool success, int errnum, const string &errmsg, const HttpGetCreateBookingInfoItem &item) {
        NSLog(@"LSRequestManager::OnGetCreateBookingInfo( task : %p, success : %s, errnum : %d, errmsg : %s, count : %d )", task, success ? "true" : "false", errnum, errmsg.c_str(), (int)item.bookTime.size());
        
        GetCreateBookingInfoItemObject *obj = [[GetCreateBookingInfoItemObject alloc] init];
        obj.bookDeposit = item.bookDeposit;
        NSMutableArray *arrayBookTime = [NSMutableArray array];
        for (HttpGetCreateBookingInfoItem::BookTimeList::const_iterator iter = item.bookTime.begin(); iter != item.bookTime.end(); iter++) {
            BookTimeItemObject *objBookTime = [[BookTimeItemObject alloc] init];
            objBookTime.timeId = [NSString stringWithUTF8String:(*iter).timeId.c_str()];
            objBookTime.time = (*iter).time;
            objBookTime.status = (*iter).status;
            [arrayBookTime addObject:objBookTime];
        }
        obj.bookTime = arrayBookTime;
        
        NSMutableArray *arrayBookGift = [NSMutableArray array];
        for (HttpGetCreateBookingInfoItem::GiftList::const_iterator iterBookGift = item.bookGift.giftList.begin(); iterBookGift != item.bookGift.giftList.end(); iterBookGift++) {
            LSGiftItemObject *objBookGift = [[LSGiftItemObject alloc] init];
            objBookGift.giftId = [NSString stringWithUTF8String:(*iterBookGift).giftId.c_str()];
            NSMutableArray *arrayGiftNum = [NSMutableArray array];
            for (HttpGetCreateBookingInfoItem::GiftNumList::const_iterator iterGiftNum = (*iterBookGift).sendNumList.begin(); iterGiftNum != (*iterBookGift).sendNumList.end(); iterGiftNum++) {
                GiftNumItemObject *objGiftNum = [[GiftNumItemObject alloc] init];
                objGiftNum.num = (*iterGiftNum).num;
                objGiftNum.isDefault = (*iterGiftNum).isDefault;
                [arrayGiftNum addObject:objGiftNum];
            }
            objBookGift.sendNumList = arrayGiftNum;
            [arrayBookGift addObject:objBookGift];
        }
        obj.bookGift = arrayBookGift;
        
        BookPhoneItemObject *bookPhone = [[BookPhoneItemObject alloc] init];
        bookPhone.country = [NSString stringWithUTF8String:item.bookPhone.country.c_str()];
        bookPhone.areaCode = [NSString stringWithUTF8String:item.bookPhone.areaCode.c_str()];
        bookPhone.phoneNo = [NSString stringWithUTF8String:item.bookPhone.phoneNo.c_str()];
        obj.bookPhone = bookPhone;
        
        GetCreateBookingInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetCreateBookingInfoCallbackImp gRequestGetCreateBookingInfoCallbackImp;
- (NSInteger)getCreateBookingInfo:(NSString *_Nullable)userId
                    finishHandler:(GetCreateBookingInfoFinishHandler _Nullable)finishHandler {
    string strUserId = "";
    if (nil != userId) {
        strUserId = [userId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetCreateBookingInfo(&mHttpRequestManager, strUserId, &gRequestGetCreateBookingInfoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSendBookingRequestCallbackImp : public IRequestSendBookingRequestCallback {
public:
    RequestSendBookingRequestCallbackImp(){};
    ~RequestSendBookingRequestCallbackImp(){};
    void OnSendBookingRequest(HttpSendBookingRequestTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSendBookingRequest( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SendBookingRequestFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSendBookingRequestCallbackImp gRequestSendBookingRequestCallbackImp;
- (NSInteger)sendBookingRequest:(NSString *_Nullable)userId
                         timeId:(NSString *_Nullable)timeId
                       bookTime:(NSInteger)bookTime
                         giftId:(NSString *_Nullable)giftId
                        giftNum:(int)giftNum
                        needSms:(BOOL)needSms
                  finishHandler:(SendBookingRequestFinishHandler _Nullable)finishHandler {
    string strUserId = "";
    if (nil != userId) {
        strUserId = [userId UTF8String];
    }
    string strTimeId = "";
    if (nil != timeId) {
        strTimeId = [timeId UTF8String];
    }
    string strGiftId = "";
    if (nil != giftId) {
        strGiftId = [giftId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.SendBookingRequest(&mHttpRequestManager, strUserId, strTimeId, bookTime, strGiftId, giftNum, needSms, &gRequestSendBookingRequestCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAcceptInstanceInviteCallbackImp : public IRequestAcceptInstanceInviteCallback {
public:
    RequestAcceptInstanceInviteCallbackImp(){};
    ~RequestAcceptInstanceInviteCallbackImp(){};
    void OnAcceptInstanceInvite(HttpAcceptInstanceInviteTask *task, bool success, int errnum, const string &errmsg, const HttpAcceptInstanceInviteItem &item, const HttpAuthorityItem& priv) {
        NSLog(@"LSRequestManager::OnAcceptInstanceInvite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        AcceptInstanceInviteItemObject *obj = [[AcceptInstanceInviteItemObject alloc] init];
        obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
        obj.roomType = item.roomType;
        
        LSHttpAuthorityItemObject* privObject = [[LSHttpAuthorityItemObject alloc] init];
        privObject.isHasOneOnOneAuth = priv.privteLiveAuth;
        privObject.isHasBookingAuth = priv.bookingPriLiveAuth;
        
        AcceptInstanceInviteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj, privObject);
        }
    }
};
RequestAcceptInstanceInviteCallbackImp gRequestAcceptInstanceInviteCallbackImp;
- (NSInteger)acceptInstanceInvite:(NSString *_Nullable)inviteId
                        isConfirm:(BOOL)isConfirm
                    finishHandler:(AcceptInstanceInviteFinishHandler _Nullable)finishHandler {
    string strInviteId = "";
    if (nil != inviteId) {
        strInviteId = [inviteId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.AcceptInstanceInvite(&mHttpRequestManager, strInviteId, isConfirm, &gRequestAcceptInstanceInviteCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 背包

class RequestGiftListCallbackImp : public IRequestGiftListCallback {
public:
    RequestGiftListCallbackImp(){};
    ~RequestGiftListCallbackImp(){};
    void OnGiftList(HttpGiftListTask *task, bool success, int errnum, const string &errmsg, const BackGiftItemList &list, int totalCount) {
        NSLog(@"LSRequestManager::OnGiftList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (BackGiftItemList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            BackGiftItemObject *item = [[BackGiftItemObject alloc] init];
            item.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            item.num = (*iter).num;
            item.grantedDate = (*iter).grantedDate;
            item.startValidDate = (*iter).startValidDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            [array addObject:item];
        }
        
        GiftListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array, totalCount);
        }
    }
};
RequestGiftListCallbackImp gRequestGiftListCallbackImp;
- (NSInteger)giftList:(GiftListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GiftList(&mHttpRequestManager, &gRequestGiftListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestVoucherListCallbackImp : public IRequestVoucherListCallback {
public:
    RequestVoucherListCallbackImp(){};
    ~RequestVoucherListCallbackImp(){};
    void OnVoucherList(HttpVoucherListTask *task, bool success, int errnum, const string &errmsg, const VoucherList &list, int totalCount) {
        NSLog(@"LSRequestManager::OnVoucherList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (VoucherList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            VoucherItemObject *item = [[VoucherItemObject alloc] init];
            item.voucherType = (*iter).voucherType;
            item.voucherId = [NSString stringWithUTF8String:(*iter).voucherId.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.photoUrlMobile = [NSString stringWithUTF8String:(*iter).photoUrlMobile.c_str()];
            item.desc = [NSString stringWithUTF8String:(*iter).desc.c_str()];
            item.useRoomType = (*iter).useRoomType;
            item.anchorType = (*iter).anchorType;
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNcikName = [NSString stringWithUTF8String:(*iter).anchorNcikName.c_str()];
            item.anchorPhotoUrl = [NSString stringWithUTF8String:(*iter).anchorPhotoUrl.c_str()];
            item.grantedDate = (*iter).grantedDate;
            item.startValidDate = (*iter).startValidDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            item.offsetMin = (*iter).offsetMin;
            [array addObject:item];
        }
        
        VoucherListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array, totalCount);
        }
    }
};
RequestVoucherListCallbackImp gRequestVoucherListCallbackImp;
- (NSInteger)voucherList:(VoucherListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.VoucherList(&mHttpRequestManager, &gRequestVoucherListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestRideListCallbackImp : public IRequestRideListCallback {
public:
    RequestRideListCallbackImp(){};
    ~RequestRideListCallbackImp(){};
    void OnRideList(HttpRideListTask *task, bool success, int errnum, const string &errmsg, const RideList &list, int totalCount) {
        NSLog(@"LSRequestManager::OnRideList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (RideList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            RideItemObject *item = [[RideItemObject alloc] init];
            item.rideId = [NSString stringWithUTF8String:(*iter).rideId.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.grantedDate = (*iter).grantedDate;
            item.startValidDate = (*iter).startValidDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            item.isUse = (*iter).isUse;
            [array addObject:item];
        }
        
        RideListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array, totalCount);
        }
    }
};
RequestRideListCallbackImp gRequestRideListCallbackImp;
- (NSInteger)rideList:(RideListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.RideList(&mHttpRequestManager, &gRequestRideListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSetRideCallbackImp : public IRequestSetRideCallback {
public:
    RequestSetRideCallbackImp(){};
    ~RequestSetRideCallbackImp(){};
    void OnSetRide(HttpSetRideTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSetRide( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        SetRideFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSetRideCallbackImp gRequestSetRideCallbackImp;
- (NSInteger)setRide:(NSString *_Nonnull)rideId
       finishHandler:(SetRideFinishHandler _Nullable)finishHandler {
    string strRideId = "";
    if (nil != rideId) {
        strRideId = [rideId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.SetRide(&mHttpRequestManager, strRideId, &gRequestSetRideCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetBackpackUnreadNumCallbackImp : public IRequestGetBackpackUnreadNumCallback {
public:
    RequestGetBackpackUnreadNumCallbackImp(){};
    ~RequestGetBackpackUnreadNumCallbackImp(){};
    void OnGetBackpackUnreadNum(HttpGetBackpackUnreadNumTask *task, bool success, int errnum, const string &errmsg, const HttpGetBackPackUnreadNumItem &item) {
        NSLog(@"LSRequestManager::OnGetBackpackUnreadNum( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        GetBackPackUnreadNumItemObject *obj = [[GetBackPackUnreadNumItemObject alloc] init];
        obj.total = item.total;
        obj.voucherUnreadNum = item.voucherUnreadNum;
        obj.giftUnreadNum = item.giftUnreadNum;
        obj.rideUnreadNum = item.rideUnreadNum;
        obj.livechatVoucherUnreadNum = item.livechatVoucherUnreadNum;
        
        GetBackpackUnreadNumFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetBackpackUnreadNumCallbackImp gRequestGetBackpackUnreadNumCallbackImp;
- (NSInteger)getBackpackUnreadNum:(GetBackpackUnreadNumFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetBackpackUnreadNum(&mHttpRequestManager, &gRequestGetBackpackUnreadNumCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetVoucherAvailableInfoCallbackImp : public IRequestGetVoucherAvailableInfoCallback {
public:
    RequestGetVoucherAvailableInfoCallbackImp(){};
    ~RequestGetVoucherAvailableInfoCallbackImp(){};
    void OnGetVoucherAvailableInfo(HttpGetVoucherAvailableInfoTask* task, bool success, int errnum, const string& errmsg, const HttpVoucherInfoItem& item) {
        NSLog(@"LSRequestManager::OnGetVoucherAvailableInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        LSVoucherAvailableInfoItemObject *obj = [[LSVoucherAvailableInfoItemObject alloc] init];
        obj.onlypublicExpTime = item.onlypublicExpTime;
        obj.onlyprivateExpTime = item.onlyprivateExpTime;
        NSMutableArray *array = [NSMutableArray array];
        for (HttpVoucherInfoItem::BindAnchorList::const_iterator iter = item.bindAnchor.begin(); iter != item.bindAnchor.end(); iter++) {
            LSBindAnchorItemObject *item = [[LSBindAnchorItemObject alloc] init];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.useRoomType = (*iter).useRoomType;
            item.expTime = (*iter).expTime;
            [array addObject:item];
        }
        obj.bindAnchor = array;
        obj.onlypublicNewExpTime = item.onlypublicNewExpTime;
        obj.onlyprivateNewExpTime = item.onlyprivateNewExpTime;
        NSMutableArray *arrayAnchor = [NSMutableArray array];
        for (WatchAnchorList::const_iterator iter = item.watchedAnchor.begin(); iter != item.watchedAnchor.end(); iter++) {
            NSString *anchorId = [NSString stringWithUTF8String:(*iter).c_str()];
            [arrayAnchor addObject:anchorId];
        }
        obj.watchedAnchor = arrayAnchor;
        
        GetVoucherAvailableInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetVoucherAvailableInfoCallbackImp gRequestGetVoucherAvailableInfoCallbackImp;
- (NSInteger)getVoucherAvailableInfo:(GetVoucherAvailableInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetVoucherAvailableInfo(&mHttpRequestManager, &gRequestGetVoucherAvailableInfoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}


class RequestGetChatVoucherListCallbackImp : public IRequestGetChatVoucherListCallback {
public:
    RequestGetChatVoucherListCallbackImp(){};
    ~RequestGetChatVoucherListCallbackImp(){};
    void OnGetChatVoucherList(HttpGetChatVoucherListTask* task, bool success, const string& errnum, const string& errmsg, const VoucherList& list, int totalCount) {
        NSLog(@"LSRequestManager::OnGetChatVoucherList( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (VoucherList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            VoucherItemObject *item = [[VoucherItemObject alloc] init];
            item.voucherType = (*iter).voucherType;
            item.voucherId = [NSString stringWithUTF8String:(*iter).voucherId.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.photoUrlMobile = [NSString stringWithUTF8String:(*iter).photoUrlMobile.c_str()];
            item.desc = [NSString stringWithUTF8String:(*iter).desc.c_str()];
            item.useRoomType = (*iter).useRoomType;
            item.anchorType = (*iter).anchorType;
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNcikName = [NSString stringWithUTF8String:(*iter).anchorNcikName.c_str()];
            item.anchorPhotoUrl = [NSString stringWithUTF8String:(*iter).anchorPhotoUrl.c_str()];
            item.grantedDate = (*iter).grantedDate;
            item.startValidDate = (*iter).startValidDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            item.offsetMin = (*iter).offsetMin;
            [array addObject:item];
        }
        
        GetChatVoucherListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], array, totalCount);
        }
    }
};
RequestGetChatVoucherListCallbackImp gRequestGetChatVoucherListCallbackImp;
- (NSInteger)getChatVoucherList:(int)start
                           step:(int)step
                  finishHandler:(GetChatVoucherListFinishHandler)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetChatVoucherList(&mHttpRequestManager, start, step, &gRequestGetChatVoucherListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 其它
LSMailPriceItemObject* getLSMailPriceItemObjectWithC(const HttpLetterPriceItem& item) {
    LSMailPriceItemObject* obj = [[LSMailPriceItemObject alloc] init];
    obj.creditPrice = item.creditPrice;
    obj.stampPrice = item.stampPrice;
    return obj;
}

LSMailTariffItemObject* getLSMailTariffItemObjectWithC(const HttpMailTariffItem& item) {
    LSMailTariffItemObject* obj = [[LSMailTariffItemObject alloc] init];
    obj.mailSendBase = getLSMailPriceItemObjectWithC(item.mailSendBase);
    obj.mailReadBase = getLSMailPriceItemObjectWithC(item.mailReadBase);
    obj.mailPhotoAttachBase = getLSMailPriceItemObjectWithC(item.mailPhotoAttachBase);
    obj.mailPhotoBuyBase = getLSMailPriceItemObjectWithC(item.mailPhotoBuyBase);
    obj.mailVideoBuyBase = getLSMailPriceItemObjectWithC(item.mailVideoBuyBase);
    return obj;
}

class RequestGetConfigCallbackImp : public IRequestGetConfigCallback {
public:
    RequestGetConfigCallbackImp(){};
    ~RequestGetConfigCallbackImp(){};
    void OnGetConfig(HttpGetConfigTask *task, bool success, int errnum, const string &errmsg, const HttpConfigItem &configItem) {
        NSLog(@"LSRequestManager::OnGetConfig( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ConfigItemObject *obj = [[ConfigItemObject alloc] init];
        obj.imSvrUrl = [NSString stringWithUTF8String:configItem.imSvrUrl.c_str()];
        obj.httpSvrUrl = [NSString stringWithUTF8String:configItem.httpSvrUrl.c_str()];
        obj.addCreditsUrl = [NSString stringWithUTF8String:configItem.addCreditsUrl.c_str()];
        obj.anchorPage = [NSString stringWithUTF8String:configItem.anchorPage.c_str()];
        obj.userLevel = [NSString stringWithUTF8String:configItem.userLevel.c_str()];
        obj.intimacy = [NSString stringWithUTF8String:configItem.intimacy.c_str()];
        obj.userProtocol = [NSString stringWithUTF8String:configItem.userProtocol.c_str()];
        obj.showDetailPage  = [NSString stringWithUTF8String:configItem.showDetailPage.c_str()];
        obj.showDescription  = [NSString stringWithUTF8String:configItem.showDescription.c_str()];
        obj.hangoutCredirMsg = [NSString stringWithUTF8String:configItem.hangoutCredirMsg.c_str()];
        obj.hangoutCreditPrice = configItem.hangoutCreditPrice;
        obj.loiH5Url = [NSString stringWithUTF8String:configItem.loiH5Url.c_str()];
        obj.emfH5Url = [NSString stringWithUTF8String:configItem.emfH5Url.c_str()];
        obj.pmStartNotice = [NSString stringWithUTF8String:configItem.pmStartNotice.c_str()];
        obj.postStampUrl = [NSString stringWithUTF8String:configItem.postStampUrl.c_str()];
        obj.httpSvrMobileUrl = [NSString stringWithUTF8String:configItem.httpSvrMobileUrl.c_str()];
        
        //alextest livechat
        obj.socketHost = [NSString stringWithUTF8String:configItem.socketHost.c_str()];
        obj.socketHostDomain = [NSString stringWithUTF8String:configItem.socketHostDomain.c_str()];
        obj.socketPort = configItem.socketPort;
        obj.webSite = obj.httpSvrUrl;//@"http://demo.latamdate.com";
        obj.appSite = obj.httpSvrUrl;//@"http://demo-mobile.latamdate.com";
        obj.chatVoiceHostUrl =  [NSString stringWithUTF8String:configItem.chatVoiceHostUrl.c_str()];
        obj.minBalanceForChat = configItem.minBalanceForChat;
        
        obj.sendLetter = [NSString stringWithUTF8String:configItem.sendLetter.c_str()];
        obj.flowersGift = configItem.flowersGift;
        obj.scheduleSaveUp = configItem.scheduleSaveUp;
        obj.mailTariff = getLSMailTariffItemObjectWithC(configItem.mailTariff);
        obj.premiumVideoCredit = configItem.premiumVideoCredit;
        obj.howItWorkUrl = [NSString stringWithUTF8String:configItem.howItWorkUrl.c_str()];
        
        
        GetConfigFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetConfigCallbackImp gRequestGetConfigCallbackImp;
- (NSInteger)getConfig:(GetConfigFinishHandler _Nullable)finishHandler {
    
    NSInteger request = (NSInteger)mHttpRequestController.GetConfig(&mConfigHttpRequestManager, &gRequestGetConfigCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetLeftCreditCallbackImp : public IRequestGetLeftCreditCallback {
public:
    RequestGetLeftCreditCallbackImp(){};
    ~RequestGetLeftCreditCallbackImp(){};
    void OnGetLeftCredit(HttpGetLeftCreditTask *task, bool success, int errnum, const string &errmsg, const HttpLeftCreditItem& leftCreditItem) {
        NSLog(@"LSRequestManager::OnGetLeftCredit( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSLeftCreditItemObject* obj = [[LSLeftCreditItemObject alloc] init];
        obj.credit = leftCreditItem.credit;
        obj.coupon = leftCreditItem.coupon;
        obj.liveChatCount = leftCreditItem.liveChatCount;
        obj.postStamp = leftCreditItem.postStamp;
        
        GetLeftCreditFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetLeftCreditCallbackImp gRequestGetLeftCreditCallbackImp;
- (NSInteger)getLeftCredit:(GetLeftCreditFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetLeftCredit(&mHttpRequestManager, &gRequestGetLeftCreditCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSetFavoriteCallbackImp : public IRequestSetFavoriteCallback {
public:
    RequestSetFavoriteCallbackImp(){};
    ~RequestSetFavoriteCallbackImp(){};
    void OnSetFavorite(HttpSetFavoriteTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSetFavorite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SetFavoriteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSetFavoriteCallbackImp gRequestSetFavoriteCallbackImp;
- (NSInteger)setFavorite:(NSString *_Nonnull)userId
                  roomId:(NSString *_Nonnull)roomId
                   isFav:(BOOL)isFav
           finishHandler:(SetFavoriteFinishHandler _Nullable)finishHandler {
    string strUserId = "";
    if (nil != userId) {
        strUserId = [userId UTF8String];
    }
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.SetFavorite(&mHttpRequestManager, strUserId, strRoomId, isFav, &gRequestSetFavoriteCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetAdAnchorListCallbackImp : public IRequestGetAdAnchorListCallback {
public:
    RequestGetAdAnchorListCallbackImp(){};
    ~RequestGetAdAnchorListCallbackImp(){};
    void OnGetAdAnchorList(HttpGetAdAnchorListTask *task, bool success, int errnum, const string &errmsg, const AdItemList &list) {
        NSLog(@"LSRequestManager::OnGetAdAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (AdItemList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            item.roomType = (*iter).roomType;
            NSMutableArray *nsInterest = [NSMutableArray array];
            //int i = 0;
            for (InterestList::const_iterator itr = (*iter).interest.begin(); itr != (*iter).interest.end(); itr++) {
                //NSString* strInterest = [NSString stringWithUTF8String:(*itr).c_str()];
                int num = (*itr);
                NSNumber *numInterest = [NSNumber numberWithInt:num];
                [nsInterest addObject:numInterest];
                //item->interest[i] = (*itr);
                //i++;
            }
            item.interest = nsInterest;
            item.anchorType = (*iter).anchorType;

            [array addObject:item];
        }
        
        GetAdAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetAdAnchorListCallbackImp gRequestGetAdAnchorListCallbackImp;
- (NSInteger)getAdAnchorList:(int)number
               finishHandler:(GetAdAnchorListFinishHandler _Nullable)finishHandler {
    
    NSInteger request = (NSInteger)mHttpRequestController.GetAdAnchorList(&mHttpRequestManager, number, &gRequestGetAdAnchorListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestCloseAdAnchorListCallbackImp : public IRequestCloseAdAnchorListCallback {
public:
    RequestCloseAdAnchorListCallbackImp(){};
    ~RequestCloseAdAnchorListCallbackImp(){};
    void OnCloseAdAnchorList(HttpCloseAdAnchorListTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnCloseAdAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        CloseAdAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestCloseAdAnchorListCallbackImp gRequestCloseAdAnchorListCallbackImp;
- (NSInteger)closeAdAnchorList:(CloseAdAnchorListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.CloseAdAnchorList(&mHttpRequestManager, &gRequestCloseAdAnchorListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetPhoneVerifyCodeCallbackImp : public IRequestGetPhoneVerifyCodeCallback {
public:
    RequestGetPhoneVerifyCodeCallbackImp(){};
    ~RequestGetPhoneVerifyCodeCallbackImp(){};
    void OnGetPhoneVerifyCode(HttpGetPhoneVerifyCodeTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnGetPhoneVerifyCode( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GetPhoneVerifyCodeFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestGetPhoneVerifyCodeCallbackImp gRequestGetPhoneVerifyCodeCallbackImp;
- (NSInteger)getPhoneVerifyCode:(NSString *_Nonnull)country
                       areaCode:(NSString *_Nonnull)areaCode
                        phoneNo:(NSString *_Nonnull)phoneNo
                  finishHandler:(GetPhoneVerifyCodeFinishHandler _Nullable)finishHandler {
    string strCountry = "";
    if (nil != country) {
        strCountry = [country UTF8String];
    }
    string strAreaCode = "";
    if (nil != areaCode) {
        strAreaCode = [areaCode UTF8String];
    }
    string strPhoneNo = "";
    if (nil != phoneNo) {
        strPhoneNo = [phoneNo UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetPhoneVerifyCode(&mHttpRequestManager, strCountry, strAreaCode, strPhoneNo, &gRequestGetPhoneVerifyCodeCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSubmitPhoneVerifyCodeCallbackImp : public IRequestSubmitPhoneVerifyCodeCallback {
public:
    RequestSubmitPhoneVerifyCodeCallbackImp(){};
    ~RequestSubmitPhoneVerifyCodeCallbackImp(){};
    void OnSubmitPhoneVerifyCode(HttpSubmitPhoneVerifyCodeTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSubmitPhoneVerifyCode( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SubmitPhoneVerifyCodeFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSubmitPhoneVerifyCodeCallbackImp gRequestSubmitPhoneVerifyCodeCallbackImp;
- (NSInteger)submitPhoneVerifyCode:(NSString *_Nonnull)country
                          areaCode:(NSString *_Nonnull)areaCode
                           phoneNo:(NSString *_Nonnull)phoneNo
                        verifyCode:(NSString *_Nonnull)verifyCode
                     finishHandler:(SubmitPhoneVerifyCodeFinishHandler _Nullable)finishHandler {
    string strCountry = "";
    if (nil != country) {
        strCountry = [country UTF8String];
    }
    string strAreaCode = "";
    if (nil != areaCode) {
        strAreaCode = [areaCode UTF8String];
    }
    string strPhoneNo = "";
    if (nil != phoneNo) {
        strPhoneNo = [phoneNo UTF8String];
    }
    string strVerifyCode = "";
    if (nil != verifyCode) {
        strVerifyCode = [verifyCode UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.SubmitPhoneVerifyCode(&mHttpRequestManager, strCountry, strAreaCode, strPhoneNo, strVerifyCode, &gRequestSubmitPhoneVerifyCodeCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestServerSpeedCallbackImp : public IRequestServerSpeedCallback {
public:
    RequestServerSpeedCallbackImp(){};
    ~RequestServerSpeedCallbackImp(){};
    void OnServerSpeed(HttpServerSpeedTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"RequestManager::OnServerSpeed( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ServerSpeedFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestServerSpeedCallbackImp gRequestServerSpeedCallbackImp;
- (NSInteger)serverSpeed:(NSString *_Nonnull)sid
                     res:(int)res
              liveRoomId:(NSString *_Nullable)liveRoomId
           finishHandler:(ServerSpeedFinishHandler _Nullable)finishHandler {
    string strSid = "";
    if (nil != sid) {
        strSid = [sid UTF8String];
    }
    string strLiveRoomId = "";
    if (nil != liveRoomId) {
        strLiveRoomId = [liveRoomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ServerSpeed(&mHttpRequestManager, strSid, res, strLiveRoomId, &gRequestServerSpeedCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestBannerCallbackImp : public IRequestBannerCallback {
public:
    RequestBannerCallbackImp(){};
    ~RequestBannerCallbackImp(){};
    void OnBanner(HttpBannerTask *task, bool success, int errnum, const string &errmsg, const string &bannerImg, const string &bannerLink, const string &bannerName) {
        NSLog(@"LSRequestManager::OnBanner( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        BannerFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:bannerImg.c_str()], [NSString stringWithUTF8String:bannerLink.c_str()], [NSString stringWithUTF8String:bannerName.c_str()]);
        }
    }
};
RequestBannerCallbackImp gRequestBannerCallbackImp;
- (NSInteger)banner:(BannerFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.Banner(&mHttpRequestManager, &gRequestBannerCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetUserInfoCallbackImp : public IRequestGetUserInfoCallback {
public:
    RequestGetUserInfoCallbackImp(){};
    ~RequestGetUserInfoCallbackImp(){};
    void OnGetUserInfo(HttpGetUserInfoTask* task, bool success, int errnum, const string& errmsg, const HttpUserInfoItem& userItem) {
        NSLog(@"LSRequestManager::OnGetUserInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSUserInfoItemObject * item  = [[LSUserInfoItemObject alloc] init];
        item.userId = [NSString stringWithUTF8String:userItem.userId.c_str()];
        item.nickName = [NSString stringWithUTF8String:userItem.nickName.c_str()];
        item.photoUrl = [NSString stringWithUTF8String:userItem.photoUrl.c_str()];
        item.age = userItem.age;
        item.country = [NSString stringWithUTF8String:userItem.country.c_str()];
        item.userLevel = userItem.userLevel;
        item.isOnline = userItem.isOnline;
        item.isAnchor = userItem.isAnchor;
        item.leftCredit = userItem.leftCredit;
        LSAnchorInfoItemObject * anchorItem = [[LSAnchorInfoItemObject alloc] init];
        anchorItem.address = [NSString stringWithUTF8String:userItem.anchorInfo.address.c_str()];
        anchorItem.anchorType = userItem.anchorInfo.anchorType;
        anchorItem.isLive = userItem.anchorInfo.isLive;
        anchorItem.introduction = [NSString stringWithUTF8String:userItem.anchorInfo.introduction.c_str()];
        anchorItem.roomPhotoUrl = [NSString stringWithUTF8String:userItem.anchorInfo.roomPhotoUrl.c_str()];
        LSAnchorPrivItemObject * anchorPriv = [[LSAnchorPrivItemObject alloc] init];
        anchorPriv.scheduleOneOnOneRecvPriv = userItem.anchorInfo.anchorPriv.scheduleOneOnOneRecvPriv;
        anchorPriv.scheduleOneOnOneSendPriv = userItem.anchorInfo.anchorPriv.scheduleOneOnOneSendPriv;
        anchorItem.anchorPriv = anchorPriv;
        item.anchorInfo = anchorItem;
        LSFansiInfoItemObject * fansiItem = [[LSFansiInfoItemObject alloc] init];
        LSFansiPrivItemObject * fansiPriv = [[LSFansiPrivItemObject alloc] init];
        fansiPriv.premiumVideoPriv = userItem.fansiInfo.fansiPriv.premiumVideoPriv;
        fansiItem.fansiPriv = fansiPriv;
        item.fansiInfo = fansiItem;

        GetUserInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};

RequestGetUserInfoCallbackImp gRequestGetUserInfoCallbackImp;
- (NSInteger)getUserInfo:(NSString * _Nonnull) userId
           finishHandler:(GetUserInfoFinishHandler _Nullable)finishHandler {
    string strUserId = "";
    if (nil != userId) {
        strUserId = [userId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetUserInfo(&mHttpRequestManager, strUserId, &gRequestGetUserInfoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetTotalNoreadNumCallbackImp : public IRequestGetTotalNoreadNumCallback {
public:
    RequestGetTotalNoreadNumCallbackImp(){};
    ~RequestGetTotalNoreadNumCallbackImp(){};
    void OnGetTotalNoreadNum(HttpGetTotalNoreadNumTask* task, bool success, int errnum, const string& errmsg, const HttpMainNoReadNumItem& item){
        NSLog(@"LSRequestManager::OnGetTotalNoreadNum( task : %p, success : %s, errnum : %d, errmsg : %s showTicketUnreadNum:%d loiUnreadNum:%d emfUnreadNum:%d privateMessageUnreadNum:%d bookingUnreadNum:%d backpackUnreadNum:%d)", task, success ? "true" : "false", errnum, errmsg.c_str(), item.showTicketUnreadNum, item.loiUnreadNum, item.emfUnreadNum, item.privateMessageUnreadNum, item.bookingUnreadNum, item.backpackUnreadNum);
        
        LSMainUnreadNumItemObject * obj  = [[LSMainUnreadNumItemObject alloc] init];
        obj.showTicketUnreadNum = item.showTicketUnreadNum;
        obj.loiUnreadNum = item.loiUnreadNum;
        obj.emfUnreadNum = item.emfUnreadNum;
        obj.privateMessageUnreadNum = item.privateMessageUnreadNum;
        obj.bookingUnreadNum = item.bookingUnreadNum;
        obj.backpackUnreadNum = item.backpackUnreadNum;
        obj.sayHiResponseUnreadNum = item.sayHiResponseUnreadNum;
        obj.livechatVocherUnreadNum = item.livechatVocherUnreadNum;
        obj.schedulePendingUnreadNum = item.schedulePendingUnreadNum;
        obj.scheduleConfirmedUnreadNum = item.scheduleConfirmedUnreadNum;
        obj.scheduleStatus = item.scheduleStatus;
        obj.requestReplyUnreadNum = item.requestReplyUnreadNum;
        
        GetTotalNoreadNumFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestGetTotalNoreadNumCallbackImp gRequestGetTotalNoreadNumCallbackImp;
- (NSInteger)getTotalNoreadNum:(GetTotalNoreadNumFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetTotalNoreadNum(&mHttpRequestManager, &gRequestGetTotalNoreadNumCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetMyProfileCallbackImp : public IRequestGetMyProfileCallback {
public:
    RequestGetMyProfileCallbackImp(){};
    ~RequestGetMyProfileCallbackImp(){};
    void OnGetMyProfile(HttpGetMyProfileTask* task, bool success, const string& errnum, const string& errmsg, const HttpProfileItem& profileItem) {
        NSLog(@"LSRequestManager::OnGetMyProfile( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        LSPersonalProfileItemObject * obj  = [[LSPersonalProfileItemObject alloc] init];
        NSMutableArray *interestsArray = [NSMutableArray array];
        obj.manId = [NSString stringWithUTF8String:profileItem.manid.c_str()];
        obj.age = profileItem.age;
        obj.birthday = [NSString stringWithUTF8String:profileItem.birthday.c_str()];
        obj.firstname = [NSString stringWithUTF8String:profileItem.firstname.c_str()];
        obj.lastname = [NSString stringWithUTF8String:profileItem.lastname.c_str()];
        obj.email = [NSString stringWithUTF8String:profileItem.email.c_str()];
        obj.gender = profileItem.gender;
        obj.country = profileItem.country;
        obj.marry = profileItem.marry;
        obj.height = profileItem.height;
        obj.weight = profileItem.weight;
        obj.smoke = profileItem.smoke;
        obj.drink = profileItem.drink;
        obj.language = profileItem.language;
        obj.religion = profileItem.religion;
        obj.education = profileItem.education;
        obj.profession = profileItem.profession;
        obj.ethnicity = profileItem.ethnicity;
        obj.income = profileItem.income;
        obj.children = profileItem.children;
        obj.resume = [NSString stringWithUTF8String:profileItem.resume.c_str()];
        obj.resume_content = [NSString stringWithUTF8String:profileItem.resume_content.c_str()];
        obj.resume_status = profileItem.resume_status;
        obj.address1 = [NSString stringWithUTF8String:profileItem.address1.c_str()];
        obj.address2 = [NSString stringWithUTF8String:profileItem.address2.c_str()];
        obj.city = [NSString stringWithUTF8String:profileItem.city.c_str()];
        obj.province = [NSString stringWithUTF8String:profileItem.province.c_str()];
        obj.zipcode = [NSString stringWithUTF8String:profileItem.zipcode.c_str()];
        obj.telephone = [NSString stringWithUTF8String:profileItem.telephone.c_str()];
        obj.fax = [NSString stringWithUTF8String:profileItem.fax.c_str()];
        obj.alternate_email = [NSString stringWithUTF8String:profileItem.alternate_email.c_str()];
        obj.money = [NSString stringWithUTF8String:profileItem.money.c_str()];
        obj.v_id = profileItem.v_id;
        obj.photoStatus = profileItem.photo;
        obj.photoUrl = [NSString stringWithUTF8String:profileItem.photoURL.c_str()];
        obj.integral = profileItem.integral;
        obj.mobile = [NSString stringWithUTF8String:profileItem.mobile.c_str()];
        obj.mobileZoom = profileItem.mobile_cc;
        obj.mobileStatus = profileItem.mobile_status;
        obj.landline = [NSString stringWithUTF8String:profileItem.landline.c_str()];
        obj.landlineZoom = profileItem.landline_cc;
        obj.landlineLocation = [NSString stringWithUTF8String:profileItem.landline_ac.c_str()];
        obj.landlineStatus = profileItem.landline_status;
        obj.zodiac = profileItem.zodiac;
        
        for (list<string>::const_iterator itr = profileItem.interests.begin(); itr != profileItem.interests.end(); itr++) {
            [interestsArray addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        obj.interests = interestsArray;
        
        GetMyProfileFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestGetMyProfileCallbackImp gRequestGetMyProfileCallbackImp;

- (NSInteger)getMyProfile:(GetMyProfileFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetMyProfile(&mNewHttpRequestManager, &gRequestGetMyProfileCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestUpdateProfileCallbackImp : public IRequestUpdateProfileCallback {
public:
    RequestUpdateProfileCallbackImp(){};
    ~RequestUpdateProfileCallbackImp(){};
    void OnUpdateProfile(HttpUpdateProfileTask* task, bool success, const string& errnum, const string& errmsg, bool isModify) {
        NSLog(@"LSRequestManager::OnUpdateProfile( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        UpdateProfileFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()], isModify);
        }
    }
};

RequestUpdateProfileCallbackImp gRequestUpdateProfileCallbackImp;

- (NSInteger)updateProfile:(int)weight
                    height:(int)height
                  language:(int)language
                 ethnicity:(int)ethnicity
                  religion:(int)religion
                 education:(int)education
                profession:(int)profession
                    income:(int)income
                  children:(int)children
                     smoke:(int)smoke
                     drink:(int)drink
                    resume:(NSString * _Nullable)resume
                 interests:(NSArray * _Nullable) interests
                    zodiac:(int)zodiac
                    finish:(UpdateProfileFinishHandler _Nullable)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strResume = "";
    if (nil != resume) {
        strResume = [resume UTF8String];
    }
    list<string> strList;
    for (NSString *str in interests) {
        const char *pStr = [str UTF8String];
        strList.push_back(pStr);
    }
    request = (NSInteger)mHttpRequestController.UpdateProfile(&mNewHttpRequestManager, weight, height, language, ethnicity, religion, education, profession, income, children, smoke, drink, strResume, strList, zodiac, &gRequestUpdateProfileCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestVersionCheckCallbackImp : public IRequestVersionCheckCallback {
public:
    RequestVersionCheckCallbackImp(){};
    ~RequestVersionCheckCallbackImp(){};
    void OnVersionCheck(HttpVersionCheckTask* task, bool success, const string& errnum, const string& errmsg, const HttpVersionCheckItem& versionItem) {
        NSLog(@"LSRequestManager::OnVersionCheck( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        LSVersionItemObject * obj = [[LSVersionItemObject alloc] init];
        obj.versionCode = versionItem.versionCode;
        obj.versionName = [NSString stringWithUTF8String:versionItem.versionName.c_str()];
        obj.versionDesc = [NSString stringWithUTF8String:versionItem.versionDesc.c_str()];
        obj.isForceUpdate = versionItem.isForceUpdate;
        obj.url = [NSString stringWithUTF8String:versionItem.url.c_str()];
        obj.storeUrl = [NSString stringWithUTF8String:versionItem.storeUrl.c_str()];
        obj.pubTime = [NSString stringWithUTF8String:versionItem.pubTime.c_str()];
        obj.checkTime = versionItem.checkTime;
        
        
        VersionCheckFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestVersionCheckCallbackImp gRequestVersionCheckCallbackImp;

- (NSInteger)versionCheck:(int)currVersion
                   finish:(VersionCheckFinishHandler _Nullable)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.VersionCheck(&mNewHttpRequestManager, currVersion, &gRequestVersionCheckCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestStartEditResumeCallbackImp : public IRequestStartEditResumeCallback {
public:
    RequestStartEditResumeCallbackImp(){};
    ~RequestStartEditResumeCallbackImp(){};
    void OnStartEditResume(HttpStartEditResumeTask* task, bool success, const string& errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnStartEditResume( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        StartEditResumeFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestStartEditResumeCallbackImp gRequestStartEditResumeCallbackImp;

- (NSInteger)startEditResume:(StartEditResumeFinishHandler _Nullable)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.StartEditResume(&mNewHttpRequestManager, &gRequestStartEditResumeCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestPhoneInfoCallbackImp : public IRequestPhoneInfoCallback {
public:
    RequestPhoneInfoCallbackImp(){};
    ~RequestPhoneInfoCallbackImp(){};
    void OnPhoneInfo(HttpPhoneInfoTask* task, bool success, const string& errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnPhoneInfo( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        PhoneInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, GetStringToHttpErrorType(errnum), [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestPhoneInfoCallbackImp gRequestPhoneInfoCallbackImp;

- (NSInteger)phoneInfo:(LSPhoneInfoObject *)phoneInfo
         finishHandler:(PhoneInfoFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.PhoneInfo(&mNewHttpRequestManager,
                                                          phoneInfo.manId != nil ? [phoneInfo.manId UTF8String] : "",
                                                          phoneInfo.verCode,
                                                          phoneInfo.verName != nil ? [phoneInfo.verName UTF8String] : "",
                                                          phoneInfo.action,
                                                          phoneInfo.siteId,
                                                          phoneInfo.density,
                                                          phoneInfo.width,
                                                          phoneInfo.height,
                                                          phoneInfo.densityDpi != nil ? [phoneInfo.densityDpi UTF8String] : "",
                                                          phoneInfo.model != nil ? [phoneInfo.model UTF8String] : "",
                                                          phoneInfo.manufacturer != nil ? [phoneInfo.manufacturer UTF8String] : "",
                                                          phoneInfo.osType != nil ? [phoneInfo.osType UTF8String] : "",
                                                          phoneInfo.releaseVer != nil ? [phoneInfo.releaseVer UTF8String] : "",
                                                          phoneInfo.sdk != nil ? [phoneInfo.sdk UTF8String] : "",
                                                          phoneInfo.language != nil ? [phoneInfo.language UTF8String] : "",
                                                          phoneInfo.country != nil ? [phoneInfo.country UTF8String] : "",
                                                          phoneInfo.lineNumber != nil ? [phoneInfo.lineNumber UTF8String] : "",
                                                          phoneInfo.simOptName != nil ? [phoneInfo.simOptName UTF8String] : "",
                                                          phoneInfo.simOpt != nil ? [phoneInfo.simOpt UTF8String] : "",
                                                          phoneInfo.simCountryIso != nil ? [phoneInfo.simCountryIso UTF8String] : "",
                                                          phoneInfo.simState != nil ? [phoneInfo.simState UTF8String] : "",
                                                          phoneInfo.phoneType,
                                                          phoneInfo.networkType,
                                                          phoneInfo.deviceId != nil ? [phoneInfo.deviceId UTF8String] : "",
                                                          &gRequestPhoneInfoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestPushPullLogsCallbackImp : public IRequestPushPullLogsCallback {
public:
    RequestPushPullLogsCallbackImp(){};
    ~RequestPushPullLogsCallbackImp(){};
    void OnPushPullLogs(HttpPushPullLogsTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnPushPullLogs( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        PushPullLogsFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestPushPullLogsCallbackImp gRequestPushPullLogsCallbackImp;

- (NSInteger)pushPullLogs:(NSString *)liveRoomId
            finishHandler:(PushPullLogsFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strLiveRoomId = "";
    if (nil != liveRoomId) {
        strLiveRoomId = [liveRoomId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.PushPullLogs(&mHttpRequestManager, strLiveRoomId, &gRequestPushPullLogsCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}



#pragma mark - IOS买点
class RequestIOSGetPayCallbackImp : public IRequestIOSGetPayCallback {
public:
    RequestIOSGetPayCallbackImp(){};
    ~RequestIOSGetPayCallbackImp(){};
    void OnIOSGetPay(HttpIOSGetPayTask* task, bool success, const string& code, const string& orderNo, const string& productId) {
        NSLog(@"LSRequestManager::OnGetIOSPay( task : %p, success : %s, code : %s orderNo : %s productId :%s )", task, success ? "true" : "false", code.c_str(), orderNo.c_str(), productId.c_str());
        
        GetIOSPayFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [NSString stringWithUTF8String:code.c_str()], [NSString stringWithUTF8String:orderNo.c_str()], [NSString stringWithUTF8String:productId.c_str()]);
        }
    }
};

RequestIOSGetPayCallbackImp gRequestIOSGetPayCallbackImp;

- (NSInteger)getIOSPay:(NSString * _Nonnull) manid
                   sid:(NSString * _Nonnull) sid
                number:(NSString * _Nonnull) number
         finishHandler:(GetIOSPayFinishHandler _Nullable)finishHandler {
    string manidStr = (manid == nil ? "" : [manid UTF8String]);
    string sidStr = (sid == nil ? "" : [sid UTF8String]);
    string numberStr = (number == nil ? "" : [number UTF8String]);
    NSInteger request = (NSInteger)mHttpRequestController.IOSGetPay(&mNewHttpRequestManager, manidStr, sidStr, numberStr,  &gRequestIOSGetPayCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestIOSCheckPayCallCallbackImp : public IRequestIOSCheckPayCallCallback {
public:
    RequestIOSCheckPayCallCallbackImp(){};
    ~RequestIOSCheckPayCallCallbackImp(){};
    void OnIOSCheckPayCall(HttpIOSCheckPayCallTask* task, bool success, const string& code) {
        NSLog(@"LSRequestManager::OnGetIOSPay( task : %p, success : %s, code : %s )", task, success ? "true" : "false", code.c_str());
        
        IOSPayCallFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [NSString stringWithUTF8String:code.c_str()]);
        }
    }
};

RequestIOSCheckPayCallCallbackImp gRequestIOSCheckPayCallCallbackImp;


- (NSInteger)iOSPayCall:(NSString * _Nonnull) manid
                    sid:(NSString * _Nonnull) sid
                receipt:(NSString * _Nonnull) receipt
                orderNo:(NSString * _Nonnull) orderNo
                   code:(AppStorePayCodeType) code
          finishHandler:(IOSPayCallFinishHandler _Nullable)finishHandler{
    string manidStr = (manid == nil ? "" : [manid UTF8String]);
    string sidStr = (sid == nil ? "" : [sid UTF8String]);
    string receiptStr = (receipt == nil ? "" : [receipt UTF8String]);
    string orderNoStr = (orderNo == nil ? "" : [orderNo UTF8String]);
    NSInteger request = (NSInteger)mHttpRequestController.IOSCheckPayCall(&mNewHttpRequestManager, manidStr, sidStr, receiptStr, orderNoStr, code, &gRequestIOSCheckPayCallCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestIOSPremiumMemberShipCallbackImp : public IRequestIOSPremiumMemberShipCallback {
public:
    RequestIOSPremiumMemberShipCallbackImp(){};
    ~RequestIOSPremiumMemberShipCallbackImp(){};
    void OnIOSPremiumMemberShip(HttpIOSPremiumMemberShipTask* task, bool success, const string& errnum, const string& errmsg, const HttpOrderProductItem& productItem) {
        NSLog(@"LSRequestManager::OnPremiumMembership( task : %p, success : %s, errnum : %s, errmsg : %s )", task, success ? "true" : "false", errnum.c_str(), errmsg.c_str());
        
        LSOrderProductItemObject * item  = [[LSOrderProductItemObject alloc] init];
        NSMutableArray *arrayProduct = [NSMutableArray array];
        for (ProductItemList::const_iterator iter = productItem.list.begin(); iter != productItem.list.end(); iter++) {
            LSProductItemObject *objProduct = [[LSProductItemObject alloc] init];
            objProduct.productId = [NSString stringWithUTF8String:(*iter).productId.c_str()];
            objProduct.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            objProduct.price = [NSString stringWithUTF8String:(*iter).price.c_str()];
            [arrayProduct addObject:objProduct];
        }
        item.list = arrayProduct;
        
        item.desc = [NSString stringWithUTF8String:productItem.desc.c_str()];
        item.more = [NSString stringWithUTF8String:productItem.more.c_str()];
        item.title = [NSString stringWithUTF8String:productItem.title.c_str()];
        item.subTitle = [NSString stringWithUTF8String:productItem.subTitle.c_str()];
        
        PremiumMembershipFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};

RequestIOSPremiumMemberShipCallbackImp gRequestIOSPremiumMemberShipCallbackImp;

- (NSInteger)premiumMembership:(PremiumMembershipFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.IOSPremiumMemberShip(&mNewHttpRequestManager, &gRequestIOSPremiumMemberShipCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestMobilePayGotoCallbackImp : public IRequestMobilePayGotoCallback {
public:
    RequestMobilePayGotoCallbackImp(){};
    ~RequestMobilePayGotoCallbackImp(){}; 
    void OnMobilePayGoto(HttpMobilePayGotoTask* task, bool success, int errnum, const string& errmsg, const string& redirect) {
        NSLog(@"LSRequestManager::OnMobilePayGoto( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());

        MobilePayGotoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:redirect.c_str()]);
        }
    }
};

RequestMobilePayGotoCallbackImp gRequestMobilePayGotoCallbackImp;

- (NSInteger)mobilePayGoto:(LSOrderType)orderType
                 clickFrom:(NSString *)clickFrom
                    number:(NSString *)number
                   orderNo:(NSString *)orderNo
             finishHandler:(MobilePayGotoFinishHandler)finishHandler {
    string strClickFrom = "";
    if (nil != clickFrom) {
        strClickFrom = [clickFrom UTF8String];
    }
    string strNumber = "";
    if (nil != number) {
        strNumber = [number UTF8String];
    }
    string strOrderNo = "";
    if (nil != orderNo) {
        strOrderNo = [orderNo UTF8String];
    }
    string strUrl = "/app?siteid=";
    HTTP_OTHER_SITE_TYPE siteId = HTTP_OTHER_SITE_PAYMENT;
    NSInteger request = (NSInteger)mHttpRequestController.MobilePayGoto(&mHttpRequestManager ,
                                                                       strUrl,
                                                                       siteId,
                                                                       orderType,
                                                                       strClickFrom,
                                                                       strNumber,
                                                                       strOrderNo,
                                                                       &gRequestMobilePayGotoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 多人互动
class RequestGetCanHangoutAnchorListCallbackImp : public IRequestGetCanHangoutAnchorListCallback {
public:
    RequestGetCanHangoutAnchorListCallbackImp(){};
    ~RequestGetCanHangoutAnchorListCallbackImp(){};
    void OnGetCanHangoutAnchorList(HttpGetCanHangoutAnchorListTask* task, bool success, int errnum, const string& errmsg, const HangoutAnchorList& list) {
        NSLog(@"LSRequestManager::OnGetCanHangoutAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        NSMutableArray* array = [NSMutableArray array];
        for(HangoutAnchorList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSHangoutAnchorItemObject* item = [[LSHangoutAnchorItemObject alloc] init];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.age = (*iter).age;
            item.country = [NSString stringWithUTF8String:(*iter).country.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            
            [array addObject:item];
        }
        
        GetCanHangoutAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetCanHangoutAnchorListCallbackImp gRequestGetCanHangoutAnchorListCallbackImp;
- (NSInteger)getCanHangoutAnchorList:(HangoutAnchorListType)type
                            anchorId:(NSString *_Nullable)anchorId
                               start:(int)start
                                step:(int)step
                       finishHandler:(GetCanHangoutAnchorListFinishHandler _Nullable)finishHandler {
    string strAnchorId = "";
    if (nil != anchorId) {
        strAnchorId = [anchorId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetCanHangoutAnchorList(&mHttpRequestManager, type, strAnchorId, start, step, &gRequestGetCanHangoutAnchorListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSendInvitationHangoutCallbackImp : public IRequestSendInvitationHangoutCallback {
public:
    RequestSendInvitationHangoutCallbackImp(){};
    ~RequestSendInvitationHangoutCallbackImp(){};
    void OnSendInvitationHangout(HttpSendInvitationHangoutTask* task, bool success, int errnum, const string& errmsg, const string& roomId, const string& inviteId, int expire) {
        NSLog(@"LSRequestManager::OnSendInvitationHangout( task : %p, success : %s, errnum : %d, errmsg : %s roomId:%s inviteId:%s, expire:%d)", task, success ? "true" : "false", errnum, errmsg.c_str(), roomId.c_str(), inviteId.c_str(), expire);
        
        SendInvitationHangoutFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:roomId.c_str()], [NSString stringWithUTF8String:inviteId.c_str()], expire);
        }
    }
};
RequestSendInvitationHangoutCallbackImp gRequestSendInvitationHangoutCallbackImp;
- (NSInteger)sendInvitationHangout:(NSString *_Nullable)roomId
                          anchorId:(NSString *_Nullable)anchorId
                       recommendId:(NSString *_Nullable)recommendId
                      isCreateOnly:(BOOL)isCreateOnly
                     finishHandler:(SendInvitationHangoutFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    string strAnchorId = "";
    if (nil != anchorId) {
        strAnchorId = [anchorId UTF8String];
    }
    string strRecommendId = "";
    if (nil != recommendId) {
        strRecommendId = [recommendId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.SendInvitationHangout(&mHttpRequestManager, strRoomId, strAnchorId, strRecommendId, isCreateOnly, &gRequestSendInvitationHangoutCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestCancelInviteHangoutCallbackImp : public IRequestCancelInviteHangoutCallback {
public:
    RequestCancelInviteHangoutCallbackImp(){};
    ~RequestCancelInviteHangoutCallbackImp(){};
    void OnCancelInviteHangout(HttpCancelInviteHangoutTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnCancelInviteHangout( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        CancelInviteHangoutFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestCancelInviteHangoutCallbackImp gRequestCancelInviteHangoutCallbackImp;
- (NSInteger)cancelInviteHangout:(NSString *_Nullable)inviteId
                   finishHandler:(CancelInviteHangoutFinishHandler _Nullable)finishHandler {
    string strInviteId = "";
    if (nil != inviteId) {
        strInviteId = [inviteId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.CancelInviteHangout(&mHttpRequestManager, strInviteId, &gRequestCancelInviteHangoutCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetHangoutInvitStatusCallbackImp : public IRequestGetHangoutInvitStatusCallback {
public:
    RequestGetHangoutInvitStatusCallbackImp(){};
    ~RequestGetHangoutInvitStatusCallbackImp(){};
    void OnGetHangoutInvitStatus(HttpGetHangoutInvitStatusTask* task, bool success, int errnum, const string& errmsg, HangoutInviteStatus status, const string& roomId, int expire) {
        NSLog(@"LSRequestManager::OnGetHangoutInvitStatus( task : %p, success : %s, errnum : %d, errmsg : %s, status:%d, roomId;%s, expire:%d)", task, success ? "true" : "false", errnum, errmsg.c_str(), status, roomId.c_str(), expire);
        
        GetHangoutInvitStatusFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], status, [NSString stringWithUTF8String:roomId.c_str()], expire);
        }
    }
};
RequestGetHangoutInvitStatusCallbackImp gRequestGetHangoutInvitStatusCallbackImp;
- (NSInteger)getHangoutInvitStatus:(NSString *_Nullable)inviteId
                     finishHandler:(GetHangoutInvitStatusFinishHandler _Nullable)finishHandler {
    string strInviteId = "";
    if (nil != inviteId) {
        strInviteId = [inviteId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetHangoutInvitStatus(&mHttpRequestManager, strInviteId, &gRequestGetHangoutInvitStatusCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestDealKnockRequestCallbackImp : public IRequestDealKnockRequestCallback {
public:
    RequestDealKnockRequestCallbackImp(){};
    ~RequestDealKnockRequestCallbackImp(){};
    void OnDealKnockRequest(HttpDealKnockRequestTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnDealKnockRequest( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        DealKnockRequestFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestDealKnockRequestCallbackImp gRequestDealKnockRequestCallbackImp;
- (NSInteger)dealKnockRequest:(NSString *_Nullable)knockId
                finishHandler:(DealKnockRequestFinishHandler _Nullable)finishHandler {
    string strKnockId = "";
    if (nil != knockId) {
        strKnockId = [knockId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.DealKnockRequest(&mHttpRequestManager, strKnockId, &gRequestDealKnockRequestCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetHangoutGiftListCallbackImp : public IRequestGetHangoutGiftListCallback {
public:
    RequestGetHangoutGiftListCallbackImp(){};
    ~RequestGetHangoutGiftListCallbackImp(){};
    void OnGetHangoutGiftList(HttpGetHangoutGiftListTask* task, bool success, int errnum, const string& errmsg, const HttpHangoutGiftListItem& item) {
        NSLog(@"LSRequestManager::OnGetHangoutGiftList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSHangoutGiftListObject* obj = [[LSHangoutGiftListObject alloc] init];
        NSMutableArray* buyforArray = [NSMutableArray array];
        for(BuyForGiftList::const_iterator itr = item.buyforList.begin(); itr != item.buyforList.end(); itr++) {
            NSString* giftId = [NSString stringWithUTF8String:(*itr).c_str()];
            [buyforArray addObject:giftId];
        }
        obj.buyforList = buyforArray;
        
        NSMutableArray* normalArray = [NSMutableArray array];
        for(BuyForGiftList::const_iterator itr = item.normalList.begin(); itr != item.normalList.end(); itr++) {
            NSString* giftId = [NSString stringWithUTF8String:(*itr).c_str()];
            [normalArray addObject:giftId];
        }
        obj.normalList = normalArray;
        
        NSMutableArray* celebrationArray = [NSMutableArray array];
        for(BuyForGiftList::const_iterator itr = item.celebrationList.begin(); itr != item.celebrationList.end(); itr++) {
            NSString* giftId = [NSString stringWithUTF8String:(*itr).c_str()];
            [celebrationArray addObject:giftId];
        }
        obj.celebrationList = celebrationArray;
        
        GetHangoutGiftListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetHangoutGiftListCallbackImp gRequestGetHangoutGiftListCallbackImp;
- (NSInteger)getHangoutGiftList:(NSString *_Nullable)roomId
                  finishHandler:(GetHangoutGiftListFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetHangoutGiftList(&mHttpRequestManager, strRoomId, &gRequestGetHangoutGiftListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    return request;
}

class RequestGetHangoutOnlineAnchorCallbackImp : public IRequestGetHangoutOnlineAnchorCallback {
public:
    RequestGetHangoutOnlineAnchorCallbackImp(){};
    ~RequestGetHangoutOnlineAnchorCallbackImp(){};
    void OnGetHangoutOnlineAnchor(HttpGetHangoutOnlineAnchorTask* task, bool success, int errnum, const string& errmsg, const HttpHangoutList& list) {
        NSLog(@"LSRequestManager::OnGetHangoutOnlineAnchor( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
    
        NSMutableArray* array = [NSMutableArray array];
        for(HttpHangoutList::const_iterator itr = list.begin(); itr != list.end(); itr++) {
            LSHangoutListItemObject* obj = [[LSHangoutListItemObject alloc] init];
            obj.anchorId = [NSString stringWithUTF8String:(*itr).anchorId.c_str()];
            obj.nickName = [NSString stringWithUTF8String:(*itr).nickName.c_str()];
            obj.avatarImg = [NSString stringWithUTF8String:(*itr).avatarImg.c_str()];
            obj.coverImg = [NSString stringWithUTF8String:(*itr).coverImg.c_str()];
            obj.onlineStatus = (*itr).onlineStatus;
            obj.friendsNum = (*itr).friendsNum;
            obj.invitationMsg = [NSString stringWithUTF8String:(*itr).invitationMsg.c_str()];
            NSMutableArray* friendsArray = [NSMutableArray array];
            for(HttpFriendsInfoList::const_iterator itrer = (*itr).friendsInfoList.begin(); itrer != (*itr).friendsInfoList.end(); itrer++) {
                LSFriendsInfoItemObject* friendsobj = [[LSFriendsInfoItemObject alloc] init];
                friendsobj.anchorId = [NSString stringWithUTF8String:(*itrer).anchorId.c_str()];
                friendsobj.nickName = [NSString stringWithUTF8String:(*itrer).nickName.c_str()];
                friendsobj.anchorImg = [NSString stringWithUTF8String:(*itrer).anchorImg.c_str()];
                friendsobj.coverImg = [NSString stringWithUTF8String:(*itrer).coverImg.c_str()];
                [friendsArray addObject:friendsobj];
            }
            obj.friendsInfoList = friendsArray;
            [array addObject:obj];
        }
        
        
        GetHangoutOnlineAnchorFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetHangoutOnlineAnchorCallbackImp gRequestGetHangoutOnlineAnchorCallbackImp;
- (NSInteger)getHangoutOnlineAnchor:(GetHangoutOnlineAnchorFinishHandler )finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetHangoutOnlineAnchor(&mHttpRequestManager, &gRequestGetHangoutOnlineAnchorCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    return request;
}

class RequestGetHangoutFriendsCallbackImp : public IRequestGetHangoutFriendsCallback {
public:
    RequestGetHangoutFriendsCallbackImp(){};
    ~RequestGetHangoutFriendsCallbackImp(){};
    void OnGetHangoutFriends(HttpGetHangoutFriendsTask* task, bool success, int errnum, const string& errmsg, const string& anchorId, const HangoutAnchorList& list) {
        NSLog(@"LSRequestManager::OnGetHangoutFriends( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        NSString* strAnchorId = [NSString stringWithUTF8String:anchorId.c_str()];
        NSMutableArray* array = [NSMutableArray array];
        for(HangoutAnchorList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSHangoutAnchorItemObject* item = [[LSHangoutAnchorItemObject alloc] init];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.avatarImg = [NSString stringWithUTF8String:(*iter).avatarImg.c_str()];
            item.age = (*iter).age;
            item.country = [NSString stringWithUTF8String:(*iter).country.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            
            [array addObject:item];
        }
        
        GetHangoutFriendsFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], strAnchorId, array);
        }
    }
};
RequestGetHangoutFriendsCallbackImp gRequestGetHangoutFriendsCallbackImp;
- (NSInteger)getHangoutFriends:(NSString *)anchorId
                 finishHandler:(GetHangoutFriendsFinishHandler)finishHandler {
    string strAnchorId = "";
    if (nil != anchorId) {
        strAnchorId = [anchorId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetHangoutFriends(&mHttpRequestManager, strAnchorId, &gRequestGetHangoutFriendsCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestAutoInvitationHangoutLiveDisplayCallbackImp : public IRequestAutoInvitationHangoutLiveDisplayCallback {
public:
    RequestAutoInvitationHangoutLiveDisplayCallbackImp(){};
    ~RequestAutoInvitationHangoutLiveDisplayCallbackImp(){};
    void OnAutoInvitationHangoutLiveDisplay(HttpAutoInvitationHangoutLiveDisplayTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnAutoInvitationHangoutLiveDisplay( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        AutoInvitationHangoutLiveDisplayFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestAutoInvitationHangoutLiveDisplayCallbackImp gRequestAutoInvitationHangoutLiveDisplayCallbackImp;
- (NSInteger)autoInvitationHangoutLiveDisplay:(NSString *)anchorId
                                       isAuto:(BOOL)isAuto
                                finishHandler:(AutoInvitationHangoutLiveDisplayFinishHandler)finishHandler {
    string strAnchorId = "";
    if (nil != anchorId) {
        strAnchorId = [anchorId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.AutoInvitationHangoutLiveDisplay(&mHttpRequestManager, strAnchorId, isAuto, &gRequestAutoInvitationHangoutLiveDisplayCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestAutoInvitationClickLogCallbackImp : public IRequestAutoInvitationClickLogCallback {
public:
    RequestAutoInvitationClickLogCallbackImp(){};
    ~RequestAutoInvitationClickLogCallbackImp(){};
    void OnAutoInvitationClickLog(HttpAutoInvitationClickLogTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnAutoInvitationClickLog( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        AutoInvitationClickLogFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestAutoInvitationClickLogCallbackImp gRequestAutoInvitationClickLogCallbackImp;
- (NSInteger)autoInvitationClickLog:(NSString *)anchorId
                             isAuto:(BOOL)isAuto
                      finishHandler:(AutoInvitationClickLogFinishHandler)finishHandler {
    string strAnchorId = "";
    if (nil != anchorId) {
        strAnchorId = [anchorId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.AutoInvitationClickLog(&mHttpRequestManager, strAnchorId, isAuto, &gRequestAutoInvitationClickLogCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetHangoutStatusCallbackImp : public IRequestGetHangoutStatusCallback {
public:
    RequestGetHangoutStatusCallbackImp(){};
    ~RequestGetHangoutStatusCallbackImp(){};
    void OnGetHangoutStatus(HttpGetHangoutStatusTask* task, bool success, int errnum, const string& errmsg, const HttpHangoutStatusList& list) {
        NSLog(@"LSRequestManager::OnGetHangoutStatus( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* objArray = [NSMutableArray array];
        for(HttpHangoutStatusList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSHangoutStatusItemObject* obj = [[LSHangoutStatusItemObject alloc] init];
            obj.liveRoomId = [NSString stringWithUTF8String:(*iter).liveRoomId.c_str()];
            NSMutableArray* array = [NSMutableArray array];
            for(HttpFriendsInfoList::const_iterator seIter = (*iter).anchorList.begin(); seIter != (*iter).anchorList.end(); seIter++) {
                LSFriendsInfoItemObject* friendsobj = [[LSFriendsInfoItemObject alloc] init];
                friendsobj.anchorId = [NSString stringWithUTF8String:(*seIter).anchorId.c_str()];
                friendsobj.nickName = [NSString stringWithUTF8String:(*seIter).nickName.c_str()];
                [array addObject:friendsobj];
            }
            obj.anchorList = array;
            
            [objArray addObject:obj];
        }
        
        GetHangoutStatusFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], objArray);
        }
    }
};
RequestGetHangoutStatusCallbackImp gRequestGetHangoutStatusCallbackImp;
- (NSInteger)getHangoutStatus:(GetHangoutStatusFinishHandler)finishHandler {

    NSInteger request = (NSInteger)mHttpRequestController.GetHangoutStatus(&mHttpRequestManager, &gRequestGetHangoutStatusCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetNoReadNumProgramCallbackImp : public IRequestGetNoReadNumProgramCallback {
public:
    RequestGetNoReadNumProgramCallbackImp(){};
    ~RequestGetNoReadNumProgramCallbackImp(){};
    void OnGetNoReadNumProgram(HttpGetNoReadNumProgramTask* task, bool success, int errnum, const string& errmsg, int num) {
        NSLog(@"LSRequestManager::OnGetNoReadNumProgram( task : %p, success : %s, errnum : %d, errmsg : %s, num : %d)", task, success ? "true" : "false", errnum, errmsg.c_str(), num);
        
        GetNoReadNumProgramFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], num);
        }
    }
};
RequestGetNoReadNumProgramCallbackImp gRequestGetNoReadNumProgramCallbackImp;
- (NSInteger)getNoReadNumProgram:(GetNoReadNumProgramFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetNoReadNumProgram(&mHttpRequestManager, &gRequestGetNoReadNumProgramCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetProgramListCallbackImp : public IRequestGetProgramListCallback {
public:
    RequestGetProgramListCallbackImp(){};
    ~RequestGetProgramListCallbackImp(){};
    void OnGetProgramList(HttpGetProgramListTask* task, bool success, int errnum, const string& errmsg, const ProgramInfoList& list) {
        NSLog(@"LSRequestManager::OnGetProgramList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(ProgramInfoList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSProgramItemObject* item = [[LSProgramItemObject alloc] init];
            item.showLiveId = [NSString stringWithUTF8String:(*iter).showLiveId.c_str()];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNickName = [NSString stringWithUTF8String:(*iter).anchorNickName.c_str()];
            item.anchorAvatar = [NSString stringWithUTF8String:(*iter).anchorAvatar.c_str()];
            item.showTitle = [NSString stringWithUTF8String:(*iter).showTitle.c_str()];
            item.showIntroduce = [NSString stringWithUTF8String:(*iter).showIntroduce.c_str()];
            item.cover = [NSString stringWithUTF8String:(*iter).cover.c_str()];
            item.approveTime = (*iter).approveTime;
            item.startTime = (*iter).startTime;
            item.duration = (*iter).duration;
            item.leftSecToStart = (*iter).leftSecToStart;
            item.leftSecToEnter = (*iter).leftSecToEnter;
            item.price = (*iter).price;
            item.status = (*iter).status;
            item.ticketStatus = (*iter).ticketStatus;
            item.isHasFollow = (*iter).isHasFollow;
            item.isTicketFull = (*iter).isTicketFull;
            [array addObject:item];
        }
        
        
        GetProgramListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetProgramListCallbackImp gRequestGetProgramListCallbackImp;
- (NSInteger)getProgramListProgram:(ProgramListType)sortType
                             start:(int)start
                              step:(int)step
                     finishHandler:(GetProgramListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetProgramList(&mHttpRequestManager, sortType, start, step, &gRequestGetProgramListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestBuyProgramCallbackImp : public IRequestBuyProgramCallback {
public:
    RequestBuyProgramCallbackImp(){};
    ~RequestBuyProgramCallbackImp(){};
    void OnBuyProgram(HttpBuyProgramTask* task, bool success, int errnum, const string& errmsg, double leftCredit) {
        NSLog(@"LSRequestManager::OnBuyProgram( task : %p, success : %s, errnum : %d, errmsg : %s, leftCredit;%f)", task, success ? "true" : "false", errnum, errmsg.c_str(), leftCredit);
        
        BuyProgramFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], leftCredit);
        }
    }
};
RequestBuyProgramCallbackImp gRequestBuyProgramCallbackImp;
- (NSInteger)buyProgram:(NSString *_Nullable)liveShowId
          finishHandler:(BuyProgramFinishHandler _Nullable)finishHandler {
    string strLiveShowId = "";
    if (nil != liveShowId) {
        strLiveShowId = [liveShowId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.BuyProgram(&mHttpRequestManager, strLiveShowId, &gRequestBuyProgramCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestChangeFavouriteCallbackImp : public IRequestChangeFavouriteCallback {
public:
    RequestChangeFavouriteCallbackImp(){};
    ~RequestChangeFavouriteCallbackImp(){};
    void OnFollowShow(HttpChangeFavouriteTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnFollowShow( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        FollowShowFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestChangeFavouriteCallbackImp gRequestChangeFavouriteCallbackImp;

- (NSInteger)followShow:(NSString *_Nullable)liveShowId
               isCancle:(BOOL)isCancle
          finishHandler:(FollowShowFinishHandler _Nullable)finishHandler {
    string strLiveShowId = "";
    if (nil != liveShowId) {
        strLiveShowId = [liveShowId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.FollowShow(&mHttpRequestManager, strLiveShowId, isCancle, &gRequestChangeFavouriteCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

//- (NSInteger)followShow:(NSString *_Nullable)liveShowId
//                isCancel:(BOOL)isCancel
//           finishHandler:(FollowShowFinishHandler _Nullable)finishHandler {
//    NSInteger request = (NSInteger)mHttpRequestController.FollowShow(&mHttpRequestManager, [liveShowId UTF8String], isCancel, &gRequestChangeFavouriteCallbackImp);
//    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
//        }
//    }
//
//    return request;
//}

class RequestGetShowRoomInfoCallbackImp : public IRequestGetShowRoomInfoCallback {
public:
    RequestGetShowRoomInfoCallbackImp(){};
    ~RequestGetShowRoomInfoCallbackImp(){};
    void OnGetShowRoomInfo(HttpGetShowRoomInfoTask* task, bool success, int errnum, const string& errmsg, const HttpProgramInfoItem& item, const string& roomId, const HttpAuthorityItem& priv) {
        NSLog(@"LSRequestManager::OnGetShowRoomInfo( task : %p, success : %s, errnum : %d, errmsg : %s, roomId:%s)", task, success ? "true" : "false", errnum, errmsg.c_str(), roomId.c_str());
        LSProgramItemObject* obj = [[LSProgramItemObject alloc] init];
        obj.showLiveId = [NSString stringWithUTF8String:item.showLiveId.c_str()];
        obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
        obj.anchorNickName = [NSString stringWithUTF8String:item.anchorNickName.c_str()];
        obj.anchorAvatar = [NSString stringWithUTF8String:item.anchorAvatar.c_str()];
        obj.showTitle = [NSString stringWithUTF8String:item.showTitle.c_str()];
        obj.showIntroduce = [NSString stringWithUTF8String:item.showIntroduce.c_str()];
        obj.cover = [NSString stringWithUTF8String:item.cover.c_str()];
        obj.approveTime = item.approveTime;
        obj.startTime = item.startTime;
        obj.duration = item.duration;
        obj.leftSecToStart = item.leftSecToStart;
        obj.leftSecToEnter = item.leftSecToEnter;
        obj.price = item.price;
        obj.status = item.status;
        obj.ticketStatus = item.ticketStatus;
        obj.isHasFollow = item.isHasFollow;
        obj.isTicketFull = item.isTicketFull;
        

        
        NSString* strRoomId = [NSString stringWithUTF8String:roomId.c_str()];
        
        LSHttpAuthorityItemObject* privObj = [[LSHttpAuthorityItemObject alloc] init];
        privObj.isHasOneOnOneAuth = priv.privteLiveAuth;
        privObj.isHasBookingAuth = priv.bookingPriLiveAuth;
        
        GetShowRoomInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj, strRoomId, privObj);
        }
    }
};
RequestGetShowRoomInfoCallbackImp gRequestGetShowRoomInfoCallbackImp;
- (NSInteger)getShowRoomInfo:(NSString *_Nullable)liveShowId
               finishHandler:(GetShowRoomInfoFinishHandler _Nullable)finishHandler {
    string strLiveShowId = "";
    if (nil != liveShowId) {
        strLiveShowId = [liveShowId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetShowRoomInfo(&mHttpRequestManager, strLiveShowId, &gRequestGetShowRoomInfoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestShowListWithAnchorIdTCallbackImp : public IRequestShowListWithAnchorIdTCallback {
public:
    RequestShowListWithAnchorIdTCallbackImp(){};
    ~RequestShowListWithAnchorIdTCallbackImp(){};
    void OnShowListWithAnchorId(HttpShowListWithAnchorIdTask* task, bool success, int errnum, const string& errmsg, const ProgramInfoList& list) {
        NSLog(@"LSRequestManager::OnShowListWithAnchorId( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(ProgramInfoList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSProgramItemObject* item = [[LSProgramItemObject alloc] init];
            item.showLiveId = [NSString stringWithUTF8String:(*iter).showLiveId.c_str()];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNickName = [NSString stringWithUTF8String:(*iter).anchorNickName.c_str()];
            item.anchorAvatar = [NSString stringWithUTF8String:(*iter).anchorAvatar.c_str()];
            item.showTitle = [NSString stringWithUTF8String:(*iter).showTitle.c_str()];
            item.showIntroduce = [NSString stringWithUTF8String:(*iter).showIntroduce.c_str()];
            item.cover = [NSString stringWithUTF8String:(*iter).cover.c_str()];
            item.approveTime = (*iter).approveTime;
            item.startTime = (*iter).startTime;
            item.duration = (*iter).duration;
            item.leftSecToStart = (*iter).leftSecToStart;
            item.leftSecToEnter = (*iter).leftSecToEnter;
            item.price = (*iter).price;
            item.status = (*iter).status;
            item.ticketStatus = (*iter).ticketStatus;
            item.isHasFollow = (*iter).isHasFollow;
            item.isTicketFull = (*iter).isTicketFull;
            [array addObject:item];
        }
        
        
        ShowListWithAnchorIdFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestShowListWithAnchorIdTCallbackImp gRequestShowListWithAnchorIdTCallbackImp;
- (NSInteger)showListWithAnchorId:(NSString *_Nullable)anchorId
                            start:(int)start
                             step:(int)step
                         sortType:(ShowRecommendListType)sortType
                    finishHandler:(ShowListWithAnchorIdFinishHandler _Nullable)finishHandler {
    string strAnchorId = "";
    if (nil != anchorId) {
        strAnchorId = [anchorId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ShowListWithAnchorId(&mHttpRequestManager, strAnchorId, start, step, sortType, &gRequestShowListWithAnchorIdTCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

- (NSInteger)getPrivateMsgFriendList:(long)callback {
    IRequestGetPrivateMsgFriendListCallback* mCallback = (IRequestGetPrivateMsgFriendListCallback*)callback;
    NSInteger request = (NSInteger)mHttpRequestController.GetPrivateMsgFriendList(&mHttpRequestManager, mCallback);
    
    return request;
}

/**
 *  10.2.获取私信Follow联系人列表接口
 *
 *
 *  @return 成功请求Id
 */
- (NSInteger)getFollowPrivateMsgFriendList:(long)callback {
    IRequestGetFollowPrivateMsgFriendListCallback* mCallback = (IRequestGetFollowPrivateMsgFriendListCallback*)callback;
    NSInteger request = (NSInteger)mHttpRequestController.GetFollowPrivateMsgFriendList(&mHttpRequestManager, mCallback);
    
    return request;
}

- (NSInteger)getPrivateMsgWithUserId:(NSString * _Nonnull)userId startMsgId:(NSString * _Nonnull)startMsgId order:(PrivateMsgOrderType)order limit:(int)limit reqId:(int)reqId callback:(long)callback {
    string strUserId = "";
    if (nil != userId) {
        strUserId = [userId UTF8String];
    }
    string strStartMsgId = "";
    if (nil != startMsgId) {
        strStartMsgId = [startMsgId UTF8String];
    }
    IRequestGetPrivateMsgHistoryByIdCallback* mCallback = (IRequestGetPrivateMsgHistoryByIdCallback*)callback;
    NSInteger request = (NSInteger)mHttpRequestController.GetPrivateMsgHistoryById(&mHttpRequestManager, strUserId, strStartMsgId, order, limit, reqId, mCallback);
    
    return request;
}

- (NSInteger)setPrivateMsgReaded:(NSString * _Nonnull)userId msgId:(NSString * _Nonnull)msgId callback:(long)callback {
    string strUserId = "";
    if (nil != userId) {
        strUserId = [userId UTF8String];
    }
    string strMsgId = "";
    if (nil != msgId) {
        strMsgId = [msgId UTF8String];
    }
    IRequestSetPrivateMsgReadedCallback* mCallback = (IRequestSetPrivateMsgReadedCallback*)callback;
    NSInteger request = (NSInteger)mHttpRequestController.SetPrivateMsgReaded(&mHttpRequestManager, strUserId, strMsgId, mCallback);
    
    return request;
}

class RequestGetPushConfigCallbackImp : public IRequestGetPushConfigCallback {
public:
    RequestGetPushConfigCallbackImp(){};
    ~RequestGetPushConfigCallbackImp(){};
    void OnGetPushConfig(HttpGetPushConfigTask* task, bool success, int errnum, const string& errmsg, const HttpAppPushConfigItem& appPushItem) {
        NSLog(@"LSRequestManager::OnGetPushConfig( task : %p, success : %s, errnum : %d, errmsg : %s, isPriMsgAppPush:%d isMailAppPush:%d isSayHiAppPush:%d)", task, success ? "true" : "false", errnum, errmsg.c_str(), appPushItem.isPriMsgAppPush, appPushItem.isMailAppPush, appPushItem.isSayHiAppPush);
        
        LSAppPushConfigItemObject* obj = [[LSAppPushConfigItemObject alloc] init];
        obj.isPriMsgAppPush = appPushItem.isPriMsgAppPush;
        obj.isMailAppPush = appPushItem.isMailAppPush;
        obj.isSayHiAppPush = appPushItem.isSayHiAppPush;
        
        
        GetPushConfigFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetPushConfigCallbackImp gRequestGetPushConfigCallbackImp;
- (NSInteger)getPushConfig:(GetPushConfigFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetPushConfig(&mHttpRequestManager, &gRequestGetPushConfigCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSetPushConfigCallbackImp : public IRequestSetPushConfigCallback {
public:
    RequestSetPushConfigCallbackImp(){};
    ~RequestSetPushConfigCallbackImp(){};
    void OnSetPushConfig(HttpSetPushConfigTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnSetPushConfig( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SetPushConfigFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSetPushConfigCallbackImp gRequestSetPushConfigCallbackImp;
- (NSInteger)setPushConfig:(BOOL)isPriMsgAppPush
             isMailAppPush:(BOOL)isMailAppPush
            isSayHiAppPush:(BOOL)isSayHiAppPush
             finishHandler:(SetPushConfigFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.SetPushConfig(&mHttpRequestManager, isPriMsgAppPush, isMailAppPush, isSayHiAppPush, &gRequestSetPushConfigCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

-(NSArray<LSHttpLetterListItemObject *>*)getLSLetterListItemObjectArray:(const HttpLetterItemList&)letterList {
    NSMutableArray* array = [NSMutableArray array];
    for(HttpLetterItemList::const_iterator iter = letterList.begin(); iter != letterList.end(); iter++) {
        LSHttpLetterListItemObject* item = [[LSHttpLetterListItemObject alloc] init];
        item.anchorId = [NSString stringWithUTF8String:(*iter).oppAnchor.anchorId.c_str()];
        item.anchorAvatar = [NSString stringWithUTF8String:(*iter).oppAnchor.anchorAvatar.c_str()];
        item.anchorNickName = [NSString stringWithUTF8String:(*iter).oppAnchor.anchorNickName.c_str()];
        item.isFollow = (*iter).oppAnchor.isFollow;
        item.letterId = [NSString stringWithUTF8String:(*iter).letterId.c_str()];
        item.letterSendTime = (*iter).letterSendTime;
        item.letterBrief = [NSString stringWithUTF8String:(*iter).letterBrief.c_str()];
        item.hasImg = (*iter).hasItem.hasImg;
        item.hasVideo = (*iter).hasItem.hasVideo;
        item.hasRead = (*iter).hasItem.hasRead;
        item.hasReplied = (*iter).hasItem.hasReplied;
        item.onlineStatus = (*iter).hasItem.onlineStatus;
        item.hasSchedule = (*iter).hasItem.hasSchedule;
        item.hasKey = (*iter).hasItem.hasAccessKey;
        [array addObject:item];
    }
    return array;
}

class RequestGetLoiListCallbackImp : public IRequestGetLoiListCallback {
public:
    RequestGetLoiListCallbackImp(){};
    ~RequestGetLoiListCallbackImp(){};
    void OnGetLoiList(HttpGetLoiListTask* task, bool success, int errnum, const string& errmsg, const HttpLetterItemList& letterList) {
        NSLog(@"LSRequestManager::OnGetLoiList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        NSArray *array = [[LSRequestManager manager] getLSLetterListItemObjectArray:letterList];
        GetLoiListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetLoiListCallbackImp gRequestGetLoiListCallbackImp;

- (NSInteger)getLoiList:(LSLetterTag)tag
                  start:(int)start
                   step:(int)step
          finishHandler:(GetLoiListFinishHandler )finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetLoiList(&mHttpRequestManager, tag, start, step, &gRequestGetLoiListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestGetLoiDetailCallbackImp : public IRequestGetLoiDetailCallback {
public:
    RequestGetLoiDetailCallbackImp(){};
    ~RequestGetLoiDetailCallbackImp(){};
    void OnGetLoiDetail(HttpGetLoiDetailTask* task, bool success, int errnum, const string& errmsg, const HttpDetailLoiItem& detailLoiItem) {
        NSLog(@"LSRequestManager::OnGetLoiDetail( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        LSHttpLetterDetailItemObject* obj = [[LSHttpLetterDetailItemObject alloc] init];
        obj.anchorId = [NSString stringWithUTF8String:detailLoiItem.oppAnchor.anchorId.c_str()];
        obj.anchorCover = [NSString stringWithUTF8String:detailLoiItem.oppAnchor.anchorAvatar.c_str()];
        obj.anchorAvatar = [NSString stringWithUTF8String:detailLoiItem.oppAnchor.anchorAvatar.c_str()];
        obj.anchorNickName = [NSString stringWithUTF8String:detailLoiItem.oppAnchor.anchorNickName.c_str()];
        obj.age = detailLoiItem.oppAnchor.age;
        obj.country = [NSString stringWithUTF8String:detailLoiItem.oppAnchor.country.c_str()];
        obj.onlineStatus = detailLoiItem.oppAnchor.onlineStatus;
        obj.isInPublic = detailLoiItem.oppAnchor.isInPublic;
        obj.isFollow = detailLoiItem.oppAnchor.isFollow;
        obj.letterId = [NSString stringWithUTF8String:detailLoiItem.loiId.c_str()];
        obj.letterSendTime = detailLoiItem.loiSendTime;
        obj.letterContent = [NSString stringWithUTF8String:detailLoiItem.loiContent.c_str()];
        obj.hasRead = detailLoiItem.hasRead;
        obj.hasReplied = detailLoiItem.hasReplied;
        NSMutableArray* letterImgList = [NSMutableArray array];
        for(HttpLetterImgList::const_iterator iter = detailLoiItem.loiImgList.begin(); iter != detailLoiItem.loiImgList.end(); iter++) {
            LSHttpLetterImgItemObject* item = [[LSHttpLetterImgItemObject alloc] init];
            item.originImg = [NSString stringWithUTF8String:(*iter).originImg.c_str()];
            item.smallImg = [NSString stringWithUTF8String:(*iter).smallImg.c_str()];
            item.blurImg = [NSString stringWithUTF8String:(*iter).blurImg.c_str()];
            [letterImgList addObject:item];
        }
        obj.letterImgList = letterImgList;
        NSMutableArray* letterVideoList = [NSMutableArray array];
        for(HttpLetterVideoList::const_iterator iter2 = detailLoiItem.loiVideoList.begin(); iter2 != detailLoiItem.loiVideoList.end(); iter2++) {
            LSHttpLetterVideoItemObject* item2 = [[LSHttpLetterVideoItemObject alloc] init];
            item2.coverSmallImg = [NSString stringWithUTF8String:(*iter2).cover.c_str()];
            item2.coverOriginImg = [NSString stringWithUTF8String:(*iter2).cover.c_str()];
            item2.video = [NSString stringWithUTF8String:(*iter2).video.c_str()];
            item2.videoTotalTime = (*iter2).videoTotalTime;
            [letterVideoList addObject:item2];
        }
        obj.letterVideoList = letterVideoList;
        GetLoiDetailFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetLoiDetailCallbackImp gRequestGetLoiDetailCallbackImp;
- (NSInteger)getLoiDetail:(NSString*)loiId
            finishHandler:(GetLoiDetailFinishHandler )finishHandler {
    string strLoiId = "";
    if (loiId != nil) {
        strLoiId = [loiId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetLoiDetail(&mHttpRequestManager, strLoiId, &gRequestGetLoiDetailCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetEmfListCallbackImp : public IRequestGetEmfListCallback {
public:
    RequestGetEmfListCallbackImp(){};
    ~RequestGetEmfListCallbackImp(){};
    void OnGetEmfList(HttpGetEmfListTask* task, bool success, int errnum, const string& errmsg, const HttpLetterItemList& letterList) {
        NSLog(@"LSRequestManager::OnGetEmfList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        NSArray *array = [[LSRequestManager manager] getLSLetterListItemObjectArray:letterList];
        GetEmfListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetEmfListCallbackImp gRequestGetEmfListCallbackImp;
- (NSInteger)getEmfboxList:(LSEMFType)type
                    tag:(LSLetterTag)tag
                   start:(int)start
                    step:(int)step
               finishHandler:(GetEmfListFinishHandler )finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetEmfboxList(&mHttpRequestManager, type, tag, start, step, &gRequestGetEmfListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestGetEmfDetailCallbackImp : public IRequestGetEmfDetailCallback {
public:
    RequestGetEmfDetailCallbackImp(){};
    ~RequestGetEmfDetailCallbackImp(){};
    void OnGetEmfDetail(HttpGetEmfDetailTask* task, bool success, int errnum, const string& errmsg, const HttpDetailEmfItem& detailEmfItem) {
        NSLog(@"LSRequestManager::OnGetEmfDetail( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        LSHttpLetterDetailItemObject* obj = [[LSHttpLetterDetailItemObject alloc] init];
        obj.anchorId = [NSString stringWithUTF8String:detailEmfItem.oppAnchor.anchorId.c_str()];
        obj.anchorCover = [NSString stringWithUTF8String:detailEmfItem.oppAnchor.anchorAvatar.c_str()];
        obj.anchorAvatar = [NSString stringWithUTF8String:detailEmfItem.oppAnchor.anchorAvatar.c_str()];
        obj.anchorNickName = [NSString stringWithUTF8String:detailEmfItem.oppAnchor.anchorNickName.c_str()];
        obj.age = detailEmfItem.oppAnchor.age;
        obj.country = [NSString stringWithUTF8String:detailEmfItem.oppAnchor.country.c_str()];
        obj.onlineStatus = detailEmfItem.oppAnchor.onlineStatus;
        obj.isInPublic = detailEmfItem.oppAnchor.isInPublic;
        obj.isFollow = detailEmfItem.oppAnchor.isFollow;
        obj.letterId = [NSString stringWithUTF8String:detailEmfItem.emfId.c_str()];
        obj.letterSendTime = detailEmfItem.emfSendTime;
        obj.letterContent = [NSString stringWithUTF8String:detailEmfItem.emfContent.c_str()];
        obj.hasRead = detailEmfItem.hasRead;
        obj.hasReplied = detailEmfItem.hasReplied;
        NSMutableArray* letterImgList = [NSMutableArray array];
        for(HttpEmfImgList::const_iterator iter = detailEmfItem.emfImgList.begin(); iter != detailEmfItem.emfImgList.end(); iter++) {
            LSHttpLetterImgItemObject* item = [[LSHttpLetterImgItemObject alloc] init];
            item.resourceId = [NSString stringWithUTF8String:(*iter).payItem.resourceId.c_str()];
            item.isFee = (*iter).payItem.isFee;
            item.status = (*iter).payItem.status;
            item.describe = [NSString stringWithUTF8String:(*iter).payItem.describe.c_str()];
            item.originImg = [NSString stringWithUTF8String:(*iter).letterImgItem.originImg.c_str()];
            item.smallImg = [NSString stringWithUTF8String:(*iter).letterImgItem.smallImg.c_str()];
            item.blurImg = [NSString stringWithUTF8String:(*iter).letterImgItem.blurImg.c_str()];
            [letterImgList addObject:item];
        }
        obj.letterImgList = letterImgList;
        NSMutableArray* letterVideoList = [NSMutableArray array];
        for(HttpEmfVideoList::const_iterator iter2 = detailEmfItem.emfVideoList.begin(); iter2 != detailEmfItem.emfVideoList.end(); iter2++) {
            LSHttpLetterVideoItemObject* item2 = [[LSHttpLetterVideoItemObject alloc] init];
            item2.resourceId = [NSString stringWithUTF8String:(*iter2).payItem.resourceId.c_str()];
            item2.isFee = (*iter2).payItem.isFee;
            item2.status = (*iter2).payItem.status;
            item2.describe = [NSString stringWithUTF8String:(*iter2).payItem.describe.c_str()];
            item2.coverSmallImg = [NSString stringWithUTF8String:(*iter2).coverSmallImg.c_str()];
            item2.coverOriginImg = [NSString stringWithUTF8String:(*iter2).coverOriginImg.c_str()];
            item2.video = [NSString stringWithUTF8String:(*iter2).video.c_str()];
            item2.videoTotalTime = (*iter2).videoTotalTime;
            [letterVideoList addObject:item2];
        }
        obj.letterVideoList = letterVideoList;
        
        if (!detailEmfItem.scheduleInfo.anchorId.empty()) {
            LSScheduleInviteDetailItemObject* giftItem = [[LSScheduleInviteDetailItemObject alloc] init];
            giftItem.anchorId = [NSString stringWithUTF8String:detailEmfItem.scheduleInfo.anchorId.c_str()];
            giftItem.inviteId = [NSString stringWithUTF8String:detailEmfItem.scheduleInfo.inviteId.c_str()];
            giftItem.sendFlag = detailEmfItem.scheduleInfo.sendFlag;
            giftItem.isSummerTime = detailEmfItem.scheduleInfo.isSummerTime;
            giftItem.startTime = detailEmfItem.scheduleInfo.startTime;
            giftItem.endTime = detailEmfItem.scheduleInfo.endTime;
            giftItem.addTime = detailEmfItem.scheduleInfo.addTime;
            giftItem.statusUpdateTime = detailEmfItem.scheduleInfo.statusUpdateTime;
            giftItem.timeZoneValue = [NSString stringWithUTF8String:detailEmfItem.scheduleInfo.timeZoneValue.c_str()];
            giftItem.timeZoneCity = [NSString stringWithUTF8String:detailEmfItem.scheduleInfo.timeZoneCity.c_str()];
            giftItem.duration = detailEmfItem.scheduleInfo.duration;
            giftItem.status = detailEmfItem.scheduleInfo.status;
            giftItem.cancelerName = [NSString stringWithUTF8String:detailEmfItem.scheduleInfo.cancelerName.c_str()];
            giftItem.type = detailEmfItem.scheduleInfo.type;
            giftItem.refId = [NSString stringWithUTF8String:detailEmfItem.scheduleInfo.refId.c_str()];
            giftItem.isActive = detailEmfItem.scheduleInfo.isActive;
            obj.scheduleInfo = giftItem;
        }
        
        if (!detailEmfItem.accessKeyInfo.videoId.empty()) {
            LSAccessKeyinfoItemObject* keyItem = [[LSAccessKeyinfoItemObject alloc] init];
            keyItem.videoId = [NSString stringWithUTF8String:detailEmfItem.accessKeyInfo.videoId.c_str()];
            keyItem.title = [NSString stringWithUTF8String:detailEmfItem.accessKeyInfo.title.c_str()];
            keyItem.describe = [NSString stringWithUTF8String:detailEmfItem.accessKeyInfo.description.c_str()];
            keyItem.duration = detailEmfItem.accessKeyInfo.duration;
            keyItem.coverUrlPng = [NSString stringWithUTF8String:detailEmfItem.accessKeyInfo.coverUrlPng.c_str()];
            keyItem.coverUrlGif = [NSString stringWithUTF8String:detailEmfItem.accessKeyInfo.coverUrlGif.c_str()];
            keyItem.accessKey = [NSString stringWithUTF8String:detailEmfItem.accessKeyInfo.accessKey.c_str()];
            keyItem.accessKeyStatus = detailEmfItem.accessKeyInfo.accessKeyStatus;
            keyItem.validTime = detailEmfItem.accessKeyInfo.validTime;
            obj.accessKeyInfo = keyItem;
        }

        
        GetEmfDetailFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetEmfDetailCallbackImp gRequestGetEmfDetailCallbackImp;
- (NSInteger)getEmfDetail:(NSString*)emfId
            finishHandler:(GetEmfDetailFinishHandler )finishHandler {
    string strEmfId = "";
    if (emfId != nil) {
        strEmfId = [emfId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.GetEmfDetail(&mHttpRequestManager, strEmfId, &gRequestGetEmfDetailCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSendEmfCallbackImp : public IRequestSendEmfCallback {
public:
    RequestSendEmfCallbackImp(){};
    ~RequestSendEmfCallbackImp(){};
    void OnSendEmf(HttpSendEmfTask* task, bool success, int errnum, const string& errmsg, const string& emfId) {
        NSLog(@"LSRequestManager::OnSendEmf( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        SendEmfFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:emfId.c_str()]);
        }
    }
};
RequestSendEmfCallbackImp gRequestSendEmfCallbackImp;
- (NSInteger)sendEmf:(NSString*)anchorId
               loiId:(NSString*)loiId
               emfId:(NSString*)emfId
             content:(NSString*)content
             imgList:(NSArray<NSString *>*)imgList
         comsumeType:(LSLetterComsumeType)comsumeType
     sayHiResponseId:(NSString*)sayHiResponseId
          isSchedule:(BOOL)isSchedule
          timeZoneId:(NSString*)timeZoneId
           startTime:(NSString*)startTime
            duration:(int)duration
       finishHandler:(SendEmfFinishHandler )finishHandler {
    string stranchorId = "";
    if (anchorId != nil) {
        stranchorId = [anchorId UTF8String];
    }
    string strloiId = "";
    if (loiId != nil) {
        strloiId = [loiId UTF8String];
    }
    string stremfId = "";
    if (emfId != nil) {
        stremfId = [emfId UTF8String];
    }
    string strcontent = "";
    if (content != nil) {
        strcontent = [content UTF8String];
    }
    list<string> list;
    if (imgList != nil) {
        for (NSString *str in imgList) {
            string pStr = [str UTF8String];
            list.push_back(pStr);
        }
    }
    
    string strSayHiResponseId = "";
    if (sayHiResponseId != nil) {
        strSayHiResponseId = [sayHiResponseId UTF8String];
    }
    
    string strtimeZoneId = "";
    if (timeZoneId != nil) {
        strtimeZoneId = [timeZoneId UTF8String];
    }
    
    string strstartTime = "";
    if (startTime != nil) {
        strstartTime = [startTime UTF8String];
    }

    NSInteger request = (NSInteger)mHttpRequestController.SendEmf(&mHttpRequestManager, stranchorId, strloiId, stremfId, strcontent, list, comsumeType, strSayHiResponseId, isSchedule, strtimeZoneId, strstartTime, duration, &gRequestSendEmfCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestUploadLetterPhotoCallbackImp : public IRequestUploadLetterPhotoCallback {
public:
    RequestUploadLetterPhotoCallbackImp(){};
    ~RequestUploadLetterPhotoCallbackImp(){};
    void OnUploadLetterPhoto(HttpUploadLetterPhotoTask* task, bool success, int errnum, const string& errmsg, const string& url, const string& md5, const string& fileName) {
        NSLog(@"LSRequestManager::OnUploadLetterPhoto( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        UploadLetterPhotoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:url.c_str()], [NSString stringWithUTF8String:md5.c_str()], [NSString stringWithUTF8String:fileName.c_str()]);
        }
    }
};
RequestUploadLetterPhotoCallbackImp gRequestUploadLetterPhotoCallbackImp;
- (NSInteger)uploadLetterPhoto:(NSString*)fileName
                          file:(NSString*)file
                 finishHandler:(UploadLetterPhotoFinishHandler )finishHandler {
    string strfile = "";
    if (file != nil) {
        strfile = [file UTF8String];
    }
    string strfileName = "";
    if (fileName != nil) {
        strfileName = [fileName UTF8String];
    }

    NSInteger request = (NSInteger)mHttpRequestController.UploadLetterPhoto(&mHttpRequestManager, strfile, strfileName, &gRequestUploadLetterPhotoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestBuyPrivatePhotoVideoCallbackImp : public IRequestBuyPrivatePhotoVideoCallback {
public:
    RequestBuyPrivatePhotoVideoCallbackImp(){};
    ~RequestBuyPrivatePhotoVideoCallbackImp(){};
    void OnBuyPrivatePhotoVideo(HttpBuyPrivatePhotoVideoTask* task, bool success, int errnum, const string& errmsg, const HttpBuyAttachItem& buyAttachItem) {
        NSLog(@"LSRequestManager::OnBuyPrivatePhotoVideo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        LSBuyAttachItemObject* obj = [[LSBuyAttachItemObject alloc] init];
        obj.emfId = [NSString stringWithUTF8String:buyAttachItem.emfId.c_str()];
        obj.resourceId = [NSString stringWithUTF8String:buyAttachItem.resourceId.c_str()];
        obj.originImg = [NSString stringWithUTF8String:buyAttachItem.originImg.c_str()];
        obj.videoUrl = [NSString stringWithUTF8String:buyAttachItem.videoUrl.c_str()];
       
        BuyPrivatePhotoVideoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestBuyPrivatePhotoVideoCallbackImp gRequestBuyPrivatePhotoVideoCallbackImp;
- (NSInteger)buyPrivatePhotoVideo:(NSString*)emfId
                       resourceId:(NSString*)resourceId
                      comsumeType:(LSLetterComsumeType)comsumeType
                    finishHandler:(BuyPrivatePhotoVideoFinishHandler )finishHandler {
    string stremfId = "";
    if (emfId != nil) {
        stremfId = [emfId UTF8String];
    }
    string strresourceId = "";
    if (resourceId != nil) {
        strresourceId = [resourceId UTF8String];
    }
    
    NSInteger request = (NSInteger)mHttpRequestController.BuyPrivatePhotoVideo(&mHttpRequestManager, stremfId, strresourceId, comsumeType, &gRequestBuyPrivatePhotoVideoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetSendMailPriceCallbackImp : public IRequestGetSendMailPriceCallback {
public:
    RequestGetSendMailPriceCallbackImp(){};
    ~RequestGetSendMailPriceCallbackImp(){};
    void OnGetSendMailPrice(HttpGetSendMailPriceTask* task, bool success, int errnum, const string& errmsg, double creditPrice, double stampPrice) {
        NSLog(@"LSRequestManager::OnGetSendMailPrice( task : %p, success : %s, errnum : %d, errmsg : %s creditPrice : %lf stampPrice : %lf)", task, success ? "true" : "false", errnum, errmsg.c_str(), creditPrice, stampPrice);
        
        GetSendMailPriceFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], creditPrice, stampPrice);
        }
    }
};

RequestGetSendMailPriceCallbackImp gRequestGetSendMailPriceCallbackImp;

- (NSInteger)getSendMailPrice:(int)imgNumber
                finishHandler:(GetSendMailPriceFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetSendMailPrice(&mHttpRequestManager,
                                                                 imgNumber,
                                                                 &gRequestGetSendMailPriceCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestCanSendEmfCallbackImp : public IRequestCanSendEmfCallback {
public:
    RequestCanSendEmfCallbackImp(){};
    ~RequestCanSendEmfCallbackImp(){};
    void OnCanSendEmf(HttpCanSendEmfTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorSendEmfPrivItem& item) {
        NSLog(@"LSRequestManager::OnCanSendEmf( task : %p, success : %s, errnum : %d, errmsg : %s userCanSend : %d anchorCanSend : %d)", task, success ? "true" : "false", errnum, errmsg.c_str(), item.userCanSend, item.anchorCanSend);
        LSAnchorLetterPrivItemObject* obj = [[LSAnchorLetterPrivItemObject alloc] init];
        obj.userCanSend = item.userCanSend;
        obj.anchorCanSend = item.anchorCanSend;
        
        GetAnchorLetterPrivFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestCanSendEmfCallbackImp gRequestCanSendEmfCallbackImp;

- (NSInteger)getAnchorLetterPriv:(NSString*)anchorId
                   finishHandler:(GetAnchorLetterPrivFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.CanSendEmf(&mHttpRequestManager,
                                                                 strAnchorId,
                                                                 &gRequestCanSendEmfCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetEmfStatusCallbackImp : public IRequestGetEmfStatusCallback {
public:
    RequestGetEmfStatusCallbackImp(){};
    ~RequestGetEmfStatusCallbackImp(){};
    void OnGetEmfStatus(HttpGetEmfStatusTask* task, bool success, int errnum, const string& errmsg, bool hasRead) {
        NSLog(@"LSRequestManager::OnGetEmfStatus( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GetEmfStatusFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], hasRead);
        }
    }
};

RequestGetEmfStatusCallbackImp gRequestGetEmfStatusCallbackImp;

- (NSInteger)getEmfStatus:(NSString*)emfId
            finishHandler:(GetEmfStatusFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string stremfId = "";
    if (emfId != nil) {
        stremfId = [emfId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetEmfStatus(&mHttpRequestManager,
                                                                 stremfId,
                                                                 &gRequestGetEmfStatusCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestResourceConfigCallbackImp : public IRequestResourceConfigCallback {
public:
    RequestResourceConfigCallbackImp(){};
    ~RequestResourceConfigCallbackImp(){};
    void OnResourceConfig(HttpResourceConfigTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiResourceConfigItem& item) {
        NSLog(@"LSRequestManager::OnResourceConfig( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        LSSayHiResourceConfigItemObject* obj = [[LSSayHiResourceConfigItemObject alloc] init];
        NSMutableArray* themeList = [NSMutableArray array];
        for(HttpThemeList::const_iterator iter = item.themeList.begin(); iter != item.themeList.end(); iter++) {
            LSSayHiThemeItemObject* themeItem = [[LSSayHiThemeItemObject alloc] init];
            themeItem.themeId = [NSString stringWithUTF8String:(*iter).themeId.c_str()];
            themeItem.themeName = [NSString stringWithUTF8String:(*iter).themeName.c_str()];
            themeItem.smallImg = [NSString stringWithUTF8String:(*iter).smallImg.c_str()];
            themeItem.bigImg = [NSString stringWithUTF8String:(*iter).bigImg.c_str()];
            [themeList addObject:themeItem];
        }
        obj.themeList = themeList;
        
        NSMutableArray* textList = [NSMutableArray array];
        for(HttpTextList::const_iterator iter2 = item.textList.begin(); iter2 != item.textList.end(); iter2++) {
            LSSayHiTextItemObject* textItem = [[LSSayHiTextItemObject alloc] init];
            textItem.textId = [NSString stringWithUTF8String:(*iter2).textId.c_str()];
            textItem.text = [NSString stringWithUTF8String:(*iter2).text.c_str()];
            [textList addObject:textItem];
        }
        obj.textList = textList;
        
        SayHiConfigFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestResourceConfigCallbackImp gRequestResourceConfigCallbackImp;

- (NSInteger)sayHiConfig:(SayHiConfigFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    request = (NSInteger)mHttpRequestController.SayHiConfig(&mHttpRequestManager,
                                                            &gRequestResourceConfigCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetSayHiAnchorListCallbackImp : public IRequestGetSayHiAnchorListCallback {
public:
    RequestGetSayHiAnchorListCallbackImp(){};
    ~RequestGetSayHiAnchorListCallbackImp(){};
    void OnGetSayHiAnchorList(HttpGetSayHiAnchorListTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiAnchorList& list) {
        NSLog(@"LSRequestManager::OnGetSayHiAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        NSMutableArray* arrayList = [NSMutableArray array];
        for(HttpSayHiAnchorList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSSayHiAnchorItemObject* anchorItem = [[LSSayHiAnchorItemObject alloc] init];
            anchorItem.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            anchorItem.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            anchorItem.coverImg = [NSString stringWithUTF8String:(*iter).coverImg.c_str()];
            anchorItem.onlineStatus = (*iter).onlineStatus;
            anchorItem.roomType = (*iter).roomType;
            [arrayList addObject:anchorItem];
        }
        
        GetSayHiAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], arrayList);
        }
    }
};

RequestGetSayHiAnchorListCallbackImp gRequestGetSayHiAnchorListCallbackImp;

- (NSInteger)getSayHiAnchorList:(GetSayHiAnchorListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    request = (NSInteger)mHttpRequestController.GetSayHiAnchorList(&mHttpRequestManager,
                                                                   &gRequestGetSayHiAnchorListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestIsCanSendSayHiCallbackImp : public IRequestIsCanSendSayHiCallback {
public:
    RequestIsCanSendSayHiCallbackImp(){};
    ~RequestIsCanSendSayHiCallbackImp(){};
    void OnIsCanSendSayHi(HttpIsCanSendSayHiTask* task, bool success, int errnum, const string& errmsg, bool isCanSend) {
        NSLog(@"LSRequestManager::OnIsCanSendSayHi( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        IsCanSendSayHiFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], isCanSend);
        }
    }
};

RequestIsCanSendSayHiCallbackImp gRequestIsCanSendSayHiCallbackImp;

- (NSInteger)isCanSendSayHi:(NSString*)anchorId
              finishHandler:(IsCanSendSayHiFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.IsCanSendSayHi(&mHttpRequestManager,
                                                               strAnchorId,
                                                               &gRequestIsCanSendSayHiCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSendSayHiCallbackImp : public IRequestSendSayHiCallback {
public:
    RequestSendSayHiCallbackImp(){};
    ~RequestSendSayHiCallbackImp(){};
    void OnSendSayHi(HttpSendSayHiTask* task, bool success, int errnum, const string& errmsg, const string& sayHiId, const string& sayHiOrLoiId, bool isFollow, OnLineStatus onlineStatus) {
        NSLog(@"LSRequestManager::OnSendSayHi( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SendSayHiFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        HTTP_LCC_ERR_TYPE errCode = [[LSRequestManager manager] intToHttpLccErrType:errnum];
        NSString* strSayHiId = [NSString stringWithUTF8String:sayHiId.c_str()];
        NSString* strLoiId = @"";
        if (errCode == HTTP_LCC_ERR_SAYHI_MAN_ALREADY_SEND_SAYHI) {
            strSayHiId = [NSString stringWithUTF8String:sayHiOrLoiId.c_str()];
        } else if (errCode == HTTP_LCC_ERR_SAYHI_ANCHOR_ALREADY_SEND_LOI) {
            strLoiId = [NSString stringWithUTF8String:sayHiOrLoiId.c_str()];
            strSayHiId = @"";
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], strSayHiId, strLoiId, isFollow, onlineStatus);
        }
    }
};

RequestSendSayHiCallbackImp gRequestSendSayHiCallbackImp;

- (NSInteger)sendSayHi:(NSString*)anchorId
               themeId:(NSString*)themeId
                textId:(NSString*)textId
         finishHandler:(SendSayHiFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    string strThemeId = "";
    if (themeId != nil) {
        strThemeId = [themeId UTF8String];
    }
    
    string strTextId = "";
    if (textId != nil) {
        strTextId = [textId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.SendSayHi(&mHttpRequestManager,
                                                          strAnchorId,
                                                          strThemeId,
                                                          strTextId,
                                                          &gRequestSendSayHiCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetAllSayHiListCallbackImp : public IRequestGetAllSayHiListCallback {
public:
    RequestGetAllSayHiListCallbackImp(){};
    ~RequestGetAllSayHiListCallbackImp(){};
    void OnGetAllSayHiList(HttpGetAllSayHiListTask* task, bool success, int errnum, const string& errmsg, const HttpAllSayHiListItem& item) {
        NSLog(@"LSRequestManager::OnGetAllSayHiList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        LSSayHiAllItemObject* obj = [[LSSayHiAllItemObject alloc] init];
        obj.totalCount = item.totalCount;
        NSMutableArray* arrayList = [NSMutableArray array];
        for(HttpAllSayHiListItem::AllSayHiList::const_iterator iter = item.allList.begin(); iter != item.allList.end(); iter++) {
            LSSayHiAllListItemObject* allItem = [[LSSayHiAllListItemObject alloc] init];
            allItem.sayHiId = [NSString stringWithUTF8String:(*iter).sayHiId.c_str()];
            allItem.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            allItem.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            allItem.cover = [NSString stringWithUTF8String:(*iter).cover.c_str()];
            allItem.avatar = [NSString stringWithUTF8String:(*iter).avatar.c_str()];
            allItem.age = (*iter).age;
            allItem.sendTime = (*iter).sendTime;
            allItem.content = [NSString stringWithUTF8String:(*iter).content.c_str()];
            allItem.responseNum = (*iter).responseNum;
            allItem.unreadNum = (*iter).unreadNum;
            allItem.isFree = (*iter).isFree;
            [arrayList addObject:allItem];
        }
        obj.list = arrayList;
        
        GetAllSayHiListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestGetAllSayHiListCallbackImp gRequestGetAllSayHiListCallbackImp;

- (NSInteger)getAllSayHiList:(int)start
                        step:(int)step
               finishHandler:(GetAllSayHiListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetAllSayHiList(&mHttpRequestManager,
                                                                start,
                                                                step,
                                                                &gRequestGetAllSayHiListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetResponseSayHiListCallbackImp : public IRequestGetResponseSayHiListCallback {
public:
    RequestGetResponseSayHiListCallbackImp(){};
    ~RequestGetResponseSayHiListCallbackImp(){};
    void OnGetResponseSayHiList(HttpGetResponseSayHiListTask* task, bool success, int errnum, const string& errmsg, const HttpResponseSayHiListItem& item) {
        NSLog(@"LSRequestManager::OnGetResponseSayHiList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        LSSayHiResponseItemObject* obj = [[LSSayHiResponseItemObject alloc] init];
        obj.totalCount = item.totalCount;
        NSMutableArray* arrayList = [NSMutableArray array];
        for(HttpResponseSayHiListItem::ResponseSayHiList::const_iterator iter = item.responseList.begin(); iter != item.responseList.end(); iter++) {
            LSSayHiResponseListItemObject* responseItem = [[LSSayHiResponseListItemObject alloc] init];
            responseItem.sayHiId = [NSString stringWithUTF8String:(*iter).sayHiId.c_str()];
            responseItem.responseId = [NSString stringWithUTF8String:(*iter).responseId.c_str()];
            responseItem.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            responseItem.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            responseItem.cover = [NSString stringWithUTF8String:(*iter).cover.c_str()];
            responseItem.avatar = [NSString stringWithUTF8String:(*iter).avatar.c_str()];
            responseItem.age = (*iter).age;
            responseItem.responseTime = (*iter).responseTime;
            responseItem.content = [NSString stringWithUTF8String:(*iter).content.c_str()];
            responseItem.hasImg = (*iter).hasImg;
            responseItem.hasRead = (*iter).hasRead;
            responseItem.isFree = (*iter).isFree;
            [arrayList addObject:responseItem];
        }
        obj.list = arrayList;
        
        GetResponseSayHiListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestGetResponseSayHiListCallbackImp gRequestGetResponseSayHiListCallbackImp;

- (NSInteger)getResponseSayHiList:(LSSayHiListType)type
                            start:(int)start
                             step:(int)step
                    finishHandler:(GetResponseSayHiListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;

    request = (NSInteger)mHttpRequestController.GetResponseSayHiList(&mHttpRequestManager,
                                                                     type,
                                                                     start,
                                                                     step,
                                                                     &gRequestGetResponseSayHiListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSayHiDetailCallbackImp : public IRequestSayHiDetailCallback {
public:
    RequestSayHiDetailCallbackImp(){};
    ~RequestSayHiDetailCallbackImp(){};
    void OnSayHiDetail(HttpSayHiDetailTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiDetailItem& item) {
        NSLog(@"LSRequestManager::OnSayHiDetail( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        LSSayHiDetailInfoItemObject* obj = [[LSSayHiDetailInfoItemObject alloc] init];
        LSSayHiDetailItemObject* detailObj = [[LSSayHiDetailItemObject alloc] init];
        detailObj.sayHiId = [NSString stringWithUTF8String:item.detail.sayHiId.c_str()];
        detailObj.anchorId = [NSString stringWithUTF8String:item.detail.anchorId.c_str()];
        detailObj.nickName = [NSString stringWithUTF8String:item.detail.nickName.c_str()];
        detailObj.cover = [NSString stringWithUTF8String:item.detail.cover.c_str()];
        detailObj.avatar = [NSString stringWithUTF8String:item.detail.avatar.c_str()];
        detailObj.age = item.detail.age;
        detailObj.sendTime = item.detail.sendTime;
        detailObj.text = [NSString stringWithUTF8String:item.detail.text.c_str()];
        detailObj.img = [NSString stringWithUTF8String:item.detail.img.c_str()];
        detailObj.responseNum = item.detail.responseNum;
        detailObj.unreadNum = item.detail.unreadNum;
        obj.detail = detailObj;
        NSMutableArray* arrayList = [NSMutableArray array];
        for(HttpSayHiDetailItem::ResponseSayHiDetailList::const_iterator iter = item.responseList.begin(); iter != item.responseList.end(); iter++) {
            LSSayHiDetailResponseListItemObject* responseItem = [[LSSayHiDetailResponseListItemObject alloc] init];
            responseItem.responseId = [NSString stringWithUTF8String:(*iter).responseId.c_str()];
            responseItem.responseTime = (*iter).responseTime;
            responseItem.simpleContent = [NSString stringWithUTF8String:(*iter).simpleContent.c_str()];
            responseItem.content = [NSString stringWithUTF8String:(*iter).content.c_str()];
            responseItem.isFree = (*iter).isFree;
            responseItem.hasRead = (*iter).hasRead;
            responseItem.hasImg = (*iter).hasImg;
            responseItem.img = [NSString stringWithUTF8String:(*iter).img.c_str()];
            [arrayList addObject:responseItem];
        }
        obj.responseList = arrayList;
        
        SayHiDetailFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestSayHiDetailCallbackImp gRequestSayHiDetailCallbackImp;
- (NSInteger)sayHiDetail:(LSSayHiDetailType)type
                 sayHiId:(NSString*)sayHiId
           finishHandler:(SayHiDetailFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strSayHiId = "";
    if (sayHiId != nil) {
        strSayHiId = [sayHiId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.SayHiDetail(&mHttpRequestManager,
                                                            type,
                                                            strSayHiId,
                                                            &gRequestSayHiDetailCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestReadResponseCallbackImp : public IRequestReadResponseCallback {
public:
    RequestReadResponseCallbackImp(){};
    ~RequestReadResponseCallbackImp(){};
    void OnReadResponse(HttpReadResponseTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiDetailItem::ResponseSayHiDetailItem& responseItem) {
        NSLog(@"LSRequestManager::OnReadResponse( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSSayHiDetailResponseListItemObject* obj = [[LSSayHiDetailResponseListItemObject alloc] init];
        obj.responseId = [NSString stringWithUTF8String:responseItem.responseId.c_str()];
        obj.responseTime = responseItem.responseTime;
        obj.content = [NSString stringWithUTF8String:responseItem.content.c_str()];
        obj.isFree = responseItem.isFree;
        obj.hasRead = responseItem.hasRead;
        obj.hasImg = responseItem.hasImg;
        obj.img = [NSString stringWithUTF8String:responseItem.img.c_str()];
        
        ReadResponseFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestReadResponseCallbackImp gRequestReadResponseCallbackImp;

- (NSInteger)readResponse:(NSString*)sayHiId
               responseId:(NSString*)responseId
            finishHandler:(ReadResponseFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strSayHiId = "";
    if (sayHiId != nil) {
        strSayHiId = [sayHiId UTF8String];
    }
    
    string strResponseId = "";
    if (responseId != nil) {
        strResponseId = [responseId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.ReadResponse(&mHttpRequestManager,
                                                             strSayHiId,
                                                             strResponseId,
                                                             &gRequestReadResponseCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestUpQnInviteIdCallbackImp : public IRequestUpQnInviteIdCallback {
public:
    RequestUpQnInviteIdCallbackImp(){};
    ~RequestUpQnInviteIdCallbackImp(){};
    void OnUpQnInviteId(HttpUpQnInviteIdTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnUpQnInviteId( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
    
        
        UpQnInviteIdFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestUpQnInviteIdCallbackImp gRequestUpQnInviteIdCallbackImp;

- (NSInteger)upQnInviteId:(NSString*)manId
                 anchorId:(NSString*)anchorId
                 inviteId:(NSString*)inviteId
                   roomId:(NSString*)roomId
               inviteType:(LSBubblingInviteType)inviteType
            finishHandler:(UpQnInviteIdFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strManId = "";
    if (manId != nil) {
        strManId = [manId UTF8String];
    }
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    string strInviteId = "";
    if (inviteId != nil) {
        strInviteId = [inviteId UTF8String];
    }
    
    string strRoomId = "";
    if (roomId != nil) {
        strRoomId = [roomId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.UpQnInviteId(&mHttpRequestManager,
                                                             strManId,
                                                             strAnchorId,
                                                             strInviteId,
                                                             strRoomId,
                                                             inviteType,
                                                             &gRequestUpQnInviteIdCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestRetrieveBannerCallbackImp : public IRequestRetrieveBannerCallback {
public:
    RequestRetrieveBannerCallbackImp(){};
    ~RequestRetrieveBannerCallbackImp(){};
    void OnRetrieveBanner(HttpRetrieveBannerTask* task, bool success, int errnum, const string& errmsg, const string& url) {
        NSLog(@"LSRequestManager::OnRetrieveBanner( task : %p, success : %s, errnum : %d, errmsg : %s, url : %s)", task, success ? "true" : "false", errnum, errmsg.c_str(), url.c_str());
        
        
        RetrieveBannerFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:url.c_str()]);
        }
    }
};

RequestRetrieveBannerCallbackImp gRequestRetrieveBannerCallbackImp;

- (NSInteger)retrieveBanner:(NSString*)manId
               isAnchorPage:(BOOL)isAnchorPage
                 bannerType:(LSBannerType)bannerType
              finishHandler:(RetrieveBannerFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strManId = "";
    if (manId != nil) {
        strManId = [manId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.RetrieveBanner(&mHttpRequestManager,
                                                               strManId,
                                                               isAnchorPage,
                                                               bannerType,
                                                               &gRequestRetrieveBannerCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 鲜花礼品
class RequestGetStoreGiftListCallbackImp : public IRequestGetStoreGiftListCallback {
public:
    RequestGetStoreGiftListCallbackImp(){};
    ~RequestGetStoreGiftListCallbackImp(){};
    void OnGetStoreGiftList(HttpGetStoreGiftListTask* task, bool success, int errnum, const string& errmsg, const StoreFlowerGiftList& list) {
        NSLog(@"LSRequestManager::OnGetStoreGiftList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* arrayList = [NSMutableArray array];
        for(StoreFlowerGiftList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSStoreFlowerGiftItemObject* item = [[LSStoreFlowerGiftItemObject alloc] init];
            item.typeId = [NSString stringWithUTF8String:(*iter).typeId.c_str()];
            item.typeName = [NSString stringWithUTF8String:(*iter).typeName.c_str()];
            item.isHasGreeting = (*iter).isHasGreeting;
            
            NSMutableArray* GiftList = [NSMutableArray array];
            for(FlowerGiftList::const_iterator giftIter = (*iter).giftList.begin(); giftIter != (*iter).giftList.end(); giftIter++) {
                LSFlowerGiftItemObject* giftItem = [[LSFlowerGiftItemObject alloc] init];
                giftItem.typeId = [NSString stringWithUTF8String:(*giftIter).typeId.c_str()];
                giftItem.giftId = [NSString stringWithUTF8String:(*giftIter).giftId.c_str()];
                giftItem.giftName = [NSString stringWithUTF8String:(*giftIter).giftName.c_str()];
                giftItem.giftImg = [NSString stringWithUTF8String:(*giftIter).giftImg.c_str()];
                giftItem.priceShowType = (*giftIter).priceShowType;
                giftItem.giftWeekdayPrice = (*giftIter).giftWeekdayPrice;
                giftItem.giftDiscountPrice = (*giftIter).giftDiscountPrice;
                giftItem.giftPrice = (*giftIter).giftPrice;
                giftItem.giftDiscount = (*giftIter).giftDiscount;
                giftItem.isNew = (*giftIter).isNew;
                NSMutableArray* CountryList = [NSMutableArray array];
                for(CountryList::const_iterator countryIter = (*giftIter).deliverableCountry.begin(); countryIter != (*giftIter).deliverableCountry.end(); countryIter++) {
                    NSString *strCountry = [NSString stringWithUTF8String:(*countryIter).c_str()];
                    [CountryList addObject:strCountry];
                }
                giftItem.deliverableCountry = CountryList;
                giftItem.giftDescription = [NSString stringWithUTF8String:(*giftIter).giftDescription.c_str()];
                [GiftList addObject:giftItem];
            }
            item.giftList = GiftList;
            
            
            [arrayList addObject:item];
        }
        
        
        GetStoreGiftListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], arrayList);
        }
    }
};

RequestGetStoreGiftListCallbackImp gRequestGetStoreGiftListCallbackImp;

- (NSInteger)getStoreGiftList:(NSString*)anchorId
                finishHandler:(GetStoreGiftListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetStoreGiftList(&mHttpRequestManager,
                                                               strAnchorId,
                                                               &gRequestGetStoreGiftListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetFlowerGiftDetailCallbackImp : public IRequestGetFlowerGiftDetailCallback {
public:
    RequestGetFlowerGiftDetailCallbackImp(){};
    ~RequestGetFlowerGiftDetailCallbackImp(){};
    void OnGetFlowerGiftDetail(HttpGetFlowerGiftDetailTask* task, bool success, int errnum, const string& errmsg, const HttpFlowerGiftItem& item) {
        NSLog(@"LSRequestManager::OnGetFlowerGiftDetail( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        LSFlowerGiftItemObject* giftItem = [[LSFlowerGiftItemObject alloc] init];
        giftItem.typeId = [NSString stringWithUTF8String:item.typeId.c_str()];
        giftItem.giftId = [NSString stringWithUTF8String:item.giftId.c_str()];
        giftItem.giftName = [NSString stringWithUTF8String:item.giftName.c_str()];
        giftItem.giftImg = [NSString stringWithUTF8String:item.giftImg.c_str()];
        giftItem.priceShowType = item.priceShowType;
        giftItem.giftWeekdayPrice = item.giftWeekdayPrice;
        giftItem.giftDiscountPrice = item.giftDiscountPrice;
        giftItem.giftPrice = item.giftPrice;
        giftItem.giftDiscount = item.giftDiscount;
        giftItem.isNew = item.isNew;
        NSMutableArray* CountryList = [NSMutableArray array];
        for(CountryList::const_iterator countryIter = item.deliverableCountry.begin(); countryIter != item.deliverableCountry.end(); countryIter++) {
            NSString *strCountry = [NSString stringWithUTF8String:(*countryIter).c_str()];
            [CountryList addObject:strCountry];
        }
        giftItem.deliverableCountry = CountryList;
        giftItem.giftDescription = [NSString stringWithUTF8String:item.giftDescription.c_str()];
        
        GetFlowerGiftDetailFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], giftItem);
        }
    }
};

RequestGetFlowerGiftDetailCallbackImp gRequestGetFlowerGiftDetailCallbackImp;

- (NSInteger)getFlowerGiftDetail:(NSString*)giftId
                   finishHandler:(GetFlowerGiftDetailFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strGiftId = "";
    if (giftId != nil) {
        strGiftId = [giftId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetFlowerGiftDetail(&mHttpRequestManager,
                                                                 strGiftId,
                                                                 &gRequestGetFlowerGiftDetailCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetRecommendGiftListCallbackImp : public IRequestGetRecommendGiftListCallback {
public:
    RequestGetRecommendGiftListCallbackImp(){};
    ~RequestGetRecommendGiftListCallbackImp(){};
    void OnGetRecommendGiftList(HttpGetRecommendGiftListTask* task, bool success, int errnum, const string& errmsg, const FlowerGiftList& list) {
        NSLog(@"LSRequestManager::OnGetRecommendGiftList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* GiftList = [NSMutableArray array];
        for(FlowerGiftList::const_iterator giftIter = list.begin(); giftIter != list.end(); giftIter++) {
            LSFlowerGiftItemObject* giftItem = [[LSFlowerGiftItemObject alloc] init];
            giftItem.typeId = [NSString stringWithUTF8String:(*giftIter).typeId.c_str()];
            giftItem.giftId = [NSString stringWithUTF8String:(*giftIter).giftId.c_str()];
            giftItem.giftName = [NSString stringWithUTF8String:(*giftIter).giftName.c_str()];
            giftItem.giftImg = [NSString stringWithUTF8String:(*giftIter).giftImg.c_str()];
            giftItem.priceShowType = (*giftIter).priceShowType;
            giftItem.giftWeekdayPrice = (*giftIter).giftWeekdayPrice;
            giftItem.giftDiscountPrice = (*giftIter).giftDiscountPrice;
            giftItem.giftPrice = (*giftIter).giftPrice;
            giftItem.giftDiscount = (*giftIter).giftDiscount;
            giftItem.isNew = (*giftIter).isNew;
            NSMutableArray* CountryList = [NSMutableArray array];
            for(CountryList::const_iterator countryIter = (*giftIter).deliverableCountry.begin(); countryIter != (*giftIter).deliverableCountry.end(); countryIter++) {
                NSString *strCountry = [NSString stringWithUTF8String:(*countryIter).c_str()];
                [CountryList addObject:strCountry];
            }
            giftItem.deliverableCountry = CountryList;
            giftItem.giftDescription = [NSString stringWithUTF8String:(*giftIter).giftDescription.c_str()];
            [GiftList addObject:giftItem];
        }

        
        GetRecommendGiftListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], GiftList);
        }
    }
};

RequestGetRecommendGiftListCallbackImp gRequestGetRecommendGiftListCallbackImp;

- (NSInteger)getRecommendGiftList:(NSString*)giftId
                         anchorId:(NSString*)anchorId
                           number:(int)number
                    finishHandler:(GetRecommendGiftListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    string strGiftId = "";
    if (giftId != nil) {
        strGiftId = [giftId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetRecommendGiftList(&mHttpRequestManager,
                                                                    strAnchorId,
                                                                    strGiftId,
                                                                    number,
                                                                    &gRequestGetRecommendGiftListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetResentRecipientListCallbackImp : public IRequestGetResentRecipientListCallback {
public:
    RequestGetResentRecipientListCallbackImp(){};
    ~RequestGetResentRecipientListCallbackImp(){};
    void OnGetResentRecipientList(HttpGetResentRecipientListTask* task, bool success, int errnum, const string& errmsg, const RecipientAnchorList& list) {
        NSLog(@"LSRequestManager::OnGetResentRecipientList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* anchorList = [NSMutableArray array];
        for(RecipientAnchorList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSRecipientAnchorItemObject* item = [[LSRecipientAnchorItemObject alloc] init];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNickName = [NSString stringWithUTF8String:(*iter).anchorNickName.c_str()];
            item.anchorAvatarImg = [NSString stringWithUTF8String:(*iter).anchorAvatarImg.c_str()];
            item.anchorAge = (*iter).anchorAge;;
            [anchorList addObject:item];
        }
        GetResentRecipientListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], anchorList);
        }
    }
};

RequestGetResentRecipientListCallbackImp gRequestGetResentRecipientListCallbackImp;

- (NSInteger)getResentRecipientList:(GetResentRecipientListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetResentRecipientList(&mHttpRequestManager,
                                                                     &gRequestGetResentRecipientListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetDeliveryListCallbackImp : public IRequestGetDeliveryListCallback {
public:
    RequestGetDeliveryListCallbackImp(){};
    ~RequestGetDeliveryListCallbackImp(){};
    void OnGetDeliveryList(HttpGetDeliveryListTask* task, bool success, int errnum, const string& errmsg, const DeliveryList& list) {
        NSLog(@"LSRequestManager::OnGetDeliveryList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* arrayList = [NSMutableArray array];
        for(DeliveryList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSDeliveryItemObject* item = [[LSDeliveryItemObject alloc] init];
            item.orderNumber = [NSString stringWithUTF8String:(*iter).orderNumber.c_str()];
            item.orderDate = (*iter).orderDate;
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNickName = [NSString stringWithUTF8String:(*iter).anchorNickName.c_str()];
            item.anchorAvatar = [NSString stringWithUTF8String:(*iter).anchorAvatar.c_str()];
            item.deliveryStatus = (*iter).deliveryStatus;
            item.deliveryStatusVal = [NSString stringWithUTF8String:(*iter).deliveryStatusVal.c_str()];
            item.greetingMessage = [NSString stringWithUTF8String:(*iter).greetingMessage.c_str()];
            item.specialDeliveryRequest = [NSString stringWithUTF8String:(*iter).specialDeliveryRequest.c_str()];
            NSMutableArray* giftList = [NSMutableArray array];
            for(DeliveryFlowerGiftList::const_iterator giftIter = (*iter).giftList.begin(); giftIter != (*iter).giftList.end(); giftIter++) {
                LSFlowerGiftBaseInfoItemObject* giftItem = [[LSFlowerGiftBaseInfoItemObject alloc] init];
                giftItem.giftId = [NSString stringWithUTF8String:(*giftIter).giftId.c_str()];
                giftItem.giftName = [NSString stringWithUTF8String:(*giftIter).giftName.c_str()];
                giftItem.giftImg = [NSString stringWithUTF8String:(*giftIter).giftImg.c_str()];
                giftItem.giftNumber = (*giftIter).giftNumber;
                giftItem.giftPrice = (*giftIter).giftPrice;
                [giftList addObject:giftItem];
            }
            item.giftList = giftList;
            [arrayList addObject:item];
        }
        GetDeliveryListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], arrayList);
        }
    }
};

RequestGetDeliveryListCallbackImp gRequestGetDeliveryListCallbackImp;

- (NSInteger)getDeliveryList:(GetDeliveryListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetDeliveryList(&mHttpRequestManager,
                                                                       &gRequestGetDeliveryListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetCartGiftTypeNumCallbackImp : public IRequestGetCartGiftTypeNumCallback {
public:
    RequestGetCartGiftTypeNumCallbackImp(){};
    ~RequestGetCartGiftTypeNumCallbackImp(){};
    void OnGetCartGiftTypeNum(HttpGetCartGiftTypeNumTask* task, bool success, int errnum, const string& errmsg, int num) {
        NSLog(@"LSRequestManager::OnGetCartGiftTypeNum( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        GetCartGiftTypeNumFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], num);
        }
    }
};

RequestGetCartGiftTypeNumCallbackImp gRequestGetCartGiftTypeNumCallbackImp;

- (NSInteger)getCartGiftTypeNum:(NSString*)anchorId
                  finishHandler:(GetCartGiftTypeNumFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetCartGiftTypeNum(&mHttpRequestManager,
                                                                     strAnchorId,
                                                                     &gRequestGetCartGiftTypeNumCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetCartGiftListCallbackImp : public IRequestGetCartGiftListCallback {
public:
    RequestGetCartGiftListCallbackImp(){};
    ~RequestGetCartGiftListCallbackImp(){};
    void OnGetCartGiftList(HttpGetCartGiftListTask* task, bool success, int errnum, const string& errmsg, int total, const MyCartItemList& list) {
        NSLog(@"LSRequestManager::OnGetCartGiftList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* arrayList = [NSMutableArray array];
        for(MyCartItemList::const_iterator iter = list.begin(); iter != list.end(); iter++) {

            LSMyCartItemObject* item = [[LSMyCartItemObject alloc] init];
            LSRecipientAnchorItemObject* anchorItem = [[LSRecipientAnchorItemObject alloc] init];
            anchorItem.anchorId = [NSString stringWithUTF8String:(*iter).anchorItem.anchorId.c_str()];
            anchorItem.anchorNickName = [NSString stringWithUTF8String:(*iter).anchorItem.anchorNickName.c_str()];
            anchorItem.anchorAvatarImg = [NSString stringWithUTF8String:(*iter).anchorItem.anchorAvatarImg.c_str()];
            anchorItem.anchorAge = (*iter).anchorItem.anchorAge;
            item.anchorItem = anchorItem;

            NSMutableArray* giftList = [NSMutableArray array];
            for(DeliveryFlowerGiftList::const_iterator giftIter = (*iter).giftList.begin(); giftIter != (*iter).giftList.end(); giftIter++) {
                LSFlowerGiftBaseInfoItemObject* giftItem = [[LSFlowerGiftBaseInfoItemObject alloc] init];
                giftItem.giftId = [NSString stringWithUTF8String:(*giftIter).giftId.c_str()];
                giftItem.giftName = [NSString stringWithUTF8String:(*giftIter).giftName.c_str()];
                giftItem.giftImg = [NSString stringWithUTF8String:(*giftIter).giftImg.c_str()];
                giftItem.giftNumber = (*giftIter).giftNumber;
                giftItem.giftPrice = (*giftIter).giftPrice;
                [giftList addObject:giftItem];
            }
            item.giftList = giftList;
            [arrayList addObject:item];
        }
        
        GetCartGiftListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], total, arrayList);
        }
    }
};

RequestGetCartGiftListCallbackImp gRequestGetCartGiftListCallbackImp;

- (NSInteger)getCartGiftList:(int)start
                        step:(int)step
               finishHandler:(GetCartGiftListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetCartGiftList(&mHttpRequestManager,
                                                                   start,
                                                                   step,
                                                                   &gRequestGetCartGiftListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestAddCartGiftCallbackImp : public IRequestAddCartGiftCallback {
public:
    RequestAddCartGiftCallbackImp(){};
    ~RequestAddCartGiftCallbackImp(){};
    void OnAddCartGift(HttpAddCartGiftTask* task, bool success, int errnum, const string& errmsg, int status) {
        NSLog(@"LSRequestManager::OnAddCartGift( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        AddCartGiftFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestAddCartGiftCallbackImp gRequestAddCartGiftCallbackImp;

- (NSInteger)addCartGift:(NSString*)anchorId
                  giftId:(NSString*)giftId
           finishHandler:(AddCartGiftFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    string strGiftId = "";
    if (giftId != nil) {
        strGiftId = [giftId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.AddCartGift(&mHttpRequestManager,
                                                            strAnchorId,
                                                            strGiftId,
                                                            &gRequestAddCartGiftCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestChangeCartGiftNumberCallbackImp : public IRequestChangeCartGiftNumberCallback {
public:
    RequestChangeCartGiftNumberCallbackImp(){};
    ~RequestChangeCartGiftNumberCallbackImp(){};
    void OnChangeCartGiftNumber(HttpChangeCartGiftNumberTask* task, bool success, int errnum, const string& errmsg, int status) {
        NSLog(@"LSRequestManager::OnChangeCartGiftNumber( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        ChangeCartGiftNumberFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestChangeCartGiftNumberCallbackImp gRequestChangeCartGiftNumberCallbackImp;

- (NSInteger)changeCartGiftNumber:(NSString*)anchorId
                           giftId:(NSString*)giftId
                       giftNumber:(int)giftNumber
                    finishHandler:(ChangeCartGiftNumberFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    string strGiftId = "";
    if (giftId != nil) {
        strGiftId = [giftId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.ChangeCartGiftNumber(&mHttpRequestManager,
                                                            strAnchorId,
                                                            strGiftId,
                                                            giftNumber,
                                                            &gRequestChangeCartGiftNumberCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestRemoveCartGiftCallbackImp : public IRequestRemoveCartGiftCallback {
public:
    RequestRemoveCartGiftCallbackImp(){};
    ~RequestRemoveCartGiftCallbackImp(){};
    void OnRemoveCartGift(HttpRemoveCartGiftTask* task, bool success, int errnum, const string& errmsg, int status) {
        NSLog(@"LSRequestManager::OnRemoveCartGift( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        RemoveCartGiftFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestRemoveCartGiftCallbackImp gRequestRemoveCartGiftCallbackImp;

- (NSInteger)removeCartGift:(NSString*)anchorId
                     giftId:(NSString*)giftId
              finishHandler:(RemoveCartGiftFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    string strGiftId = "";
    if (giftId != nil) {
        strGiftId = [giftId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.RemoveCartGift(&mHttpRequestManager,
                                                                     strAnchorId,
                                                                     strGiftId,
                                                                     &gRequestRemoveCartGiftCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestCheckOutCartGiftCallbackImp : public IRequestCheckOutCartGiftCallback {
public:
    RequestCheckOutCartGiftCallbackImp(){};
    ~RequestCheckOutCartGiftCallbackImp(){};
    void OnCheckOutCartGift(HttpCheckOutCartGiftTask* task, bool success, int errnum, const string& errmsg, const HttpCheckoutItem& item) {
        NSLog(@"LSRequestManager::OnCheckOutCartGift( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSCheckoutItemObject* obj = [[LSCheckoutItemObject alloc] init];
        NSMutableArray* giftList = [NSMutableArray array];
        for(CheckoutFlowerGiftList::const_iterator giftIter = item.giftList.begin(); giftIter != item.giftList.end(); giftIter++) {
            LSCheckoutGiftItemObject* giftItem = [[LSCheckoutGiftItemObject alloc] init];
            giftItem.giftId = [NSString stringWithUTF8String:(*giftIter).giftId.c_str()];
            giftItem.giftName = [NSString stringWithUTF8String:(*giftIter).giftName.c_str()];
            giftItem.giftImg = [NSString stringWithUTF8String:(*giftIter).giftImg.c_str()];
            giftItem.giftNumber = (*giftIter).giftNumber;
            giftItem.giftPrice = (*giftIter).giftPrice;
            giftItem.giftstatus = (*giftIter).giftstatus;
            giftItem.isGreetingCard = (*giftIter).isGreetingCard;
            [giftList addObject:giftItem];
        }
        obj.giftList = giftList;
        LSGreetingCardItemObject* greetingItem = [[LSGreetingCardItemObject alloc] init];
        greetingItem.giftId = [NSString stringWithUTF8String:item.greetingCard.giftId.c_str()];
        greetingItem.giftName = [NSString stringWithUTF8String:item.greetingCard.giftName.c_str()];
        greetingItem.giftNumber = item.greetingCard.giftNumber;
        greetingItem.isBirthday = item.greetingCard.isBirthday;
        greetingItem.giftPrice = item.greetingCard.giftPrice;
        greetingItem.giftImg = [NSString stringWithUTF8String:item.greetingCard.giftImg.c_str()];
        obj.greetingCard = greetingItem;
        
        obj.deliveryPrice = item.deliveryPrice;
        obj.holidayName = [NSString stringWithUTF8String:item.holidayName.c_str()];
        obj.holidayPrice = item.holidayPrice;
        obj.totalPrice = item.totalPrice;
        
        obj.greetingmessage = [NSString stringWithUTF8String:item.greetingmessage.c_str()];
        obj.specialDeliveryRequest = [NSString stringWithUTF8String:item.specialDeliveryRequest.c_str()];

        
        CheckOutCartGiftFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestCheckOutCartGiftCallbackImp gRequestCheckOutCartGiftCallbackImp;

- (NSInteger)checkOutCartGift:(NSString*)anchorId
                finishHandler:(CheckOutCartGiftFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.CheckOutCartGift(&mHttpRequestManager,
                                                               strAnchorId,
                                                               &gRequestCheckOutCartGiftCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestCreateGiftOrderCallbackImp : public IRequestCreateGiftOrderCallback {
public:
    RequestCreateGiftOrderCallbackImp(){};
    ~RequestCreateGiftOrderCallbackImp(){};
    void OnCreateGiftOrder(HttpCreateGiftOrderTask* task, bool success, int errnum, const string& errmsg, const string& orderNumber) {
        NSLog(@"LSRequestManager::OnCreateGiftOrder( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        CreateGiftOrderFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:orderNumber.c_str()]);
        }
    }
};

RequestCreateGiftOrderCallbackImp gRequestCreateGiftOrderCallbackImp;

- (NSInteger)createGiftOrder:(NSString*)anchorId
             greetingMessage:(NSString*)greetingMessage
      specialDeliveryRequest:(NSString*)specialDeliveryRequest
               finishHandler:(CreateGiftOrderFinishHandler)finishHandler{
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    string strGreetingMessage = "";
    if (greetingMessage != nil) {
        strGreetingMessage = [greetingMessage UTF8String];
    }
    
    string strSpecialDeliveryRequest = "";
    if (specialDeliveryRequest != nil) {
        strSpecialDeliveryRequest = [specialDeliveryRequest UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.CreateGiftOrder(&mHttpRequestManager,
                                                                 strAnchorId,
                                                                strGreetingMessage,
                                                                strSpecialDeliveryRequest,
                                                                 &gRequestCreateGiftOrderCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestCheckDiscountCallbackImp : public IRequestCheckDiscountCallback {
public:
    RequestCheckDiscountCallbackImp(){};
    ~RequestCheckDiscountCallbackImp(){};
    void OnCheckDiscount(HttpCheckDiscountTask* task, bool success, int errnum, const string& errmsg, const HttpCheckDiscountItem& item) {
        NSLog(@"LSRequestManager::OnCheckDiscount( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSCheckDiscountItemObject* obj = [[LSCheckDiscountItemObject alloc] init];
        obj.type = item.type;
        obj.name = [NSString stringWithUTF8String:item.name.c_str()];
        obj.discount = item.discount;
        obj.imgUrl = [NSString stringWithUTF8String:item.imgUrl.c_str()];
        
        
        CheckDiscountFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestCheckDiscountCallbackImp gRequestCheckDiscountCallbackImp;

- (NSInteger)checkDiscount:(NSString*)anchorId
             finishHandler:(CheckDiscountFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strAnchorId = "";
    if (anchorId != nil) {
        strAnchorId = [anchorId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.CheckDiscount(&mHttpRequestManager,
                                                                 strAnchorId,
                                                                 &gRequestCheckDiscountCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 广告模块回调

class RequestWomanListAdvertCallbackImp : public IRequestWomanListAdvertCallback {
public:
    RequestWomanListAdvertCallbackImp(){};
    ~RequestWomanListAdvertCallbackImp(){};
    void OnWomanListAdvert(HttpWomanListAdvertTask* task, bool success, int errnum, const string& errmsg, const HttpAdWomanListAdvertItem& advertItem) {
        NSLog(@"LSRequestManager::OnWomanListAdvert( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSWomanListAdItemObject* obj = [[LSWomanListAdItemObject alloc] init];
        obj.advertId = [NSString stringWithUTF8String:advertItem.advertId.c_str()];
        obj.image = [NSString stringWithUTF8String:advertItem.image.c_str()];
        obj.width = advertItem.width;
        obj.height = advertItem.height;
        obj.adurl = [NSString stringWithUTF8String:advertItem.adurl.c_str()];
        obj.openType = advertItem.openType;
        obj.advertTitle = [NSString stringWithUTF8String:advertItem.advertTitle.c_str()];
        
        WonmanListAdvertFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestWomanListAdvertCallbackImp gRequestWomanListAdvertCallbackImp;

- (NSInteger)wonmanListAdvert:(WonmanListAdvertFinishHandler )finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string deviceId = "";
    if ([self getDeviceId] != nil) {
        deviceId = [[self getDeviceId] UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.WomanListAdvert(&mHttpRequestManager,
                                                                deviceId,
                                                                LSAD_SPACE_TYPE_IOS,
                                                                &gRequestWomanListAdvertCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 预付费直播

class RequestGetScheduleDurationListCallbackImp : public IRequestGetScheduleDurationListCallback {
public:
    RequestGetScheduleDurationListCallbackImp(){};
    ~RequestGetScheduleDurationListCallbackImp(){};
    void OnGetScheduleDurationList(HttpGetScheduleDurationListTask* task, bool success, int errnum, const string& errmsg, const ScheduleDurationList& list) {
        NSLog(@"LSRequestManager::OnGetScheduleDurationList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* giftList = [NSMutableArray array];
        for(ScheduleDurationList::const_iterator giftIter = list.begin(); giftIter != list.end(); giftIter++) {
            LSScheduleDurationItemObject* giftItem = [[LSScheduleDurationItemObject alloc] init];
            giftItem.duration = (*giftIter).duration;
            giftItem.isDefault = (*giftIter).isDefault;
            giftItem.credit = (*giftIter).credit;
            giftItem.originalCredit = (*giftIter).originalCredit;
            [giftList addObject:giftItem];
        }
        
        GetScheduleDurationListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], giftList);
        }
    }
};

RequestGetScheduleDurationListCallbackImp gRequestGetScheduleDurationListCallbackImp;

- (NSInteger)getScheduleDurationList:(GetScheduleDurationListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetScheduleDurationList(&mHttpRequestManager,
                                                                &gRequestGetScheduleDurationListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestGetCountryTimeZoneListCallbackImp : public IRequestGetCountryTimeZoneListCallback {
public:
    RequestGetCountryTimeZoneListCallbackImp(){};
    ~RequestGetCountryTimeZoneListCallbackImp(){};
    void OnGetCountryTimeZoneList(HttpGetCountryTimeZoneListTask* task, bool success, int errnum, const string& errmsg, const CountryTimeZoneList& list) {
        NSLog(@"LSRequestManager::OnGetCountryTimeZoneList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* giftList = [NSMutableArray array];
        for(CountryTimeZoneList::const_iterator giftIter = list.begin(); giftIter != list.end(); giftIter++) {
            LSCountryTimeZoneItemObject* giftItem = [[LSCountryTimeZoneItemObject alloc] init];
            giftItem.countryCode = [NSString stringWithUTF8String:(*giftIter).countryCode.c_str()];
            giftItem.countryName = [NSString stringWithUTF8String:(*giftIter).countryName.c_str()];
            giftItem.isDefault = (*giftIter).isDefault;
            NSMutableArray* androidList = [NSMutableArray array];
            for(TimeZoneList::const_iterator androidIter = (*giftIter).timeZoneList.begin(); androidIter != (*giftIter).timeZoneList.end(); androidIter++) {
                LSTimeZoneItemObject* androidItem = [[LSTimeZoneItemObject alloc] init];
                androidItem.zoneId = [NSString stringWithUTF8String:(*androidIter).zoneId.c_str()];
                androidItem.value = [NSString stringWithUTF8String:(*androidIter).value.c_str()];
                androidItem.city = [NSString stringWithUTF8String:(*androidIter).city.c_str()];
                androidItem.cityCode = [NSString stringWithUTF8String:(*androidIter).cityCode.c_str()];
                androidItem.summerTimeStart = (*androidIter).summerTimeStart;
                androidItem.summerTimeEnd = (*androidIter).summerTimeEnd;
                [androidList addObject:androidItem];
            }
            giftItem.timeZoneList = androidList;
            [giftList addObject:giftItem];
        }
        
        GetCountryTimeZoneListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], giftList);
        }
    }
};

RequestGetCountryTimeZoneListCallbackImp gRequestGetCountryTimeZoneListCallbackImp;

- (NSInteger)getCountryTimeZoneList:(GetCountryTimeZoneListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetCountryTimeZoneList(&mHttpRequestManager,
                                                                &gRequestGetCountryTimeZoneListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestSendScheduleInviteCallbackImp : public IRequestSendScheduleInviteCallback {
public:
    RequestSendScheduleInviteCallbackImp(){};
    ~RequestSendScheduleInviteCallbackImp(){};
    void OnSendScheduleInvite(HttpSendScheduleInviteTask* task, bool success, int errnum, const string& errmsg, const HttpScheduleInviteItem& item, long long activityTime) {
        NSLog(@"LSRequestManager::OnSendScheduleInvite( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSSendScheduleInviteItemObject* obj = [[LSSendScheduleInviteItemObject alloc] init];
        obj.inviteId = [NSString stringWithUTF8String:item.inviteId.c_str()];
        obj.isSummerTime = item.isSummerTime;
        obj.startTime = item.startTime;
        obj.addTime = item.addTime;
        
        SendScheduleInviteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj, activityTime);
        }
    }
};

RequestSendScheduleInviteCallbackImp gRequestSendScheduleInviteCallbackImp;

- (NSInteger)sendScheduleInvite:(LSScheduleInviteType)type
                          refId:(NSString*)refId
                       anchorId:(NSString*)anchorId
                     timeZoneId:(NSString*)timeZoneId
                      startTime:(NSString*)startTime
                       duration:(int)duration
                  finishHandler:(SendScheduleInviteFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strrefId = "";
    if (refId != nil) {
        strrefId = [refId UTF8String];
    }
    
    string stranchorId = "";
    if (anchorId != nil) {
        stranchorId = [anchorId UTF8String];
    }
    
    string strtimeZoneId = "";
    if (timeZoneId != nil) {
        strtimeZoneId = [timeZoneId UTF8String];
    }
    
    string strstartTime = "";
    if (startTime != nil) {
        strstartTime = [startTime UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.SendScheduleInvite(&mHttpRequestManager,
                                                                   type,
                                                                   strrefId,
                                                                   stranchorId,
                                                                   strtimeZoneId,
                                                                   strstartTime,
                                                                   duration,
                                                                   &gRequestSendScheduleInviteCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestAcceptScheduleInviteCallbackImp : public IRequestAcceptScheduleInviteCallback {
public:
    RequestAcceptScheduleInviteCallbackImp(){};
    ~RequestAcceptScheduleInviteCallbackImp(){};
    void OnAcceptScheduleInvite(HttpAcceptScheduleInviteTask* task, bool success, int errnum, const string& errmsg, long long starusUpdateTime, int duration) {
        NSLog(@"LSRequestManager::OnAcceptScheduleInvite( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        AcceptScheduleInviteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], (NSInteger)starusUpdateTime, duration);
        }
    }
};

RequestAcceptScheduleInviteCallbackImp gRequestAcceptScheduleInviteCallbackImp;

- (NSInteger)acceptScheduleInvite:(NSString*)inviteId
                         duration:(int)duration
                    finishHandler:(AcceptScheduleInviteFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strinviteId = "";
    if (inviteId != nil) {
        strinviteId = [inviteId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.AcceptScheduleInvite(&mHttpRequestManager,
                                                                     strinviteId,
                                                                     duration,
                                                                     &gRequestAcceptScheduleInviteCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestDeclinedScheduleInviteCallbackImp : public IRequestDeclinedScheduleInviteCallback {
public:
    RequestDeclinedScheduleInviteCallbackImp(){};
    ~RequestDeclinedScheduleInviteCallbackImp(){};
    void OnDeclinedScheduleInvite(HttpDeclinedScheduleInviteTask* task, bool success, int errnum, const string& errmsg, long long starusUpdateTime) {
        NSLog(@"LSRequestManager::OnDeclinedScheduleInvite( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        DeclinedScheduleInviteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], starusUpdateTime);
        }
    }
};

RequestDeclinedScheduleInviteCallbackImp gRequestDeclinedScheduleInviteCallbackImp;

- (NSInteger)declinedScheduleInvite:(NSString*)inviteId
                      finishHandler:(DeclinedScheduleInviteFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strinviteId = "";
    if (inviteId != nil) {
        strinviteId = [inviteId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.DeclinedScheduleInvite(&mHttpRequestManager,
                                                                       strinviteId,
                                                                       &gRequestDeclinedScheduleInviteCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestCancelScheduleInviteCallbackImp : public IRequestCancelScheduleInviteCallback {
public:
    RequestCancelScheduleInviteCallbackImp(){};
    ~RequestCancelScheduleInviteCallbackImp(){};
    void OnCancelScheduleInvite(HttpCancelScheduleInviteTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSRequestManager::OnCancelScheduleInvite( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        CancelScheduleInviteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestCancelScheduleInviteCallbackImp gRequestCancelScheduleInviteCallbackImp;

- (NSInteger)cancelScheduleInvite:(NSString*)inviteId
                    finishHandler:(CancelScheduleInviteFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strinviteId = "";
    if (inviteId != nil) {
        strinviteId = [inviteId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.CancelScheduleInvite(&mHttpRequestManager,
                                                                     strinviteId,
                                                                     &gRequestCancelScheduleInviteCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetScheduleInviteListCallbackImp : public IRequestGetScheduleInviteListCallback {
public:
    RequestGetScheduleInviteListCallbackImp(){};
    ~RequestGetScheduleInviteListCallbackImp(){};
    void OnGetScheduleInviteList(HttpGetScheduleInviteListTask* task, bool success, int errnum, const string& errmsg, const ScheduleInviteList& list) {
        NSLog(@"LSRequestManager::OnGetScheduleInviteList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* giftList = [NSMutableArray array];
        for(ScheduleInviteList::const_iterator giftIter = list.begin(); giftIter != list.end(); giftIter++) {
            LSScheduleInviteListItemObject* giftItem = [[LSScheduleInviteListItemObject alloc] init];
            LSScheduleAnchorInfoItemObject* anchorIdItem = [[LSScheduleAnchorInfoItemObject alloc] init];
            anchorIdItem.anchorId = [NSString stringWithUTF8String:(*giftIter).anchorInfo.anchorId.c_str()];
            anchorIdItem.nickName = [NSString stringWithUTF8String:(*giftIter).anchorInfo.nickName.c_str()];
            anchorIdItem.avatarImg = [NSString stringWithUTF8String:(*giftIter).anchorInfo.avatarImg.c_str()];
            anchorIdItem.onlineStatus = (*giftIter).anchorInfo.onlineStatus;
            anchorIdItem.age = (*giftIter).anchorInfo.age;
            anchorIdItem.country = [NSString stringWithUTF8String:(*giftIter).anchorInfo.country.c_str()];
            giftItem.anchorInfo = anchorIdItem;
            giftItem.inviteId = [NSString stringWithUTF8String:(*giftIter).inviteId.c_str()];
            giftItem.sendFlag = (*giftIter).sendFlag;
            giftItem.isSummerTime = (*giftIter).isSummerTime;
            giftItem.startTime = (*giftIter).startTime;
            giftItem.endTime = (*giftIter).endTime;
            giftItem.timeZoneValue = [NSString stringWithUTF8String:(*giftIter).timeZoneValue.c_str()];
            giftItem.timeZoneCity = [NSString stringWithUTF8String:(*giftIter).timeZoneCity.c_str()];
            giftItem.duration = (*giftIter).duration;
            giftItem.status = (*giftIter).status;
            giftItem.type = (*giftIter).type;
            giftItem.refId = [NSString stringWithUTF8String:(*giftIter).refId.c_str()];
            giftItem.hasRead = (*giftIter).hasRead;
            giftItem.isActive = (*giftIter).isActive;
            [giftList addObject:giftItem];
        }
        
        GetScheduleInviteListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], giftList);
        }
    }
};

RequestGetScheduleInviteListCallbackImp gRequestGetScheduleInviteListCallbackImp;

- (NSInteger)getScheduleInviteList:(LSScheduleInviteStatus)status
                          sendFlag:(LSScheduleSendFlagType)sendFlag
                          anchorId:(NSString*)anchorId
                             start:(int)start
                              step:(int)step
                     finishHandler:(GetScheduleInviteListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string stranchorId = "";
    if (anchorId != nil) {
        stranchorId = [anchorId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetScheduleInviteList(&mHttpRequestManager,
                                                                      status,
                                                                      sendFlag,
                                                                      stranchorId,
                                                                      start,
                                                                      step,
                                                                      &gRequestGetScheduleInviteListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetScheduleInviteDetailCallbackImp : public IRequestGetScheduleInviteDetailCallback {
public:
    RequestGetScheduleInviteDetailCallbackImp(){};
    ~RequestGetScheduleInviteDetailCallbackImp(){};
    void OnGetScheduleInviteDetail(HttpGetScheduleInviteDetailTask* task, bool success, int errnum, const string& errmsg, const HttpScheduleInviteDetailItem& item) {
        NSLog(@"LSRequestManager::OnGetScheduleInviteDetail( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSScheduleInviteDetailItemObject* giftItem = [[LSScheduleInviteDetailItemObject alloc] init];
        giftItem.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
        giftItem.inviteId = [NSString stringWithUTF8String:item.inviteId.c_str()];
        giftItem.sendFlag = item.sendFlag;
        giftItem.isSummerTime = item.isSummerTime;
        giftItem.startTime = item.startTime;
        giftItem.endTime = item.endTime;
        giftItem.addTime = item.addTime;
        giftItem.statusUpdateTime = item.statusUpdateTime;
        giftItem.timeZoneValue = [NSString stringWithUTF8String:item.timeZoneValue.c_str()];
        giftItem.timeZoneCity = [NSString stringWithUTF8String:item.timeZoneCity.c_str()];
        giftItem.duration = item.duration;
        giftItem.status = item.status;
        giftItem.cancelerName = [NSString stringWithUTF8String:item.cancelerName.c_str()];
        giftItem.type = item.type;
        giftItem.refId = [NSString stringWithUTF8String:item.refId.c_str()];
        giftItem.isActive = item.isActive;
        
        GetScheduleInviteDetailFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], giftItem);
        }
    }
};

RequestGetScheduleInviteDetailCallbackImp gRequestGetScheduleInviteDetailCallbackImp;

- (NSInteger)getScheduleInviteDetail:(NSString*)inviteId
                       finishHandler:(GetScheduleInviteDetailFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strinviteId = "";
    if (inviteId != nil) {
        strinviteId = [inviteId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetScheduleInviteDetail(&mHttpRequestManager,
                                                                        strinviteId,
                                                                        &gRequestGetScheduleInviteDetailCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetSessionInviteListCallbackImp : public IRequestGetSessionInviteListCallback {
public:
    RequestGetSessionInviteListCallbackImp(){};
    ~RequestGetSessionInviteListCallbackImp(){};
    void OnGetSessionInviteList(HttpGetSessionInviteListTask* task, bool success, int errnum, const string& errmsg, const LiveScheduleInviteList& list) {
        NSLog(@"LSRequestManager::OnGetSessionInviteList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* giftList = [NSMutableArray array];
        for(LiveScheduleInviteList::const_iterator giftIter = list.begin(); giftIter != list.end(); giftIter++) {
            LSScheduleLiveInviteItemObject* giftItem = [[LSScheduleLiveInviteItemObject alloc] init];
            giftItem.inviteId = [NSString stringWithUTF8String:(*giftIter).inviteId.c_str()];
            giftItem.sendFlag = (*giftIter).sendFlag;
            giftItem.isSummerTime = (*giftIter).isSummerTime;
            giftItem.startTime = (*giftIter).startTime;
            giftItem.endTime = (*giftIter).endTime;
            giftItem.timeZoneValue = [NSString stringWithUTF8String:(*giftIter).timeZoneValue.c_str()];
            giftItem.timeZoneCity = [NSString stringWithUTF8String:(*giftIter).timeZoneCity.c_str()];
            giftItem.duration = (*giftIter).duration;
            giftItem.status = (*giftIter).status;
            giftItem.addTime = (*giftIter).addTime;
            giftItem.statusUpdateTime = (*giftIter).statusUpdateTime;
            [giftList addObject:giftItem];
        }
        
        GetSessionInviteListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], giftList);
        }
    }
};

RequestGetSessionInviteListCallbackImp gRequestGetSessionInviteListCallbackImp;

- (NSInteger)getSessionInviteList:(LSScheduleInviteType)type
                            refId:(NSString*)refId
                    finishHandler:(GetSessionInviteListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strrefId = "";
    if (refId != nil) {
        strrefId = [refId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetSessionInviteList(&mHttpRequestManager,
                                                                     type,
                                                                     strrefId,
                                                                     &gRequestGetSessionInviteListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetScheduleInviteStatusCallbackImp : public IRequestGetScheduleInviteStatusCallback {
public:
    RequestGetScheduleInviteStatusCallbackImp(){};
    ~RequestGetScheduleInviteStatusCallbackImp(){};
    void OnGetScheduleInviteStatus(HttpGetScheduleInviteStatusTask* task, bool success, int errnum, const string& errmsg, const HttpScheduleInviteStatusItem& item) {
        NSLog(@"LSRequestManager::OnGetScheduleInviteStatus( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSScheduleinviteStatusItemObject* obj = [[LSScheduleinviteStatusItemObject alloc] init];
        obj.needStartNum = item.needStartNum;
        obj.beStartNum = item.beStartNum;
        obj.beStrtTime = item.beStrtTime;
        obj.startLeftSeconds = item.startLeftSeconds;
        GetScheduleInviteStatusFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestGetScheduleInviteStatusCallbackImp gRequestGetScheduleInviteStatusCallbackImp;

- (NSInteger)getScheduleInviteStatus:(GetScheduleInviteStatusFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetScheduleInviteStatus(&mHttpRequestManager,
                                                                        &gRequestGetScheduleInviteStatusCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetActivityTimeCallbackImp : public IRequestGetActivityTimeCallback {
public:
    RequestGetActivityTimeCallbackImp(){};
    ~RequestGetActivityTimeCallbackImp(){};
    void OnGetActivityTime(HttpGetActivityTimeTask* task, bool success, int errnum, const string& errmsg, long long activityTime) {
        NSLog(@"LSRequestManager::OnGetActivityTime( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        GetActivityTimeFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], activityTime);
        }
    }
};
RequestGetActivityTimeCallbackImp gRequestGetActivityTimeCallbackImp;

- (NSInteger)getActivityTime:(GetActivityTimeFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetActivityTime(&mHttpRequestManager,
                                                                        &gRequestGetActivityTimeCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetPremiumVideoTypeListCallbackImp : public IRequestGetPremiumVideoTypeListCallback {
public:
    RequestGetPremiumVideoTypeListCallbackImp(){};
    ~RequestGetPremiumVideoTypeListCallbackImp(){};
    void OnGetPremiumVideoTypeList(HttpGetPremiumVideoTypeListTask* task, bool success, int errnum, const string& errmsg, const PremiumVideoTypeList& list) {
        NSLog(@"LSRequestManager::OnGetPremiumVideoTypeList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(PremiumVideoTypeList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSPremiumVideoTypeItemObject* item = [[LSPremiumVideoTypeItemObject alloc] init];
            item.typeId = [NSString stringWithUTF8String:(*iter).typeId.c_str()];
            item.typeName = [NSString stringWithUTF8String:(*iter).typeName.c_str()];
            item.isDefault = (*iter).isDefault;
            [array addObject:item];
        }
        
        GetPremiumVideoTypeListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetPremiumVideoTypeListCallbackImp gRequestGetPremiumVideoTypeListCallbackImp;

- (NSInteger)getPremiumVideoTypeList:(GetPremiumVideoTypeListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetPremiumVideoTypeList(&mHttpRequestManager,
                                                                        &gRequestGetPremiumVideoTypeListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

LSPremiumVideoinfoItemObject* getPremiumVideoinfoItemObjectWithPremiumVideoBaseInfoItem(const HttpPremiumVideoBaseInfoItem& item) {
    LSPremiumVideoinfoItemObject* obj = [[LSPremiumVideoinfoItemObject alloc] init];
    obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
    obj.anchorAge = item.anchorAge;
    obj.anchorNickname = [NSString stringWithUTF8String:item.anchorNickname.c_str()];
    obj.anchorAvatarImg = [NSString stringWithUTF8String:item.anchorAvatarImg.c_str()];
    obj.onlineStatus = item.onlineStatus;
    obj.videoId = [NSString stringWithUTF8String:item.videoId.c_str()];
    obj.title = [NSString stringWithUTF8String:item.title.c_str()];
    obj.describe = [NSString stringWithUTF8String:item.description.c_str()];
    obj.duration = item.duration;
    obj.coverUrlPng = [NSString stringWithUTF8String:item.coverUrlPng.c_str()];
    obj.coverUrlGif = [NSString stringWithUTF8String:item.coverUrlGif.c_str()];
    obj.isInterested = item.isInterested;
    return obj;
}

class RequestGetPremiumVideoListCallbackImp : public IRequestGetPremiumVideoListCallback {
public:
    RequestGetPremiumVideoListCallbackImp(){};
    ~RequestGetPremiumVideoListCallbackImp(){};
    void OnGetPremiumVideoList(HttpGetPremiumVideoListTask* task, bool success, int errnum, const string& errmsg, int totalCount, const PremiumVideoBaseInfoList& list) {
        NSLog(@"LSRequestManager::OnGetPremiumVideoTypeList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(PremiumVideoBaseInfoList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSPremiumVideoinfoItemObject* item = getPremiumVideoinfoItemObjectWithPremiumVideoBaseInfoItem((*iter));//[[LSPremiumVideoinfoItemObject alloc] init];
//            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
//            item.anchorAge = (*iter).anchorAge;
//            item.anchorNickname = [NSString stringWithUTF8String:(*iter).anchorNickname.c_str()];
//            item.anchorAvatarImg = [NSString stringWithUTF8String:(*iter).anchorAvatarImg.c_str()];
//            item.onlineStatus = (*iter).onlineStatus;
//            item.videoId = [NSString stringWithUTF8String:(*iter).videoId.c_str()];
//            item.title = [NSString stringWithUTF8String:(*iter).title.c_str()];
//            item.describe = [NSString stringWithUTF8String:(*iter).description.c_str()];
//            item.duration = (*iter).duration;
//            item.coverUrlPng = [NSString stringWithUTF8String:(*iter).coverUrlPng.c_str()];
//            item.coverUrlGif = [NSString stringWithUTF8String:(*iter).coverUrlGif.c_str()];
//            item.isInterested = (*iter).isInterested;
            [array addObject:item];
        }
        
        GetPremiumVideoListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], totalCount, array);
        }
    }
};
RequestGetPremiumVideoListCallbackImp gRequestGetPremiumVideoListCallbackImp;

- (NSInteger)getPremiumVideoList:(NSString*)typeIds
                           start:(int)start
                            step:(int)step
                   finishHandler:(GetPremiumVideoListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strtypeIds = "";
    if (typeIds != nil) {
        strtypeIds = [typeIds UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetPremiumVideoList(&mHttpRequestManager,
                                                                    strtypeIds,
                                                                    start,
                                                                    step,
                                                                    &gRequestGetPremiumVideoListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetPremiumVideoKeyRequestListCallbackImp : public IRequestGetPremiumVideoKeyRequestListCallback {
public:
    RequestGetPremiumVideoKeyRequestListCallbackImp(){};
    ~RequestGetPremiumVideoKeyRequestListCallbackImp(){};
    void OnGetPremiumVideoKeyRequestList(HttpGetPremiumVideoKeyRequestListTask* task, bool success, int errnum, const string& errmsg, int totalCount, const PremiumVideoAccessKeyList& list) {
        NSLog(@"LSRequestManager::OnGetPremiumVideoKeyRequestList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(PremiumVideoAccessKeyList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSPremiumVideoAccessKeyItemObject* item = [[LSPremiumVideoAccessKeyItemObject alloc] init];
            item.requestId = [NSString stringWithUTF8String:(*iter).requestId.c_str()];
            LSPremiumVideoinfoItemObject* premiumVideoInfo = getPremiumVideoinfoItemObjectWithPremiumVideoBaseInfoItem((*iter).premiumVideoInfo);
            item.premiumVideoInfo = premiumVideoInfo;
            item.emfId = [NSString stringWithUTF8String:(*iter).emfId.c_str()];
            item.emfReadStatus = (*iter).emfReadStatus;
            item.validTime = (*iter).validTime;
            item.lastSendTime = (*iter).lastSendTime;
            item.currentTime = (*iter).currentTime;
            [array addObject:item];
        }
        
        GetPremiumVideoKeyRequestListinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], totalCount, array);
        }
    }
};
RequestGetPremiumVideoKeyRequestListCallbackImp gRequestGetPremiumVideoKeyRequestListCallbackImp;

- (NSInteger)getPremiumVideoKeyRequestList:(LSAccessKeyType)type
                                     start:(int)start
                                      step:(int)step
                             finishHandler:(GetPremiumVideoKeyRequestListinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetPremiumVideoKeyRequestList(&mHttpRequestManager,
                                                                    type,
                                                                    start,
                                                                    step,
                                                                    &gRequestGetPremiumVideoKeyRequestListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSendPremiumVideoKeyRequestCallbackImp : public IRequestSendPremiumVideoKeyRequestCallback {
public:
    RequestSendPremiumVideoKeyRequestCallbackImp(){};
    ~RequestSendPremiumVideoKeyRequestCallbackImp(){};
    void OnSendPremiumVideoKeyRequest(HttpSendPremiumVideoKeyRequestTask* task, bool success, int errnum, const string& errmsg, const string& videoId, const string& requestId){
        NSLog(@"LSRequestManager::OnSendPremiumVideoKeyRequest( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SendPremiumVideoKeyRequestFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:videoId.c_str()], [NSString stringWithUTF8String:requestId.c_str()]);
        }
    }
};
RequestSendPremiumVideoKeyRequestCallbackImp gRequestSendPremiumVideoKeyRequestCallbackImp;

- (NSInteger)sendPremiumVideoKeyRequest:(NSString*)videoId
                          finishHandler:(SendPremiumVideoKeyRequestFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strvideoId = "";
    if (videoId != nil) {
        strvideoId = [videoId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.SendPremiumVideoKeyRequest(&mHttpRequestManager,
                                                                    strvideoId,
                                                                    &gRequestSendPremiumVideoKeyRequestCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestRemindeSendPremiumVideoKeyRequestCallbackImp : public IRequestRemindeSendPremiumVideoKeyRequestCallback {
public:
    RequestRemindeSendPremiumVideoKeyRequestCallbackImp(){};
    ~RequestRemindeSendPremiumVideoKeyRequestCallbackImp(){};
    void OnRemindeSendPremiumVideoKeyRequest(HttpRemindeSendPremiumVideoKeyRequestTask* task, bool success, int errnum, const string& errmsg, const string& requestId, long long currentTime, int limitSecodns) {
        NSLog(@"LSRequestManager::OnRemindeSendPremiumVideoKeyRequest( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        RemindeSendPremiumVideoKeyRequestFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:requestId.c_str()], currentTime, limitSecodns);
        }
    }
};
RequestRemindeSendPremiumVideoKeyRequestCallbackImp gRequestRemindeSendPremiumVideoKeyRequestCallbackImp;

- (NSInteger)remindeSendPremiumVideoKeyRequest:(NSString*)requestId
                          finishHandler:(RemindeSendPremiumVideoKeyRequestFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strrequestId = "";
    if (requestId != nil) {
        strrequestId = [requestId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.RemindeSendPremiumVideoKeyRequest(&mHttpRequestManager,
                                                                    strrequestId,
                                                                    &gRequestRemindeSendPremiumVideoKeyRequestCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetPremiumVideoRecentlyWatchedListCallbackImp : public IRequestGetPremiumVideoRecentlyWatchedListCallback {
public:
    RequestGetPremiumVideoRecentlyWatchedListCallbackImp(){};
    ~RequestGetPremiumVideoRecentlyWatchedListCallbackImp(){};
    void OnGetPremiumVideoRecentlyWatchedList(HttpGetPremiumVideoRecentlyWatchedListTask* task, bool success, int errnum, const string& errmsg, int totalCount, const PremiumVideoRecentlyWatchedList& list) {
        NSLog(@"LSRequestManager::OnGetPremiumVideoRecentlyWatchedList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(PremiumVideoRecentlyWatchedList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSPremiumVideoRecentlyWatchedItemObject* item = [[LSPremiumVideoRecentlyWatchedItemObject alloc] init];
            item.watchedId = [NSString stringWithUTF8String:(*iter).watchedId.c_str()];
            LSPremiumVideoinfoItemObject* premiumVideoInfo = getPremiumVideoinfoItemObjectWithPremiumVideoBaseInfoItem((*iter).premiumVideoInfo);
            item.premiumVideoInfo = premiumVideoInfo;
            item.addTime = (*iter).addTime;
            [array addObject:item];
        }
        
        GetPremiumVideoRecentlyWatchedListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], totalCount, array);
        }
    }
};
RequestGetPremiumVideoRecentlyWatchedListCallbackImp gRequestGetPremiumVideoRecentlyWatchedListCallbackImp;

- (NSInteger)getPremiumVideoRecentlyWatchedList:(int)start
                                           step:(int)step
                                  finishHandler:(GetPremiumVideoRecentlyWatchedListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetPremiumVideoRecentlyWatchedList(&mHttpRequestManager,
                                                                    start,
                                                                    step,
                                                                    &gRequestGetPremiumVideoRecentlyWatchedListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestDeletePremiumVideoRecentlyWatchedCallbackImp : public IRequestDeletePremiumVideoRecentlyWatchedCallback {
public:
    RequestDeletePremiumVideoRecentlyWatchedCallbackImp(){};
    ~RequestDeletePremiumVideoRecentlyWatchedCallbackImp(){};
    void OnDeletePremiumVideoRecentlyWatched(HttpDeletePremiumVideoRecentlyWatchedTask* task, bool success, int errnum, const string& errmsg, const string& watchedId) {
        NSLog(@"LSRequestManager::OnDeletePremiumVideoRecentlyWatched( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        DeletePremiumVideoRecentlyWatchedFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:watchedId.c_str()]);
        }
    }
};
RequestDeletePremiumVideoRecentlyWatchedCallbackImp gRequestDeletePremiumVideoRecentlyWatchedCallbackImp;

- (NSInteger)deletePremiumVideoRecentlyWatched:(NSString*)watchedId
                          finishHandler:(DeletePremiumVideoRecentlyWatchedFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strwatchedId= "";
    if (watchedId != nil) {
        strwatchedId = [watchedId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.DeletePremiumVideoRecentlyWatched(&mHttpRequestManager,
                                                                    strwatchedId,
                                                                    &gRequestDeletePremiumVideoRecentlyWatchedCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestGetInterestedPremiumVideoListCallbackImp : public IRequestGetInterestedPremiumVideoListCallback {
public:
    RequestGetInterestedPremiumVideoListCallbackImp(){};
    ~RequestGetInterestedPremiumVideoListCallbackImp(){};
    void OnGetInterestedPremiumVideoList(HttpGetInterestedPremiumVideoListTask* task, bool success, int errnum, const string& errmsg, int totalCount, const PremiumVideoBaseInfoList& list) {
        NSLog(@"LSRequestManager::OnGetInterestedPremiumVideoList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(PremiumVideoBaseInfoList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSPremiumVideoinfoItemObject* item = getPremiumVideoinfoItemObjectWithPremiumVideoBaseInfoItem((*iter));//[[LSPremiumVideoinfoItemObject alloc] init];
//            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
//            item.anchorAge = (*iter).anchorAge;
//            item.anchorNickname = [NSString stringWithUTF8String:(*iter).anchorNickname.c_str()];
//            item.anchorAvatarImg = [NSString stringWithUTF8String:(*iter).anchorAvatarImg.c_str()];
//            item.onlineStatus = (*iter).onlineStatus;
//            item.videoId = [NSString stringWithUTF8String:(*iter).videoId.c_str()];
//            item.title = [NSString stringWithUTF8String:(*iter).title.c_str()];
//            item.describe = [NSString stringWithUTF8String:(*iter).description.c_str()];
//            item.duration = (*iter).duration;
//            item.coverUrlPng = [NSString stringWithUTF8String:(*iter).coverUrlPng.c_str()];
//            item.coverUrlGif = [NSString stringWithUTF8String:(*iter).coverUrlGif.c_str()];
//            item.isInterested = (*iter).isInterested;
            [array addObject:item];
        }
        
        GetInterestedPremiumVideoListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], totalCount, array);
        }
    }
};
RequestGetInterestedPremiumVideoListCallbackImp gRequestGetInterestedPremiumVideoListCallbackImp;

- (NSInteger)getInterestedPremiumVideoList:(int)start
                                      step:(int)step
                             finishHandler:(GetInterestedPremiumVideoListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.GetInterestedPremiumVideoList(&mHttpRequestManager,
                                                                    start,
                                                                    step,
                                                                    &gRequestGetInterestedPremiumVideoListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestDeleteInterestedPremiumVideoCallbackImp : public IRequestDeleteInterestedPremiumVideoCallback {
public:
    RequestDeleteInterestedPremiumVideoCallbackImp(){};
    ~RequestDeleteInterestedPremiumVideoCallbackImp(){};
    void OnDeleteInterestedPremiumVideo(HttpDeleteInterestedPremiumVideoTask* task, bool success, int errnum, const string& errmsg, const string& videoId) {
        NSLog(@"LSRequestManager::OnDeleteInterestedPremiumVideo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        DeleteInterestedPremiumVideoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:videoId.c_str()]);
        }
    }
};
RequestDeleteInterestedPremiumVideoCallbackImp gRequestDeleteInterestedPremiumVideoCallbackImp;

- (NSInteger)deleteInterestedPremiumVideo:(NSString*)videoId
                          finishHandler:(DeleteInterestedPremiumVideoFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strvideoId= "";
    if (videoId != nil) {
        strvideoId = [videoId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.DeleteInterestedPremiumVideo(&mHttpRequestManager,
                                                                    strvideoId,
                                                                    &gRequestDeleteInterestedPremiumVideoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestAddInterestedPremiumVideoCallbackImp : public IRequestAddInterestedPremiumVideoCallback {
public:
    RequestAddInterestedPremiumVideoCallbackImp(){};
    ~RequestAddInterestedPremiumVideoCallbackImp(){};
    void OnAddInterestedPremiumVideo(HttpAddInterestedPremiumVideoTask* task, bool success, int errnum, const string& errmsg, const string& videoId) {
        NSLog(@"LSRequestManager::OnDeleteInterestedPremiumVideo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        AddInterestedPremiumVideoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:videoId.c_str()]);
        }
    }
};
RequestAddInterestedPremiumVideoCallbackImp gRequestAddInterestedPremiumVideoCallbackImp;

- (NSInteger)addInterestedPremiumVideo:(NSString*)videoId
                         finishHandler:(AddInterestedPremiumVideoFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strvideoId= "";
    if (videoId != nil) {
        strvideoId = [videoId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.AddInterestedPremiumVideo(&mHttpRequestManager,
                                                                    strvideoId,
                                                                    &gRequestAddInterestedPremiumVideoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestRecommendPremiumVideoListCallbackImp : public IRequestRecommendPremiumVideoListCallback {
public:
    RequestRecommendPremiumVideoListCallbackImp(){};
    ~RequestRecommendPremiumVideoListCallbackImp(){};
    void OnRecommendPremiumVideoList(HttpRecommendPremiumVideoListTask* task, bool success, int errnum, const string& errmsg, int num, const PremiumVideoBaseInfoList& list) {
        NSLog(@"LSRequestManager::OnRecommendPremiumVideoList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(PremiumVideoBaseInfoList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSPremiumVideoinfoItemObject* item = getPremiumVideoinfoItemObjectWithPremiumVideoBaseInfoItem((*iter));//[[LSPremiumVideoinfoItemObject alloc] init];
//            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
//            item.anchorAge = (*iter).anchorAge;
//            item.anchorNickname = [NSString stringWithUTF8String:(*iter).anchorNickname.c_str()];
//            item.anchorAvatarImg = [NSString stringWithUTF8String:(*iter).anchorAvatarImg.c_str()];
//            item.onlineStatus = (*iter).onlineStatus;
//            item.videoId = [NSString stringWithUTF8String:(*iter).videoId.c_str()];
//            item.title = [NSString stringWithUTF8String:(*iter).title.c_str()];
//            item.describe = [NSString stringWithUTF8String:(*iter).description.c_str()];
//            item.duration = (*iter).duration;
//            item.coverUrlPng = [NSString stringWithUTF8String:(*iter).coverUrlPng.c_str()];
//            item.coverUrlGif = [NSString stringWithUTF8String:(*iter).coverUrlGif.c_str()];
//            item.isInterested = (*iter).isInterested;
            [array addObject:item];
        }
        
        RecommendPremiumVideoListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], num, array);
        }
    }
};
RequestRecommendPremiumVideoListCallbackImp gRequestRecommendPremiumVideoListCallbackImp;

- (NSInteger)recommendPremiumVideoList:(int)num
                         finishHandler:(RecommendPremiumVideoListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    request = (NSInteger)mHttpRequestController.RecommendPremiumVideoList(&mHttpRequestManager,
                                                                    num,
                                                                    &gRequestRecommendPremiumVideoListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetAnchorPremiumVideoListCallbackImp : public IRequestGetAnchorPremiumVideoListCallback {
public:
    RequestGetAnchorPremiumVideoListCallbackImp(){};
    ~RequestGetAnchorPremiumVideoListCallbackImp(){};
    void OnGetAnchorPremiumVideoList(HttpGetAnchorPremiumVideoListTask* task, bool success, int errnum, const string& errmsg, const PremiumVideoBaseInfoList& list) {
        NSLog(@"LSRequestManager::OnGetAnchorPremiumVideoList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(PremiumVideoBaseInfoList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSPremiumVideoinfoItemObject* item = getPremiumVideoinfoItemObjectWithPremiumVideoBaseInfoItem((*iter));//[[LSPremiumVideoinfoItemObject alloc] init];
//            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
//            item.anchorAge = (*iter).anchorAge;
//            item.anchorNickname = [NSString stringWithUTF8String:(*iter).anchorNickname.c_str()];
//            item.anchorAvatarImg = [NSString stringWithUTF8String:(*iter).anchorAvatarImg.c_str()];
//            item.onlineStatus = (*iter).onlineStatus;
//            item.videoId = [NSString stringWithUTF8String:(*iter).videoId.c_str()];
//            item.title = [NSString stringWithUTF8String:(*iter).title.c_str()];
//            item.describe = [NSString stringWithUTF8String:(*iter).description.c_str()];
//            item.duration = (*iter).duration;
//            item.coverUrlPng = [NSString stringWithUTF8String:(*iter).coverUrlPng.c_str()];
//            item.coverUrlGif = [NSString stringWithUTF8String:(*iter).coverUrlGif.c_str()];
//            item.isInterested = (*iter).isInterested;
            [array addObject:item];
        }
        
        GetAnchorPremiumVideoListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetAnchorPremiumVideoListCallbackImp gRequestGetAnchorPremiumVideoListCallbackImp;

- (NSInteger)getAnchorPremiumVideoList:(NSString*)anchorId
                         finishHandler:(GetAnchorPremiumVideoListFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string stranchorId = "";
    if (anchorId != nil) {
        stranchorId = [anchorId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetAnchorPremiumVideoList(&mHttpRequestManager,
                                                                    stranchorId,
                                                                    &gRequestGetAnchorPremiumVideoListCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetPremiumVideoDetailCallbackImp : public IRequestGetPremiumVideoDetailCallback {
public:
    RequestGetPremiumVideoDetailCallbackImp(){};
    ~RequestGetPremiumVideoDetailCallbackImp(){};
    void OnGetPremiumVideoDetail(HttpGetPremiumVideoDetailTask* task, bool success, int errnum, const string& errmsg, const HttpPremiumVideoDetailItem& item) {
        NSLog(@"LSRequestManager::OnGetPremiumVideoDetail( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSPremiumVideoDetailItemObject* obj = [[LSPremiumVideoDetailItemObject alloc] init];
        obj.anchorId = [NSString stringWithUTF8String:item.anchorId.c_str()];
        obj.videoId = [NSString stringWithUTF8String:item.videoId.c_str()];
        NSMutableArray* array = [NSMutableArray array];
        for(PremiumVideoTypeList::const_iterator iter = item.typeList.begin(); iter != item.typeList.end(); iter++) {
            LSPremiumVideoTypeItemObject* item = [[LSPremiumVideoTypeItemObject alloc] init];
            item.typeId = [NSString stringWithUTF8String:(*iter).typeId.c_str()];
            item.typeName = [NSString stringWithUTF8String:(*iter).typeName.c_str()];
            item.isDefault = (*iter).isDefault;
            [array addObject:item];
        }
        obj.typeList = array;
        obj.title = [NSString stringWithUTF8String:item.title.c_str()];
        obj.describe = [NSString stringWithUTF8String:item.description.c_str()];
        obj.duration = item.duration;
        obj.coverUrlPng = [NSString stringWithUTF8String:item.coverUrlPng.c_str()];
        obj.coverUrlGif = [NSString stringWithUTF8String:item.coverUrlGif.c_str()];
        obj.videoUrlShort = [NSString stringWithUTF8String:item.videoUrlShort.c_str()];
        obj.videoUrlFull = [NSString stringWithUTF8String:item.videoUrlFull.c_str()];
        obj.isInterested = item.isInterested;
        obj.lockStatus = item.lockStatus;
        obj.requestId = [NSString stringWithUTF8String:item.requestId.c_str()];
        obj.requestLastTime = item.requestLastTime;
        obj.emfId = [NSString stringWithUTF8String:item.emfId.c_str()];
        obj.unlockTime = item.unlockTime;
        obj.currentTime = item.currentTime;
        
        GetPremiumVideoDetailFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetPremiumVideoDetailCallbackImp gRequestGetPremiumVideoDetailCallbackImp;

- (NSInteger)getPremiumVideoDetail:(NSString*)videoId
                     finishHandler:(GetPremiumVideoDetailFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string strvideoId = "";
    if (videoId != nil) {
        strvideoId = [videoId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.GetPremiumVideoDetail(&mHttpRequestManager,
                                                                    strvideoId,
                                                                    &gRequestGetPremiumVideoDetailCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestUnlockPremiumVideoCallbackImp : public IRequestUnlockPremiumVideoCallback {
public:
    RequestUnlockPremiumVideoCallbackImp(){};
    ~RequestUnlockPremiumVideoCallbackImp(){};
    void OnUnlockPremiumVideo(HttpUnlockPremiumVideoTask* task, bool success, int errnum, const string& errmsg, const string& videoId, const string& videoUrlFull) {
        NSLog(@"LSRequestManager::OnUnlockPremiumVideo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        UnlockPremiumVideoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:videoId.c_str()], [NSString stringWithUTF8String:videoUrlFull.c_str()]);
        }
    }
};
RequestUnlockPremiumVideoCallbackImp gRequestUnlockPremiumVideoCallbackImp;

- (NSInteger)unlockPremiumVideo:(LSUnlockActionType)type
                      accessKey:(NSString*)accessKey
                        videoId:(NSString*)videoId
                  finishHandler:(UnlockPremiumVideoFinishHandler)finishHandler {
    NSInteger request = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    string straccessKey = "";
    if (accessKey != nil) {
        straccessKey = [accessKey UTF8String];
    }
    
    string strvideoId = "";
    if (videoId != nil) {
        strvideoId = [videoId UTF8String];
    }
    
    request = (NSInteger)mHttpRequestController.UnlockPremiumVideo(&mHttpRequestManager,
                                                                      type,
                                                                      straccessKey,
                                                                      strvideoId,
                                                                      &gRequestUnlockPremiumVideoCallbackImp);
    if (request != LS_HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

@end



