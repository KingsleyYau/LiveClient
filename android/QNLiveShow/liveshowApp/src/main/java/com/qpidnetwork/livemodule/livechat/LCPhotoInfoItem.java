package com.qpidnetwork.livemodule.livechat;

import java.io.Serializable;

public class LCPhotoInfoItem implements Serializable {

    private static final long serialVersionUID = 8498488393432473717L;

    /**
     * 指定类型图片请求状态
     */
    public enum StatusType{
        Default,
        Downloading,
        Failed,
        Success
    }

    public LCPhotoInfoItem(){
        statusType = StatusType.Default;
        errmsg = "";
        errno = "";
        photoPath = "";
    }

    public LCPhotoInfoItem(StatusType statusType,
                        String errno,
                        String errmsg,
                        String photoPath){
        this.statusType = statusType;
        this.errno = errno;
        this.errmsg = errmsg;
        this.photoPath = photoPath;
    }


    public StatusType statusType;
    public String errno;
    public String errmsg;
    public String photoPath;
}
