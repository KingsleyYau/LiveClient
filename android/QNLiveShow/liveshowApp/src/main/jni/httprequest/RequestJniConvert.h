/*
 * RequestJniConvert.h
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 *  Description Jni中间转换层
 */

#ifndef REQUESTJNICONVERT_H_
#define REQUESTJNICONVERT_H_

#include "GlobalFunc.h"

/*直播间状态转换*/
static const int HTTPErrorTypeArray[] = {
	    HTTP_LCC_ERR_SUCCESS,   		// 成功
	    HTTP_LCC_ERR_FAIL, 				// 服务器返回失败结果

	    // 客户端定义的错误
	    HTTP_LCC_ERR_PROTOCOLFAIL,   	// 协议解析失败（服务器返回的格式不正确）
	    HTTP_LCC_ERR_CONNECTFAIL,    	// 连接服务器失败/断开连接
	    //HTTP_LCC_ERR_CHECKVERFAIL,   	// 检测版本号失败（可能由于版本过低导致）

	    //HTTP_LCC_ERR_SVRBREAK,       	// 服务器踢下线
	    //HTTP_LCC_ERR_INVITE_TIMEOUT, 	// 邀请超时
	    // 服务器返回错误
	    HTTP_LCC_ERR_ROOM_FULL,   		// 房间人满
	    HTTP_LCC_ERR_NO_CREDIT,   		// 信用点不足
	    /* IM公用错误码 */
	    HTTP_LCC_ERR_NO_LOGIN,   		// 未登录
	    HTTP_LCC_ERR_SYSTEM,     		// 系统错误
	    HTTP_LCC_ERR_TOKEN_EXPIRE, 		// Token 过期了
	    HTTP_LCC_ERR_NOT_FOUND_ROOM, 	// 进入房间失败 找不到房间信息or房间关闭
	    HTTP_LCC_ERR_CREDIT_FAIL, 		// 远程扣费接口调用失败

	    HTTP_LCC_ERR_ROOM_CLOSE,  		// 房间已经关闭
	    HTTP_LCC_ERR_KICKOFF, 			// 被挤掉线 默认通知内容
	    HTTP_LCC_ERR_NO_AUTHORIZED, 	// 不能操作 不是对应的userid
	    HTTP_LCC_ERR_LIVEROOM_NO_EXIST, // 直播间不存在
	    HTTP_LCC_ERR_LIVEROOM_CLOSED, 	// 直播间已关闭

	    HTTP_LCC_ERR_ANCHORID_INCONSISTENT, 	// 主播id与直播场次的主播id不合
	    HTTP_LCC_ERR_CLOSELIVE_DATA_FAIL, 		// 关闭直播场次,数据表操作出错
	    HTTP_LCC_ERR_CLOSELIVE_LACK_CODITION, 	// 主播立即关闭私密直播间, 不满足关闭条件
	    /* 其它错误码*/
	    HTTP_LCC_ERR_USED_OUTLOG, 				// 退出登录 (用户主动退出登录)
	    HTTP_LCC_ERR_NOTCAN_CANCEL_INVITATION, 	// 取消立即私密邀请失败 状态不是带确认 /*important*/
	    HTTP_LCC_ERR_NOT_FIND_ANCHOR, 			// 主播机构信息找不到
	    HTTP_LCC_ERR_NOTCAN_REFUND, 			// 立即私密退点失败，已经定时扣费不能退点
	    HTTP_LCC_ERR_NOT_FIND_PRICE_INFO, 		// 找不到price_setting表信息

        HTTP_LCC_ERR_ANCHOR_BUSY,			  	// 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
	    HTTP_LCC_ERR_CHOOSE_TIME_ERR, 			// 预约时间错误 /*important*/
	    HTTP_LCC_ERR_BOOK_EXIST, 				// 用户预约时间段已经存在预约 /*important*/
	    HTTP_LCC_ERR_BIND_PHONE, 				// 手机号码已绑定
        HTTP_LCC_ERR_RETRY_PHONE, 				// 请稍后再重试

        HTTP_LCC_ERR_MORE_TWENTY_PHONE, 		// 60分钟内验证超过20次，请24小时后再试
	    HTTP_LCC_ERR_UPDATE_PHONE_FAIL, 		// 更新失败
	    HTTP_LCC_ERR_ANCHOR_OFFLIVE,            // 主播不在线，不能操作
		HTTP_LCC_ERR_VIEWER_AGREEED_BOOKING, 	// 观众已同意预约
		HTTP_LCC_ERR_OUTTIME_REJECT_BOOKING, 	// 预约邀请已超时（当观众拒绝时）

		HTTP_LCC_ERR_OUTTIME_AGREE_BOOKING,   	// 预约邀请已超时（当观众同意时）

		/* 换站的错误码和域名的错误吗*/
        HTTP_LCC_ERR_PLOGIN_PASSWORD_INCORRECT,      // 帐号或密码不正确
        HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION ,      // 需要验证码 和 MBCE21002: Please enter the verification code.
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
        HTTP_LCC_ERR_DEMAIN_DATA_NO_EXIST_KEY ,            // MBCE12002:( 更新失败：Key不存在。)  /mobile/updatepro.php
        HTTP_LCC_ERR_DEMAIN_DATA_UNCHANGE_VALUE,            // MBCE12003：( 更新失败：Value值没有改变。)
        HTTP_LCC_ERR_DEMAIN_DATA_UNPASS_VALUE,            // MBCE12004：( 更新失败：Value值检测没通过。)

        HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFO_DESC_LOG,            // MBCE12005：update info_desc_log
        HTTP_LCC_ERR_DEMAIN_DATA_INSERT_INFO_DESC_LOG,            // MBCE12006：insert into info_desc_log
        HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFODESCLOG_SETGROUPID,   // MBCE12007：update info_desc_log set group_id
        HTTP_LCC_ERR_DEMAIN_APP_EXIST_LOGS,                       // MBCE22001：(APP安装记录已存在。)
        HTTP_LCC_ERR_PRIVTE_INVITE_AUTHORITY,                     // 主播无立即私密邀请权限(17002)
            /* 信件*/
        //HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_HASCREDIT,          // 购买图片使用邮票支付时，邮票不足，但信用点可用(17213)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_NOCREDIT,          // 购买图片使用邮票支付时，邮票不足，且信用点不足(17214)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOCREDIT_HASSTAMP,          // 购买图片使用信用点支付时，信用点不足，但邮票可用(17215)(调用13.7.购买信件附件接口)

        //HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOSTAMP_NOCREDIT6,          // 购买图片使用信用点支付时，信用点不足，且邮票不足(17216)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_PHOTO_OVERTIME,                     // 照片已过期(17217)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_HASCREDIT,          // 购买视频使用邮票支付时，邮票不足，但信用点可用(17218)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_NOCREDIT,          // 购买视频使用邮票支付时，邮票不足，且信用点不足(17219)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOCREDIT_HASSTAMP,          // 购买视频使用信用点支付时，信用点不足，但邮票可用(17220)(调用13.7.购买信件附件接口)

        //HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOSTAMP_NOCREDIT,          // 购买视频使用信用点支付时，信用点不足，且邮票不足(17221)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_VIDEO_OVERTIME,                                // 视频已过期(17222)(调用13.7.购买信件附件接口)
        //HTTP_LCC_ERR_LETTER_NO_CREDIT_OR_NO_STAMP,                         // 信用点或者邮票不足(17208):(调用13.4.信件详情接口, 调用13.5.发送信件接口)
        HTTP_LCC_ERR_EXIST_HANGOUT,                                        // 当前会员已在hangout直播间（调用8.11.获取当前会员Hangout直播状态接口）

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
        //HTTP_LCC_ERR_INVITATION_IS_INVLID,                  // 主播发送私密邀请ID无效（10057）（调用4.7.观众处理立即私密邀请）
        //HTTP_LCC_ERR_INVITATION_HAS_EXPIRED,                // 主播发送私密邀请过期（10058）（调用4.7.观众处理立即私密邀请）
        //HTTP_LCC_ERR_INVITATION_HAS_CANCELED,               // 主播发送私密邀请被取消了（10070）（调用4.7.观众处理立即私密邀请）
        //HTTP_LCC_ERR_SHOW_HAS_ENDED,                        // 节目已经结束了（13017）（调用9.5.获取可进入的节目信息）

        //HTTP_LCC_ERR_SHOW_HAS_CANCELLED,                    // 节目已经取消了（13024）（调用9.5.获取可进入的节目信息）
        //HTTP_LCC_ERR_ANCHOR_NOCOME_SHOW_HAS_CLOSE,          // 主播没有来关闭节目（13010）（调用9.5.获取可进入的节目信息）
        //HTTP_LCC_ERR_NO_BUY_SHOW_HAS_CANCELLED,             // 对于没买票用户节目取消了（13023）（调用9.5.获取可进入的节目信息）
        //HTTP_LCC_ERR_HANGOUT_EXIST_COUNTDOWN_PRIVITEROOM,   // 多人视频流程 主播存在开始倒数私密直播间（Sorry, the broadcaster is busy at the moment. Please try again later.(10114)）
        //HTTP_LCC_ERR_HANGOUT_EXIST_COUNTDOWN_HANGOUTROOM,   // 多人视频流程 主播存在开始倒数多人视频直播间（Sorry, the broadcaster is busy at the moment. Please try again later.(10115)）

        //HTTP_LCC_ERR_HANGOUT_EXIST_FOUR_MIN_SHOW,           // 多人视频流程 主播存在4分钟内开始的预约（Sorry, the broadcaster is busy at the moment. Please try again later.(10116)）
        //HTTP_LCC_ERR_KNOCK_EXIST_ROOM,                      // 男士同意敲门请求，主播存在在线的直播间（Sorry, the broadcaster is busy at the moment. Please try again later.(10136)）
        //HTTP_LCC_ERR_INVITE_FAIL_SHOWING,                   // 发送立即邀请失败 主播正在节目中（Sorry, the broadcaster is busy at the moment. Please try again later.(13020)）
        //HTTP_LCC_ERR_INVITE_FAIL_BUSY,                      // 发送立即邀请 用户收到主播繁忙通知（Sorry, the broadcaster is busy at the moment. Please try again later.(13021)）
        //HTTP_LCC_ERR_SEND_RECOMMEND_HAS_SHOWING,            // 主播发送推荐好友请求：好友4分钟后有节目开播（Sorry, the broadcaster is busy at the moment. Please try again later.(16318)）

        //HTTP_LCC_ERR_SEND_RECOMMEND_EXIT_HANGOUTROOM,       // 主播发送推荐好友请求：好友跟其他男士hangout中（Sorry, the broadcaster is busy at the moment. Please try again later.(16320)）
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
};

// 底层状态转换JAVA坐标
int HTTPErrorTypeToInt(HTTP_LCC_ERR_TYPE errType);

/*主播在线状态状态*/
static const int AnchorOnlineStatusArray[] = {
	ONLINE_STATUS_UNKNOWN,
	ONLINE_STATUS_OFFLINE,
	ONLINE_STATUS_LIVE
};

// 底层状态转换JAVA坐标
int AnchorOnlineStatusToInt(OnLineStatus liveRoomStatus);

/*直播间类型*/
static const int LiveRoomTypeArray[] = {
	    HTTPROOMTYPE_NOLIVEROOM,                  // 没有直播间
	    HTTPROOMTYPE_FREEPUBLICLIVEROOM,          // 免费公开直播间
	    HTTPROOMTYPE_COMMONPRIVATELIVEROOM,       // 普通私密直播间
	    HTTPROOMTYPE_CHARGEPUBLICLIVEROOM,        // 付费公开直播间
	    HTTPROOMTYPE_LUXURYPRIVATELIVEROOM,       // 豪华私密直播间
	    HTTPROOMTYPE_HANGOUTLIVEROOM              // Hangout直播间
};

// 底层状态转换JAVA坐标
int LiveRoomTypeToInt(HttpRoomType liveRoomType);

/*主播VIP类型*/
static const int AnchorLevelTypeArray[] = {
	    ANCHORLEVELTYPE_UNKNOW,             // 未知
	    ANCHORLEVELTYPE_SILVER,             // 白银
	    ANCHORLEVELTYPE_GOLD                // 黄金
};
int AnchorLevelTypeToInt(AnchorLevelType anchorLevelType);

/*立即私密邀请处理状态*/
static const int ImmediateInviteReplyTypeArray[]{
	HTTPREPLYTYPE_UNKNOWN,              // 未知
	HTTPREPLYTYPE_UNCONFIRM,            // 待确定
	HTTPREPLYTYPE_AGREE,                // 已同意
	HTTPREPLYTYPE_REJECT,               // 已拒绝
	HTTPREPLYTYPE_OUTTIME,              // 已超时
	HTTPREPLYTYPE_CANCEL,               // 观众/主播取消
	HTTPREPLYTYPE_ANCHORABSENT,         // 主播缺席
	HTTPREPLYTYPE_FANSABSENT,           // 观众缺席
	HTTPREPLYTYPE_COMFIRMED             // 已完成
};

// 底层状态转换JAVA坐标
int ImmediateInviteReplyTypeToInt(HttpReplyType giftType);

/* 礼物类型  */
static const int GiftTypeArray[]{
	GIFTTYPE_UNKNOWN,
	GIFTTYPE_COMMON,    // 普通礼物
	GIFTTYPE_Heigh,     // 高级礼物（动画）
    GIFTTYPE_BAR,       // 吧台礼物
    GIFTTYPE_CELEBRATE  // 庆祝礼物
};

// 底层状态转换JAVA坐标
int GiftTypeToInt(GiftType giftType);

/* 预约邀请处理状态 */
static const int BookInviteStatusArray[]{
	BOOKINGREPLYTYPE_UNKNOWN,           // 未知
	BOOKINGREPLYTYPE_PENDING,           // 待确定
	BOOKINGREPLYTYPE_ACCEPT,           // 已接受
	BOOKINGREPLYTYPE_REJECT,           // 已拒绝
	BOOKINGREPLYTYPE_OUTTIME,           // 超时
	BOOKINGREPLYTYPE_CANCEL,           // 取消
	BOOKINGREPLYTYPE_ANCHORABSENT,      // 主播缺席
	BOOKINGREPLYTYPE_FANSABSENT,        // 观众缺席
	BOOKINGREPLYTYPE_COMFIRMED          // 已完成
};

/*预约邀请列表类型*/
static const int BookInviteListTypeArray[] = {
	BOOKINGLISTTYPE_WAITFANSHANDLEING,          // 等待观众处理
	BOOKINGLISTTYPE_WAITANCHORHANDLEING,        // 等待主播处理
	BOOKINGLISTTYPE_COMFIRMED,                  // 已确认
	BOOKINGLISTTYPE_HISTORY                     // 历史
};

//Java层转底层枚举
BookingListType IntToBookInviteListType(int value);

// 底层状态转换JAVA坐标
int BookInviteStatusToInt(BookingReplyType replyType);

/* 才艺邀请状态  */
static const int TalentInviteStatusArray[]{
	HTTPTALENTSTATUS_UNREPLY,               // 未回复
	HTTPTALENTSTATUS_ACCEPT,                // 已接受
	HTTPTALENTSTATUS_REJECT,                // 拒绝
	HTTPTALENTSTATUS_OUTTIME,				// 已超时
	HTTPTALENTSTATUS_CANCEL					// 已取消
};

// 底层状态转换JAVA坐标
int TalentInviteStatusToInt(HTTPTalentStatus talentStatus);

/* 预约邀请时段可预约状态 */
static const int BookInviteTimeStatusArray[]{
	BOOKTIMESTATUS_BOOKING,             // 可预约
	BOOKTIMESTATUS_INVITEED,            // 本人已邀请
	BOOKTIMESTATUS_COMFIRMED,           // 本人已确认
	BOOKTIMESTATUS_INVITEEDOTHER		// 本人已邀请其它主播
};

// 底层状态转换JAVA坐标
int  BookInviteTimeStatusToInt(BookTimeStatus bookTimeStatus);

/* 预约邀请时段可预约状态 */
static const int VoucherUseRoomTypeArray[]{
	USEROOMTYPE_LIMITLESS,                  // 不限
	USEROOMTYPE_PUBLIC,                     // 公开
	USEROOMTYPE_PRIVATE                     // 私密
};

// 底层状态转换JAVA坐标
int  VoucherUseRoomTypeToInt(UseRoomType useRoomType);

/* 预约邀请时段可预约状态 */
static const int VoucherAnchorTypeArray[]{
	ANCHORTYPE_LIMITLESS,                  // 不限
	ANCHORTYPE_APPOINTANCHOR,              // 指定主播
	ANCHORTYPE_NOSEEANCHOR                 // 没看过直播的主播
};

// 底层状态转换JAVA坐标
int  VoucherAnchorTypeToInt(AnchorType voucherAnchorType);

/*观众用户类型（1：A1类型 2：A2类型） （A1类型：仅可看付费公开及豪华私密直播间， A2类型:可看所有直播间）*/
static const int LSHttpLiveChatInviteRiskTypeArray[] = {
		LSHTTP_LIVECHATINVITE_RISK_NOLIMIT,    // 不作任何限制
		LSHTTP_LIVECHATINVITE_RISK_LIMITSEND,    // 限制发送信息
		LSHTTP_LIVECHATINVITE_RISK_LIMITREV,    // 限制接受邀请
		LSHTTP_LIVECHATINVITE_RISK_LIMITALL    // 收发全部限制
};
int LSHttpLiveChatInviteRiskTypeToInt(LSHttpLiveChatInviteRiskType type);

/*观众用户类型（1：A1类型 2：A2类型） （A1类型：仅可看付费公开及豪华私密直播间， A2类型:可看所有直播间）*/
static const int UserTypeArray[] = {
		USERTYPEUNKNOW,             // 未知
		USERTYPEA1,             // A1类型：仅可看付费公开及豪华私密直播间
		USERTYPEA2                // A2类型:可看所有直播间
};
int UserTypeToInt(UserType userType);

/*视频活动操作类型*/
static const int InteractiveOperateTypeArray[] = {
	CONTROLTYPE_START,                   // 开始
	CONTROLTYPE_CLOSE                    // 关闭
};

//Java层转底层枚举
ControlType IntToInteractiveOperateType(int value);

/*获取界面的类型*/
static const int PromoAnchorTypeArray[] = {
	    PROMOANCHORTYPE_UNKNOW,                             // 未知
	    PROMOANCHORTYPE_LIVEROOM,                           // 直播间
	    PROMOANCHORTYPE_ANCHORPERSONAL                     // 主播个人页
};
//Java层转底层枚举
PromoAnchorType IntToPromoAnchorType(int value);


/*地区ID的类型*/
static const int RegionIdTypeArray[] = {
        REGIONIDTYPE_UNKNOW,                             // 未知
        REGIONIDTYPE_CD,                           		 // CD
        REGIONIDTYPE_LD,		                     	 // LD
        REGIONIDTYPE_AME
};
//Java层转底层枚举
RegionIdType IntToRegionIdType(int value);

/*多人邀请类型 */
static const int HangoutInviteStatusArray[] = {
		HANGOUTINVITESTATUS_UNKNOW,             // 未知
		HANGOUTINVITESTATUS_PENDING,            // 待确定
		HANGOUTINVITESTATUS_ACCEPT,             // 已接受
		HANGOUTINVITESTATUS_REJECT,				// 已拒绝
		HANGOUTINVITESTATUS_OUTTIME,			// 已超时
		HANGOUTINVITESTATUS_CANCLE,             // 观众取消邀
		HANGOUTINVITESTATUS_NOCREDIT,           // 余额不足
		HANGOUTINVITESTATUS_BUSY                // 主播繁忙
};
int HangoutInviteStatusToInt(HangoutInviteStatus type);

/*列表类型*/
static const int HangoutAnchorListTypeArray[] = {
		HANGOUTANCHORLISTTYPE_UNKNOW,                    // 未知
		HANGOUTANCHORLISTTYPE_FOLLOW,                   // 已关注
		HANGOUTANCHORLISTTYPE_WATCHED,		            // Watched(看过的)
		HANGOUTANCHORLISTTYPE_FRIEND,					// 主播好友
        HANGOUTANCHORLISTTYPE_ONLINEANCHOR              // 在线主播
};
//Java层转底层枚举
HangoutAnchorListType IntToHangoutAnchorListType(int value);


/*列表类型*/
static const int ProgramListTypeArray[] = {
		PROGRAMLISTTYPE_UNKNOW,             // 未知
		PROGRAMLISTTYPE_STARTTIEM,          // 按节目开始时间排序
		PROGRAMLISTTYPE_VERIFYTIEM,         // 按节目审核时间排序
		PROGRAMLISTTYPE_FEATURE,            // 按广告排序
		PROGRAMLISTTYPE_BUYTICKET,          // 已购票列表
        PROGRAMLISTTYPE_HISTORY            // 购票历史列表
};
//Java层转底层枚举
ProgramListType IntToProgramListType(int value);

/*节目状态类型 */
static const int ProgramStatusArray[] = {
		PROGRAMSTATUS_UNVERIFY,             // 未审核
		PROGRAMSTATUS_VERIFYPASS,           // 审核通过
		PROGRAMSTATUS_VERIFYREJECT,         // 审核被拒
		PROGRAMSTATUS_PROGRAMEND,           // 节目正常结束
		PROGRAMSTATUS_PROGRAMCALCEL,        // 节目已取消
		PROGRAMSTATUS_OUTTIME               // 节目已超时
};
int ProgramStatusToInt(ProgramStatus type);

/*节目推荐列表类型*/
static const int ShowRecommendListTypeArray[] = {
		SHOWRECOMMENDLISTTYPE_UNKNOW,                    // 未知
		SHOWRECOMMENDLISTTYPE_ENDRECOMMEND,              // 直播结束推荐<包括指定主播及其它主播
		SHOWRECOMMENDLISTTYPE_PERSONALRECOMMEND,         // 主播个人节目推荐<仅包括指定主播>
		SHOWRECOMMENDLISTTYPE_NOHOSTRECOMMEND           // 不包括指定主播
};
//Java层转底层枚举
ShowRecommendListType IntToShowRecommendListType(int value);

/*节目购票状态 */
static const int ProgramTicketStatusArray[] = {
		PROGRAMTICKETSTATUS_NOBUY,      // 未购票
		PROGRAMTICKETSTATUS_BUYED,      // 已购票
		PROGRAMTICKETSTATUS_OUT         // 已退票
};
int ProgramTicketStatusToInt(ProgramTicketStatus type);

/*主播在线状态状态*/
static const int LSLoginSidTypeArray[] = {
    LSLOGINSIDTYPE_UNKNOW,    // 未知
    LSLOGINSIDTYPE_QNLOGIN,       // QN登录成功返回的
    LSLOGINSIDTYPE_LSLOGIN        // 直播登录成功返回的
};
//Java层转底层枚举
LSLoginSidType IntToLSLoginSidType(int value);

/*验证码类型*/
static const int LSValidateCodeTypeArray[] = {
		LSVALIDATECODETYPE_UNKNOW,    // 未知
		LSVALIDATECODETYPE_LOGIN,       // login：登录获取
		LSVALIDATECODETYPE_FINDPW        // 找回密码获取
};
//Java层转底层枚举
LSValidateCodeType IntToLSValidateCodeType(int value);

/*验证码类型*/
static const int LSOrderTypeArray[] = {
		LSORDERTYPE_CREDIT,      // 信用点
		LSORDERTYPE_FLOWERGIFT,  // 鲜花礼品
		LSORDERTYPE_MONTHFEE,    // 月费服务
		LSORDERTYPE_STAMP        // 邮票
};
//Java层转底层枚举
LSOrderType IntToLSOrderType(int value);

/*主播状态类型*/
static const int ComIMChatOnlineStatusArray[] = {
    IMCHATONLINESTATUS_UNKNOW,    // 未知
    IMCHATONLINESTATUS_OFF,      // 离线
    IMCHATONLINESTATUS_ONLINE   // 在线

};

// 底层状态转换JAVA坐标
int ComIMChatOnlineStatusToInt(IMChatOnlineStatus type);

/*发送信件权限类型*/
static const int LSSendImgRiskTypeArray[] = {
		LSSENDIMGRISKTYPE_NORMAL,           // 正常
		LSSENDIMGRISKTYPE_ONLYFREE,         // 只能发免费
		LSSENDIMGRISKTYPE_ONLYPAYMENT,      // 只能发付费
		LSSENDIMGRISKTYPE_NOSEND            // 不能发照片
};
int LSSendImgRiskTypeToInt(LSSendImgRiskType type);

/*SayHi列表类型*/
static const int LSSayHiListTypeArray[] = {
		LSSAYHILISTTYPE_UNKOWN,
		LSSAYHILISTTYPE_UNREAD,
		LSSAYHILISTTYPE_LATEST
};
//Java层转底层枚举
LSSayHiListType IntToLSSayHiListType(int value);

/*SayHi列表类型*/
static const int LSLSSayHiDetailTypeArray[] = {
		LSSAYHIDETAILTYPE_UNKOWN,
		LSSAYHIDETAILTYPE_EARLIEST,
		LSSAYHIDETAILTYPE_LATEST,
		LSSAYHIDETAILTYPE_UNREAD
};
//Java层转底层枚举
LSSayHiDetailType IntToLSSayHiDetailType(int value);

/*SayHi列表类型*/
static const int LSBubblingInviteTypeArray[] = {
		LSBUBBLINGINVITETYPE_UNKNOW,
		LSBUBBLINGINVITETYPE_ONEONONE,
		LSBUBBLINGINVITETYPE_HANGOUT,
		LSBUBBLINGINVITETYPE_LIVECHAT
};
//Java层转底层枚举
LSBubblingInviteType IntToLSBubblingInviteType(int value);


/*广告类型*/
static const int LSBannerTypeArray[] = {
		    LSBANNERTYPE_UNKNOW,
            LSBANNERTYPE_NINE_SQUARED,
            LSBANNERTYPE_ALL_BROADCASTERS,
            LSBANNERTYPE_FEATURED_BROADCASTERS,
            LSBANNERTYPE_SAYHI,
            LSBANNERTYPE_GREETMAIL,
            LSBANNERTYPE_MAIL,
            LSBANNERTYPE_CHAT,
            LSBANNERTYPE_HANGOUT,
            LSBANNERTYPE_GIFTSFLOWERS
};
//Java层转底层枚举
LSBannerType IntToLSBannerType(int value);

/*广告类型*/
static const int LSGiftRoomTypeArray[] = {
		    LSGIFTROOMTYPE_UNKNOW,
            LSGIFTROOMTYPE_PUBLIC,
            LSGIFTROOMTYPE_PRIVATE
};
//Java层转底层枚举
LSGiftRoomType IntToLSGiftRoomType(int value);

/*主播状态类型*/
static const int VoucherTypeArray[] = {
    VOUCHERTYPE_BROADCAST,    // 直播试聊劵
    VOUCHERTYPE_LIVECHAT      // livechat试聊劵

};

// 底层状态转换JAVA坐标
int VoucherTypeToInt(VoucherType type);


/*鲜花礼品价格类型*/
static const int PriceShowTypeArray[] = {
    LSPRICESHOWTYPE_WEEKDAY,    // 平日价
    LSPRICESHOWTYPE_HOLIDAY,    // 假日价
    LSPRICESHOWTYPE_DISCOUNT    // 优惠价
};

// 底层状态转换JAVA坐标
int PriceShowTypeToInt(LSPriceShowType type);

/*鲜花礼品价格类型*/
static const int DeliveryStatusArray[] = {
    LSDELIVERYSTATUS_UNKNOW,
    LSDELIVERYSTATUS_PENDING,
    LSDELIVERYSTATUS_SHIPPED,
    LSDELIVERYSTATUS_DELIVERED,
    LSDELIVERYSTATUS_CANCELLED
};

// 底层状态转换JAVA坐标
int DeliveryStatusToInt(LSDeliveryStatus type);

/*广告URL打开方式类型*/
static const int LSAdvertOpenTypeArray[] = {
    LSAD_OT_HIDE,
    LSAD_OT_SYSTEMBROWER,
    LSAD_OT_APPBROWER,
    LSAD_OT_UNKNOW
};

// 底层状态转换JAVA坐标
int LSAdvertOpenTypeToInt(LSAdvertOpenType type);


//c++对象转Java对象
jobjectArray getJavaStringArray(JNIEnv *env, const list<string>& sourceList);
jintArray getJavaIntArray(JNIEnv *env, const list<int>& sourceList);
jintArray getInterestJavaIntArray(JNIEnv *env, const list<InterestType>& sourceList);

jobject getLoginItem(JNIEnv *env, const HttpLoginItem& item);

jobjectArray getPageRecommendAnchorArray(JNIEnv *env, const RecommendAnchorList& listItem);
jobjectArray getMyContactArray(JNIEnv *env, const RecommendAnchorList& listItem);
jobjectArray getAdListArray(JNIEnv *env, const AdItemList& listItem);
jobjectArray getHotListArray(JNIEnv *env, const HotItemList& listItem);
jobjectArray getFollowingListArray(JNIEnv *env, const FollowItemList& listItem);
jobjectArray getValidRoomArray(JNIEnv *env, const HttpGetRoomInfoItem::RoomItemList& listItem);
jobjectArray getImmediateInviteArray(JNIEnv *env, const InviteItemList& listItem);
jobjectArray getAudienceArray(JNIEnv *env, const HttpLiveFansList& listItem);
jobjectArray getGiftArray(JNIEnv *env, const GiftItemList& listItem);
jobjectArray getSendableGiftArray(JNIEnv *env, const GiftWithIdItemList& listItem);
jobject getGiftDetailItem(JNIEnv *env, const HttpGiftInfoItem& item);
jobjectArray getEmotionCategoryArray(JNIEnv *env, const EmoticonItemList& listItem);
jobjectArray getTalentArray(JNIEnv *env, const TalentItemList& listItem);
jobject getTalentInviteItem(JNIEnv *env, const HttpGetTalentStatusItem& item);
jobject getAudienceInfoItem(JNIEnv *env, const HttpLiveFansItem& item);

jobject getImmediateInviteItem(JNIEnv *env, const HttpInviteInfoItem& item);
jobjectArray getBookInviteArray(JNIEnv *env, const BookingPrivateInviteItemList& listItem);
jobject getBookInviteConfigItem(JNIEnv *env, const HttpGetCreateBookingInfoItem& item);

jobjectArray getPackgetGiftArray(JNIEnv *env, const BackGiftItemList& listItem);
jobjectArray getPackgetVoucherArray(JNIEnv *env, const VoucherList& listItem);
jobjectArray getPackgetRideArray(JNIEnv *env, const RideList& listItem);

jobject getSynConfigItem(JNIEnv *env, const HttpConfigItem& item);
jobject getAudienceBaseInfoItem(JNIEnv *env, const HttpLiveFansInfoItem& item);
jobjectArray getServerArray(JNIEnv *env, const HttpLoginItem::SvrList& list);
jobject getServerItem(JNIEnv *env, const HttpLoginItem::SvrItem& item);

jobject getUserInfoItem(JNIEnv *env, const HttpUserInfoItem& item);
jobject getAnchorInfoItem(JNIEnv *env, const HttpAnchorInfoItem& item);

jobject getBindAnchorItem(JNIEnv *env, const HttpVoucherInfoItem::BindAnchorItem& item);
jobjectArray getBindAnchorArray(JNIEnv *env, const HttpVoucherInfoItem::BindAnchorList& list);
jobject getVoucherInfoItem(JNIEnv *env, const HttpVoucherInfoItem& item);

jobject getHangoutAnchorInfoItem(JNIEnv *env, const HttpHangoutAnchorItem& item);
jobjectArray getHangoutAnchorInfoArray(JNIEnv *env, const HangoutAnchorList& list);
jobject getHangoutGiftListItem(JNIEnv *env, const HttpHangoutGiftListItem& item);
jobjectArray getHangoutOnlineAnchorArray(JNIEnv *env, const HttpHangoutList& list);
jobject getHangoutListItem(JNIEnv *env, const HttpHangoutListItem& item);
jobjectArray getFriendsInfoArray(JNIEnv *env, const HttpFriendsInfoList& list);
jobject getHttpFriendsInfoItem(JNIEnv *env, const HttpFriendsInfoItem& item);
jobjectArray getHangoutStatusArray(JNIEnv *env, const HttpHangoutStatusList& list);
jobject getHttpHangoutStatusItem(JNIEnv *env, const HttpHangoutStatusItem& item);

jobject getProgramInfoItem(JNIEnv *env, const HttpProgramInfoItem& item);
jobjectArray getProgramInfoArray(JNIEnv *env, const ProgramInfoList& list);

jobject getMainNoReadNumItem(JNIEnv *env, const HttpMainNoReadNumItem& item);

jobjectArray getValidSiteIdListArray(JNIEnv *env, HttpValidSiteIdList siteIdList);

jobject getMyProfileItem(JNIEnv *env, const HttpProfileItem& item);

jobject getVersionCheckItem(JNIEnv *env, const HttpVersionCheckItem& item);

jobject getHttpAuthorityItem(JNIEnv *env, const HttpAuthorityItem& item);

// 用户权限item
jobject getUserPrivItem(JNIEnv *env, const HttpLoginItem::HttpUserPrivItem& item);
jobject getLiveChatPrivItem(JNIEnv *env, const HttpLoginItem::HttpLiveChatPrivItem& item);
jobject getUserSendMailPrivItem(JNIEnv *env, const HttpLoginItem::HttpUserSendMailPrivItem& item);
jobject getMailPrivItem(JNIEnv *env, const HttpLoginItem::HttpMailPrivItem& item);
jobject getHangoutPrivItem(JNIEnv *env, const HttpLoginItem::HttpHangoutPrivItem& item);

/* SayHi */
jobject getSayHiResourceConfigItem(JNIEnv *env, const HttpSayHiResourceConfigItem& item);
jobjectArray getSayHiAnchorListArray(JNIEnv *env, const HttpSayHiAnchorList& list);
jobject getSayHiAllListInfoItem(JNIEnv *env, const HttpAllSayHiListItem& item);
jobject getSayHiResponseListInfoItem(JNIEnv *env, const HttpResponseSayHiListItem& item);
jobject getSayHiDetailItem(JNIEnv *env, const HttpSayHiDetailItem& item);
jobject getSayHiDetailResponseItem(JNIEnv *env, const HttpSayHiDetailItem::ResponseSayHiDetailItem& item);

jobjectArray getGiftTypeListArray(JNIEnv *env, const GiftTypeList& list);

jobject getLSLeftCreditItem(JNIEnv *env, const HttpLeftCreditItem& item);

jobject getLSBackpackUnreadNumItem(JNIEnv *env, const HttpGetBackPackUnreadNumItem& item);

/* 鲜花礼品*/
jobject getFlowerGiftItem(JNIEnv *env, const HttpFlowerGiftItem& item);
jobjectArray getFlowerGiftListArray(JNIEnv *env, const FlowerGiftList& list);
jobject getStoreFlowerGiftItem(JNIEnv *env, const HttpStoreFlowerGiftItem& item);
jobjectArray getStoreFlowerGiftListArray(JNIEnv *env, const StoreFlowerGiftList& list);
jobject getDeliveryFlowerGiftItem(JNIEnv *env, const HttpDeliveryFlowerGiftItem& item);
jobjectArray getDeliveryFlowerGiftListArray(JNIEnv *env, const DeliveryFlowerGiftList& list);
jobject getDeliveryItem(JNIEnv *env, const HttpMyDeliveryItem& item);
jobjectArray getDeliveryListArray(JNIEnv *env, const DeliveryList& list);
jobject getRecipientAnchorItem(JNIEnv *env, const HttpRecipientAnchorItem& item);
jobject getMyCartItem(JNIEnv *env, const HttpMyCartItem& item);
jobjectArray getMyCartListArray(JNIEnv *env, const MyCartItemList& list);
jobject getCheckoutFlowerGiftItem(JNIEnv *env, const HttpCheckoutFlowerGiftItem& item);
jobjectArray getCheckoutFlowerGiftListArray(JNIEnv *env, const CheckoutFlowerGiftList& list);
jobject getGreetingCardItem(JNIEnv *env, const HttpGreetingCardItem& item);
jobject getCheckoutItem(JNIEnv *env, const HttpCheckoutItem& item);
jobject getAdWomanListAdvertItem(JNIEnv *env, const HttpAdWomanListAdvertItem& item);

#endif
