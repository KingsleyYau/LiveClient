package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;

import java.util.ArrayList;
import java.util.List;

public class AutoChargeManager {
	public static final long AUTO_RECHARGE_OVERTIME = 2 * 60 * 1000;
	/**
	 * 记录当前系统自动充值状态
	 */
	private boolean isAutoCharging = false;
	/**
	 * 自动买点开关（0：无权限，大于0：每次买点的数量）
	 */
	private int rechargeCredit = 0; 
	/**
	 * 待处理消息列表（发送或者nomoney回调）
	 */
	private List<String> mPendingSendList;
	/**
	 * 待购买主题列表
	 */
	private List<PayingThemeItem> mPendingThemeList;
	/**
	 * 单例
	 */
	private static AutoChargeManager mAutoChargeManage;
	
	public AutoChargeManager(){
		mPendingSendList = new ArrayList<String>();
		mPendingThemeList = new ArrayList<PayingThemeItem>();
	}
	
	public static AutoChargeManager getInstatnce(){
		if(mAutoChargeManage == null){
			mAutoChargeManage = new AutoChargeManager();
		}
		return mAutoChargeManage;
	}
	
	public void addToPendingList(String userId){
		synchronized (mPendingSendList) {
			mPendingSendList.add(userId);
		}
	}
	
	public List<String> getPendingList(){
		List<String> temp = new ArrayList<String>();
		synchronized (mPendingSendList) {
			for(String item : mPendingSendList){
				temp.add(item);
			}
			mPendingSendList.clear();
		}
		return temp;
	}
	
	public void addToPendingThemeList(PayingThemeItem themeItem){
		synchronized (mPendingThemeList) {
			boolean isContain = false;
			for(PayingThemeItem item : mPendingThemeList){
				if(item.womanId.equals(themeItem.womanId)
						&&(item.themeId.equals(themeItem.themeId))){
					isContain = true;
					break;
				}
			}
			if(!isContain){
				mPendingThemeList.add(themeItem);
			}
		}
	}
	
	public List<PayingThemeItem> getPendingThemeList(){
		List<PayingThemeItem> temp = new ArrayList<PayingThemeItem>();
		synchronized (mPendingThemeList) {
			for(PayingThemeItem item : mPendingThemeList){
				temp.add(item);
			}
			mPendingThemeList.clear();
		}
		return temp;
	}
	
	/**
	 * livechat登录成功上传自动充值标志
	 */
	public void uploadAutoChargeFlags(){
		if(rechargeCredit > 0){
			LiveChatClient.UploadAutoChargeStatus(true);
		}else{
			LiveChatClient.UploadAutoChargeStatus(false);
		}
	}
	
	
	/**
	 * 注销时销毁
	 */
	public void onDestroy() {
		isAutoCharging = false;
		rechargeCredit = 0;
		mPendingSendList.clear();
		mPendingThemeList.clear();
	}

	public boolean isAutoCharging() {
		return isAutoCharging;
	}

	public void setAutoCharging(boolean isAutoCharging) {
		this.isAutoCharging = isAutoCharging;
	}

	public int getRechargeCredit() {
		return rechargeCredit;
	}

	public void setRechargeCredit(int rechargeCredit) {
		this.rechargeCredit = rechargeCredit;
	}
}
