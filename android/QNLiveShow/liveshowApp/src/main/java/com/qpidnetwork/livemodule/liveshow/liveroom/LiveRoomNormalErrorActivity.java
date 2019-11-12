package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Html;
import android.text.TextUtils;
import android.view.DragEvent;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetPageRecommendAnchorListCallback;
import com.qpidnetwork.livemodule.httprequest.item.PageRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMAuthorityItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.List;

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
    private static final String LIVEROOM_AUTH = "auth";

    private final int MAX_RECOMMAND_COUT = 6;

    //view
    private ImageView btnClose;
    private CircleImageView civPhoto;
    private TextView tvAnchorName;
    private TextView tvDesc;

    private ButtonRaised btnBook;
    private ButtonRaised btnViewHot;
    private ButtonRaised btnAddCredit;

    private LinearLayout llRecommand;
    private RecyclerView recycleView;
    private ImageView ivLeftArraw;
    private ImageView ivRightArraw;

    //data
    private String mAnchorId;
    private String mAnchorName;
    private IMAuthorityItem mAuthorityItem;

    //纪录recycle当前可见索引
    int mRecycleViewCurrentPoston = 0;

    public static Intent getIntent(Context context, PageErrorType type, String errMsg, String anchorId
            , String anchorName, String anchorPhotoUrl, String roomPhotoUrl, boolean isShowRecommand, IMAuthorityItem priv){
        Intent intent = new Intent(context, LiveRoomNormalErrorActivity.class);
        intent.putExtra(LIVEROOM_PAGE_TYPE, type.ordinal());
        intent.putExtra(LIVEROOM_PAGE_ERROR_MSG, errMsg);
        intent.putExtra(ANCHOR_ID, anchorId);
        intent.putExtra(ANCHOR_NICKNAME, anchorName);
        intent.putExtra(ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, roomPhotoUrl);
        intent.putExtra(LIVEROOM_PAGE_SHOW_RECOMMAND, isShowRecommand?1:0);
        intent.putExtra(LIVEROOM_AUTH, priv);
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

        btnBook = (ButtonRaised)findViewById(R.id.btnBook);
        btnViewHot = (ButtonRaised)findViewById(R.id.btnViewHot);
        btnAddCredit = (ButtonRaised)findViewById(R.id.btnAddCredit);

        llRecommand = (LinearLayout)findViewById(R.id.llRecommand);
        ivLeftArraw = (ImageView) findViewById(R.id.ivLeftArraw);
        ivRightArraw = (ImageView) findViewById(R.id.ivRightArraw);

        recycleView = (RecyclerView) findViewById(R.id.recycleView);

        //设定宽度，解决使用权重在部分手机（moto）导致recycle加载 getItemCount个数据导致内存爆
        LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) recycleView.getLayoutParams();
        params.width = DisplayUtil.getScreenWidth(mContext) - DisplayUtil.dip2px(mContext, 56) * 2;

        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        recycleView.setLayoutManager(linearLayoutManager);
        recycleView.setNestedScrollingEnabled(false);
        //屏蔽手动拖动等手动滚动列表动作
        recycleView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                if (motionEvent.getAction() == MotionEvent.ACTION_MOVE
                || motionEvent.getAction() == MotionEvent.ACTION_SCROLL){
                    return true;
                }
                return false;
            }
        });
        recycleView.setOnDragListener(new View.OnDragListener() {
            @Override
            public boolean onDrag(View view, DragEvent dragEvent) {
                return true;
            }
        });

        recycleView.setOnFlingListener(new RecyclerView.OnFlingListener() {
            @Override
            public boolean onFling(int i, int i1) {
                return true;
            }
        });

        btnClose.setOnClickListener(this);
        btnAddCredit.setOnClickListener(this);
        btnBook.setOnClickListener(this);
        btnViewHot.setOnClickListener(this);
        ivLeftArraw.setOnClickListener(this);
        ivRightArraw.setOnClickListener(this);
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

            if(bundle.containsKey(LIVEROOM_AUTH)){
                mAuthorityItem = (IMAuthorityItem) bundle.getSerializable(LIVEROOM_AUTH);
            }

        }
        if(!TextUtils.isEmpty(anchorPhotoUrl)) {
            PicassoLoadUtil.loadUrlNoMCache(civPhoto,anchorPhotoUrl,R.drawable.ic_default_photo_woman);
        }

        tvAnchorName.setText(Html.fromHtml(getResources().getString(R.string.liveroom_transition_anchor_name_and_id, mAnchorName, mAnchorId)));
        Log.i("Jagger" , "直播间结束页 initData book:" + (mAuthorityItem == null?"null":mAuthorityItem.isHasBookingAuth));
        switch (errType){
            case PAGE_ERROR_LIEV_EDN:{
                if(TextUtils.isEmpty(errorMsg)) {
                    tvDesc.setText(getResources().getString(R.string.liveroom_transition_broadcast_ended));
                }else{
                    tvDesc.setText(errorMsg);
                }

                if(mAuthorityItem != null && mAuthorityItem.isHasBookingAuth){  //add by Jagger 2018-12-5 增加权限
                    btnBook.setVisibility(View.VISIBLE);
                }else {
                    btnBook.setVisibility(View.GONE);
                }

                //获取推荐列表
                if(isRecommand) {
                    llRecommand.setVisibility(View.INVISIBLE);
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
            LiveModule.getInstance().onAddCreditClick(mContext, new NoMoneyParamsBean());
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
        }else if (i == R.id.ivLeftArraw) {
            if(llRecommand.getVisibility() == View.VISIBLE){
                mRecycleViewCurrentPoston = mRecycleViewCurrentPoston + 1;
                recycleView.smoothScrollToPosition(mRecycleViewCurrentPoston);
            }
        }else if (i == R.id.ivRightArraw) {
            if(llRecommand.getVisibility() == View.VISIBLE){
                if(mRecycleViewCurrentPoston >= 1){
                    mRecycleViewCurrentPoston = mRecycleViewCurrentPoston - 1;
                    recycleView.smoothScrollToPosition(mRecycleViewCurrentPoston);
                }
            }
        }
    }

    /**
     * 获取推荐列表
     */
    private void getPromoAnchorList(){
        Log.d(TAG,"getPromoAnchorList");
        LiveRequestOperator.getInstance().GetPageRecommendAnchorList(new OnGetPageRecommendAnchorListCallback() {
                    @Override
                    public void onGetPageRecommendAnchorList(boolean isSuccess, int errCode, String errMsg, final PageRecommendItem[] anchorList) {
                        final List<PageRecommendItem> recommandList = filterSelfFromRecommand(anchorList);
                        if( isSuccess && recommandList != null && recommandList.size() > 1) {
                            //显示推荐模块
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    llRecommand.setVisibility(View.VISIBLE);
                                    int width = DisplayUtil.getScreenWidth(mContext) - DisplayUtil.dip2px(mContext, 56) * 2;
                                    PageRecommendItem[] recommandArray = recommandList.toArray(new PageRecommendItem[recommandList.size()]);
                                    LiveRoomRecommandAdapter adapter = new LiveRoomRecommandAdapter(mContext, filterAnchorList(recommandArray), width);
                                    recycleView.setAdapter(adapter);
                                    mRecycleViewCurrentPoston = Integer.MAX_VALUE/2;//初始化到第一个
                                    recycleView.scrollToPosition(mRecycleViewCurrentPoston);
                                }
                            });
                        }
                    }
                });
    }

    /**
     * 推荐主播过滤当前主播
     * @param anchorList
     * @return
     */
    private List<PageRecommendItem> filterSelfFromRecommand(PageRecommendItem[] anchorList){
        List<PageRecommendItem> recommandList = new ArrayList<PageRecommendItem>();
        if(anchorList != null && anchorList.length > 1){
            for(PageRecommendItem item : anchorList){
                if(!item.anchorId.equals(mAnchorId)){
                    recommandList.add(item);
                }
            }
        }
        return recommandList;
    }


    /**
     * 根据设计需要，取前6个
     * @param anchorList
     * @return
     */
    private List<LiveRoomRecommandAdapter.RecommandDataBean> filterAnchorList(PageRecommendItem[] anchorList){
        List<LiveRoomRecommandAdapter.RecommandDataBean> list = new ArrayList<LiveRoomRecommandAdapter.RecommandDataBean>();
        if(anchorList != null){
            int length = anchorList.length;
            if(anchorList.length < MAX_RECOMMAND_COUT){
                if(anchorList.length % 2 != 0){
                    length = anchorList.length - 1;
                }
            }else{
                length = MAX_RECOMMAND_COUT;
            }
            for(int i=0; i< length; i=i+2){
                LiveRoomRecommandAdapter.RecommandDataBean bean = new LiveRoomRecommandAdapter.RecommandDataBean();
                bean.leftData = anchorList[i];
                bean.rightData = anchorList[i+1];
                list.add(bean);
            }
        }
        return list;
    }
}
