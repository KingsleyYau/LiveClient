package com.qpidnetwork.liveshow.model.http;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/1.
 */

public class CreateRoomRsp {

    public CreateRoomRsp(boolean isSuccess,int errCode,String errMsg,String roomId,String roomStreamUrl){
        this.isSuccess = isSuccess;
        this.errCode = errCode;
        this.errMsg = errMsg;
        this.roomId = roomId;
        this.roomStreamUrl = roomStreamUrl;
    }

    public boolean isSuccess;
    public int errCode;
    public String errMsg;
    public String roomId;
    public String roomStreamUrl;


}
