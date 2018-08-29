package com.qpidnetwork.anchor.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.view.ButtonRaised;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

/**
 * 直播结束
 * @author Jagger
 */
public class LiveRoomEndActivity extends BaseActionBarFragmentActivity {

    private static final String TRANSITION_USER_PHOTOURL = "anchorPhotoUrl";
    private static final String TRANSITION_DESCRIPTION = "describtion";

    //控件
    private CircleImageView civPhoto;
    private TextView tvAnchorName;
    private ImageView mBtnClose;

    //变量
    private String mUserPhotoUrl = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = LiveRoomEndActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_liveroom_end);

        civPhoto = (CircleImageView)findViewById(R.id.civPhoto);
        tvAnchorName = (TextView)findViewById(R.id.tvAnchorName);
        mBtnClose = (ImageView)findViewById(R.id.btn_close);
        mBtnClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        //不需要导航栏
        setTitleVisible(View.GONE);
        initData();

        if(!TextUtils.isEmpty(mUserPhotoUrl)) {
            Picasso.with(getApplicationContext()).load(mUserPhotoUrl)
                    .placeholder(R.drawable.ic_default_photo_man)
                    .error(R.drawable.ic_default_photo_man)
                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                    .into(civPhoto);
        }
    }

    /**
     * 主播邀请用户进入直播间
     * @param context
     * @param userPhotoUrl
     * @return
     */
    public static void show(Context context, String userPhotoUrl, String description){
        Intent intent = new Intent(context, LiveRoomEndActivity.class);
        intent.putExtra(TRANSITION_USER_PHOTOURL, userPhotoUrl);
        intent.putExtra(TRANSITION_DESCRIPTION, description);
        context.startActivity(intent);
    }

    public void initData() {
        Bundle bundle = getIntent().getExtras();
        String description = "";
        if (bundle != null) {
            if (bundle.containsKey(TRANSITION_USER_PHOTOURL)) {
                mUserPhotoUrl = bundle.getString(TRANSITION_USER_PHOTOURL);
                Log.d(TAG,"initData-mUserPhotoUrl:"+mUserPhotoUrl);
            }
            if (bundle.containsKey(TRANSITION_DESCRIPTION)) {
                description = bundle.getString(TRANSITION_DESCRIPTION);
                Log.d(TAG,"initData-description:"+description);
            }
        }
        if(!TextUtils.isEmpty(description)) {
            tvAnchorName.setText(description);
        }
    }
}
