package com.qpidnetwork.anchor.liveshow.liveroom.gift.advance;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/18.
 */

public class BigGiftAnimItem {
    //礼物数量
    public int giftNum =0 ;
    //播放时长
    public int playTime = 0;
    //大礼物动画类型
    public BigGiftAnimType giftAnimType=null;

    /**
     * 大礼物文件路径
     */
    public String bigAnimFileLocalPath;

    public enum BigGiftAnimType{
        AdvanceGift,//豪华大礼物 webp
        BarGift,//吧台礼物 静态图片 png
        CelebGift//庆祝礼物 webp

    }

    /**
     * 豪华礼物构造方法
     * @param bigAnimFileLocalPath
     * @param giftNum
     */
    public BigGiftAnimItem(String bigAnimFileLocalPath, int giftNum){
        this.bigAnimFileLocalPath = bigAnimFileLocalPath;
        this.giftNum = giftNum;
        giftAnimType = BigGiftAnimType.AdvanceGift;
    }

    /**
     * 庆祝礼物构造方法
     * @param bigAnimFileLocalPath
     * @param giftNum
     * @param giftAnimType
     */
    public BigGiftAnimItem(String bigAnimFileLocalPath, int giftNum, BigGiftAnimType giftAnimType){
        this.bigAnimFileLocalPath = bigAnimFileLocalPath;
        this.giftNum = giftNum;
        this.giftAnimType = giftAnimType;
    }

    /**
     * 吧台礼物构造方法
     * @param bigAnimFileLocalPath
     * @param giftNum
     * @param giftAnimType
     */
    public BigGiftAnimItem(String bigAnimFileLocalPath, int giftNum, BigGiftAnimType giftAnimType, int playTime){
        this.bigAnimFileLocalPath = bigAnimFileLocalPath;
        this.giftNum = giftNum;
        this.giftAnimType = giftAnimType;
        this.playTime = playTime;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("BigGiftAnimItem[");
        sb.append("bigAnimFileLocalPath:");
        sb.append(bigAnimFileLocalPath);
        sb.append(" giftNum:");
        sb.append(giftNum);
        sb.append(" giftAnimType:");
        sb.append(giftAnimType);
        sb.append(" playTime:");
        sb.append(playTime);
        sb.append("]");
        return sb.toString();
    }
}
