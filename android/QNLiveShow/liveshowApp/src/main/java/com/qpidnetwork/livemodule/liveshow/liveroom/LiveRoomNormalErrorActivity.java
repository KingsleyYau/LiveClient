package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.AbstractDraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.postprocessors.IterativeBoxBlurPostProcessor;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetPromoAnchorListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.bean.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.Log;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ROOMPHOTOURL;

/**
 * Created by Hunter on 17/10/7.
 */

public class LiveRoomNormalErrorActivity extends BaseFragmentActivity{

    private static final String ANCHOR_ID = "anchorId";
    private static final String ANCHOR_NICKNAME = "anchorName";
    private static final String ANCHOR_PHOTOURL = "anchorPhotoUrl";
    private static final String LIVEROOM_PAGE_TYPE = "pageType";
    private static final String LIVEROOM_PAGE_ERROR_MSG = "errMsg";
    private static final String LIVEROOM_PAGE_SHOW_RECOMMAND = "recommandFlag";

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
    private LinearLayout llRecommand2;
    private CircleImageView civRecommand2;
    private TextView tvRecommandName2;

    //高斯模糊背景
    private SimpleDraweeView iv_gaussianBlur;
    private View v_gaussianBlurFloat;

    //data
    private String mAnchorId;
    private String mAnchorName;

    public static Intent getIntent(Context context, PageErrorType type, String errMsg, String anchorId
            , String anchorName, String anchorPhotoUrl, String roomPhotoUrl, boolean isShowRecommand){
        Intent intent = new Intent(context, LiveRoomNormalErrorActivity.class);
        intent.putExtra(LIVEROOM_PAGE_TYPE, type.ordinal());
        intent.putExtra(LIVEROOM_PAGE_ERROR_MSG, errMsg);
        intent.putExtra(ANCHOR_ID, anchorId);
        intent.putExtra(ANCHOR_NICKNAME, anchorName);
        intent.putExtra(ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, roomPhotoUrl);
        intent.putExtra(LIVEROOM_PAGE_SHOW_RECOMMAND, isShowRecommand?1:0);
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
        civRecommand1.setOnClickListener(this);
        tvRecommandName1 = (TextView)findViewById(R.id.tvRecommandName1);
        tvRecommandName1.setOnClickListener(this);

        llRecommand2 = (LinearLayout)findViewById(R.id.llRecommand2);
        civRecommand2 = (CircleImageView)findViewById(R.id.civRecommand2);
        civRecommand2.setOnClickListener(this);
        tvRecommandName2 = (TextView)findViewById(R.id.tvRecommandName2);
        tvRecommandName2.setOnClickListener(this);

        btnClose.setOnClickListener(this);
        btnAddCredit.setOnClickListener(this);
        btnBook.setOnClickListener(this);
        btnViewHot.setOnClickListener(this);
        civRecommand1.setOnClickListener(this);
        civRecommand2.setOnClickListener(this);

        //高斯模糊背景
        iv_gaussianBlur = (SimpleDraweeView) findViewById(R.id.iv_gaussianBlur);
        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
        v_gaussianBlurFloat.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#cc000000")));
    }

    private void initData(){
        String anchorPhotoUrl = "";
        PageErrorType errType = null;
        String roomPhotoUrl = null;
        String errorMsg = "";
        boolean isRecommand = false;

        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(LIVEROOM_PAGE_TYPE)){
                errType = PageErrorType.values()[bundle.getInt(LIVEROOM_PAGE_TYPE)];
            }
            if(bundle.containsKey(LIVEROOM_PAGE_ERROR_MSG)){
                errorMsg = bundle.getString(LIVEROOM_PAGE_ERROR_MSG);
            }
            if(bundle.containsKey(ANCHOR_ID)){
                mAnchorId = bundle.getString(ANCHOR_ID);
            }
            if(bundle.containsKey(ANCHOR_NICKNAME)){
                mAnchorName = bundle.getString(ANCHOR_NICKNAME);
            }
            if(bundle.containsKey(ANCHOR_PHOTOURL)){
                anchorPhotoUrl = bundle.getString(ANCHOR_PHOTOURL);
            }
            if(bundle.containsKey(LIVEROOM_ROOMINFO_ROOMPHOTOURL)){
                roomPhotoUrl = bundle.getString(LIVEROOM_ROOMINFO_ROOMPHOTOURL);
            }
            if(bundle.containsKey(LIVEROOM_PAGE_SHOW_RECOMMAND)){
                isRecommand = bundle.getInt(LIVEROOM_PAGE_SHOW_RECOMMAND)==1?true:false;
            }
        }
        if(!TextUtils.isEmpty(anchorPhotoUrl)) {
            Picasso.with(getApplicationContext()).load(anchorPhotoUrl)
                    .placeholder(R.drawable.ic_default_photo_woman)
                    .error(R.drawable.ic_default_photo_woman)
                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                    .into(civPhoto);
        }

        if(!TextUtils.isEmpty(roomPhotoUrl)) {
            try {
                Uri uri = Uri.parse(roomPhotoUrl);
                ImageRequest request = ImageRequestBuilder.newBuilderWithSource(uri)
                        .setPostprocessor(new IterativeBoxBlurPostProcessor(
                                getResources().getInteger(R.integer.gaussian_blur_iterations),
                                getResources().getInteger(R.integer.gaussian_blur_tran)))
                        .build();
                AbstractDraweeController controller = Fresco.newDraweeControllerBuilder()
                        .setOldController(iv_gaussianBlur.getController())
                        .setImageRequest(request)
                        .build();
                iv_gaussianBlur.setController(controller);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        tvAnchorName.setText(mAnchorName);
        switch (errType){
            case PAGE_ERROR_LIEV_EDN:{
                if(TextUtils.isEmpty(errorMsg)) {
                    tvDesc.setText(getResources().getString(R.string.liveroom_transition_broadcast_ended));
                }else{
                    tvDesc.setText(errorMsg);
                }
                btnBook.setVisibility(View.VISIBLE);
                //获取推荐列表
                if(isRecommand) {
                    getPromoAnchorList();
                }
            }break;

            case PAGE_ERROR_BACKGROUD_OVERTIME:{
                tvDesc.setText(getResources().getString(R.string.liveroom_live_backgroud_too_long_finish));
                btnViewHot.setVisibility(View.VISIBLE);
            }break;

            case PAGE_ERROR_NOMONEY:{
                tvDesc.setText(getResources().getString(R.string.liveroom_noenough_money_tips_watch_end));
                btnAddCredit.setVisibility(View.VISIBLE);
            }break;
        }
        Log.d(TAG,"initData-mAnchorId:"+mAnchorId+" anchorName:"+mAnchorName
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
            startActivity(BookPrivateActivity.getIntent(mContext, mAnchorId, mAnchorName));
            finish();
        } else if (i == R.id.btnAddCredit) {
            LiveService.getInstance().onAddCreditClick(new NoMoneyParamsBean());
            finish();
        } else if (i == R.id.btnViewHot) {
            Intent intent = new Intent(this, MainFragmentActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            finish();
        } else if (i == R.id.civRecommand1 || i == R.id.civRecommand2|| i == R.id.tvRecommandName1|| i == R.id.tvRecommandName2) {
            String anchorId = (String) v.getTag();
            if (!TextUtils.isEmpty(anchorId)) {
                AnchorProfileActivity.launchAnchorInfoActivty(this,
                        getResources().getString(R.string.live_webview_anchor_profile_title),
                        anchorId,
                        false,
                        AnchorProfileActivity.TagType.Album);
            }
            //GA统计点击推荐
            onAnalyticsEvent(getResources().getString(R.string.Live_BroadcastEnd_Category),
                    getResources().getString(R.string.Live_BroadcastEnd_Action_Recommend),
                    getResources().getString(R.string.Live_BroadcastEnd_Label_Recommend));

            //点击推荐，关闭界面
            finish();
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
                                    civRecommand1.setImageResource(R.drawable.ic_default_photo_woman);
                                    civRecommand2.setImageResource(R.drawable.ic_default_photo_woman);
                                    if(!TextUtils.isEmpty(anchorList[0].photoUrl)){
                                        Picasso.with(getApplicationContext())
                                                .load(anchorList[0].photoUrl)
                                                .placeholder(R.drawable.ic_default_photo_woman)
                                                .error(R.drawable.ic_default_photo_woman)
                                                .memoryPolicy(MemoryPolicy.NO_CACHE)
                                                .into(civRecommand1);
                                    }
                                    civRecommand1.setTag(anchorList[0].userId);
                                    tvRecommandName1.setTag(anchorList[0].userId);
                                    tvRecommandName1.setText(anchorList[0].nickName);

                                    if(anchorList.length >= 2){
                                        civRecommand2.setTag(anchorList[1].userId);
                                        tvRecommandName2.setTag(anchorList[1].userId);
                                        llRecommand2.setVisibility(View.VISIBLE);
                                        if(!TextUtils.isEmpty(anchorList[1].photoUrl)){
                                            Picasso.with(getApplicationContext())
                                                    .load(anchorList[1].photoUrl)
                                                    .placeholder(R.drawable.ic_default_photo_woman)
                                                    .error(R.drawable.ic_default_photo_woman)
                                                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                                                    .into(civRecommand2);
                                        }
                                        tvRecommandName2.setText(anchorList[1].nickName);
                                    }else{
                                        llRecommand2.setVisibility(View.GONE);
                                    }
                                    llRecommand.setVisibility(View.VISIBLE);
                                }
                            });
                        }
                    }
                });
    }
}
