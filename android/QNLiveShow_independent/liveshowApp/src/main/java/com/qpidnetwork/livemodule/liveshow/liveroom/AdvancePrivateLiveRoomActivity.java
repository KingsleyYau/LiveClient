package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;


/**
 * 豪华私密直播间
 * Created by Harry Wei on 2017/6/15.
 */

public class AdvancePrivateLiveRoomActivity extends BaseCommonLiveRoomActivity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        TAG = AdvancePrivateLiveRoomActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        initAdvancePrivateRoomView();
    }

    private void initAdvancePrivateRoomView(){
        ll_privateRoomHeader.setVisibility(View.VISIBLE);
        include_audience_area.setVisibility(View.VISIBLE);
        ll_buttom_audience.setVisibility(View.VISIBLE);
    }

    @Override
    public void initData() {
        super.initData();
        //互动模块初始化
        initPublishData();
        //查询头像列表
        LiveRequestOperator.getInstance().GetAudienceListInRoom(mIMRoomInItem.roomId,0,0,this);
    }

    @Override
    protected void addRebateGrantedMsg(double rebateGranted) {
        super.addRebateGrantedMsg(rebateGranted);
        //添加消息列表
        IMMessageItem imMessageItem = new IMMessageItem(mIMRoomInItem.roomId,
                mIMManager.mMsgIdIndex.getAndIncrement(),"",
                IMMessageItem.MessageType.SysNotice,
                new IMSysNoticeMessageContent(getResources().getString(R.string.system_notice_recv_rebate,
                        ApplicationSettingUtil.formatCoinValue(rebateGranted)),
                        null, IMSysNoticeMessageContent.SysNoticeType.Normal));
        Log.d(TAG,"addRebateGrantedMsg-msg:"+imMessageItem.sysNoticeContent.message+" link:"+imMessageItem.sysNoticeContent.link);
        sendMessageUpdateEvent(imMessageItem);
    }

    @Override
    public void OnRecvSendSystemNotice(final IMMessageItem msgItem) {
        if(!isCurrentRoom(msgItem.roomId)){
            return;
        }
        super.OnRecvSendSystemNotice(msgItem);
        if(null != msgItem && null != msgItem.sysNoticeContent
                && msgItem.sysNoticeContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Warning){
            if(!TextUtils.isEmpty(msgItem.sysNoticeContent.message)){
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        showWarningDialog(msgItem.sysNoticeContent.message);
                    }
                });
            }
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch(msg.what){
            case EVENT_MESSAGE_UPDATE_ONLINEFANS:{
                HttpRespObject httpRespObject= (HttpRespObject) msg.obj;
                if(httpRespObject.isSuccess){
                    AudienceInfoItem[] audienceList = (AudienceInfoItem[])httpRespObject.data;
                    if(null != audienceList && audienceList.length==1){
                        AudienceInfoItem myAudienceInfoItem = audienceList[0];
                        Log.d(TAG,"EVENT_MESSAGE_UPDATE_ONLINEFANS-myAudienceInfoItem:"+myAudienceInfoItem);
                        Picasso.with(getApplicationContext())
                                .load(myAudienceInfoItem.photoUrl)
                                .error(R.drawable.ic_default_photo_man)
                                .placeholder(R.drawable.ic_default_photo_man)
                                .memoryPolicy(MemoryPolicy.NO_CACHE)
                                .into(civ_prvUserIcon);
                    }

                }
            }break;
        }
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
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
