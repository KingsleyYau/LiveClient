package com.qpidnetwork.livemodule.livechat;

import android.util.Log;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem.DeviceType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJni;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.FunctionType;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCCheckFunctionsCallback;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 功能设置管理模块
 * @author Hunter
 * @since 2016.4.12
 */
public class LCFunctionsManager {
	/**
	 * 存放正在获取的类型列表，防止重复请求
	 */
	private HashMap<String, List<OnGetFunctionSettingCallback>> mProcessingMap;
	/**
	 * 存放当前FunctionList（key主要由版本及设备类型组成）
	 */
	private HashMap<String,HashMap<FunctionType, Boolean>> mFunctionListMap;
	
	public LCFunctionsManager(){
		mProcessingMap = new HashMap<String, List<OnGetFunctionSettingCallback>>();
		mFunctionListMap = new HashMap<String,HashMap<FunctionType, Boolean>>();
	}
	
	/**
	 * 检测指定版本指定设备的功能开启情况
	 * @param deviceType
	 * @param clientVersion
	 * @return
	 */
	public void GetFunctionSetting(final DeviceType deviceType, final String clientVersion, OnGetFunctionSettingCallback callback){
		final String identify = getIdentifyKey(deviceType, clientVersion);
		HashMap<FunctionType, Boolean> functionSetting = GetFunctionSetting(deviceType, clientVersion);
		if(functionSetting != null){
			//本地存在直接回调
			callback.OnGetFunctionSetting(true, functionSetting);
			return;
		}
		if(isProcessingAndAdd(identify, callback)){
			return;
		}
		
		long requestId = LCRequestJni.InvalidRequestId;
		//获取指定女士功能设置列表
		LoginItem loginItem = LoginManager.getInstance().getLoginItem();
		if(loginItem != null){
			requestId = LCRequestJniLiveChat.CheckFunctions(getCheckFunctionList(), deviceType,
					clientVersion, loginItem.sessionId, loginItem.userId, new OnLCCheckFunctionsCallback() {
				
				@Override
				public void OnLCCheckFunctions(boolean isSuccess, String errno,
						String errmsg, int[] flags) {
					boolean success = isSuccess;
					HashMap<FunctionType, Boolean> functionSetting = new HashMap<FunctionType, Boolean>();
					List<FunctionType> functionList = getCheckFunctionList();
					if(functionList.size() == flags.length){
						for(int i=0; i< functionList.size(); i++){
							Log.i("LCFunctionsManager", "Function type: " + functionList.get(i).ordinal() + " flag: " + flags[i]);
							functionSetting.put(functionList.get(i), flags[i]==0?false:true);
						}
						saveFunctionSetting(identify, functionSetting);
					}else{
						success = false;
					}
					List<OnGetFunctionSettingCallback> callbackList = removeFromChecking(identify);
					if(callbackList != null){
						for(OnGetFunctionSettingCallback item : callbackList){
							item.OnGetFunctionSetting(success, functionSetting);
						}
					}
				}
			});
		}
		if(requestId == LCRequestJni.InvalidRequestId){
			List<OnGetFunctionSettingCallback> callbackList = removeFromChecking(identify);
			for(OnGetFunctionSettingCallback item : callbackList){
				item.OnGetFunctionSetting(false, null);
			}
		}
	}
	
	/**
	 * 默认查询功能列表
	 * @return
	 */
	private List<FunctionType> getCheckFunctionList(){
		List<FunctionType> functionList = new ArrayList<FunctionType>();
		functionList.add(FunctionType.CHAT_TEXT);
		functionList.add(FunctionType.CHAT_EMOTION);
		functionList.add(FunctionType.CHAT_TRYTIKET);
		functionList.add(FunctionType.CHAT_VOICE);
		functionList.add(FunctionType.CHAT_MAGICICON);
		functionList.add(FunctionType.CHAT_PRIVATEPHOTO);
		functionList.add(FunctionType.CHAT_SHORTVIDEO);
		return functionList;
	}
	
	/**
	 * 添加到正在处理列表
	 * @param identify
	 */
	private boolean isProcessingAndAdd(String identify, OnGetFunctionSettingCallback callback){
		boolean isProcessing = false;
		synchronized (mProcessingMap){
			if(mProcessingMap.containsKey(identify)){
				isProcessing = true;
				mProcessingMap.get(identify).add(callback);
			}else{
				List<OnGetFunctionSettingCallback> callbackList = new ArrayList<OnGetFunctionSettingCallback>();
				callbackList.add(callback);
				mProcessingMap.put(identify, callbackList);
			}
		}
		return isProcessing;
	}
	
	/**
	 * 本地缓存功能配置
	 * @param identify
	 * @param functionSetting
	 */
	private void saveFunctionSetting(String identify, HashMap<FunctionType, Boolean> functionSetting){
		synchronized (mFunctionListMap){
			mFunctionListMap.put(identify, functionSetting);
		}
	}
 	
	/**
	 * 获取本地缓存中功能配置列表
	 * @param deviceType
	 * @param clientVersion
	 * @return
	 */
	public HashMap<FunctionType, Boolean> GetFunctionSetting(DeviceType deviceType, String clientVersion){
		HashMap<FunctionType, Boolean> functionSetting = null;
		synchronized (mFunctionListMap) {
			String identify = getIdentifyKey(deviceType, clientVersion);
			if(mFunctionListMap.containsKey(identify)){
				functionSetting = mFunctionListMap.get(identify);
			}
		}
		return functionSetting;
	}
	
	/**
	 * 清除正在处理标志
	 * @param identify
	 */
	private List<OnGetFunctionSettingCallback> removeFromChecking(String identify){
		List<OnGetFunctionSettingCallback> callbackList;
		Log.i("LCFunctionsManager", "identify : " + identify + " mapContain: " + mProcessingMap.containsKey(identify));
		synchronized (mProcessingMap){
			callbackList = mProcessingMap.remove(identify);
		}
		return callbackList;
	}
	
	/**
	 * 获取唯一key(用于存储制定版本，指定设备的功能配置列表)
	 * @return
	 */
	private String getIdentifyKey(DeviceType deviceType, String clientVersion){
		String identifyKey = "";
		identifyKey += "FunctionSetting" + deviceType.ordinal();
		identifyKey += clientVersion;
		return identifyKey;
	}
	
	public interface OnGetFunctionSettingCallback{
		public void OnGetFunctionSetting(boolean success, HashMap<FunctionType, Boolean> functionSetting);
	}
}
