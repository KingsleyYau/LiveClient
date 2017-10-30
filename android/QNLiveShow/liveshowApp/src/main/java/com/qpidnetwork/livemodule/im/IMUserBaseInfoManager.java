package com.qpidnetwork.livemodule.im;

import java.util.HashMap;

import android.text.TextUtils;

import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;

/**
 * 本地缓存会员基本信息（主播/观众）
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMUserBaseInfoManager {
	
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
