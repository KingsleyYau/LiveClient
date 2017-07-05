package com.qpidnetwork.im;

import java.util.HashMap;

import android.content.Context;
import android.text.TextUtils;

import com.qpidnetwork.httprequest.OnGetUserPhotoCallback;
import com.qpidnetwork.httprequest.RequestJni;
import com.qpidnetwork.httprequest.RequestJniUserInfo;
import com.qpidnetwork.im.listener.IMMessageItem;
import com.qpidnetwork.im.listener.IMUserBaseInfoItem;

/**
 * 本地缓存会员基本信息（主播/观众）
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMUserBaseInfoManager {
	
	private HashMap<String, IMUserBaseInfoItem> mUserBaseInfoMap;

	private static IMUserBaseInfoManager mIMUserBaseInfoManager;

	public static IMUserBaseInfoManager newInstance(){
		if(mIMUserBaseInfoManager == null){
			mIMUserBaseInfoManager = new IMUserBaseInfoManager();
		}
		return mIMUserBaseInfoManager;
	}

	public static IMUserBaseInfoManager getInstance(){
		return mIMUserBaseInfoManager;
	}
	
	private IMUserBaseInfoManager(){
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
				if(item == null){
					item = new IMUserBaseInfoItem();
					item.userId = userId;
					mUserBaseInfoMap.put(userId, item);
				}
			}
		}
		return item;
	}

	/**
	 * 检测本地是否存在用户信息（没有则创建）
	 * @param userId
	 * @param nickName
	 * @return
	 */
	public IMUserBaseInfoItem getUserBaseInfo(String userId, String nickName){
		IMUserBaseInfoItem item = null;
		if(!TextUtils.isEmpty(userId)){
			synchronized (mUserBaseInfoMap) {
				if(mUserBaseInfoMap.containsKey(userId)){
					item = mUserBaseInfoMap.get(userId);
					item.nickName = nickName;
				}
				if(item == null){
					item = new IMUserBaseInfoItem();
					item.userId = userId;
					item.nickName = nickName;
					mUserBaseInfoMap.put(userId, item);
				}
			}
		}
		return item;
	}

	/**
	 * 根据用户ID获取用户小头像用于显示
	 * @param userId
	 */
	public long getUserSmallPhoto(final String userId, final OnGetUserPhotoCallback callback){
		return RequestJniUserInfo.GetUserPhotoInfo(userId, RequestJniUserInfo.PhotoType.Thumb, new OnGetUserPhotoCallback() {
			@Override
			public void onGetUserPhoto(boolean isSuccess, int errCode, String errMsg, String photoUrl) {
				IMUserBaseInfoItem userItem = getUserBaseInfo(userId);
				if(!TextUtils.isEmpty(photoUrl)){
					userItem.photoUrl = photoUrl;
				}
				if(callback != null) {
					callback.onGetUserPhoto(isSuccess, errCode, errMsg, photoUrl);
				}
			}
		});
	}
}
