package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem.DeviceType;

import java.util.List;

/**
 * 5.Live Chat
 * @author Max.Chiu
 *
 */
public class LCRequestJniLiveChat {
	
	public enum ServiceType{
		LiveChat,
		CamShare
	}
	/**
	 * 5.1.查询是否符合试聊条件
	 * @param womanId			女士ID
	 * @param serviceType       查询指定服务类型
	 * @param callback			
	 * @return					请求唯一标识
	 */
	static public long CheckCoupon(String womanId, ServiceType serviceType, OnCheckCouponCallCallback callback){
		return CheckCoupon(womanId, serviceType.ordinal(), callback);
	}
	static public native long CheckCoupon(String womanId, int serviceType, OnCheckCouponCallCallback callback);
	
	/**
	 * 5.2.使用试聊券
	 * @param womanId			女士ID
	 * @param serviceType       查询指定服务类型
	 * @param callback			
	 * @return					请求唯一标识
	 */
	static public long UseCoupon(String womanId, ServiceType serviceType, OnLCUseCouponCallback callback){
		return UseCoupon(womanId, serviceType.ordinal(), callback);
	}
	
	static public native long UseCoupon(String womanId, int serviceType, OnLCUseCouponCallback callback);
	
//	/**
//	 * 5.3.获取虚拟礼物列表
//	 * @param sessionId			登录成功返回的sessionid
//	 * @param userId			登录成功返回的manid
//	 * @param callback
//	 * @return					请求唯一标识
//	 */
//	static public native long QueryChatVirtualGift(String sessionId, String userId,
//			OnQueryChatVirtualGiftCallback callback);
	
	/**
	 * 5.4.查询聊天记录
	 * @param inviteId			邀请ID
	 * @param callback			
	 * @return					请求唯一标识
	 */
	static public native long QueryChatRecord(String inviteId, OnQueryChatRecordCallback callback);
	
	/**
	 * 5.5.批量查询聊天记录
	 * @param inviteId			邀请ID数组
	 * @param callback			
	 * @return					请求唯一标识
	 */
	static public native long QueryChatRecordMutiple(String[] inviteIds, OnQueryChatRecordMutipleCallback callback);
	
//	/**
//	 * 发送私密照片
//	 * @param targetId	接收方ID
//	 * @param inviteId	邀请ID
//	 * @param userId	用户ID
//	 * @param sid		sid
//	 * @param filePath	待发送的文件路径
//	 * @return
//	 */
//	static public native long SendPhoto(String targetId, String inviteId, String userId, String sid, String filePath, OnLCSendPhotoCallback callback);
//
//	/**
//	 * 付费获取私密照片
//	 * @param targetId	接收方ID
//	 * @param inviteId	邀请ID
//	 * @param userId	用户ID
//	 * @param sid		sid
//	 * @param photoId	照片ID
//	 * @return
//	 */
//	static public native long PhotoFee(String targetId, String inviteId, String userId, String sid, String photoId, OnLCPhotoFeeCallback callback);
//
	/**
	 * 获取类型
	 */
	public enum ToFlagType {
		/**
		 * 女士获取男士
		 */
		WomanGetMan,
		/**
		 * 男士获取女士
		 */
		ManGetWoman,
		/**
		 * 女士获取自己
		 */
		WomanGetSelf,
		/**
		 * 男士获取自己
		 */
		ManGetSelf
	}
	
	/**
	 * 照片尺寸
	 */
	public enum PhotoSizeType {
		/**
		 * 大图
		 */
		Large,
		/**
		 * 中图
		 */
		Middle,
		/**
		 * 小图
		 */
		Small,
		/**
		 * 原图
		 */
		Original
	}
	
	/**
	 * 照片类型
	 */
	public enum PhotoModeType {
		/**
		 * 模糊
		 */
		Fuzzy,
		/**
		 * 清晰
		 */
		Clear
	}

//	/**
//	 * 获取照片
//	 * @param toFlag	获取类型
//	 * @param targetId	照片所有者ID
//	 * @param userId	用户ID
//	 * @param sid		sid
//	 * @param photoId	照片ID
//	 * @param sizeType	照片尺寸
//	 * @param modeType	照片类型
//	 * @param filePath	照片文件路径
//	 * @return
//	 */
//	static public long GetPhoto(ToFlagType toFlag, String targetId, String userId, String sid, String photoId, PhotoSizeType sizeType, PhotoModeType modeType, String filePath, OnLCGetPhotoCallback callback) {
//		return GetPhoto(toFlag.ordinal(), targetId, userId, sid, photoId, sizeType.ordinal(), modeType.ordinal(), filePath, callback);
//	}
//	static protected native long GetPhoto(int toFlag, String targetId, String userId, String sid, String photoId, int sizeType, int modeType, String filePath, OnLCGetPhotoCallback callback);
//
	/**
	 * 上传语音文件
	 * @param voiceCode		语音验证码
	 * @param inviteId		邀请ID
	 * @param mineId		自己的用户ID
	 * @param isMan			是否男士
	 * @param userId		对方的用户ID
	 * @param siteType		站点ID		
	 * @param fileType		文件类型(mp3, aac...)
	 * @param voiceLength	语音时长
	 * @param filePath		语音文件路径
	 * @param callback
	 * @return
	 */
	static public native long UploadVoice(
			String voiceCode
			, String inviteId
			, String mineId
			, boolean isMan
			, String userId
			, int siteType
			, String fileType
			, int voiceLength
			, String filePath
			, OnLCUploadVoiceCallback callback);
	
	/**
	 * 下载语音文件
	 * @param voiceId	语音ID
	 * @param siteType	站点ID
	 * @param filePath	文件路径
	 * @param callback
	 * @return
	 */
	static public native long PlayVoice(String voiceId, int siteType, String filePath, OnLCPlayVoiceCallback callback);
	
	/**
	 * 模块类型
	 */
	public enum UseType {
		/**
		 * 邮件
		 */
		EMF,
		/**
		 * LiveChat
		 */
		CHAT
	}
	
//	/**
//	 * 6.11.发送虚拟礼物
//	 * @param womanId		女士ID
//	 * @param vg_id			虚拟礼物ID
//	 * @param device_id		设备唯一标识
//	 * @param chat_id		livechat邀请ID或EMF邮件ID
//	 * @param use_type		模块类型<UseType>
//	 * @param user_sid		登录成功返回的sessionid
//	 * @param user_id		登录成功返回的manid
//	 * @param callback
//	 * @return				请求唯一Id
//	 */
//	static public long SendGift(
//			String womanId,
//			String vg_id,
//			String device_id,
//			String chat_id,
//			UseType use_type,
//			String user_sid,
//			String user_id,
//			OnLiveChatRequestCallback callback) {
//		return SendGift(womanId, vg_id, device_id, chat_id, use_type.ordinal(), user_sid, user_id, callback);
//	}
//	static protected native long SendGift(
//			String womanId,
//			String vg_id,
//			String device_id,
//			String chat_id,
//			int use_type,
//			String user_sid,
//			String user_id,
//			OnLiveChatRequestCallback callback);
//
//	/**
//	 * 6.12.获取最近已看微视频列表（http post）（New）
//	 * @param womanId		女士ID
//	 * @param callback
//	 * @return				请求唯一Id
//	 */
//	static public native long QueryRecentVideo(
//			String user_sid,
//			String user_id,
//			String womanId,
//			OnQueryRecentVideoListCallback callback);
//
	/**
	 * 获取类型
	 */
	public enum VideoPhotoType {
		Default,
		Big,
	}
//	/**
//	 * 6.13.获取微视频图片（http get）（New）
//	 * @param womanId		女士ID
//	 * @param videoid		视频ID
//	 * @param type			图片尺寸<VideoPhotoType>
//	 * @param filePath		文件路径
//	 * @param callback
//	 * @return				请求唯一Id
//	 */
//	static public long GetVideoPhoto(
//			String user_sid,
//			String user_id,
//			String womanId,
//			String videoid,
//			VideoPhotoType type,
//			String filePath,
//			OnLCRequestFileCallback callback) {
//		return GetVideoPhoto(user_sid, user_id, womanId, videoid, type.ordinal(), filePath, callback);
//	}
//	static protected native long GetVideoPhoto(
//			String user_sid,
//			String user_id,
//			String womanId,
//			String videoid,
//			int type,
//			String filePath,
//			OnLCRequestFileCallback callback);
//
	/**
	 * 获取类型
	 */
	public enum VideoToFlagType {
		Woman,
		Man,
	}
//
//	/**
//	 * 6.14.获取微视频文件URL（http post）
//	 * @param womanId		女士ID
//	 * @param videoid		视频ID
//	 * @param inviteid		邀请ID
//	 * @param toflag		客户端类型<VideoToFlagType>
//	 * @param sendid		发送ID，在LiveChat收到女士端发出的消息中
//	 * @param callback
//	 * @return				请求唯一Id
//	 */
//	static public long GetVideo(
//			String user_sid,
//			String user_id,
//			String womanId,
//			String videoid,
//			String inviteid,
//			VideoToFlagType toflag,
//			String sendid,
//			OnLCGetVideoCallback callback) {
//		return GetVideo(user_sid, user_id, womanId, videoid, inviteid, toflag.ordinal(), sendid, callback);
//	}
//	static protected native long GetVideo(
//			String user_sid,
//			String user_id,
//			String womanId,
//			String videoid,
//			String inviteid,
//			int toflag,
//			String sendid,
//			OnLCGetVideoCallback callback);
	
	/**
	 * 6.15 查询小高级表情配置
	 * @param callback
	 * @return
	 */
	static public native long GetMagicIconConfig(OnLCGetMagicIconConfigCallback callback);
	
//	/**
//	 * 6.16.开聊自动买点（http post）
//	 * @param womanId		女士ID
//	 * @param callback		回调
//	 * @return
//	 */
//	static public native long ChatRecharge(String womanId, String user_sid, String user_id, OnLCChatRechargeCallback callback);
//
//	/**
//	 * 6.17 获取主题配置
//	 * @param user_sid
//	 * @param user_id
//	 * @param callback
//	 * @return
//	 */
//	static public native long GetThemeConfig(String user_sid, String user_id, OnLCGetThemeConfigCallback callback);
//
//	/**
//	 * 6.17 获取指定主题详情
//	 * @param themeIds 制定主题ID列表
//	 * @param user_sid
//	 * @param user_id
//	 * @param callback
//	 * @return
//	 */
//	public static long GetThemeDetail(List<String> themeIds, String user_sid, String user_id, OnLCGetThemeDetailCallback callback){
//		String themes = "";
//		if(themeIds != null){
//			for(int i=0; i < themeIds.size(); i++){
//				if(i != (themeIds.size()-1)){
//					themes += themeIds.get(i) + ",";
//				}else{
//					themes += themeIds.get(i);
//				}
//			}
//		}
//		return GetThemeDetail(themes, user_sid, user_id, callback);
//	}
//	static public native long GetThemeDetail(String themeIds, String user_sid, String user_id, OnLCGetThemeDetailCallback callback);
//
	/**
	 * 功能点列表
	 */
	public enum FunctionType{
		CHAT_TEXT,
		CHAT_VIDEO,
		CHAT_EMOTION,
		CHAT_TRYTIKET,
		CHAT_GAME,
		CHAT_VOICE,
		CHAT_MAGICICON,
		CHAT_PRIVATEPHOTO,
		CHAT_SHORTVIDEO;
	}
	/**
	 * 6.19检测功能是否开通
	 * @param functionList 待检测功能列表
	 * @param type 设备类型
	 * @param versionCode 待检测版本号
	 * @param user_sid session id
	 * @param user_id 用户ID
	 * @return
	 */
	public static long CheckFunctions(List<FunctionType> functionList,
                                      DeviceType type, String versionCode, String user_sid, String user_id, OnLCCheckFunctionsCallback callback){
		int[] functions = null;
		if(functionList != null){
			functions = new int[functionList.size()];
			for(int i=0; i<functionList.size(); i++){
				functions[i] = functionList.get(i).ordinal();
			}
		}
		return CheckFunctions(functions, type.ordinal(), versionCode, user_sid, user_id, callback);
	}
	
	static protected native long CheckFunctions( int[] functionIds, int deviceType, String versionCode, String user_sid, String user_id, OnLCCheckFunctionsCallback callback);
}
