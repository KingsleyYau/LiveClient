package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 主播在线状态
 * @author Hunter Mun
 *
 */
public enum HttpLccErrType {
    HTTP_LCC_ERR_SUCCESS,   		// 成功(0)
    HTTP_LCC_ERR_FAIL, 				// 服务器返回失败结果(-10000)

    // 客户端定义的错误
    HTTP_LCC_ERR_PROTOCOLFAIL,   	// 协议解析失败（服务器返回的格式不正确）(-10001)
    HTTP_LCC_ERR_CONNECTFAIL,    	// 连接服务器失败/断开连接(-10002)
//    HTTP_LCC_ERR_CHECKVERFAIL,   	// 检测版本号失败（可能由于版本过低导致）(-10003)
//
//    HTTP_LCC_ERR_SVRBREAK,       	// 服务器踢下线(-10004)
//    HTTP_LCC_ERR_INVITE_TIMEOUT, 	// 邀请超时(-10005)
    // 服务器返回错误
    HTTP_LCC_ERR_ROOM_FULL,   		// 房间人满(10023)
    HTTP_LCC_ERR_NO_CREDIT,   		// 信用点不足(10025)
    /* IM公用错误码 */
    HTTP_LCC_ERR_NO_LOGIN,   		// 未登录(10002)
    HTTP_LCC_ERR_SYSTEM,     		// 系统错误(10003)
    HTTP_LCC_ERR_TOKEN_EXPIRE, 		// Token 过期了(10004)
    HTTP_LCC_ERR_NOT_FOUND_ROOM, 	// 进入房间失败 找不到房间信息or房间关闭(10021)
    HTTP_LCC_ERR_CREDIT_FAIL, 		// 远程扣费接口调用失败(10027)

    HTTP_LCC_ERR_ROOM_CLOSE,  		// 房间已经关闭(10029)
    HTTP_LCC_ERR_KICKOFF, 			// 被挤掉线 默认通知内容(10037)
    HTTP_LCC_ERR_NO_AUTHORIZED, 	// 不能操作 不是对应的userid(10039)
    HTTP_LCC_ERR_LIVEROOM_NO_EXIST, // 直播间不存在(16104)
    HTTP_LCC_ERR_LIVEROOM_CLOSED, 	// 直播间已关闭(16106)

    HTTP_LCC_ERR_ANCHORID_INCONSISTENT, 	// 主播id与直播场次的主播id不合(16108)
    HTTP_LCC_ERR_CLOSELIVE_DATA_FAIL, 		// 关闭直播场次,数据表操作出错(16110)
    HTTP_LCC_ERR_CLOSELIVE_LACK_CODITION, 	// 主播立即关闭私密直播间, 不满足关闭条件(16122)
    /* 其它错误码*/
    HTTP_LCC_ERR_USED_OUTLOG, 				// 退出登录 (用户主动退出登录)(10051)
    HTTP_LCC_ERR_NOTCAN_CANCEL_INVITATION, 	// 取消立即私密邀请失败 状态不是带确认 /*important*/(10036)
    HTTP_LCC_ERR_NOT_FIND_ANCHOR, 			// 主播机构信息找不到(10026)
    HTTP_LCC_ERR_NOTCAN_REFUND, 			// 立即私密退点失败，已经定时扣费不能退点(10032)
    HTTP_LCC_ERR_NOT_FIND_PRICE_INFO, 		// 找不到price_setting表信息(10024)

    HTTP_LCC_ERR_ANCHOR_BUSY,			  	// 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/(10035)
    HTTP_LCC_ERR_CHOOSE_TIME_ERR, 			// 预约时间错误 /*important*/(10042)
    HTTP_LCC_ERR_BOOK_EXIST, 				// 用户预约时间段已经存在预约 /*important*/(10043)
    HTTP_LCC_ERR_BIND_PHONE, 				// 手机号码已绑定(10064)
    HTTP_LCC_ERR_RETRY_PHONE, 				// 请稍后再重试(10065)

    HTTP_LCC_ERR_MORE_TWENTY_PHONE, 		// 60分钟内验证超过20次，请24小时后再试(10066)
    HTTP_LCC_ERR_UPDATE_PHONE_FAIL, 		// 更新失败(10067)
    HTTP_LCC_ERR_ANCHOR_OFFLIVE,			// 主播不在线，不能操作(10059)
    HTTP_LCC_ERR_VIEWER_AGREEED_BOOKING,    // 观众已同意预约(10072)
    HTTP_LCC_ERR_OUTTIME_REJECT_BOOKING,    // 预约邀请已超时（当观众拒绝时, 10073）

    HTTP_LCC_ERR_OUTTIME_AGREE_BOOKING,      // 预约邀请已超时（当观众同意时, 10078）

    /* 换站的错误码和域名的错误吗*/
    HTTP_LCC_ERR_PLOGIN_PASSWORD_INCORRECT,      // 帐号或密码不正确 (200006)
    HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION,      // 需要验证码 和 MBCE21002: Please enter the verification code.(200003)
    HTTP_LCC_ERR_PLOGIN_VERIFICATION_WRONG,      // 验证码不正确 和 MBCE21003:The verification code is wrong(200004)
    HTTP_LCC_ERR_TLOGIN_SID_NULL,                // sid无效(200017)
    HTTP_LCC_ERR_TLOGIN_SID_OUTTIME,             // sid超时(200018)

    HTTP_LCC_ERR_DEMAIN_NO_FIND_MAIL,            // MBCE21001：(没有找到匹配的邮箱。)(921001)
    HTTP_LCC_ERR_DEMAIN_CURRENT_PASSWORD_WRONG,  // MBCE13001：Sorry, the current password you entered is wrong!(913001)
    HTTP_LCC_ERR_DEMAIN_ALL_FIELDS_WRONG,       // MBCE13002：Please check if all fields are filled and correct!(913002)
    HTTP_LCC_ERR_DEMAIN_THE_OPERATION_FAILED,       // MBCE13003：The operation failed  /mobile/changepwd.ph(913003)
    HTTP_LCC_ERR_DEMAIN_PASSWORD_FORMAT_WRONG,      // MBCE13004：Password format error(913004)

    HTTP_LCC_ERR_DEMAIN_NO_FIND_USERID,         // MBCE11001：(QpidNetWork男士会员ID未找到) /mobile/myprofile.php(911001)
    HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_ERR,        // MBCE12001：Data update error. ( 数据更新失败)  /mobile/updatepro.php(912001)
    HTTP_LCC_ERR_DEMAIN_DATA_NO_EXIST_KEY,            // MBCE12002:( 更新失败：Key不存在。)  /mobile/updatepro.php(912002)
    HTTP_LCC_ERR_DEMAIN_DATA_UNCHANGE_VALUE,            // MBCE12003：( 更新失败：Value值没有改变。)(912002)
    HTTP_LCC_ERR_DEMAIN_DATA_UNPASS_VALUE,            // MBCE12004：( 更新失败：Value值检测没通过。)(912004)

    HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFO_DESC_LOG,            // MBCE12005：update info_desc_log(912005)
    HTTP_LCC_ERR_DEMAIN_DATA_INSERT_INFO_DESC_LOG,            // MBCE12006：insert into info_desc_log(912006)
    HTTP_LCC_ERR_DEMAIN_DATA_UPDATE_INFODESCLOG_SETGROUPID,   // MBCE12007：update info_desc_log set group_id(912007)
    HTTP_LCC_ERR_DEMAIN_APP_EXIST_LOGS,                        // MBCE22001：(APP安装记录已存在。)(912008)
    HTTP_LCC_ERR_PRIVTE_INVITE_AUTHORITY,                        // 主播无立即私密邀请权限(17002)
//    /* 信件*/
//    HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_HASCREDIT,          // 购买图片使用邮票支付时，邮票不足，但信用点可用(17213)(调用13.7.购买信件附件接口)
//    HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_NOCREDIT,          // 购买图片使用邮票支付时，邮票不足，且信用点不足(17214)(调用13.7.购买信件附件接口)
//    HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOCREDIT_HASSTAMP,          // 购买图片使用信用点支付时，信用点不足，但邮票可用(17215)(调用13.7.购买信件附件接口)
//
//    HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOSTAMP_NOCREDIT,          // 购买图片使用信用点支付时，信用点不足，且邮票不足(17216)(调用13.7.购买信件附件接口)
//    HTTP_LCC_ERR_LETTER_PHOTO_OVERTIME,                     // 照片已过期(17217)(调用13.7.购买信件附件接口)
//    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_HASCREDIT,          // 购买视频使用邮票支付时，邮票不足，但信用点可用(17218)(调用13.7.购买信件附件接口)
//    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_NOCREDIT,          // 购买视频使用邮票支付时，邮票不足，且信用点不足(17219)(调用13.7.购买信件附件接口)
//    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOCREDIT_HASSTAMP,          // 购买视频使用信用点支付时，信用点不足，但邮票可用(17220)(调用13.7.购买信件附件接口)
//
//    HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOSTAMP_NOCREDIT,          // 购买视频使用信用点支付时，信用点不足，且邮票不足(17221)(调用13.7.购买信件附件接口)
//    HTTP_LCC_ERR_LETTER_VIDEO_OVERTIME,                                // 视频已过期(17222)(调用13.7.购买信件附件接口)
//    HTTP_LCC_ERR_LETTER_NO_CREDIT_OR_NO_STAMP,                         // 信用点或者邮票不足(17208):(调用13.4.信件详情接口, 调用13.5.发送信件接口)
    HTTP_LCC_ERR_EXIST_HANGOUT                                        // 当前会员已在hangout直播间（调用8.11.获取当前会员Hangout直播状态接口） 18003
}
