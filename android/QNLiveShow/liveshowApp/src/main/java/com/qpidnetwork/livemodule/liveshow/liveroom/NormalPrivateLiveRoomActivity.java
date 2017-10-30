package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.os.Bundle;
import android.view.View;


/**
 * 普通私密直播间
 * Created by Harry Wei on 2017/6/15.
 */

public class NormalPrivateLiveRoomActivity extends BaseCommonLiveRoomActivity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        TAG = NormalPrivateLiveRoomActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        initNormalPrivateRoomView();
    }

    private void initNormalPrivateRoomView(){
        ll_privateRoomHeader.setVisibility(View.VISIBLE);
        include_audience_area.setVisibility(View.VISIBLE);
        ll_buttom_audience.setVisibility(View.VISIBLE);
    }

    @Override
    public void initData() {
        super.initData();
        //权限 add by Jagger 2017-10-25
        checkPermission();
        //互动模块初始化
        initPublishData();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        uninitLPlayer();
    }
}
