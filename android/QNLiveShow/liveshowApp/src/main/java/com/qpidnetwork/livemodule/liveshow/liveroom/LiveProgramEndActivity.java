package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
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
import com.qpidnetwork.livemodule.httprequest.OnShowListWithAnchorIdCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniProgram;
import com.qpidnetwork.livemodule.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.ProgramStatus;
import com.qpidnetwork.livemodule.httprequest.item.ProgramTicketStatus;
import com.qpidnetwork.livemodule.liveshow.bean.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.home.LiveProgramDetailActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ROOMPHOTOURL;

/**
 * Created by Hunter on 18/4/25.
 */

public class LiveProgramEndActivity extends BaseFragmentActivity {

    private static final String ANCHOR_ID = "anchorId";
    private static final String ANCHOR_NICKNAME = "anchorName";
    private static final String ANCHOR_PHOTOURL = "anchorPhotoUrl";
    private static final String LIVEROOM_PAGE_TYPE = "pageType";
    private static final String LIVEROOM_PAGE_ERROR_MSG = "errMsg";
    private static final String LIVEROOM_PAGE_SHOW_RECOMMAND = "recommandFlag";

    private CircleImageView civPhoto;
    private TextView tvAnchorName;
    private TextView tvDesc;

    private Button btnBook;
    private Button btnViewHot;
    private Button btnAddCredit;

    //高斯模糊背景
    private SimpleDraweeView iv_gaussianBlur;
    private View v_gaussianBlurFloat;

    //data
    private String mAnchorId;
    private String mAnchorName;

    //当前推荐节目
    private ProgramInfoItem mProgramInfoItem;

    public static Intent getIntent(Context context, LiveRoomNormalErrorActivity.PageErrorType type, String errMsg, String anchorId
            , String anchorName, String anchorPhotoUrl, String roomPhotoUrl, boolean isShowRecommand){
        Intent intent = new Intent(context, LiveProgramEndActivity.class);
        intent.putExtra(LIVEROOM_PAGE_TYPE, type.ordinal());
        intent.putExtra(LIVEROOM_PAGE_ERROR_MSG, errMsg);
        intent.putExtra(ANCHOR_ID, anchorId);
        intent.putExtra(ANCHOR_NICKNAME, anchorName);
        intent.putExtra(ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, roomPhotoUrl);
        intent.putExtra(LIVEROOM_PAGE_SHOW_RECOMMAND, isShowRecommand?1:0);
        return intent;
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        TAG = LiveRoomNormalErrorActivity.class.getSimpleName();
        setContentView(R.layout.activity_program_show_end);
        initViews();
        initData();
    }


    private void initViews(){
        civPhoto = (CircleImageView)findViewById(R.id.civPhoto);
        tvAnchorName = (TextView)findViewById(R.id.tvAnchorName);
        tvDesc = (TextView)findViewById(R.id.tvDesc);

        btnBook = (Button)findViewById(R.id.btnBook);
        btnViewHot = (Button)findViewById(R.id.btnViewHot);
        btnAddCredit = (Button)findViewById(R.id.btnAddCredit);

        //绑定返回按钮事件
        ((ImageView)findViewById(R.id.btnClose)).setOnClickListener(this);
        btnAddCredit.setOnClickListener(this);
        btnBook.setOnClickListener(this);
        btnViewHot.setOnClickListener(this);

        //高斯模糊背景
        iv_gaussianBlur = (SimpleDraweeView) findViewById(R.id.iv_gaussianBlur);
        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
        v_gaussianBlurFloat.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#cc000000")));
    }

    private void initData(){
        String anchorPhotoUrl = "";
        LiveRoomNormalErrorActivity.PageErrorType errType = null;
        String roomPhotoUrl = null;
        String errorMsg = "";
        boolean isRecommand = false;

        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(LIVEROOM_PAGE_TYPE)){
                errType = LiveRoomNormalErrorActivity.PageErrorType.values()[bundle.getInt(LIVEROOM_PAGE_TYPE)];
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
        } else if (i == R.id.includeRecommand) {
            //推荐点击跳转逻辑
            if (mProgramInfoItem != null) {
                startActivity(LiveProgramDetailActivity.getProgramInfoIntent(this,
                        getResources().getString(R.string.live_program_detail_title),
                        mProgramInfoItem.showLiveId,
                        true));
            }

            //GA统计点击推荐
            onAnalyticsEvent(getResources().getString(R.string.Live_Calendar_Category),
                    getResources().getString(R.string.Live_CalendarEnd_Action_Recommend),
                    getResources().getString(R.string.Live_CalendarEnd_Label_Recommend));

            //点击推荐，关闭界面
            finish();
        }
    }

    /**
     * 获取推荐列表
     */
    private void getPromoAnchorList() {
        //获取推荐列表
        LiveRequestOperator.getInstance().ShowListWithAnchorId(RequestJniProgram.ShowRecommendListType.EndRecommend, 0, 10, mAnchorId, new OnShowListWithAnchorIdCallback() {
            @Override
            public void onShowListWithAnchorId(boolean isSuccess, int errCode, String errMsg, final ProgramInfoItem[] array) {
                if(isSuccess && array != null && array.length > 0){
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            //默认取第一个推荐
                            ProgramInfoItem item = array[0];
                            refreshShowRecommand(item);
                        }
                    });
                }
            }
        });
    }

    /****************************************  推荐界面显示逻辑  *************************************************/
    //开播前剩余时间(秒)
    private final int SEC_PROGRAMME_START = 0;
    //开播前倒数时间(秒)
    private final int SEC_PROGRAMME_COUNTDOWN = 30 * 60 ;

    /**
     * 刷新推荐界面
     * @param item
     */
    private void refreshShowRecommand(ProgramInfoItem item){
        //本地存储推荐数据
        mProgramInfoItem = item;
        //初始化view
        findViewById(R.id.includeRecommand).setVisibility(View.VISIBLE);
        findViewById(R.id.includeRecommand).setOnClickListener(this);
        findViewById(R.id.viewCalendarDivider).setVisibility(View.GONE);
        findViewById(R.id.rlCalendarButtonArea).setVisibility(View.GONE);

        SimpleDraweeView imgCover = (SimpleDraweeView)findViewById(R.id.img_cover);
        TextView tvOnShow = (TextView)findViewById(R.id.tv_on_show);
        TextView tvStartTime = (TextView)findViewById(R.id.tv_start_time);
        TextView tvDuration = (TextView)findViewById(R.id.tv_duration);
        TextView tvPrice = (TextView)findViewById(R.id.tv_price);
        SimpleDraweeView imgAnchorAvatar = (SimpleDraweeView)findViewById(R.id.img_room_logo);
        TextView tvTitle = (TextView)findViewById(R.id.tv_room_title);
        TextView tvAnchorNickname = (TextView)findViewById(R.id.tv_anchor_name);

        imgCover.setImageURI(item.cover);
        tvStartTime.setText(DateUtil.getDateStr(item.startTime*1000l, DateUtil.FORMAT_MMMDDhmm_24));
        tvDuration.setText(mContext.getString(R.string.live_duration_time, String.valueOf(item.duration)));
        tvPrice.setText(mContext.getString(R.string.live_credits, String.valueOf(item.price)));
        imgAnchorAvatar.setImageURI(item.anchorAvatar);
        tvTitle.setText(item.showTitle);
        tvAnchorNickname.setText(item.anchorNickname);

        if (item.status == ProgramStatus.VerifyPass) {
            //准备开始,开始中 (绿色)
            if (item.leftSecToEnter <= SEC_PROGRAMME_START) {
                //开播中
                tvOnShow.setText(mContext.getString(R.string.live_programme_on_show));
                Drawable drawableLeft = mContext.getResources().getDrawable(R.drawable.ic_live_programme_onshow);
                // 这一步必须要做，否则不会显示。
                drawableLeft.setBounds(0,
                        0,
                        mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp),
                        mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp));// 设置图片宽高
                tvOnShow.setCompoundDrawables(drawableLeft , null , null , null);
                tvOnShow.setVisibility(View.VISIBLE);
            } else {
                //未开始
                if (item.leftSecToStart <= SEC_PROGRAMME_COUNTDOWN) {
                    //开播前30分钟
                    tvOnShow.setText(mContext.getString(
                            R.string.live_programme_on_show_countdown,
                            String.valueOf(item.leftSecToStart / 60 == 0 ? 1 : (item.leftSecToStart / 60) + (item.leftSecToStart % 60 == 0 ? 0:1))//余0不加1
                    ));
                    Drawable drawableLeft = mContext.getResources().getDrawable(R.drawable.ic_live_programme_countdown);
                    // 这一步必须要做，否则不会显示。
                    drawableLeft.setBounds(0,
                            0,
                            mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp),
                            mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp));// 设置图片宽高
                    tvOnShow.setCompoundDrawables(drawableLeft, null, null, null);
                    tvOnShow.setVisibility(View.VISIBLE);
                }else {
                    //开播剩余时间>30分钟
                    tvOnShow.setVisibility(View.GONE);
                }
            }
        } else {
            tvOnShow.setVisibility(View.GONE);
        }
    }
}
