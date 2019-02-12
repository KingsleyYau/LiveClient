package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TryTicketEventType;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;

/**
 * LiveChat管理回调接口类
 * @author Samson Fan
 *
 */
public interface LiveChatManagerTryTicketListener {
	// ---------------- 试聊券相关回调函数(Try Ticket) ----------------
	/**
	 * 使用试聊券回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param eventType	试聊券使用情况
	 */
	public void OnUseTryTicket(
            LiveChatErrType errType
            , String errno
            , String errmsg
            , String userId
            , TryTicketEventType eventType);
	
	/**
	 * 接收试聊开始消息回调
	 * @param userItem	用户item
	 * @param time		试聊时长
	 */
	public void OnRecvTryTalkBegin(LCUserItem userItem, int time);
	
	/**
	 * 接收试聊结束消息回调
	 * @param userItem	用户item户
	 */
	public void OnRecvTryTalkEnd(LCUserItem userItem);
	
	/**
	 * 查询是否能使用试聊券回调
	 * @param errno		错误代码
	 * @param errmsg	错误描述
	 * @param item		查询结果
	 */
	public void OnCheckCoupon(boolean success, String errno, String errmsg, Coupon item);
	
	// ---------------- 对话状态改变或对话操作回调函数(try ticket) ----------------
	/**
	 * 结束对话回调
	 * @param errType	错误类型
	 * @param errmsg	错误描述
	 * @param userItem	对方Item
	 */
	public void OnEndTalk(LiveChatErrType errType, String errmsg, LCUserItem userItem);
	
	/**
	 * 接收聊天事件消息回调
	 * @param item		用户item
	 */
	public void OnRecvTalkEvent(LCUserItem item);
}
