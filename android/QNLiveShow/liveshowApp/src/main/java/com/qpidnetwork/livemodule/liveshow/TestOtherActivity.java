package com.qpidnetwork.livemodule.liveshow;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.AdvancePrivateLiveRoomActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.NormalPrivateLiveRoomActivity;
import com.qpidnetwork.livemodule.view.ProgressButton;

import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ITEM;

public class TestOtherActivity extends Activity implements View.OnClickListener{

    private ProgressButton btnStartProcess;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_test);
        initView();
    }

    private void initView(){
        findViewById(R.id.tv_normalprv).setOnClickListener(this);
        findViewById(R.id.tv_advanceprv).setOnClickListener(this);
        btnStartProcess = (ProgressButton)findViewById(R.id.btnStartProcess);
        btnStartProcess.toggle();
        btnStartProcess.setProgress(50);
    }

    public void onClick(View v) {
        int index = 2;
        Intent intent = null;
        int viewResId = v.getId();
        if(viewResId == R.id.tv_normalprv) {
            index = 2;
            intent = new Intent(this, NormalPrivateLiveRoomActivity.class);
        }else if(viewResId == R.id.tv_advanceprv){
                index = 4;
                intent = new Intent(this,AdvancePrivateLiveRoomActivity.class);
        }
        IMRoomInItem imRoomInItem = new IMRoomInItem("CMTS09983","nickName",null,null,"100692",
                index,0.12f,false,1024,null,5,null,false,0,true,null,6,5.0f,6.0f,8, "", "");
        intent.putExtra(LIVEROOM_ROOMINFO_ITEM, imRoomInItem);
        startActivity(intent);
    }
}
