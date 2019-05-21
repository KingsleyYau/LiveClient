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
    //播放时长
    public int playTime = 0;
    //大礼物动画类型
    public AdvanceGiftType giftAnimType=null;

    public enum AdvanceGiftType{
        AdvanceGift,//豪华大礼物 webp
        BarGift,//吧台礼物 静态图片 png
        CelebGift//庆祝礼物 webp

    }

    /**
     * 豪华礼物构造方法
     * @param srcWebLocalPath
     * @param sendNum
     */
    public AdvanceGiftItem(String srcWebLocalPath,int sendNum){
        this.srcWebLocalPath = srcWebLocalPath;
        this.sendNum = sendNum;
    }

    /**
     * 庆祝礼物构造方法
     * @param srcWebLocalPath
     * @param sendNum
     * @param advanceGiftType
     */
    public AdvanceGiftItem(String srcWebLocalPath,int sendNum, AdvanceGiftType advanceGiftType){
        this.srcWebLocalPath = srcWebLocalPath;
        this.sendNum = sendNum;
        this.giftAnimType = advanceGiftType;
    }

    /**
     * 吧台礼物构造方法
     * @param srcWebLocalPath
     * @param sendNum
     * @param advanceGiftType
     * @param playTime
     */
    public AdvanceGiftItem(String srcWebLocalPath,int sendNum, AdvanceGiftType advanceGiftType, int playTime){
        this.srcWebLocalPath = srcWebLocalPath;
        this.sendNum = sendNum;
        this.giftAnimType = advanceGiftType;
        this.playTime = playTime;
    }

}
