package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.os.Bundle;
import android.os.Message;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.TestDataUtil;

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
        TestDataUtil.testOnLineHeader(this,cihsv_onlineVIPPublic);
    }

    private void initFreePublicRoomViews(){
        ll_publicRoomHeader.setVisibility(View.VISIBLE);
        rl_freePublic.setVisibility(View.VISIBLE);
        include_audience_area.setVisibility(View.VISIBLE);
        ll_buttom_audience.setVisibility(View.VISIBLE);
        if(mIMRoomInItem != null && mIMRoomInItem.videoUrls!=null
                && mIMRoomInItem.videoUrls.length > 0){
            initLPlayer(mIMRoomInItem.videoUrls[0], "", "", "");
        }
        resetRoomViewParams();
        showFreePublicRoomButtomImGBg();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        uninitLPlayer();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.iv_inputMsg:
                ll_buttom_audience.setVisibility(View.GONE);
                break;
            case R.id.iv_gift_public:
                showLiveGiftDialog();
                break;
            default:
                break;
        }
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
                    if(mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
                        cihsv_onlineFreePublic.setList(photoUrls);
                    }
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
        }
    }

    @Override
    public void onSoftKeyboardHide() {
        if(!isEmojiOpera){
            ll_buttom_audience.setVisibility(View.VISIBLE);
        }
        super.onSoftKeyboardHide();
    }
}
