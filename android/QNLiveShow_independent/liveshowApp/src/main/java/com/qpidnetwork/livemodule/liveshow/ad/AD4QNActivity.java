package com.qpidnetwork.livemodule.liveshow.ad;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetAdAnchorListCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/**
 * 用于QN主界面显示广告
 * Created by Jagger on 2017/9/22.
 */
public class AD4QNActivity extends BaseFragmentActivity {
    private int MAX_LIST_ITEMS = 4;
    private final int REQUEST_LIST_SUCCESS = 0;
    private final int REQUEST_LIST_FAILED = 1;
    private int MIN_SHOW_SUM = 2; //至少有几个主播才显示列表

    private Context mContext;
    private List<HotListItem> mDatas = new ArrayList<>();
    private UIHandler mUIHandler;

    private LinearLayout mLLTitle;
    private RecyclerView mRecyclerView;
    private GridLayoutManager mLayoutManager;
    private ADAnchorAdapter mAdapter;
    private Button mBtnGo;
    private ImageButton mBtnCancel;
    private ImageView mImageViewEmpty;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ad4_qn);

        mContext = this;

        mLLTitle = (LinearLayout)findViewById(R.id.ll_header_title);
        mLLTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //test
                //打开URL到直播列表
                toLiveList();

                //GA统计，关闭home广告banner
                onAnalyticsEvent(getResources().getString(R.string.LiveQN_Category),
                        getResources().getString(R.string.LiveQN_Action_AdvertBanner),
                        getResources().getString(R.string.LiveQN_Label_AdvertBanner));
            }
        });

        mLayoutManager = new GridLayoutManager(mContext, 2, GridLayoutManager.VERTICAL, false);
        mAdapter = new ADAnchorAdapter(mDatas);

        mRecyclerView = (RecyclerView)findViewById(R.id.rcv_anchors);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setAdapter(mAdapter);

        mBtnGo =(Button)findViewById(R.id.btn_go_bottom);
        mBtnGo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //test
                //打开URL到直播列表
                toLiveList();

                //GA统计，关闭home界面直播广告
                onAnalyticsEvent(getResources().getString(R.string.LiveQN_Category),
                        getResources().getString(R.string.LiveQN_Action_GoWatch),
                        getResources().getString(R.string.LiveQN_Label_GoWatch));
            }
        });

        mBtnCancel = (ImageButton)findViewById(R.id.btn_ad_close) ;
        mBtnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //调用广告关闭接口，通知服务器
                LiveRequestOperator.getInstance().CloseAdAnchorList(new OnRequestCallback() {
                    @Override
                    public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                    }
                });

                finish();

                //GA统计，关闭home界面直播广告
                onAnalyticsEvent(getResources().getString(R.string.LiveQN_Category),
                        getResources().getString(R.string.LiveQN_Action_CloseAD),
                        getResources().getString(R.string.LiveQN_Label_CloseAD));
            }
        });

        mImageViewEmpty = (ImageView)findViewById(R.id.img_ad_empty);

        loadData();
    }

    /**
     * 请求数据
     */
    private void loadData(){

        mUIHandler = new UIHandler(this){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                if(msg != null){
                    switch (msg.what){
                        case REQUEST_LIST_SUCCESS:
                            mRecyclerView.setVisibility(View.VISIBLE);
                            mImageViewEmpty.setVisibility(View.GONE);

                            mAdapter.notifyDataSetChanged();
                            break;
                        case REQUEST_LIST_FAILED:

                            mRecyclerView.setVisibility(View.GONE);
                            mImageViewEmpty.setVisibility(View.VISIBLE);
                            break;
                    }
                }
            }
        };

        LiveRequestOperator.getInstance().GetAdAnchorList(MAX_LIST_ITEMS, new OnGetAdAnchorListCallback() {
            @Override
            public void onGetAdAnchorList(boolean isSuccess, int errCode, String errMsg, HotListItem[] hotList) {
                if(isSuccess){
                    if(hotList != null && hotList.length > 0){
                        mDatas.clear();

                        int sum = 0;
                        for (HotListItem item:hotList) {
                            sum ++;
                            if(sum > MAX_LIST_ITEMS) break;
                            mDatas.add(item);
                        }
                    }

                    //少于2个主播时，显示空界面
                    if(mDatas.size() < MIN_SHOW_SUM){
                        mUIHandler.sendEmptyMessage(REQUEST_LIST_FAILED);
                        return;
                    }

                    mUIHandler.sendEmptyMessage(REQUEST_LIST_SUCCESS);
                }else {
                    mUIHandler.sendEmptyMessage(REQUEST_LIST_FAILED);
                }

            }
        });
    }

    /**
     * 跳转到主界面
     */
    private void toLiveList(){
        String pushActionUrl = URL2ActivityManager.createServiceEnter();
        //建立Intent
        Intent intent = new Intent();
        intent.putExtra(CommonConstant.KEY_PUSH_NOTIFICATION_URL, pushActionUrl);
        intent.setAction(CommonConstant.ACTION_PUSH_NOTIFICATION);
        sendBroadcast(intent);
    }

    /**
     * 处理 请求返回,可避免Activity关闭后还处理界面的问题
     * @author Jagger
     * 2017-9-19
     */
    private static class UIHandler extends Handler {
        private final WeakReference<Activity> mActivity;

        public UIHandler(Activity activity){
            mActivity = new WeakReference<Activity>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            // TODO Auto-generated method stub
            super.handleMessage(msg);
            if(mActivity == null) return;
        }
    }
}
