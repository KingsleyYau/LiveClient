package com.qpidnetwork.livemodule.livechat;

import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.livechat.LCFunctionsManager.OnGetFunctionSettingCallback;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.FunctionType;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.HashMap;

/**
 * 女士端是否开启相关功能检测
 * @author Hunter
 * 2016.4.11
 */
public class LCFunctionCheckManager {
	
	private static final int GET_LADY_INFO_CALLBACK = 1;
	private static final int FUNCTION_CHECK_FINISH = 2;
	
	/**
	 * 存放当前详情的更新时间
	 */
	private HashMap<String, Long> mCheckingMap;
	
	/**
	 * 用户管理类
	 */
	private LCUserManager mUserMgr;
	
	/**
	 * 功能设置管理
	 */
	private LCFunctionsManager mLCFunctionsManager;
	
	private Handler mHandler;
	
	private LiveChatManager mLivechatManager;
	
	private LCUserInfoManager mUserInfoManager;
	
	public LCFunctionCheckManager(LCUserManager userMgr, LiveChatManager manager, LCUserInfoManager userInfoManager){
		mUserMgr = userMgr;
		mLivechatManager = manager;
		mUserInfoManager = userInfoManager;
		mCheckingMap = new HashMap<String, Long>();
		mLCFunctionsManager = new LCFunctionsManager();
		mHandler = new Handler() {
			@Override
			public void handleMessage(Message msg){
				switch (msg.what) {
				case GET_LADY_INFO_CALLBACK:{
					LiveChatTalkUserListItem item = (LiveChatTalkUserListItem)msg.obj;
					if(msg.arg1 == 1){
						//成功
						if(mCheckingMap.containsKey(item.userId)){
							//正在检测功能中...
							GetFunctionSetting(item);
						}
					}else{
						mCheckingMap.remove(item.userId);
						mLivechatManager.onFunctionCheckFinish(item.userId);
					}
				}break;
				case FUNCTION_CHECK_FINISH:{
					String userId = (String) msg.obj;
					mCheckingMap.remove(userId);
					mLivechatManager.onFunctionCheckFinish(userId);
				}break;

				default:
					break;
				}
			}
		};
	}
	
	/**
	 * 检测功能是否可用
	 * @param womanId
	 */
	public void CheckFunctionSupported(String womanId){
		Log.i("LCFunctionCheckManager", "CheckFunctionSupported UserId: " + womanId);
		LiveChatTalkUserListItem info = null;
		//建立会话时才可使用本地缓存中女士信息
		LCUserItem userItem = mUserMgr.getUserItem(womanId);
		if(userItem.isInSession()){
			info = mUserInfoManager.getLadyInfo(womanId);
		}
		if(info != null){
			GetFunctionSetting(info);
		}else{
			if(LiveChatClient.GetUserInfo(womanId)){
				mCheckingMap.put(womanId, Long.valueOf(System.currentTimeMillis()/1000));
			}else{
				NotifyFunctionCheckFinish(womanId);
			}
		}
	}
	
	/**
	 * 根据本地数据监测功能对端是否支持
	 * @param item
	 * @return
	 */
	public boolean localCheckFunctionSupport(LCMessageItem item){
		boolean isSupported = true;
		String userId = item.getUserItem().userId;
		FunctionType type = LiveChatMessageHelper.getFunctionTypeByMsgType(item.msgType);
		Log.i("LCFunctionCheckManager", "localCheckFunctionSupport userId: " + item.getUserItem().userId + " msgType: " + item.msgType.ordinal() + " Function type:" + type.ordinal());
		if(!TextUtils.isEmpty(userId) && type != null ){
			LiveChatTalkUserListItem ladyInfo = mUserInfoManager.getLadyInfo(userId);
			Log.i("LCFunctionCheckManager", "localCheckFunctionSupport ladyInfo: " + ladyInfo);
			if(ladyInfo != null){
				HashMap<FunctionType, Boolean> functionSetting = mLCFunctionsManager.GetFunctionSetting(
						ladyInfo.deviceType, ladyInfo.clientVersion);
				Log.i("LCFunctionCheckManager", "localCheckFunctionSupport functionSetting: " + functionSetting);
				if(functionSetting != null && functionSetting.containsKey(type)){
					isSupported = functionSetting.get(type);
					Log.i("LCFunctionCheckManager", "localCheckFunctionSupport functionSetting setting type: " + type.ordinal() + "isSupported: " + isSupported);
				}
			}
		}
		Log.i("LCFunctionCheckManager", "localCheckFunctionSupport isSupported:" + isSupported);
		return isSupported;
	}
	
	private void GetFunctionSetting(final LiveChatTalkUserListItem info){
		mLCFunctionsManager.GetFunctionSetting(info.deviceType, info.clientVersion, new OnGetFunctionSettingCallback() {
			
			@Override
			public void OnGetFunctionSetting(boolean success,
					HashMap<FunctionType, Boolean> functionSetting) {
				NotifyFunctionCheckFinish(info.userId);
			}
		});
	}
	
	private void NotifyFunctionCheckFinish(String userId){
		Message msg = Message.obtain();
		msg.what = FUNCTION_CHECK_FINISH;
		msg.obj = userId;
		mHandler.sendMessage(msg);
	}
	
	/**
	 * 获取相关女士相关信息回调
	 * @param errType
	 * @param item
	 */
	public void onGetWomanInfo(LiveChatErrType errType, String userId, LiveChatTalkUserListItem item){
		boolean isSuccess = false;
		Message msg = Message.obtain();
		msg.what = GET_LADY_INFO_CALLBACK;
		if(errType == LiveChatErrType.Success && item != null){
			isSuccess = true;
		}else{
			if(item == null){
				item = new LiveChatTalkUserListItem();
			}
			item.userId = userId;
		}
		msg.arg1 = isSuccess?1:0;
		msg.obj = item;
		mHandler.sendMessage(msg);
	}

}
