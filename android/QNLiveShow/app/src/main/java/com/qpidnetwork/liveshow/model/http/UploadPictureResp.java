package com.qpidnetwork.liveshow.model.http;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/19.
 */

public class UploadPictureResp {
    public boolean isSuccess;
    public int errCode;
    public String errMsg;
    public String photoId;
    public String photoUrl;

    public UploadPictureResp(boolean isSuccess, int errCode, String errMsg, String photoId, String photoUrl){
        this.isSuccess = isSuccess;
        this.errCode = errCode;
        this.errMsg = errMsg;
        this.photoId = photoId;
        this.photoUrl = photoUrl;
    }
}
