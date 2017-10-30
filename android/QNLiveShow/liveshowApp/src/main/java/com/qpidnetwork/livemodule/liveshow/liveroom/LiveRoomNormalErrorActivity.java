package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetPromoAnchorListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.Log;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ROOMPHOTOURL;

/**
 * Created by Hunter on 17/10/7.
 */

public class LiveRoomNormalErrorActivity extends BaseFragmentActivity{

    private static final String ANCHOR_ID = "anchorId";
    private static final String ANCHOR_NICKNAME = "anchorName";
    private static final String ANCHOR_PHOTOURL = "anchorPhotoUrl";
    private static final String LIVEROOM_PAGE_TYPE = "pageType";

    //view
    private ImageView btnClose;
    private CircleImageView civPhoto;
    private TextView tvAnchorName;
    private TextView tvDesc;

    private Button btnBook;
    private Button btnViewHot;
    private Button btnAddCredit;

    private LinearLayout llRecommand;
    private CircleImageView civRecommand1;
    private TextView tvRecommandName1;
    private CircleImageView civRecommand2;
    private TextView tvRecommandName2;

    //高斯模糊背景
    private ImageView iv_gaussianBlur;
    private View v_gaussianBlurFloat;

    //data
    private String mAnchorId;

    public static Intent getIntent(Context context, PageErrorType type, String anchorId
            , String anchorName, String anchorPhotoUrl, String roomPhotoUrl){
        Intent intent = new Intent(context, LiveRoomNormalErrorActivity.class);
        intent.putExtra(LIVEROOM_PAGE_TYPE, type.ordinal());
        intent.putExtra(ANCHOR_ID, anchorId);
        intent.putExtra(ANCHOR_NICKNAME, anchorName);
        intent.putExtra(ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, roomPhotoUrl);
        return intent;
    }

    /**
     * 直播错误页面类型
     */
    public enum PageErrorType{
        PAGE_ERROR_LIEV_EDN,
        PAGE_ERROR_NOMONEY,
        PAGE_ERROR_BACKGROUD_OVERTIME
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        TAG = LiveRoomNormalErrorActivity.class.getSimpleName();
        setContentView(R.layout.activity_liveroom_error_page);
        initViews();
        initData();
    }

    private void initViews(){
        btnClose = (ImageView)findViewById(R.id.btnClose);
        civPhoto = (CircleImageView)findViewById(R.id.civPhoto);
        tvAnchorName = (TextView)findViewById(R.id.tvAnchorName);
        tvDesc = (TextView)findViewById(R.id.tvDesc);

        btnBook = (Button)findViewById(R.id.btnBook);
        btnViewHot = (Button)findViewById(R.id.btnViewHot);
        btnAddCredit = (Button)findViewById(R.id.btnAddCredit);

        llRecommand = (LinearLayout)findViewById(R.id.llRecommand);
        civRecommand1 = (CircleImageView)findViewById(R.id.civRecommand1);
        tvRecommandName1 = (TextView)findViewById(R.id.tvRecommandName1);
        civRecommand2 = (CircleImageView)findViewById(R.id.civRecommand2);
        tvRecommandName2 = (TextView)findViewById(R.id.tvRecommandName2);

        btnClose.setOnClickListener(this);
        btnAddCredit.setOnClickListener(this);
        btnBook.setOnClickListener(this);
        btnViewHot.setOnClickListener(this);
        civRecommand1.setOnClickListener(this);
        civRecommand2.setOnClickListener(this);

        //高斯模糊背景
        iv_gaussianBlur = (ImageView) findViewById(R.id.iv_gaussianBlur);
        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
        v_gaussianBlurFloat.setVisibility(View.GONE);
        v_gaussianBlurFloat.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#de000000")));
    }

    private void initData(){
        String anchorName = "";
        String anchorPhotoUrl = "";
        PageErrorType errType = null;
        String roomPhotoUrl = null;

        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(LIVEROOM_PAGE_TYPE)){
                errType = PageErrorType.values()[bundle.getInt(LIVEROOM_PAGE_TYPE)];
            }
            if(bundle.containsKey(ANCHOR_ID)){
                mAnchorId = bundle.getString(ANCHOR_ID);
            }
            if(bundle.containsKey(ANCHOR_NICKNAME)){
                anchorName = bundle.getString(ANCHOR_NICKNAME);
            }
            if(bundle.containsKey(ANCHOR_PHOTOURL)){
                anchorPhotoUrl = bundle.getString(ANCHOR_PHOTOURL);
            }
            if(bundle.containsKey(LIVEROOM_ROOMINFO_ROOMPHOTOURL)){
                roomPhotoUrl = bundle.getString(LIVEROOM_ROOMINFO_ROOMPHOTOURL);
            }
        }
        if(!TextUtils.isEmpty(anchorPhotoUrl)) {
            Picasso.with(getApplicationContext()).load(anchorPhotoUrl)
                    .placeholder(R.drawable.ic_default_photo_woman)
                    .error(R.drawable.ic_default_photo_woman)
                    .into(civPhoto);
        }

        if(!TextUtils.isEmpty(roomPhotoUrl)) {
            Picasso.with(getApplicationContext()).load(roomPhotoUrl)
                    .into(new Target() {
                        @Override
                        public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom loadedFrom) {
                            Log.d(TAG,"onBitmapLoaded");
                            iv_gaussianBlur.setImageBitmap(bitmap);
                            v_gaussianBlurFloat.setVisibility(View.VISIBLE);
                        }

                        @Override
                        public void onBitmapFailed(Drawable drawable) {
                            Log.d(TAG,"onBitmapFailed");
                            iv_gaussianBlur.setImageDrawable(getResources().getDrawable(R.drawable.bg_liveroom_transition));
                        }

                        @Override
                        public void onPrepareLoad(Drawable drawable) {
                            Log.d(TAG,"onPrepareLoad");
                            iv_gaussianBlur.setImageDrawable(getResources().getDrawable(R.drawable.bg_liveroom_transition));
                        }
                    });
        }
        tvAnchorName.setText(anchorName);
        switch (errType){
            case PAGE_ERROR_LIEV_EDN:{
                tvDesc.setText(getResources().getString(R.string.liveroom_transition_broadcast_ended));
                btnBook.setVisibility(View.VISIBLE);
                //获取推荐列表
                getPromoAnchorList();
            }break;

            case PAGE_ERROR_BACKGROUD_OVERTIME:{
                tvDesc.setText(getResources().getString(R.string.liveroom_live_backgroud_too_long_finish));
                btnViewHot.setVisibility(View.VISIBLE);
            }break;

            case PAGE_ERROR_NOMONEY:{
                tvDesc.setText(getResources().getString(R.string.liveroom_live_no_enough_money));
                btnAddCredit.setVisibility(View.VISIBLE);
            }break;
        }
        Log.d(TAG,"initData-mAnchorId:"+mAnchorId+" anchorName:"+anchorName
                +" anchorPhotoUrl:"+anchorPhotoUrl+" roomPhotoUrl:"+roomPhotoUrl
                +" errType:"+errType.toString());
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.btnClose) {
            finish();
        } else if (i == R.id.btnBook) {
            startActivity(new Intent(mContext, BookPrivateActivity.class));
            finish();
        } else if (i == R.id.btnAddCredit) {
            startActivity(WebViewActivity.getIntent(this, "Add Credit", "http://www.baidu.com"));
        } else if (i == R.id.btnViewHot) {
            Intent intent = new Intent(this, MainFragmentActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            finish();
        } else if (i == R.id.civRecommand1 || i == R.id.civRecommand2) {
            String anchorId = (String) v.getTag();
            if (!TextUtils.isEmpty(anchorId)) {

            }
        }
    }

    /**
     * 获取推荐列表
     */
    private void getPromoAnchorList(){
        Log.d(TAG,"getPromoAnchorList");
        LiveRequestOperator.getInstance().GetPromoAnchorList(2,
                RequestJniLiveShow.PromotionCategoryType.LiveRoom, mAnchorId,
                new OnGetPromoAnchorListCallback() {
                    @Override
                    public void onGetPromoAnchorList(boolean isSuccess, int errCode, String errMsg,
                                                     final HotListItem[] anchorList) {
                        if( isSuccess && anchorList != null && anchorList.length > 0) {
                            //显示推荐模块
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    if(!TextUtils.isEmpty(anchorList[0].photoUrl)){
                                        Picasso.with(getApplicationContext()).load(anchorList[0].photoUrl)
                                                .placeholder(R.drawable.ic_default_photo_woman)
                                                .error(R.drawable.ic_default_photo_woman)
                                                .into(civRecommand1);
                                    }
                                    civRecommand1.setTag(anchorList[0].userId);
                                    tvRecommandName1.setText(anchorList[0].nickName);

                                    if(anchorList.length >= 2){
                                        civRecommand2.setTag(anchorList[1].userId);
                                        civRecommand2.setVisibility(View.VISIBLE);
                                        tvRecommandName2.setVisibility(View.VISIBLE);
                                        if(!TextUtils.isEmpty(anchorList[1].photoUrl)){
                                            Picasso.with(getApplicationContext()).load(anchorList[1].photoUrl)
                                                    .placeholder(R.drawable.ic_default_photo_woman)
                                                    .error(R.drawable.ic_default_photo_woman)
                                                    .into(civRecommand2);
                                        }
                                        tvRecommandName2.setText(anchorList[1].nickName);
                                    }
                                    llRecommand.setVisibility(View.VISIBLE);
                                }
                            });
                        }
                    }
                });
    }
}
