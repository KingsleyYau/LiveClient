package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.os.Bundle;
import android.os.Message;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.online.AudienceHeadItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
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
        ll_freePublic.setVisibility(View.VISIBLE);
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
                    Log.d(TAG,"EVENT_MESSAGE_UPDATE_ONLINEFANS-audienceList.length:"+audienceList.length);
                    List<AudienceHeadItem> audienceHeadItems = new ArrayList<AudienceHeadItem>();
                    int maxAudienceNum = 6;
                    if(mIMRoomInItem != null && mIMRoomInItem.audienceLimitNum > 0){
                        maxAudienceNum = mIMRoomInItem.audienceLimitNum;
                    }
                    for(int index = 0;index < maxAudienceNum;index++){
                        if(index<audienceList.length){
                            //edit by Jagger 2018-5-3 加上是否已购票的属性
                            AudienceHeadItem audienceHeadItem = new AudienceHeadItem(audienceList[index].photoUrl,
                                    AudienceHeadItem.DEFAULT_ID_AUDIENCEHEAD);
                            audienceHeadItem.setHasTicket(audienceList[index].isHasTicket);
                            audienceHeadItems.add(audienceHeadItem);
                        }else{
                            Log.d(TAG,"EVENT_MESSAGE_UPDATE_ONLINEFANS-defaultPhotoUrl:我是"
                                    +(index-audienceList.length+1)+"号群众演员");
                            //edit by Jagger 2018-5-3 加上是否已购票的属性
                            AudienceHeadItem audienceHeadItem = new AudienceHeadItem(null,
                                    AudienceHeadItem.DEFAULT_ID_PLACEHOLDER);
                            audienceHeadItem.setHasTicket(false);
                            audienceHeadItems.add(audienceHeadItem);
                        }
                    }
                    //2018年2月8日 14:35:54目前直播间改版为只有付费公开，观众头像列表使用原来免费公开直播间的控件ID，
                    //以最小化样式修改，后续如果公开直播间改为免费和付费且样式有比较大的出入，那么需要重新改xml布局并改resId
                    cihsv_onlineFreePublic.setList(audienceHeadItems);
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
                            audienceInfoItem.nickName,audienceInfoItem.photoUrl,audienceInfoItem.isHasTicket));
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
                new IMSysNoticeMessageContent(getResources().getString(R.string.system_notice_recv_rebate,
                        ApplicationSettingUtil.formatCoinValue(rebateGranted)),
                        null, IMSysNoticeMessageContent.SysNoticeType.Normal));
        Log.d(TAG,"addRebateGrantedMsg-msg:"+imMessageItem.sysNoticeContent.message+" link:"+imMessageItem.sysNoticeContent.link);
        sendMessageUpdateEvent(imMessageItem);
    }
}
