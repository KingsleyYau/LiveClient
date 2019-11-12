package com.qpidnetwork.livemodule.liveshow.livechat;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.v7.widget.GridLayoutManager;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.livechathttprequest.LivechatRequestOperator;
import com.qpidnetwork.livemodule.livechathttprequest.OnQueryRecentVideoListCallback;
import com.qpidnetwork.livemodule.livechathttprequest.item.LCVideoItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.RecentWatchAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.WatchItemDecoration;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.view.EmptyView;
import com.qpidnetwork.livemodule.view.ErrorView;
import com.qpidnetwork.livemodule.view.RefreshRecyclerView;

import java.util.Arrays;
import java.util.List;

/**
 * 直播LiveChat观看历史视频界面
 *
 * @author Oscar 2019-05-13
 */
public class LiveChatRecentWatchActivity extends BaseActionBarFragmentActivity
        implements OnQueryRecentVideoListCallback {


    private final static String KEY_WOMENID = "KEY_WOMENID";
    private final static int WHAT_SHOWLIST_SUCCESSUL = 1000;
    private final static int WHAT_SHOWLIST_FAIL = -1000;


    private String token = "";
    private String uid = "";
    private String womenId = "";

    private RefreshRecyclerView recentWatchList;
    private RecentWatchEmptyView emptyView;
    private ErrorView errorView;
    private RecentWatchAdapter recentWatchAdapter;
    private String[] videoTitles;
    private String[] videoUrls;
    private String[] videoCovers;


    public static void launch(Context context, String womenId) {

        Intent intent = new Intent(context, LiveChatRecentWatchActivity.class);
        intent.putExtra(KEY_WOMENID, womenId);
        context.startActivity(intent);

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_live_chat_recent_watch);
        initTitle();
        initView();
        initData();
        recentWatchList.getSwipeRefreshLayout().setRefreshing(true);
        loadRecentWatch();
    }

    private void initData() {

        Intent data = getIntent();
        womenId = data.getStringExtra(KEY_WOMENID);

        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if(loginItem != null){
            token = loginItem.token;
            uid = loginItem.userId;
        }
    }

    private void initView() {

        recentWatchList = findViewById(R.id.live_chat_recent_watch_list);
        emptyView = findViewById(R.id.emptyView);
        errorView = findViewById(R.id.errorView);
        GridLayoutManager manager = new GridLayoutManager(this, 2);
        recentWatchList.getRecyclerView().setLayoutManager(manager);
        recentWatchAdapter = new RecentWatchAdapter(this);
        recentWatchList.getRecyclerView().addItemDecoration(new WatchItemDecoration(this));
        recentWatchList.setAdapter(recentWatchAdapter);
        recentWatchList.setOnPullRefreshListener(new RefreshRecyclerView.OnPullRefreshListener() {
            @Override
            public void onPullDownToRefresh() {
                recentWatchAdapter.notifyItemRangeRemoved(0,recentWatchAdapter.getList().size());
                recentWatchAdapter.getList().clear();
                loadRecentWatch();
            }

            @Override
            public void onPullUpToRefresh() {

            }
        });
        recentWatchList.setCanPullUp(false);
        emptyView.setOnClickedEventsListener(new RecentWatchEmptyView.OnClickedEventsListener() {
            @Override
            public void onRetry() {
                loadRecentWatch();
            }
        });
        errorView.setOnClickedEventsListener(new ErrorView.OnClickedEventsListener() {
            @Override
            public void onRetry() {
                noDataReload();
            }
        });
        recentWatchAdapter.setOnItemClickListener(new BaseRecyclerViewAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View v,
                                    int position) {

                LiveChatRecentWatchPreviewActivity.launch(
                        LiveChatRecentWatchActivity.this,
                        position,
                        videoTitles,
                        videoCovers,
                        videoUrls
                );
            }
        });

    }

    private void noDataReload(){
        recentWatchList.setVisibility(View.VISIBLE);
        errorView.setVisibility(View.GONE);
        recentWatchList.getSwipeRefreshLayout().setRefreshing(true);
        loadRecentWatch();
    }

    private void loadRecentWatch() {

        LivechatRequestOperator.getInstance().QueryRecentVideo(token, uid, womenId, this);

    }

    /**
     * 初始化Title
     */
    private void initTitle() {
        //title处理
        setTitle(getString(R.string.live_chat_recent_watched_title), R.color.theme_default_black);
    }

    @Override
    public void OnQueryRecentVideoList(boolean isSuccess,
                                       String errno,
                                       String errmsg,
                                       LCVideoItem[] itemList) {
        Message message = new Message();
        if (isSuccess) {
            message.what = WHAT_SHOWLIST_SUCCESSUL;
            message.obj = itemList;
        } else {
            message.what = WHAT_SHOWLIST_FAIL;
            message.obj = errmsg;
        }
        sendUiMessage(message);
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        switch (msg.what) {
            case WHAT_SHOWLIST_SUCCESSUL:
                LCVideoItem[] itemList = (LCVideoItem[]) msg.obj;
                int length = 0;
                if(itemList != null){
                    length = itemList.length;
                }
                if (length > 0) {
                    videoTitles = new String[length];
                    videoUrls = new String[length];
                    videoCovers = new String[length];
                    for (int i = 0; i < length; i++) {
                        videoTitles[i] = itemList[i].title;
                        videoUrls[i] = itemList[i].video_url;
                        videoCovers[i] = itemList[i].videoCover;

                    }
                    List data = Arrays.asList(itemList);
                    recentWatchList.setVisibility(View.VISIBLE);
                    emptyView.setVisibility(View.GONE);
                    errorView.setVisibility(View.GONE);
                    recentWatchAdapter.addData(data);
                    recentWatchList.onRefreshComplete();
                } else {
                    emptyView.setVisibility(View.VISIBLE);
                    emptyView.onReloadComplete();
                    errorView.setVisibility(View.GONE);
                    recentWatchList.setVisibility(View.GONE);
                }

                break;
            case WHAT_SHOWLIST_FAIL:
                errorView.setVisibility(View.VISIBLE);
                recentWatchList.setVisibility(View.GONE);
                emptyView.setVisibility(View.GONE);
                break;

        }
    }

}
