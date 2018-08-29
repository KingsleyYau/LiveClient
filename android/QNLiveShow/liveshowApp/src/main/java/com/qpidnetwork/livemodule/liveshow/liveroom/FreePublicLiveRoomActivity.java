package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.os.Bundle;
import android.os.Message;
import android.view.View;

import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.online.AudienceHeadItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.ArrayList;
import java.util.List;


/**
 * 免费公开直播间
 * Created by Hunter Mun on 2017/6/15.
 */

public class FreePublicLiveRoomActivity extends BaseCommonLiveRoomActivity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        TAG = PayPublicLiveRoomActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        initFreePublicRoomViews();
    }

    @Override
    public void initData() {
        super.initData();
        updatePublicRoomOnlineData(mIMRoomInItem.fansNum);
    }

    private void initFreePublicRoomViews(){
        ll_publicRoomHeader.setVisibility(View.VISIBLE);
        ll_freePublic.setVisibility(View.VISIBLE);
        include_audience_area.setVisibility(View.VISIBLE);
        ll_buttom_audience.setVisibility(View.VISIBLE);
        showFreePublicRoomButtomImGBg();
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
                    //edit by Jagger 2018-5-4
                    mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(audienceInfoItem.userId,
                            audienceInfoItem.nickName,audienceInfoItem.photoUrl,audienceInfoItem.isHasTicket));
                }
            }
        }
    }
}
