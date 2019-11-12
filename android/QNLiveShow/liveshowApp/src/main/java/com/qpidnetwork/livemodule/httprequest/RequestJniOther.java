package com.qpidnetwork.livemodule.httprequest;


import com.qpidnetwork.livemodule.httprequest.item.LSAdvertSpaceType;
import com.qpidnetwork.livemodule.httprequest.item.RegionType;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Children;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Country;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Drink;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Education;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Ethnicity;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.HandleEmailType;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Height;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Income;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Language;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Profession;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Religion;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Smoke;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Weight;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Zodiac;

/**
 * 5. 其他接口
 * @author Hunter Mun
 * @since 2017-6-8
 */
public class RequestJniOther {
	
	/**
	 * 6.1. 同步配置
	 * @param callback
	 * @return
	 */
	static public native long SynConfig(OnSynConfigCallback callback);
	

	/**
	 * 6.2.获取账号余额
	 * @param callback
	 * @return
	 */
	static public native long GetAccountBalance(OnGetAccountBalanceCallback callback);
	
	/**
	 * 6.3.添加/取消收藏
	 * @param anchorId
	 * @param roomId  直播间ID（可无，无则表示不在直播间操作）
	 * @param isFav
	 * @param callback
	 * @return
	 */
	static public native long AddOrCancelFavorite(String anchorId, String roomId, boolean isFav, OnRequestCallback callback);
	/**
	 * 6.4.获取QN广告列表
	 * @param number      客户端需要获取的数量
	 * @param callback
	 * @return
	 */
	static public native long GetAdAnchorList(int number, OnGetAdAnchorListCallback callback);


	/**
	 * 6.5.关闭QN广告列表
	 * @param callback
	 * @return
	 */
	static public native long CloseAdAnchorList(OnRequestCallback callback);
	
	/**
	 * 6.6.获取手机验证码
	 * @param country      国家
	 * @param areaCode     手机区号
	 * @param phoneNo      手机号码
	 * @param callback
	 * @return
	 */
	static public native long GetPhoneVerifyCode(String country, String areaCode, String phoneNo, OnRequestCallback callback);
	
	/**
	 * 6.7.提交手机验证码
	 * @param country      国家
	 * @param areaCode     手机区号
	 * @param phoneNo      手机号码
	 * @param verifyCode   验证码
	 * @param callback
	 * @return
	 */
	static public native long SubmitPhoneVerifyCode(String country, String areaCode, String phoneNo, String verifyCode, OnRequestCallback callback);
	
	/**
	 * 6.8.提交流媒体服务器测速结果
	 * @param sid      	流媒体服务器ID
	 * @param res     	http请求完成时间（毫秒）
	 * @param callback
	 * @return
	 */
	static public native long ServerSpeed(String sid, int res, OnRequestCallback callback);
	
	/**
	 * 6.9.获取Hot/Following列表头部广告
	 * @param callback
	 * @return
	 */
	static public native long Banner(OnBannerCallback callback);
	
	/**
	 * 6.10.获取主播/观众信息
	 * @param userId   		观众ID或者主播ID
	 * @param callback
	 * @return
	 */
	static public native long GetUserInfo(String userId, OnGetUserInfoCallback callback);

	/**
	 * 6.17.获取主界面未读数量
	 * @param callback
	 * @return
	 */
	static public native long GetMainUnreadNum(OnGetMainUnreadNumCallback callback);

	/**
	 * 6.18.查询个人信息
	 * @param callback
	 * @return
	 */
	static public native long GetMyProfile(OnGetMyProfileCallback callback);

	/**
	 * 2.2.修改个人信息
	 * @param weight		体重
	 * @param height		身高
	 * @param language		语言
	 * @param ethnicity		人种
	 * @param religion		宗教
	 * @param education		教育程度
	 * @param profession	职业
	 * @param income		收入情况
	 * @param children		子女状况
	 * @param smoke			吸烟情况
	 * @param drink			喝酒情况
	 * @param resume		个人简介
	 * @param interest		兴趣爱好
	 * @param zodiac		星座
	 * @return				请求唯一标识
	 */
	static public long UpdateProfile(
			Weight weight,
			Height height,
			Language language,
			Ethnicity ethnicity,
			Religion religion,
			Education education,
			Profession profession,
			Income income,
			Children children,
			Smoke smoke,
			Drink drink,
			String resume,
			String[] interest,
			Zodiac zodiac,
			OnUpdateMyProfileCallback callback
	) {
		return UpdateProfile(
				weight.ordinal(),
				height.ordinal(),
				language.ordinal(),
				ethnicity.ordinal(),
				religion.ordinal(),
				education.ordinal(),
				profession.ordinal(),
				income.ordinal(),
				children.ordinal(),
				smoke.ordinal(),
				drink.ordinal(),
				resume,
				interest,
				zodiac.ordinal(),
				callback
		);
	}
	static protected native long UpdateProfile(
			int weight,
			int height,
			int language,
			int ethnicity,
			int religion,
			int education,
			int profession,
			int income,
			int children,
			int smoke,
			int drink,
			String resume,
			String[] interest,
			int zodiac,
			OnUpdateMyProfileCallback callback
	);

	/**
	 * 6.20.检查客户端更新
	 * @param currVer	当前客户端内部版本号
	 * @param callback
	 * @return
	 */
	static public native long VersionCheck(int currVer, OnOtherVersionCheckCallback callback);

	/**
	 * 6.21.开始编辑简介触发计时
	 * @param callback
	 * @return
	 */
	static public native long StartEditResume(OnRequestCallback callback);

	public enum LSActionType {
		SETUP,		// 新安装
		NEWUSER		// 新用户
	}
	/**
	 * 6.22.收集手机硬件信息
	 * @param manId			男士ID
	 * @param verCode		客户端内部版本号
	 * @param verName		客户端显示版本号
	 * @param action		新用户类型
	 * @param siteId		站点ID
	 * @param density		屏幕密度
	 * @param width			屏幕宽度
	 * @param height		屏幕高度
	 * @param lineNumber	电话号码
	 * @param simOptName	sim卡服务商名字
	 * @param simOpt		sim卡移动国家码
	 * @param simCountryIso	sim卡ISO国家码
	 * @param simState		sim卡状态
	 * @param phoneType		手机类型
	 * @param networkType	网络类型
	 * @param deviceId		设备唯一标识
	 * @param callback
	 * @return
	 */
	static public long PhoneInfo(String manId, int verCode, String verName, LSActionType action, int siteId
			, double density, int width, int height, String lineNumber, String simOptName, String simOpt, String simCountryIso
			, String simState, int phoneType, int networkType, String deviceId
			, OnRequestCallback callback) {
		return PhoneInfo(manId, verCode, verName, action.ordinal(), siteId
				, density, width, height, lineNumber, simOptName, simOpt, simCountryIso
				, simState, phoneType, networkType, deviceId
				, callback);
	}
		static protected native long PhoneInfo(String manId, int verCode, String verName, int action, int siteId
				, double density, int width, int height, String lineNumber, String simOptName, String simOpt, String simCountryIso
				, String simState, int phoneType, int networkType, String deviceId
				, OnRequestCallback callback);


	/**
	 *  6.23.qn邀请弹窗更新邀请id
	 * @param manId					用户ID
	 * @param anchorId				主播id
	 * @param inviteId				邀请id
	 * @param roomId				直播间id
	 * @param inviteType			邀請類型(LSBUBBLINGINVITETYPE_ONEONONE:one-on-one LSBUBBLINGINVITETYPE_HANGOUT:Hangout LSBUBBLINGINVITETYPE_LIVECHAT:Livechat)
	 * @param callback
	 * @return
	 */
	static public long UpQnInviteId(String manId, String anchorId, String inviteId, String roomId, LSRequestEnum.LSBubblingInviteType inviteType, OnRequestCallback callback){
		return UpQnInviteId(manId, anchorId, inviteId, roomId, inviteType.ordinal(), callback);
	}
	static private native long UpQnInviteId(String manId, String anchorId, String inviteId, String roomId, int inviteType, OnRequestCallback callback);

	/**
	 *  6.24.获取直播广告
	 * @param manId					用户ID
	 * @param isAnchorPage			是否主播详情页 （是否在主播详情页里，暂时用在主页使用false）
	 * @param bannerType			广告页类型（主播在那个界面，暂时用在主页显示广告使用Unknow）
	 * @param callback
	 * @return
	 */
	static public long RetrieveBanner(String manId, boolean isAnchorPage, LSRequestEnum.LSBannerType bannerType, OnRetrieveBannerCallback callback) {

		return RetrieveBanner(manId, isAnchorPage, bannerType.ordinal(), callback);
	}
	static private native long RetrieveBanner(String manId, boolean isAnchorPage, int bannerType, OnRetrieveBannerCallback callback);


	/**
	 * 6.25.获取直播主播列表广告
	 * @param deviceId		设备唯一标识
	 * @param callback		回调object
	 * @return
	 */

	static public native long WomanListAdvert(String deviceId, OnLSAdWomanistAdvertCallback callback);

}
