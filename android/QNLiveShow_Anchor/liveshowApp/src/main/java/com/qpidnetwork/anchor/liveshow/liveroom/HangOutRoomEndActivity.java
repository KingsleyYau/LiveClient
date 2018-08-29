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
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

/**
 * HangOut直播间结束页面
 * @author Harry
 */
public class HangOutRoomEndActivity extends BaseActionBarFragmentActivity {

    private static final String TRANSITION_USER_PHOTOURL = "manPhotoUrl";
    private static final String TRANSITION_DESCRIPTION = "describtion";
    private static final String TRANSITION_USER_NICKNAME = "manNickname";

    //变量
    private String mUserPhotoUrl = "";
    private String mUserNickname = "";
    private String mDesc = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = HangOutRoomEndActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_hangout_room_end);
        //不需要导航栏
        setTitleVisible(View.GONE);
        initData();
        initView();
    }

    private void initView() {
        CircleImageView civ_photo = (CircleImageView)findViewById(R.id.civ_photo);
        TextView tv_manNickname = (TextView)findViewById(R.id.tv_manNickname);
        TextView tv_desc = (TextView)findViewById(R.id.tv_desc);
        ImageView btn_close = (ImageView)findViewById(R.id.btn_close);
        btn_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        if(!TextUtils.isEmpty(mUserPhotoUrl)) {
            Picasso.with(getApplicationContext()).load(mUserPhotoUrl)
                    .placeholder(R.drawable.ic_default_photo_man)
                    .error(R.drawable.ic_default_photo_man)
                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                    .into(civ_photo);
        }

        if(!TextUtils.isEmpty(mUserNickname)) {
            tv_manNickname.setText(mUserNickname);
        }

        if(!TextUtils.isEmpty(mDesc)) {
            tv_desc.setText(mDesc);
        }
    }

    /**
     * 主播邀请用户进入直播间
     * @param context
     * @param userPhotoUrl
     * @param userNickname
     * @param description
     * @return
     */
    public static void show(Context context, String userPhotoUrl, String userNickname, String description){
        Intent intent = new Intent(context, HangOutRoomEndActivity.class);
        intent.putExtra(TRANSITION_USER_PHOTOURL, userPhotoUrl);
        intent.putExtra(TRANSITION_USER_NICKNAME, userNickname);
        intent.putExtra(TRANSITION_DESCRIPTION, description);
        context.startActivity(intent);
    }

    public void initData() {
        Bundle bundle = getIntent().getExtras();

        if (bundle != null) {
            if (bundle.containsKey(TRANSITION_USER_PHOTOURL)) {
                mUserPhotoUrl = bundle.getString(TRANSITION_USER_PHOTOURL);
                Log.d(TAG,"initData-mUserPhotoUrl:"+mUserPhotoUrl);
            }
            if (bundle.containsKey(TRANSITION_DESCRIPTION)) {
                mDesc = bundle.getString(TRANSITION_DESCRIPTION);
                Log.d(TAG,"initData-mDesc:"+ mDesc);
            }
            if (bundle.containsKey(TRANSITION_USER_NICKNAME)) {
                mUserNickname = bundle.getString(TRANSITION_USER_NICKNAME);
                Log.d(TAG,"initData-mUserNickname:"+mUserNickname);
            }
        }
    }
}
