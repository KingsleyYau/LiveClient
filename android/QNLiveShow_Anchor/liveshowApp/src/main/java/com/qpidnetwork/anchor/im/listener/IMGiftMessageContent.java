package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

/**
 * 礼物消息内容封装
 * Created by Hunter Mun on 2017/6/15.
 */

public class IMGiftMessageContent implements Serializable{

    public IMGiftMessageContent(){

    }

    public IMGiftMessageContent(String giftId,
                                String giftName,
                                int giftNum,
                                boolean multi_click,
                                int multi_click_start,
                                int multi_click_end,
                                int multi_click_id){
        this.giftId = giftId;
        this.giftName = giftName;
        this.giftNum = giftNum;
        this.multi_click = multi_click;
        this.multi_click_start = multi_click_start;
        this.multi_click_end = multi_click_end;
        this.multi_click_id = multi_click_id;
        this.isSecretly = false;
    }

    public IMGiftMessageContent(String giftId,
                                String giftName,
                                int giftNum,
                                boolean multi_click,
                                int multi_click_start,
                                int multi_click_end,
                                int multi_click_id,
                                boolean isSecretly){
        this.giftId = giftId;
        this.giftName = giftName;
        this.giftNum = giftNum;
        this.multi_click = multi_click;
        this.multi_click_start = multi_click_start;
        this.multi_click_end = multi_click_end;
        this.multi_click_id = multi_click_id;
        this.isSecretly = isSecretly;
    }

    public String giftId;         //礼物Id
    public String giftName;       //礼物名字
    public int giftNum;          //发送礼物数目
    public boolean multi_click;     //是否连击
    public int multi_click_start;   //连击开始数
    public int multi_click_end;     //连接结束数
    public int multi_click_id;      //连击Id,用于区分是否同一个连击
    public boolean isSecretly;      //是否私密发送
}
