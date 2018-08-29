package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.Log;


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
    protected void onDestroy() {
        super.onDestroy();
    }
}
