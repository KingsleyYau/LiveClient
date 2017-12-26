package com.qpidnetwork.livemodule.liveshow.share;

import android.graphics.Bitmap;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/19.
 */

public class ShareContentInfo {
    /**链接*/
    public String contentUrl;
    /**话题标签*/
    public String hashTag;
    /**引文*/
    public String quote;
    /**分享图片,照片大小必须小雨12M*/
    public Bitmap bitmap;
    /**视频链接*/
    public String vedioUrl;

    public ShareContentType shareContentType;

    public enum ShareContentType{
        Link,           //链接分享
        Img,            //图文分享
        Vedio,          //视频分享
        Media           //多媒体分享，即可以分享多种类型多个资源
    }

}
