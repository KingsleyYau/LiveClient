package com.qpidnetwork.livemodule.im;

import android.text.TextUtils;

import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.HashMap;

/**
 * 本地缓存会员基本信息（主播/观众）
 *
 * 2018年1月11日 13:45:16
 * 1.进入直播间，将携带的主播ID、photoUrl等信息更新到mUserBaseInfoMap，
 * 	同时以用户自己的ID调用http 3.12获取指定观众信息接口，更新mUserBaseInfoMap
 * 2.接收到进入直播间通知，不更新mUserBaseInfoMap
 * 3.刷新在线观众头像列表数据后，不更新mUserBaseInfoMap(这两点都是为了避免oom)
 * 4.接收到直播间弹幕/礼物通知时，查询mUserBaseInfoMap，
 * 	查询不到时，则调用http 3.12获取指定观众信息接口，更新到mUserBaseInfoMap
 *
 *2018年1月11日 14:25:52 Samson - 我们刚刚讨论的用户信息处理如下：
 1. 独立App的《6.14.获取个人信息（仅独立）（http post）》（getManBaseInfo）
 或QN App登录成功后调用《6.10.获取主播/观众信息（http post）》页获取的个人资料，仅用于个人信息中心显示，与直播间中的用户信息显示无关
 2. 直播间中的观众列表是通过《3.4.获取直播间观众头像列表（http post）》来获取头像并显示，且不同步到UserInfoManager中
 3. 直播间中显示的主播信息是从过渡界面调用《6.10.获取主播/观众信息（http post）》获取回来的
 4. 进入直播间后，调用《3.12.获取指定观众信息（http post）》获取当前用户信息并同步到UserInfoManager中（不是调用UserInfoManager为空才调用接口获取，是主动调用并更新）
 5. 在直播间中，若有观众发送礼物、弹幕等，才调用UserInfoManager获取用户信息，已有则从缓存给出，若没有则调用《3.12.获取指定观众信息（http post）》获取并同步到UserInfoManager
 *
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMUserBaseInfoManager {

	private final String TAG = IMUserBaseInfoManager.class.getSimpleName();

	private HashMap<String, IMUserBaseInfoItem> mUserBaseInfoMap;
	
	public IMUserBaseInfoManager(){
		mUserBaseInfoMap = new HashMap<String, IMUserBaseInfoItem>();
	}

	/**
	 * 添加到本地缓存
	 * @param userInfo
	 */
	public void updateOrAddUserBaseInfo(IMUserBaseInfoItem userInfo){
		if(userInfo != null && !TextUtils.isEmpty(userInfo.userId)){
			Log.d(TAG,"updateOrAddUserBaseInfo-userId:"+userInfo.userId+" photoUrl:"+userInfo.photoUrl);
			synchronized (mUserBaseInfoMap) {
				if(mUserBaseInfoMap.containsKey(userInfo.userId)){
					IMUserBaseInfoItem item = mUserBaseInfoMap.get(userInfo.userId);
					item.nickName = userInfo.nickName;
					item.photoUrl = userInfo.photoUrl;
				}else{
					mUserBaseInfoMap.put(userInfo.userId, userInfo);
				}
			}
		}
	}
	
	/**
	 * 从本地缓存取出用户信息
	 * @param userId
	 * @return
	 */
	public IMUserBaseInfoItem getUserBaseInfo(String userId){
		IMUserBaseInfoItem item = null;
		if(!TextUtils.isEmpty(userId)){
			synchronized (mUserBaseInfoMap) {
				if(mUserBaseInfoMap.containsKey(userId)){
					item = mUserBaseInfoMap.get(userId);
				}
			}
		}
		return item;
	}
}
