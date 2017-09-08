package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.R;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/14.
 */

public class AudienceEndActivity extends BaseFragmentActivity {

    private ImageView iv_gaussianBlur;
    private CircleImageView civ_endAudienceHeader;
    private TextView tv_endAudienceHostNick;
    private TextView tv_endAudienceViewers;
    private TextView tv_endliveBroadcast;
    private Button btn_endLiveAudience;
    private View ll_endLiveAudience;
    private View ll_follow;
    private View v_followedTopBlank;
    private View ll_following;
    private View v_unfollowButtomBlank;
    private View v_followedButtomBlank;
    private int fansNum = 0;
    private boolean isFocusHost = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_end_audience);
        initData();
        initView();
    }

    private void initView(){
        iv_gaussianBlur = (ImageView) findViewById(R.id.iv_gaussianBlur);
        civ_endAudienceHeader = (CircleImageView) findViewById(R.id.civ_endAudienceHeader);
        tv_endAudienceHostNick = (TextView) findViewById(R.id.tv_endAudienceHostNick);
        tv_endAudienceViewers = (TextView) findViewById(R.id.tv_endAudienceViewers);
        tv_endAudienceViewers.setText(String.valueOf(fansNum));
        btn_endLiveAudience = (Button) findViewById(R.id.btn_endLiveAudience);
        ll_endLiveAudience = findViewById(R.id.ll_endLiveAudience);
        ll_endLiveAudience.setVisibility(View.VISIBLE);
        ll_follow = findViewById(R.id.ll_follow);
        v_followedTopBlank = findViewById(R.id.v_followedTopBlank);
        ll_following = findViewById(R.id.ll_following);
        v_unfollowButtomBlank = findViewById(R.id.v_unfollowButtomBlank);
        v_followedButtomBlank = findViewById(R.id.v_followedButtomBlank);

        //未关注
//        tv_endliveBroadcast.setVisibility(View.GONE);
        ll_follow.setVisibility(isFocusHost ? View.GONE : View.VISIBLE);
        v_followedTopBlank.setVisibility(isFocusHost ? View.VISIBLE : View.GONE);
        v_unfollowButtomBlank.setVisibility(isFocusHost ? View.GONE : View.VISIBLE);
        v_followedButtomBlank.setVisibility(isFocusHost ? View.VISIBLE : View.GONE);
        ll_following.setVisibility(View.GONE);

//        tv_endAudienceHostNick.setText(getInte);
    }

    private void initData(){
        Intent intent = getIntent();
        isFocusHost = intent.getBooleanExtra("isFocusHost",false);
        fansNum = intent.getIntExtra("fansNum",0);
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.btn_endLiveAudience) {
            Toast.makeText(this, "End Audience", Toast.LENGTH_SHORT).show();
            finish();

        } else if (i == R.id.iv_endLiveShareTwitter) {
            Toast.makeText(this, "twitter", Toast.LENGTH_SHORT).show();

        } else if (i == R.id.iv_endLiveShareFacebook) {
            Toast.makeText(this, "facebook", Toast.LENGTH_SHORT).show();

        } else if (i == R.id.iv_endLiveShareInstagram) {
            Toast.makeText(this, "instagram", Toast.LENGTH_SHORT).show();

        } else if (i == R.id.ll_follow) {
            Toast.makeText(this, "已经关注", Toast.LENGTH_SHORT).show();
            //关注中，动画
            ll_follow.setVisibility(View.GONE);
            ll_following.setVisibility(View.VISIBLE);
            handler.sendEmptyMessageDelayed(MSG_WHAT_ENDFOLLOWINGANIM, 5000l);

        }
        super.onClick(v);
    }

    private final int MSG_WHAT_ENDFOLLOWINGANIM = 1;

    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what){
                case MSG_WHAT_ENDFOLLOWINGANIM:
                    //关注后
                    v_followedTopBlank.setVisibility(View.VISIBLE);
                    v_followedButtomBlank.setVisibility(View.VISIBLE);
                    ll_following.setVisibility(View.GONE);
                    v_unfollowButtomBlank.setVisibility(View.GONE);
                    break;
                default:
                    super.handleMessage(msg);
                    break;
            }

        }
    };
}
