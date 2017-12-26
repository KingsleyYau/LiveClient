package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.os.Bundle;
import android.os.Message;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.ArrayList;
import java.util.List;


/**
 * 付费公开直播间
 * Created by Harry Wei on 2017/6/15.
 */

public class PayPublicLiveRoomActivity extends BaseCommonLiveRoomActivity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        TAG = PayPublicLiveRoomActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        initPayPublicRoomViews();
    }

    @Override
    public void initData() {
        super.initData();
        updatePublicRoomOnlineData(mIMRoomInItem.fansNum);
    }

    private void initPayPublicRoomViews(){
        ll_publicRoomHeader.setVisibility(View.VISIBLE);
        rl_vipPublic.setVisibility(View.VISIBLE);
        include_audience_area.setVisibility(View.VISIBLE);
        ll_buttom_audience.setVisibility(View.VISIBLE);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch(msg.what){
            case EVENT_UPDATE_ONLINEFANSNUM:
                updatePublicRoomOnlineData(mRoomAudienceNum);
                break;
            case EVENT_MESSAGE_UPDATE_ONLINEFANS:{
                HttpRespObject httpRespObject= (HttpRespObject) msg.obj;
                if(httpRespObject.isSuccess){
                    AudienceInfoItem[] audienceList = (AudienceInfoItem[])httpRespObject.data;
                    List<String> photoUrls = new ArrayList<>();
                    for(AudienceInfoItem item : audienceList){
                        photoUrls.add(item.photoUrl);
                    }
                    cihsv_onlineVIPPublic.setList(photoUrls);
                }
            }break;
        }
    }

    @Override
    protected void onRoomAudienceChangeUpdate() {
        super.onRoomAudienceChangeUpdate();
        Message msg = Message.obtain();
        msg.what = EVENT_UPDATE_ONLINEFANSNUM;
        sendUiMessage(msg);
    }

    @Override
    public void onGetAudienceList(boolean isSuccess, int errCode, String errMsg, AudienceInfoItem[] audienceList) {
        super.onGetAudienceList(isSuccess,errCode,errMsg,audienceList);
        if(isSuccess && null != audienceList){
            HttpRespObject imRespObject = new HttpRespObject(isSuccess,errCode,errMsg,audienceList);
            Message msg = Message.obtain();
            msg.what = EVENT_MESSAGE_UPDATE_ONLINEFANS;
            msg.obj = imRespObject;
            sendUiMessage(msg);
            if(null != mIMManager){
                for(AudienceInfoItem audienceInfoItem : audienceList){
                    mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(audienceInfoItem.userId,
                            audienceInfoItem.nickName,audienceInfoItem.photoUrl));
                }
            }
        }
    }

    @Override
    protected void addRebateGrantedMsg(double rebateGranted) {
        super.addRebateGrantedMsg(rebateGranted);
        //添加消息列表
        IMMessageItem imMessageItem = new IMMessageItem(mIMRoomInItem.roomId,
                mIMManager.mMsgIdIndex.getAndIncrement(),"",
                IMMessageItem.MessageType.SysNotice,
                new IMSysNoticeMessageContent(getResources().getString(R.string.system_notice_recv_rebate,String.format ("%.2f", rebateGranted)),
                        null, IMSysNoticeMessageContent.SysNoticeType.Normal));
        Log.d(TAG,"addRebateGrantedMsg-msg:"+imMessageItem.sysNoticeContent.message+" link:"+imMessageItem.sysNoticeContent.link);
        sendMessageUpdateEvent(imMessageItem);
    }
}
