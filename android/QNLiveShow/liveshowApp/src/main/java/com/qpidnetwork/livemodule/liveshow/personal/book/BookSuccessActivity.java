package com.qpidnetwork.livemodule.liveshow.personal.book;

import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.view.ButtonRaised;

/**
 * 预约成功界面
 * Created by Jagger on 2017/9/30.
 */
public class BookSuccessActivity extends BaseActionBarFragmentActivity {

    public static String KEY_BROADCASTER_NAME = "KEY_BROADCASTER_NAME";
    public static String KEY_BOOK_TIME = "KEY_BOOK_TIME";
    public static String KEY_GIFT_URL = "KEY_GIFT_URL";
    public static String KEY_GIFT_SUM = "KEY_GIFT_SUM";

    //变量
    private String mBroadcasterName = "", mBookTime = "" , mGiftUrl = "" ;
    private int mGiftSum = 0;
    private boolean isSomeGift = false;

    //控件
    private TextView mTvBroadcast, mTvBookTime , mTvGiftSum;
    private SimpleDraweeView mImgGift;
    private ConstraintLayout mClGift;
    private ButtonRaised mBtnOK , mBtnMyReserations;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_live_book_success);

        //设置头
        setTitle(getString(R.string.live_book_title), Color.GRAY);

        //
        initIntent();

        //
        initUI();
    }

    private void initIntent(){
        Bundle bundle = getIntent().getExtras();
        if( bundle != null) {
            if(bundle.containsKey(KEY_BROADCASTER_NAME)){
                mBroadcasterName =  bundle.getString(KEY_BROADCASTER_NAME);
            }

            if(bundle.containsKey(KEY_BOOK_TIME)){
                mBookTime =  bundle.getString(KEY_BOOK_TIME);
            }

            if(bundle.containsKey(KEY_GIFT_URL)){
                mGiftUrl = bundle.getString(KEY_GIFT_URL);
            }

            if(bundle.containsKey(KEY_GIFT_SUM)){
                mGiftSum = bundle.getInt(KEY_GIFT_SUM , 0);
                if(mGiftSum > 0 ){
                    isSomeGift = true;
                }
            }

        }
    }

    private void initUI(){
        mTvBroadcast = (TextView)findViewById(R.id.tv_broadcaster_name);
        mTvBroadcast.setText(mBroadcasterName);

        mTvBookTime = (TextView)findViewById(R.id.tv_book_time);
        mTvBookTime.setText(mBookTime);

        mClGift = (ConstraintLayout) findViewById(R.id.cl_gift);
        if(isSomeGift){
            mClGift.setVisibility(View.VISIBLE);
        }else {
            mClGift.setVisibility(View.GONE);
        }

        mTvGiftSum = (TextView)findViewById(R.id.tv_gift_num);
        mTvGiftSum.setText(getString(R.string.live_book_giftsumx , String.valueOf(mGiftSum)));

        mImgGift = (SimpleDraweeView)findViewById(R.id.img_gift);
        if(!TextUtils.isEmpty(mGiftUrl)){
            mImgGift.setImageURI(Uri.parse(mGiftUrl));
        }

        mBtnOK = (ButtonRaised)findViewById(R.id.btn_ok);
        mBtnOK.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mBtnMyReserations = (ButtonRaised)findViewById(R.id.btn_myreservations);
        mBtnMyReserations.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
    }
}
