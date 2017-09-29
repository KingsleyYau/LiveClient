package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;

/**
 * Description:直播结束页面
 * <p>
 * Created by Harry on 2017/9/19.
 */

public class EndLiveActivity extends BaseFragmentActivity {

    private static final String ENDLIVE_PARAMS_HOSTPHOTOURL ="hostPhotoUrl";
    private static final String ENDLIVE_PARAMS_LIVEROOMHOTOURL ="roomPhotoUrl";
    private static final String ENDLIVE_PARAMS_HOSTNICKNAME="hostNickName";
    private static final String ENDLIVE_PARAMS_HOSTID="hostId";
    private static final String ENDLIVE_PARAMS_ROOMTYPE="roomType";
    private static final String ENDLIVE_PARAMS_ISENDBYLEAVETOOLONG = "isEndByLeaveTooLong";

    public static Intent getEndLiveIntent(Context context, String hostPhotoUrl, String hostId, String hostNickName,
                                          IMRoomInItem.IMLiveRoomType roomType, String roomPhotoUrl, boolean isEndByLeaveTooLong){
        Intent intent = new Intent(context,EndLiveActivity.class);
        intent.putExtra(ENDLIVE_PARAMS_HOSTPHOTOURL,hostPhotoUrl);
        intent.putExtra(ENDLIVE_PARAMS_HOSTID,hostId);
        intent.putExtra(ENDLIVE_PARAMS_HOSTNICKNAME,hostNickName);
        intent.putExtra(ENDLIVE_PARAMS_ROOMTYPE,roomType);
        intent.putExtra(ENDLIVE_PARAMS_LIVEROOMHOTOURL,roomPhotoUrl);
        intent.putExtra(ENDLIVE_PARAMS_ISENDBYLEAVETOOLONG,isEndByLeaveTooLong);
        return intent;
    }

    @Override
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_endlive_audience);
        findViewById(R.id.ll_closeEndLive).setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.ll_closeEndLive:
                finish();
                break;
        }
    }
}
