package com.qpidnetwork.livemodule.liveshow.home;

import android.app.Activity;
import android.app.Dialog;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.v7.widget.LinearLayoutManager;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.dou361.dialogui.DialogUIUtils;
import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.base.BaseRecyclerViewFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnBuyProgramCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetProgramListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniProgram;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.ProgramTicketStatus;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.RegisterActivity;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.tickets.TicketHistoryAdapter;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.stickyDecoration4Recyclerview.PowerfulStickyDecoration;
import com.qpidnetwork.qnbridgemodule.view.stickyDecoration4Recyclerview.listener.PowerGroupListener;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
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

public class CalendarFragment extends BaseRecyclerViewFragment implements CalendarAdapter.OnItemClickedListener, IAuthorizationListener {

    //展示界面
    public enum ShowType{
        CALENDAR,   //主界面列表
        UNUSED,     //MyTicket--Unused
        HISTORY     //MyTicket--History
    }

    //启动参数
    private static final String PARAM_SHOW_TYPE = "PARAM_SHOW_TYPE";
    //本地自动倒计时时间间隔
    private static final int STEP_ENTERTIME_COUNTDOWN = 10 * 1000;
    //请求返回
    private static final int GET_PROGRAMMES_LIST_CALLBACK = 1;
    private static final int GET_TICKET_CALLBACK = 2;
    //每页刷新数据条数
    private static final int STEP_PAGE_SIZE = 50;
    //超过？条显示更多（上拉更多操作，当在一页能显示所有条数时，会和下拉刷新冲突，所以当一页能显示所有数据时，不要显示上拉更多）
    //2018-5-15 需求改动，少于50条不需要上拉更多
//    private static final int STEP_PAGE_MORE = 50;

    //控件
    private Dialog mDialogGetTicket , mDialogLoading;
//    private BuildBean mBuildBeanDialogLoading;

    //变量
    private RequestJniProgram.ProgramSortType mProgramSortType = RequestJniProgram.ProgramSortType.Start;
    private boolean mIsHeaderShow = true;   //是否要显示列表头
    private Vector<ProgramInfoItem> mList = new Vector<>(); //Vector线程安全
    private CalendarAdapter mAdapter;
    private Disposable mDisposable;  //本地倒计时
    private ShowType mShowType = ShowType.CALENDAR;
    private List<Integer> mListNeedUpdateItemIndex = new ArrayList<>(); //记录需要更新开播时间的选项
    private boolean mIsGroupByStartTime = false;   //是否按开始时间排序
    private Comparator<ProgramInfoItem> mComparatorList;
    private boolean mIsShowMore = false;   //是否需要显示“更多”
    private boolean isNeedRefresh = true;   //是否需要刷新列表 刷新逻辑可看BUG#13060

    /**
     * 带参数启动方式
     * @param showType
     * @return
     */
    public static CalendarFragment newInstance(ShowType showType){
        CalendarFragment fragment = new CalendarFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable( PARAM_SHOW_TYPE, showType);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        Log.d(TAG,"onActivityCreated");
        //取启动参数
        if(getArguments() != null){
            if(getArguments().containsKey(PARAM_SHOW_TYPE)){
                mShowType = (ShowType)getArguments().getSerializable(PARAM_SHOW_TYPE);
            }
        }

        LinearLayoutManager manager = new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false);
        refreshRecyclerView.getRecyclerView().setLayoutManager(manager);
        mComparatorList = new ComparatorStartTimeHighToLow();
        //跟据类型初始化界面
        if(mShowType == ShowType.CALENDAR){
            doInitView4TypeCalendar();
        }else if(mShowType == ShowType.UNUSED){
            doInitView4TypeUnused();
        }else if(mShowType == ShowType.HISTORY){
            doInitView4TypeHistory();
        }
        LoginManager.getInstance().register(this);

        //del by Jagger
        //无节目时要看到列表头同时也要看到EmptyView,不能设置背景色，透明才可以看到EmptyView
        //列表背景色
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            setBgColor(mContext.getColor(R.color.live_programme_list_bg));
//        }else{
//            setBgColor(mContext.getResources().getColor(R.color.live_programme_list_bg));
//        }

        //modify by harry 2018年7月13日 15:50:09 避免预加载Fragment时因为刷新数据导致取消未读
//        //初始化数据
//        showLoadingProcess();
//        refreshByData(false);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        TAG = CalendarFragment.class.getSimpleName();
        Log.d(TAG,"onCreateView");
        return view;
    }

    /**
     * 列表类型为主界面中Calendar时
     */
    private void doInitView4TypeCalendar(){
        //列表分组
        PowerfulStickyDecoration decoration = PowerfulStickyDecoration.Builder
                .init(new PowerGroupListener() {
                    @Override
                    public String getGroupName(int position) {
                        //获取组名，用于判断是否是同一组
                        if (mList.size() > position) {
                            if(mList.get(position).type == ProgramInfoItem.TYPE.Programme.ordinal()){
                                return DateUtil.getDate( mList.get(position).startTime*1000l );    //改为播放时间
                            }else {
                                return null;
                            }
                        }
                        return null;
                    }

                    @Override
                    public View getGroupView(int position) {
                        //获取自定定义的组View(注:普通Item的View在Adapter中定义)
                        if (mList.size() > position) {
                            View view = getActivity().getLayoutInflater().inflate(R.layout.item_live_calendar_list_group_name, null, false);
                            if(mList.get(position) != null){
                                ((TextView) view.findViewById(R.id.tv_group_name)).setText(DateUtil.getDate(mList.get(position).startTime*1000l ));
                            }
                            return view;
                        } else {
                            return null;
                        }
                    }
                })
                .setGroupHeight(getResources().getDimensionPixelSize(R.dimen.live_size_40dp))   //设置高度
                .isGroupHolding(false)      //是否分组悬浮
//                .setDivideHeight(20)    //item间距
//                .setDivideColor(getResources().getColor(R.color.transparent))
                .build();

        refreshRecyclerView.getRecyclerView().addItemDecoration(decoration);

        //列表头是否显示
        mIsHeaderShow = true;

        //是否按开始时间排序
        mIsGroupByStartTime = true;

        //适配器
        mAdapter = new CalendarAdapter(getActivity(), mList);
        mAdapter.setOnTicketEventListener(this);
        refreshRecyclerView.setAdapter(mAdapter);

        //排序方式
        mProgramSortType = RequestJniProgram.ProgramSortType.Start;

        //空页样式
        setDefaultEmptyMessage(
                getActivity().getResources().getString(R.string.live_programme_list_empty) ,
                R.drawable.ic_no_tickets ,
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp)
        );
        setDefaultEmptyButtonText("");
        setDefaultEmptyIconVisible(View.INVISIBLE);
    }

    /**
     * 列表类型为MyTicked中的Unused时
     */
    private void doInitView4TypeUnused(){
        //列表头是否显示
        mIsHeaderShow = false;
        //是否按开始时间排序
        mIsGroupByStartTime = false;

        //适配器
        mAdapter = new CalendarAdapter(getActivity(), mList);
        mAdapter.setOnTicketEventListener(this);
        refreshRecyclerView.setAdapter(mAdapter);

        //排序方式
        mProgramSortType = RequestJniProgram.ProgramSortType.Ticket;


        //空页样式
        setDefaultEmptyMessage(
                getActivity().getResources().getString(R.string.live_ticket_list_empty) ,
                R.drawable.ic_no_tickets ,
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp)
        );
        setDefaultEmptyButtonText("");
        setDefaultEmptyIconVisible(View.INVISIBLE);
    }

    /**
     * 列表类型为MyTicked中的History时
     */
    private void doInitView4TypeHistory(){
        //列表头是否显示
        mIsHeaderShow = false;
        //是否按开始时间排序
        mIsGroupByStartTime = false;

        //适配器
        mAdapter = new TicketHistoryAdapter(getActivity(), mList);
        mAdapter.setOnTicketEventListener(this);
        refreshRecyclerView.setAdapter(mAdapter);

        //排序方式
        mProgramSortType = RequestJniProgram.ProgramSortType.History;

        //空页样式
        setDefaultEmptyMessage(
                getActivity().getResources().getString(R.string.live_ticket_list_empty) ,
                R.drawable.ic_no_tickets ,
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp)
        );
        setDefaultEmptyButtonText("");
        setDefaultEmptyIconVisible(View.INVISIBLE);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        doCancelUpdateEnterTime();
        LoginManager.getInstance().unRegister(this);
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d(TAG,"onResume");
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        Log.d(TAG,"setUserVisibleHint-isVisibleToUser:"+isVisibleToUser);
        //方法解释见https://blog.csdn.net/czhpxl007/article/details/51277319
        //setUserVisibleHint->onAttach->onCreate->onCreateView->onActivityCreated->onResume
    }

    @Override
    protected void onReVisible() {
        super.onReVisible();
        Log.d(TAG,"onReVisible");
        boolean hasUnreadProgram = false;
        Activity activity = getActivity();
        if(activity != null && activity instanceof MainFragmentActivity){
            hasUnreadProgram = ((MainFragmentActivity)activity).getProgramHasUnread();
        }
        //可见且无数据或这有未读需要刷新时，刷新列表
        if(isNeedRefresh || hasUnreadProgram){
            showLoadingProcess();
            refreshByData(false);
        }
    }

    @Override
    protected void onBackFromHomeInTimeInterval() {
        super.onBackFromHomeInTimeInterval();

        showLoadingProcess();
        refreshByData(false);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        showLoadingProcess();
        refreshByData(false);
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        showLoadingProcess();
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
        Log.d(TAG,"refreshByData-isMore:"+isMore);
        //标记是否刷新数据, 控制本地是否自动倒计时
        if(!isMore){
            hideNodataPage();
            hideErrorPage();
            doCancelUpdateEnterTime();
            if(getActivity() != null && getActivity() instanceof MainFragmentActivity){
                //calendar tab红点取消
                ((MainFragmentActivity)getActivity()).refreshShowUnreadStatus(false);
            }
        }

        //正式
        //起始条目
        int startIndex = 0;
        if(isMore){
            if(mIsHeaderShow){
                //有头要减去头
                startIndex = mList.size() - 1;
            }else {
                startIndex = mList.size();
            }
        }

        //请求接口
        LiveRequestOperator.getInstance().GetProgramList(mProgramSortType, startIndex, STEP_PAGE_SIZE, new OnGetProgramListCallback() {
            @Override
            public void onGetProgramList(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem[] array) {
                Log.d(TAG,"onGetProgramList-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" array.length:"+(null == array? 0 : array.length));
                //回调界面
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, array);
                Message msg = Message.obtain();
                msg.what = GET_PROGRAMMES_LIST_CALLBACK;
                msg.arg1 = isMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
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
                boolean isMore = msg.arg1 == 1?true:false;
                //数据处理
                if(!isMore){
                    //下拉刷新

                    //成功才清空
                    //del by Jagger 2018-5-22 Samson说失败也清数据
//                    if(isSuccess){
                    mList.clear();

                    //add header
                    //列表头(其实是插入一条数据，mAdapter.getItemCount()会+1,注意插入时机)
                    if(response.isSuccess && mIsHeaderShow){
                        addIntroductionView();
                    }
//                    }
                }

                //判空处理
                if(response.data != null){
                    ProgramInfoItem[] array = (ProgramInfoItem[])response.data;

                    mList.addAll(Arrays.asList(array));
                    //排序，StartTime从近到远
                    if(mIsGroupByStartTime){
                        Collections.sort(mList, mComparatorList);
                    }
                    //是否需显示“更多”
                    if(array.length < STEP_PAGE_SIZE){
                        mIsShowMore = false;
                    }else {
                        mIsShowMore = true;
                    }
                }else {
                    //返回 无数据也不要“更多”
                    mIsShowMore = false;
                }

                //界面处理
                hideLoadingProcess();

                //刷新界面
                mAdapter.notifyDataSetChanged();

                //
                isNeedRefresh = false;

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
                        isNeedRefresh = true;
                        return;
                    }
                }

                if(mAdapter.getItemCount() == 0){
                    //无数据显示空页
                    showEmptyView();
                }else{
                    if(mAdapter.getItemCount() == 1){
                        //只有一条数据且它是描述时
                        boolean hasIntroductionButProgramme = true;
                        for(ProgramInfoItem programInfoItem:mList){
                            if(programInfoItem.type == ProgramInfoItem.TYPE.Programme.ordinal()){
                                hasIntroductionButProgramme = false;
                            }
                        }

                        //显示空页
                        if(hasIntroductionButProgramme){
                            showEmptyView();
                        }
                    }else{
                        //有数据 且 不是更多, 才开始本地倒计时
                        if(msg.arg1 == 0){
                            //add by Jagger 2018-5-24 BUG#11063 刷新后回到顶部
                            refreshRecyclerView.getRecyclerView().getLayoutManager().scrollToPosition(0);
                            doUpdateEnterTime();
                        }
                    }
                }

                //是否需要显示更多
                if(mIsShowMore){
                    closePullUpRefresh(false);
                }else {
                    closePullUpRefresh(true);
                }
            }
            break;
            case GET_TICKET_CALLBACK: {
                //隐藏loading
                DialogUIUtils.dismiss(mDialogLoading);

                if(response.isSuccess){
                    String programmeId = String.valueOf(response.data);
                    for (ProgramInfoItem item:mList) {
                        if(item.type == ProgramInfoItem.TYPE.Programme.ordinal() && item.showLiveId.equals(programmeId)){
                            item.ticketStatus = ProgramTicketStatus.Buy;
                            item.isHasFollow = true;
                            mAdapter.notifyDataSetChanged();
                            break;
                        }
                    }

                    DialogUIUtils.dismiss(mDialogGetTicket);

                    Toast.makeText(mContext.getApplicationContext() , mContext.getString(R.string.live_programme_get_ticket_success_tips) ,Toast.LENGTH_LONG ).show();
                }else {
                    if(response.errCode == HttpLccErrType.HTTP_LCC_ERR_NO_CREDIT.ordinal()){
                        if(getActivity() != null){
                            ((BaseFragmentActivity)getActivity()).showCreditNoEnoughDialog(R.string.live_programme_get_ticket_not_enough_money_tips);
                        }
                    }else{
                        if(!TextUtils.isEmpty(response.errMsg)){
                            Toast.makeText(mContext.getApplicationContext() , response.errMsg , Toast.LENGTH_LONG).show();
                        }
                    }
                }
            }break;
        }
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        if(null != getActivity()){
            showNodataPage();
        }
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
     * 添加列表头
     */
    private void addIntroductionView(){
        //不用这种方式 , 因为这样添加的头,会排在第一个分组名的下面
//        if(LoginManager.getInstance().getSynConfig() != null && !TextUtils.isEmpty(LoginManager.getInstance().getSynConfig().showDescription)){
//            View headerView = getActivity().getLayoutInflater().inflate(R.layout.view_live_calendar_list_header, null, false);
//
//            TextView tvDes = (TextView)headerView.findViewById(R.id.tv_introduction_des);
//            tvDes.setText(LoginManager.getInstance().getSynConfig().showDescription);
//
//            refreshRecyclerView.getRecyclerView().addHeaderView(headerView);
//        }

//        if(LoginManager.getInstance().getSynConfig() != null && !TextUtils.isEmpty(LoginManager.getInstance().getSynConfig().showDescription)){
            ProgramInfoItem item = new ProgramInfoItem();
            item.type = ProgramInfoItem.TYPE.Introduction.ordinal();
            //edit by Jagger 2018-11-1 改为写死 Samson已确认
            item.des = getString(R.string.live_program_des); //LoginManager.getInstance().getSynConfig().showDescription;
            mList.add(item);
//        }
    }

    @Override
    public void onDetailClicked(ProgramInfoItem programInfoItem) {
        //add by Jagger 2018-9-29
        //优先登录
        if(LoginManager.getInstance().getLoginStatus() != LoginManager.LoginStatus.Logined){
            RegisterActivity.launchRegisterActivity(mContext);
            return;
        }

        mContext.startActivity(LiveProgramDetailActivity.getProgramInfoIntent(mContext,
                getResources().getString(R.string.live_program_detail_title),
                programInfoItem.showLiveId,
                true));

        //GA统计MyOtherShows
        uploadGoogleAnalyticsData(getResources().getString(R.string.Live_Calendar_Category),
                getResources().getString(R.string.Live_Calendar_Action_OtherShows),
                getResources().getString(R.string.Live_Calendar_Label_OtherShows));
    }

    @Override
    public void onWatchClicked(ProgramInfoItem programInfoItem) {
        //add by Jagger 2018-9-29
        //优先登录
        if(LoginManager.getInstance().getLoginStatus() != LoginManager.LoginStatus.Logined){
            RegisterActivity.launchRegisterActivity(mContext);
            return;
        }

        mContext.startActivity(LiveRoomTransitionActivity.getProgramShowIntent(mContext,
                LiveRoomTransitionActivity.CategoryType.Enter_Program_Public_Room,
                programInfoItem.anchorId,
                programInfoItem.anchorNickname,
                programInfoItem.anchorAvatar,
                programInfoItem.showLiveId));
        //GA统计点击watch now
        uploadGoogleAnalyticsData(getResources().getString(R.string.Live_EnterBroadcast_Category),
                getResources().getString(R.string.Live_EnterBroadcast_Action_ShowBroadcast),
                getResources().getString(R.string.Live_EnterBroadcast_Label_ShowBroadcast));
    }

    @Override
    public void onGetTicketClicked(ProgramInfoItem item) {
        //add by Jagger 2018-9-29
        //优先登录
        if(LoginManager.getInstance().getLoginStatus() != LoginManager.LoginStatus.Logined){
            RegisterActivity.launchRegisterActivity(mContext);
            return;
        }

        doGetTicket(item);
        //GA统计点击买票
        uploadGoogleAnalyticsData(getResources().getString(R.string.Live_Calendar_Category),
                getResources().getString(R.string.Live_Calendar_Action_GetTicket),
                getResources().getString(R.string.Live_Calendar_Label_GetTicket));
    }

    /**
     * 购票确认弹窗
     */
    private void doGetTicket(final ProgramInfoItem item){
        if(mDialogGetTicket != null && mDialogGetTicket.isShowing()){
            return;
        }

        View rootView = View.inflate(mContext, R.layout.dialog_get_ticket, null);
        mDialogGetTicket = DialogUIUtils.showCustomAlert(mContext, rootView,
                null,
                null,
                Gravity.CENTER, true, true,
                null).show();
        //VIEW内事件
//        ImageView imgClose = (ImageView)rootView.findViewById(R.id.img_close) ;
//        imgClose.setOnClickListener(new View.OnClickListener() {

        // 2018/12/1 Hardy 增大点击面积
        View imgClose = rootView.findViewById(R.id.fl_close) ;
        imgClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                DialogUIUtils.dismiss(mDialogGetTicket);
            }
        });

        SimpleDraweeView imgAnchorAvatar = (SimpleDraweeView)rootView.findViewById(R.id.img_room_logo);
        imgAnchorAvatar.setImageURI(item.anchorAvatar);

        TextView tvTitle = (TextView)rootView.findViewById(R.id.txtRoomTitle);
        tvTitle.setText(item.showTitle);

        TextView tvPrice  = (TextView)rootView.findViewById(R.id.txtPrice);
        tvPrice.setText(mContext.getString(R.string.live_credits , String.valueOf(item.price)));

        ButtonRaised btnGet = (ButtonRaised)rootView.findViewById(R.id.btn_get_ticket);
        btnGet.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                DialogUIUtils.dismiss(mDialogGetTicket);
                //add by Jagger 2018-5-24 BUG#11062 加个Loading
                mDialogLoading = DialogUIUtils.showLoading(mContext , "" , true , false , false , false).show();
                //请求接口
                doGetTicketRequest(item.showLiveId);
                //GA统计点击确认买票
                uploadGoogleAnalyticsData(getResources().getString(R.string.Live_Calendar_Category),
                        getResources().getString(R.string.Live_Calendar_Action_GetTicket_Confirm),
                        getResources().getString(R.string.Live_Calendar_Label_GetTicket_Confirm));
            }
        });
    }

    /**
     * 执行购买请求
     * @param programmeId
     */
    private void doGetTicketRequest(final String programmeId){
        //请求接口
        LiveRequestOperator.getInstance().BuyProgram(programmeId, new OnBuyProgramCallback() {
            @Override
            public void onBuyProgram(boolean isSuccess, int errCode, String errMsg, double leftCredit) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, programmeId);
                Message msg = Message.obtain();
                msg.what = GET_TICKET_CALLBACK;
                msg.obj = response;

                sendUiMessage(msg);
            }
        });
    }

    /**
     * 提交点击GA统计
     * @param category
     * @param action
     * @param label
     */
    private void uploadGoogleAnalyticsData(String category, String action, String label){
        Activity activity = getActivity();
        if(activity != null && activity instanceof AnalyticsFragmentActivity){
            ((AnalyticsFragmentActivity)activity).onAnalyticsEvent(category, action, label);
        }
    }

    /**
     * 列表按开始时间排序
     */
    public class ComparatorStartTimeHighToLow implements Comparator<ProgramInfoItem> {

        @Override
        public int compare(ProgramInfoItem itemBean1, ProgramInfoItem itemBean2) {

            if(itemBean1.startTime > itemBean2.startTime){
                return 1;
            }
            else if(itemBean1.startTime < itemBean2.startTime){
                return -1;
            }
            else{
                return 0;
            }
        }
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        //
        refreshByData(false);
    }

    @Override
    public void onLogout(boolean isMannual) {
        //
        refreshByData(false);
    }
}
