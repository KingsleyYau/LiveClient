package com.qpidnetwork.livemodule.liveshow.liveroom.gift.advance;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/18.
 */

public class AdvanceGiftItem {

    /**
     * 大礼物文件url
     */
    public String srcWebLocalPath;
    public int sendNum =0 ;

    public AdvanceGiftItem(String srcWebLocalPath,int sendNum){
        this.srcWebLocalPath = srcWebLocalPath;
        this.sendNum = sendNum;
    }



}
