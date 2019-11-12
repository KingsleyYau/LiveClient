package com.qpidnetwork.livemodule.httprequest.item;

public class EmotionItem {

    public enum EmotionActionTag {
        Unknown,
        Static,             // 静态表情
        DYNAMIC                // 动画表情
    }

    public EmotionItem() {

    }

    /**
     * 表情Item
     *
     * @param emoSign
     * @param emoUrl
     */
    public EmotionItem(String emotionId,
                       String emoSign,
                       String emoUrl,
                       int emoType,
                       String emoIconUrl) {
        this.emotionId = emotionId;
        this.emoSign = emoSign;
        this.emoUrl = emoUrl;
        if (emoType < 0 || emoType >= EmotionActionTag.values().length) {
            this.emoType = EmotionActionTag.Unknown;
        } else {
            this.emoType = EmotionActionTag.values()[emoType + 1];
        }
        this.emoIconUrl = emoIconUrl;
    }

    public String emotionId;
    public String emoSign;
    public String emoUrl;
    public EmotionActionTag emoType;
    public String emoIconUrl;


    //************************  自定义字段   ***********************************
    /*
        2019/9/5 Hardy
        高级表情是否可点击发送?
        判断条件：根据男士亲密度 >= 3
        否则，全部 emoji item 变灰
     */
    public boolean isEmoJiAdvancedCanClick;
}
