package com.qpidnetwork.livemodule.liveshow.personal.chatemoji;

/**
 * Description:表情
 * <p>
 * Created by Harry on 2017/8/2.
 */

public class ChatEmoji {
    /**
     * 表情对应的正则表达式规则0
     */
    public String regular = "";
    /**
     * 表情对应的远程Url
     */
    public String url = null;
    /**
     * 表情对应的Id
     */
    public int id = 0;
    /**
     * 表情对应的资源ID
     */
    public int resId = 0;
    /**
     * 表情对应的本地文件路径
     */
    public String localFilePath = null;

    /**
     * 表情对应的类型
     */
    public String type ;
    /**
     * 表情描述/表情名称
     */
    public String desc = "";

    public ChatEmoji(){}

    public ChatEmoji(String regular, String desc, String url, int id, int resId, String type){
        this.regular = regular;
        this.url = url;
        this.id = id;
        this.resId = resId;
        this.type = type;
        this.desc = desc;
    }

    @Override
    public String toString() {
        return "ChatEmoji[id:"+id+" regular:"+ regular +"]";
    }
}
