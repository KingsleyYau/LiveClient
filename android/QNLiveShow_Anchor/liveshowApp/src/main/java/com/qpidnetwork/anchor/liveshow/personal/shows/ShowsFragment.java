package com.qpidnetwork.anchor.liveshow.personal.shows;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.v7.widget.LinearLayoutManager;
import android.text.TextUtils;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseFragmentActivity;
import com.qpidnetwork.anchor.framework.base.BaseRecyclerViewFragment;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetProgramListCallback;
import com.qpidnetwork.anchor.httprequest.RequestJniProgram;
import com.qpidnetwork.anchor.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.anchor.liveshow.liveroom.ProgramLiveTransitionActivity;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Vector;
import java.util.concurrent.TimeUnit;

import io.reactivex.Flowable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;
import io.reactivex.functions.Function;

/**
 * 节目
 * Created by Jagger on 2018/4/18.
 */

public class ShowsFragment extends BaseRecyclerViewFragment implements ShowsAdapter.OnItemClickedListener {

    //启动参数
    private static final String PARAM_SORT_TYPE = "PARAM_SORT_TYPE";
    //本地自动倒计时时间间隔
    private static final int STEP_ENTERTIME_COUNTDOWN = 10 * 1000;
    private static final int GET_PROGRAMMES_LIST_CALLBACK = 1;
    //每页刷新数据条数
    private static final int STEP_PAGE_SIZE = 50;
    //超过？条显示更多（上拉更多操作，当在一页能显示所有条数时，会和下拉刷新冲突，所以当一页能显示所有数据时，不要显示上拉更多）
//    private static final int STEP_PAGE_MORE = 4;

    private RequestJniProgram.ProgramSortType mProgramSortType = RequestJniProgram.ProgramSortType.VerifyPass;
    private Vector<ProgramInfoItem> mList = new Vector<>(); //Vector线程安全
    private ShowsAdapter mAdapter;
    private Disposable mDisposable;  //本地倒计时
    private List<Integer> mListNeedUpdateItemIndex = new ArrayList<>(); //记录需要更新开播时间的选项
    private boolean mIsShowMore = false;   //是否需要显示“更多”

    /**
     * 带参数启动方式
     * @param sortType
     * @return
     */
    public static ShowsFragment newInstance(RequestJniProgram.ProgramSortType sortType){
        ShowsFragment fragment = new ShowsFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable( PARAM_SORT_TYPE, sortType);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        //取启动参数
        if(getArguments() != null){
            if(getArguments().containsKey(PARAM_SORT_TYPE)){
                mProgramSortType = (RequestJniProgram.ProgramSortType)getArguments().getSerializable(PARAM_SORT_TYPE);
            }
        }

        //列表分组
        LinearLayoutManager manager = new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false);
        refreshRecyclerView.getRecyclerView().setLayoutManager(manager);
        mAdapter = new ShowsAdapter(getActivity(), mList);
        mAdapter.setOnItemClickedListener(this);
        refreshRecyclerView.setAdapter(mAdapter);

        //列表背景色
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            setBgColor(mContext.getColor(R.color.live_programme_list_group_gray));
        }else{
            setBgColor(mContext.getResources().getColor(R.color.live_programme_list_group_gray));
        }

        //初始化数据
        showLoadingProcess();
        refreshByData(false);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        doCancelUpdateEnterTime();
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if(mContext != null && isVisibleToUser && (mList == null || mList.size() == 0)){
            showLoadingProcess();
            refreshByData(false);
        }
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        refreshByData(false);
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        refreshByData(false);
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        refreshByData(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        refreshByData(true);
    }

    /**
     * 取数据
     * @param isMore 是否取更多
     */
    private void refreshByData(final boolean isMore){
        //标记是否刷新数据, 控制本地是否自动倒计时
        if(!isMore){
            hideNodataPage();
            doCancelUpdateEnterTime();
        }

        //正式
        //起始条目
        int startIndex = 0;
        if(isMore){
            startIndex = mList.size();
        }

        //请求接口
        LiveRequestOperator.getInstance().GetProgramList(mProgramSortType, startIndex, STEP_PAGE_SIZE, new OnGetProgramListCallback() {
            @Override
            public void onGetProgramList(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem[] array) {
                //数据处理
                if(!isMore){
                    //成功才清空
                    //del by Jagger 2018-5-22 Samson说失败也清数据
//                    if(isSuccess){
                    mList.clear();
//                    }
                }
                //判空处理
                if(array != null){
                    mList.addAll(Arrays.asList(array));
                    //是否需显示“更多”
                    if(array.length < STEP_PAGE_SIZE){
                        mIsShowMore = false;
                    }else {
                        mIsShowMore = true;
                    }
                }

                //回调界面
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, array);
                Message msg = Message.obtain();
                msg.what = GET_PROGRAMMES_LIST_CALLBACK;
                msg.arg1 = isMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
        //end 正式
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        if (getActivity() == null) {
            return;
        }

        onRefreshComplete();
        HttpRespObject response = (HttpRespObject) msg.obj;

        switch (msg.what) {
            case GET_PROGRAMMES_LIST_CALLBACK: {
                hideLoadingProcess();
                //刷新界面
                mAdapter.notifyDataSetChanged();
                //失败但本来有数据显示Toast
                if (!response.isSuccess) {
                    if(mAdapter.getItemCount() > 0){
                        if(getActivity() != null && getActivity() instanceof BaseFragmentActivity && !TextUtils.isEmpty(response.errMsg)){
                            BaseFragmentActivity activity = (BaseFragmentActivity)getActivity();
                            activity.showToast(response.errMsg);
                            return;
                        }
                    }else{
                        showErrorPage();
                        return;
                    }
                }

                if(mAdapter.getItemCount() == 0){
                    //无数据显示空页
                    showEmptyView();
                }else{
                    //是否需要显示更多
                    if(mIsShowMore){
                        closePullUpRefresh(false);
                    }else {
                        closePullUpRefresh(true);
                    }
                    //不是更多, 才开始本地倒计时
                    if(msg.arg1 == 0){
                        doUpdateEnterTime();
                    }
                }
            }
            break;
        }
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        if(null != getActivity()){
            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.live_programme_list_empty));
            setDefaultEmptyButtonText("");
        }
        showNodataPage();
//        if(null != getActivity()){
//            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.live_programme_list_empty),
//                    R.drawable.ic_no_tickets ,
//                    mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp),
//                    mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp)
//            );
//            setDefaultEmptyButtonText("");
//            setDefaultEmptyIconVisible(View.INVISIBLE);
//            showNodataPage();
//        }
    }

    /**
     * 本地自动倒计时
     */
    private void doUpdateEnterTime(){
        if(mDisposable != null && !mDisposable.isDisposed()){
            return;
        }

        mDisposable = Flowable.interval(STEP_ENTERTIME_COUNTDOWN, TimeUnit.MILLISECONDS)
                .doOnNext(new Consumer<Long>() {
                    @Override
                    public void accept(@NonNull Long aLong) throws Exception {
                        synchronized (mList) {
                            mListNeedUpdateItemIndex.clear();
                            //对每项操作
                            for(int i = 0 ; i < mList.size(); i++){
                                if(mList.get(i).leftSecToEnter > 0){
                                    mList.get(i).leftSecToEnter -= (STEP_ENTERTIME_COUNTDOWN / 1000);//转为秒
                                    //记录需要更新时间的item
                                    if(!mListNeedUpdateItemIndex.contains(i)){
                                        mListNeedUpdateItemIndex.add(i);
                                    }
                                }

                                if(mList.get(i).leftSecToStart > 0){
                                    mList.get(i).leftSecToStart -= (STEP_ENTERTIME_COUNTDOWN / 1000);//转为秒
                                    //记录需要更新时间的item
                                    if(!mListNeedUpdateItemIndex.contains(i)){
                                        mListNeedUpdateItemIndex.add(i);
                                    }
                                }
                            }
                        }
                    }
                })
                .map(new Function<Long, List<Integer>>() {
                    @Override
                    public List<Integer> apply(Long aLong) {
                        //因为不能在子线程和主线程同时对mListNeedUpdateItemIndex进行遍历和改动，所以把它拷贝到一个新数组中
                        ArrayList<Integer> listItemIndex = new ArrayList<>();
                        listItemIndex.addAll(mListNeedUpdateItemIndex);
                        return listItemIndex;
                    }
                })
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<List<Integer>>() {
                    @Override
                    public void accept(@NonNull List<Integer> listItemIndex) throws Exception {
                        for (Integer i: listItemIndex) {
                            //payload 可看作成一个标记，类型不限
                            mAdapter.notifyItemChanged(i, true);
                        }
                    }
                });

    }

    /**
     * 中止本地倒计时
     */
    private void doCancelUpdateEnterTime(){
        if(mDisposable!=null&&!mDisposable.isDisposed()){
            mDisposable.dispose();
        }
    }

    /**
     * 打开节目详情
     * @param programInfoItem
     */
    @Override
    public void onDetailClicked(ProgramInfoItem programInfoItem) {
        Intent i = ProgramDetailActivity.getProgramDetailIntent(mContext , getResources().getString(R.string.live_programme_detail_title) , programInfoItem.showLiveId);
        mContext.startActivity(i);
    }

    /**
     * 开播
     * @param programInfoItem
     */
    @Override
    public void onStartShowClicked(ProgramInfoItem programInfoItem) {
        Intent i = ProgramLiveTransitionActivity.getProgramIntent(mContext , programInfoItem.showLiveId);
        mContext.startActivity(i);
    }
}
