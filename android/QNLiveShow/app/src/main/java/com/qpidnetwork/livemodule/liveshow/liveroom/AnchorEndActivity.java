package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/14.
 */

public class AnchorEndActivity extends BaseFragmentActivity {

    private ImageView iv_gaussianBlur;
    private TextView tv_fans_value;
    private TextView tv_shares_value;
    private TextView tv_diamonds_value;
    private TextView tv_viewers_value;
    private TextView tv_liveTime;
    private Button btn_endliveBroadcast;
    private View ll_endLiveAudience;


    private int diamonds = 0;
    private int viewers = 0;
    private int newFans = 0;
    private int shares = 0;
    private long liveTimes = 0l;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_end_broadcast);
        initView();
        initData();
    }

    private void initView(){
        iv_gaussianBlur = (ImageView) findViewById(R.id.iv_gaussianBlur);

        tv_fans_value = (TextView) findViewById(R.id.tv_fans_value);
        tv_shares_value = (TextView) findViewById(R.id.tv_shares_value);
        tv_diamonds_value = (TextView) findViewById(R.id.tv_diamonds_value);
        tv_viewers_value = (TextView) findViewById(R.id.tv_viewers_value);
        tv_liveTime = (TextView) findViewById(R.id.tv_liveTime);

        btn_endliveBroadcast = (Button) findViewById(R.id.btn_endliveBroadcast);
        ll_endLiveAudience = findViewById(R.id.ll_endLiveAudience);

        btn_endliveBroadcast.setVisibility(View.VISIBLE);
        ll_endLiveAudience.setVisibility(View.GONE);
    }

    private void initData(){
        Intent intent = getIntent();
        diamonds = intent.getIntExtra("diamonds",0);
        viewers = intent.getIntExtra("viewers",0);
        newFans = intent.getIntExtra("newFans",0);
        shares = intent.getIntExtra("shares",0);
        liveTimes = intent.getLongExtra("liveTimes",0l);

        tv_fans_value.setText(String.valueOf(newFans));
        tv_shares_value.setText(String.valueOf(shares));
        tv_diamonds_value.setText(String.valueOf(diamonds));
        tv_viewers_value.setText(String.valueOf(viewers));

        SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss");
        format.format(new Date(liveTimes));
        String liveTimeStr = format.format(new Date(liveTimes)).toString();
        tv_liveTime.setText(liveTimeStr);
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.btn_endliveBroadcast) {
            Toast.makeText(this, "End broadcast", Toast.LENGTH_SHORT).show();
            finish();

        } else if (i == R.id.iv_endLiveShareTwitter) {
            Toast.makeText(this, "twitter", Toast.LENGTH_SHORT).show();

        } else if (i == R.id.iv_endLiveShareFacebook) {
            Toast.makeText(this, "facebook", Toast.LENGTH_SHORT).show();

        } else if (i == R.id.iv_endLiveShareInstagram) {
            Toast.makeText(this, "instagram", Toast.LENGTH_SHORT).show();

        }
        super.onClick(v);
    }
}
