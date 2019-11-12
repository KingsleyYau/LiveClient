package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Say Hi详情的Response列表Item
 *
 * @author Alex
 */
public class SayHiDetailResponseListItem {

    public SayHiDetailResponseListItem() {

    }

    /**
     * Say Hi详情的Response列表Item
     *
     * @param responseId    回复ID
     * @param responseTime  回复时间戳
     * @param simpleContent 回复内容的摘要
     * @param content       回复内容(当免费或已付费才有值)
     * @param isFree        是否免费（1：是，0：否）
     * @param hasRead       是否已读
     * @param hasImg        是否有图片
     * @param imgUrl        图片地址
     */
    public SayHiDetailResponseListItem(
            String responseId,
            int responseTime,
            String simpleContent,
            String content,
            boolean isFree,
            boolean hasRead,
            boolean hasImg,
            String imgUrl) {
        this.responseId = responseId;
        this.responseTime = responseTime;
        this.simpleContent = simpleContent;
        this.content = content;
        this.isFree = isFree;
        this.hasRead = hasRead;
        this.hasImg = hasImg;
        this.imgUrl = imgUrl;
    }

    public String responseId;
    public int responseTime;
    public String simpleContent;
    public String content;
    public boolean isFree;
    public boolean hasRead;
    public boolean hasImg;
    public String imgUrl;

    public void update(SayHiDetailResponseListItem newItem){

        this.responseId = newItem.responseId;
        this.responseTime = newItem.responseTime;
        this.content = newItem.content;
        this.isFree = newItem.isFree;
        this.hasRead = newItem.hasRead;
        this.hasImg = newItem.hasImg;
        this.imgUrl = newItem.imgUrl;
    }


    @Override
    public String toString() {
        return "SayHiDatailResponseListItem[responseId:" + responseId
                + " responseTime:" + responseTime
                + " anchosimpleContentrId:" + simpleContent
                + " content:" + content
                + " isFree:" + isFree
                + " hasRead:" + hasRead
                + " hasImg:" + hasImg
                + " imgUrl:" + imgUrl
                + "]";
    }
}
