package com.qpidnetwork.livemodule.livechathttprequest.item;

/**
 * 附录枚举
 * @author Max.Chiu
 */
public class LCRequestEnum {
    /**
     * 聊天邀请风控类型
     */
    public enum LivechatInviteRiskType{
    	UNLIMITED,
    	SEND_LIMITED,
    	RECV_LIMITED,
    	SEND_RECV_LIMITED
    }
}
