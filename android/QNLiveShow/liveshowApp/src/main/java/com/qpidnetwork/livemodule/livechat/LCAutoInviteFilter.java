package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatLadyCondition;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem.ChildrenType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem.MarryType;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;

public class LCAutoInviteFilter {
	/**
	 * 是否初始化成功
	 */
	private boolean isInit = false;
	/**
	 * 过滤邀请时间间隔（防止短时间内邀请过多负荷过重）
	 */
	private final long mFilterTimeInterval;
	/**
	 * 上一次处理邀请的时间
	 */
	private long mPreHandleTime;
	/**
	 * Livechat 管理器
	 */
	private LiveChatManager mLiveChatManager;
	/**
	 * 系统邀请(单人列表最多同时仅存一个)
	 */
	private HashMap<String, LCAutoInviteItem> mSystemInviteMap;
	/**
	 * 记录男士择偶条件等信息
	 */
	private LiveChatTalkUserListItem mUserItem;
	/**
	 * 随机数生成器
	 */
	private Random mRandom;
	
	public LCAutoInviteFilter(LiveChatManager livechatManager){
		this.mLiveChatManager = livechatManager;
		//处理时间间隔
		mFilterTimeInterval = 1 * 1000;
		//上次处理时间
		mPreHandleTime = 0;
		//存放待处理自动邀请
		mSystemInviteMap = new HashMap<String, LCAutoInviteItem>();
		// 随机数生成器
		mRandom = new Random();
	}
	
	/**
	 * 过滤系统邀请，并异步生成LCMessage
	 * @param womanId
	 * @param manId
	 * @param key
	 */
	public void filterAutoInvite(String womanId, String manId, String key){
		if(isInit){
			if(mPreHandleTime == 0
					|| mPreHandleTime + mFilterTimeInterval <= System.currentTimeMillis()){
				boolean isContain = false;
				LCAutoInviteItem item  = new LCAutoInviteItem(womanId, manId, key);
				synchronized (mSystemInviteMap) {
					if(!mSystemInviteMap.containsKey(womanId)){
						mSystemInviteMap.put(womanId, item);
					}else{
						isContain = true;
					}
				}
				if(!isContain){
					mPreHandleTime = System.currentTimeMillis();
					//新邀请，查询女士女士设置匹配条件
					if(!LiveChatClient.GetLadyCondition(womanId)){
						//获取女士匹配条件失败，删除当前邀请
						clearAutoInviteById(womanId);
					}
				}
			}
		}
	}
	
	/**
	 * 获取女士匹配条件回掉
	 * @param errType
	 * @param errmsg
	 * @param womanId
	 * @param condition
	 */
	public void OnGetLadyCondition(LiveChatErrType errType, String errmsg, String womanId , LiveChatLadyCondition condition){
		if(errType == LiveChatErrType.Success){
			if(checkConditionMap(condition)){
				//条件满足，获取女士模板列表
				if(!LiveChatClient.GetLadyCustomTemplate(womanId)){
					//获取女士模板失败
					clearAutoInviteById(womanId);
				}
			}else{
				//条件不匹配直接抛掉
				clearAutoInviteById(womanId);
			}
		}else{
			//获取女士匹配条件失败，删除当前邀请
			clearAutoInviteById(womanId);
		}
	}
	
	/**
	 * 获取女士自定义模板回掉
	 * @param errType
	 * @param errmsg
	 * @param womanId
	 * @param contents
	 * @param flags
	 */
	public void OnGetLadyCustomTemplate(LiveChatErrType errType, String errmsg,
                                        String womanId, String[] contents, boolean[] flags){
		LCAutoInviteItem item = clearAutoInviteById(womanId);
		List<String> tempList = getValidCustomTemplateList(contents, flags);
		if(tempList.size() > 0){
			int position = mRandom.nextInt(tempList.size());
			createSystemInviteMessage(item, tempList.get(position));
		}
	}
	
	/**
	 * 用户择偶条件更新（过滤前提是获取男士择偶条件）
	 * @param userItem
	 */
	public void onGetUserInfoUpdate(LiveChatTalkUserListItem userItem){
		if(userItem != null){
			mUserItem = userItem;
			isInit = true;
		}
	}
	
	/**
	 * 清除指定女士的自动邀请
	 * @param womanId
	 */
	private LCAutoInviteItem clearAutoInviteById(String womanId){
		LCAutoInviteItem item = null;
		synchronized (mSystemInviteMap){
			if(mSystemInviteMap.containsKey(womanId)){
				item = mSystemInviteMap.remove(womanId);
			}
		}
		return item;
	}
	
	/**
	 * 过滤获取女士可用自定义模板列表
	 * @param contents
	 * @param flags
	 * @return
	 */
	private List<String> getValidCustomTemplateList(String[] contents, boolean[] flags){
		List<String> templateList = new ArrayList<String>();
		if(contents != null && flags != null && contents.length == flags.length){
			for(int i=0; i < contents.length; i++){
				if(flags[i]){
					templateList.add(contents[i]);
				}
			}
		}
		return templateList;
	}
	
	/**
	 * 验证通过生成系统邀请信息
	 * @param inviteItem
	 * @param message
	 */
	private void createSystemInviteMessage(LCAutoInviteItem inviteItem, String message){
		if(inviteItem != null){
			mLiveChatManager.onAutoInviteFilterCallback(inviteItem, message);
		}
	}
	
	/**
	 * 检测男士是否满足女士条件
	 * @param condition
	 * @return
	 */
	private boolean checkConditionMap(LiveChatLadyCondition condition){
		boolean isMap = false;
		if((condition != null)&&(isInit)){
			//婚姻情况判定
			if(condition.marriageCondition){
				isMap = checkMarryCondition(condition);
			}else{
				isMap = true;
			}
			if(isMap){
				//判断子女状况
				if(condition.childCondition){
					if((condition.noChild && mUserItem.childrenType == ChildrenType.NoChildren) ||
							(!condition.noChild && mUserItem.childrenType == ChildrenType.Yes)){
						isMap = true;
					}else{
						isMap = false;
					}
				}else{
					isMap = true;
				}
			}
			
			if(isMap){
				//判断国籍
				if(condition.countryCondition){
					isMap = checkCountryCondition(condition);
				}else{
					isMap = true;
				}
			}
			
			if(isMap){
				//判断年龄
				if(mUserItem.age >= condition.startAge && mUserItem.age <= condition.endAge){
					isMap = true;
				}else{
					isMap = false;
				}
			}
		}
		return isMap;
	}
	
	/**
	 * 判断婚姻状况是否符合
	 * @param condition
	 * @return
	 */
	private boolean checkMarryCondition(LiveChatLadyCondition condition){
		if(condition.neverMarried && mUserItem.marryType == MarryType.NeverMarried){
			return true;
		}
		
		if(condition.divorced && mUserItem.marryType == MarryType.Disvorced){
			return true;
		}
		
		if(condition.widowed && mUserItem.marryType == MarryType.Widowed){
			return true;
		}
		
		if(condition.separated && mUserItem.marryType == MarryType.Separated){
			return true;
		}
	
		if(condition.married && mUserItem.marryType == MarryType.Married){
			return true;
		}
		
		return false;
	}
	
	/**
	 * 判断国籍是否符合设置
	 * @param condition
	 * @return
	 */
	private boolean checkCountryCondition(LiveChatLadyCondition condition){
		if(condition.unitedstates && (mUserItem.country.equals("United States") 
				|| mUserItem.country.equals("US"))){
			return true;
		}
		if(condition.canada && (mUserItem.country.equals("Canada") 
				|| mUserItem.country.equals("CA"))){
			return true;
		}
		if(condition.newzealand && (mUserItem.country.equals("New Zealand") 
				|| mUserItem.country.equals("NZ"))){
			return true;
		}
		if(condition.australia && (mUserItem.country.equals("Australia") 
				|| mUserItem.country.equals("AU"))){
			return true;
		}
		if(condition.unitedkingdom && (mUserItem.country.equals("United Kingdom") 
				|| mUserItem.country.equals("GB"))){
			return true;
		}
		
		if(condition.germany && (mUserItem.country.equals("Germany") 
				|| mUserItem.country.equals("DE"))){
			return true;
		}
		
		if(condition.othercountries){
			if((!mUserItem.country.equals("United States") && !mUserItem.country.equals("US"))
					&& (!mUserItem.country.equals("Canada") && !mUserItem.country.equals("CA")) 
					&& (!mUserItem.country.equals("New Zealand") && !mUserItem.country.equals("NZ"))
					&& (!mUserItem.country.equals("Australia") && !mUserItem.country.equals("AU")) 
					&& (!mUserItem.country.equals("United Kingdom") && !mUserItem.country.equals("GB"))
					&& (!mUserItem.country.equals("Germany") && !mUserItem.country.equals("DE"))){
				return true;
			}
		}
		return false;
	}

}
