package com.qpidnetwork.anchor.liveshow.liveroom.gift.dialog;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.canadapter.CanAdapter;
import com.qpidnetwork.anchor.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.anchor.framework.widget.NoScrollGridView;
import com.qpidnetwork.anchor.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutGiftListItem;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.GiftLimitNumItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.anchor.liveshow.liveroom.BaseHangOutLiveRoomActivity;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.HangOutGiftSender;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.HangoutRoomGiftManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.anchor.liveshow.model.http.HttpReqStatus;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.view.ScrollLayout;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 HangoutRoomGiftManager 直播间对应礼物列表
 * Created by Hunter Mun on 2017/6/16.
 */
public class HangOutGiftDialog extends Dialog implements View.OnClickListener,HangOutGiftSender.HangOutGiftSendResultListener{

    private final String TAG = HangOutGiftDialog.class.getSimpleName();
    private WeakReference<BaseHangOutLiveRoomActivity> mActivity;
    private View fl_giftDialogRootView;
    private View fl_giftDialogContainer;
    private FrameLayout fl_giftPageContainer;
    private FrameLayout fl_giftListContainer;
    private ScrollLayout sl_giftPagerContainer;

    //tabs
    private TabPageIndicator tpi_tabs;

    private List<CanAdapter> giftAdapters = new ArrayList<>();
    //indicator
    private LinearLayout ll_indicator;
    //提示
    private LinearLayout ll_loading;
    private LinearLayout ll_emptyData;
    private TextView tvEmptyDesc;
    private LinearLayout ll_errorRetry;
    private TextView tv_errerReload;
    //dialog和adapters共用的数据
    private GiftItem lastSelectedGiftItem = null;//用于礼物发送、连送动画逻辑展示
    private long lastGiftSendTime = 0l;
    private Map<String,GiftItem> giftItemMap = new HashMap<>();
    private List<GiftItem> barCounterGiftItems = new ArrayList<>();
    private List<GiftItem> storeGiftItems = new ArrayList<>();
    private List<GiftItem> celebGiftItems = new ArrayList<>();
    private Map<String,GiftLimitNumItem> limitGiftNumMap = new HashMap<>();

    private IMHangoutRoomItem imHangoutRoomItem;
    private boolean hasHangOutGiftDataChanged = false;

    //dialog属性
    private int dialogMaxHeight = 0;
    private int gridViewHeight;
    private int gridViewItemWidth;
    private int pageCount;
    private int currPageIndex = 0;
    //每页显示多少个item
    private int barAndStoreGiftNumPerPage = 0;
    private int celebGiftNumPerPage = 0;
    //每一列显示多少个item
    private int barAndStoreGiftColumnNumPerPage = 0;
    private int celebGiftColumnNumPerPage = 0;
    private boolean notFirstDialogShow = false;
    private View rootView;

    private int lastSelectedTabIndex = 0;
    private int celebHorizontalSpacing = 0;
    private int lineNum = 0;

    private int celebGiftItemViewHeight;
    private int barGiftItemViewHeight;
    private int celebGiftItemViewWidth;
    private int barGiftItemViewWidth;

    //增加房间礼物管理器
    private HangoutRoomGiftManager mHangoutRoomGiftManager;

    public HangOutGiftDialog(BaseHangOutLiveRoomActivity context, HangoutRoomGiftManager hangoutRoomGiftManager){
        super(context, R.style.CustomTheme_LiveGiftDialog);
        this.mActivity = new WeakReference<>(context);
        mHangoutRoomGiftManager = hangoutRoomGiftManager;
        //计算定时器间隔
        barAndStoreGiftNumPerPage = getContext().getResources().getInteger(R.integer.giftNumPerPage);
        barAndStoreGiftColumnNumPerPage = getContext().getResources().getInteger(R.integer.giftColumnNumPerPage);
        celebGiftNumPerPage = getContext().getResources().getInteger(R.integer.celebGiftNumPerPage);
        celebGiftColumnNumPerPage = getContext().getResources().getInteger(R.integer.celebGiftColumnNumPerPage);
        int lineCount = barAndStoreGiftNumPerPage / barAndStoreGiftColumnNumPerPage;
        gridViewHeight = DisplayUtil.getScreenWidth(mActivity.get())/lineCount;
        celebHorizontalSpacing = DisplayUtil.dip2px(mActivity.get(),26f);

        View celebGiftItemView = View.inflate(mActivity.get(),R.layout.item_giftlist_dialog_hangout_celeb,null);
        celebGiftItemView.measure(0,0);
        celebGiftItemViewHeight = celebGiftItemView.getMeasuredHeight();
        celebGiftItemViewWidth = celebGiftItemView.getMeasuredWidth();
        View barGiftItemView = View.inflate(mActivity.get(),R.layout.item_giftlist_dialog_hangout_barnormal,null);
        barGiftItemView.measure(0,0);
        barGiftItemViewHeight = barGiftItemView.getMeasuredHeight();
        barGiftItemViewWidth = barGiftItemView.getMeasuredWidth();
        Log.d(TAG,"onCreate-celebGiftItemViewHeight:"+ celebGiftItemViewHeight
                +" celebGiftItemViewWidth:"+ celebGiftItemViewWidth
                +" barGiftItemViewHeight:"+barGiftItemViewHeight
                +" barGiftItemViewWidth:"+barGiftItemViewWidth);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);
        rootView = View.inflate(getContext(),R.layout.view_live_gift_dialog_hangout,null);
        setContentView(rootView);
        initView(rootView);
    }

    private void initView(View rootView){
        Log.d(TAG,"initView");
        fl_giftDialogRootView = rootView.findViewById(R.id.fl_giftDialogRootView);
        fl_giftDialogRootView.setOnClickListener(this);
        fl_giftDialogContainer = rootView.findViewById(R.id.fl_giftDialogContainer);
        fl_giftDialogContainer.setOnClickListener(this);
        sl_giftPagerContainer = (ScrollLayout) rootView.findViewById(R.id.sl_giftPagerContainer);
        sl_giftPagerContainer.setOnScreenChangeListener(new ScrollLayout.OnScreenChangeListener() {
            @Override
            public void onScreenChange(int currentIndex) {
                updateIndicatorStatus(currentIndex);
            }
        });
        tpi_tabs = (TabPageIndicator) rootView.findViewById(R.id.tpi_tabs);
        //设置控件的模式
        tpi_tabs.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_NOWEIGHT_NOEXPAND_SAME);
        tpi_tabs.setTitles(mActivity.get().getResources().getStringArray(R.array.hangout_gift_tabs));
        tpi_tabs.setOnTabClickListener(new TabPageIndicator.OnTabClickListener() {
            @Override
            public void onTabClicked(int position, String title) {
                Log.d(TAG,"onTabClicked-position:"+position+" title:"+title);
                if(position != lastSelectedTabIndex){
                    lastSelectedTabIndex = position;
                    lastSelectedGiftItem = null;
                    updateGiftView();
                }
            }
        });
        ll_indicator = (LinearLayout) rootView.findViewById(R.id.ll_indicator);
        fl_giftPageContainer = (FrameLayout) rootView.findViewById(R.id.fl_giftPageContainer);
        fl_giftListContainer = (FrameLayout) rootView.findViewById(R.id.fl_giftListContainer);
        ll_loading = (LinearLayout) rootView.findViewById(R.id.ll_loading);
        ll_loading.setVisibility(View.GONE);
        ll_emptyData = (LinearLayout) rootView.findViewById(R.id.ll_emptyData);
        tvEmptyDesc = (TextView) rootView.findViewById(R.id.tvEmptyDesc);
        ll_emptyData.setVisibility(View.GONE);
        ll_errorRetry = (LinearLayout) rootView.findViewById(R.id.ll_errorRetry);
        ll_errorRetry.setVisibility(View.GONE);
        tv_errerReload = (TextView) rootView.findViewById(R.id.tv_errerReload);
        tv_errerReload.setOnClickListener(this);
        updateGiftView();
    }

    public void show() {
        Log.d(TAG,"show-hasHangOutGiftDataChanged:"+hasHangOutGiftDataChanged);
        super.show();
        if(notFirstDialogShow && hasHangOutGiftDataChanged){
            updateGiftView();
        }
        hasHangOutGiftDataChanged = false;
        notFirstDialogShow = true;
        showDataTipsView();
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG,"dismiss");
    }

    @Override
    public void dismiss() {
        Log.d(TAG,"dismiss");
        super.dismiss();
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        Log.d(TAG,"onWindowFocusChanged-hasFocus:"+hasFocus);
        if (!hasFocus && dialogMaxHeight>0) {
            return;
        }
        setHeight();
    }

    private void setHeight() {
        Window window = getWindow();
        window.setGravity(Gravity.BOTTOM);
        WindowManager.LayoutParams attributes = window.getAttributes();
        attributes.height = dialogMaxHeight;
        attributes.width = WindowManager.LayoutParams.MATCH_PARENT;
        window.setAttributes(attributes);
    }

    /**
     * 展示错误提示界面，应该在tab点击的时候，判断展示
     */
    private void showDataTipsView(){
        if(null == imHangoutRoomItem){
            //刷新之中
            showDataTipsViewByStatus(true,false,false);
            return;
        }
        List<GiftItem> giftList = null;
        if(0 == lastSelectedTabIndex){
            giftList = barCounterGiftItems;
        }else if(1 == lastSelectedTabIndex){
            giftList = storeGiftItems;
        }else{
            giftList = celebGiftItems;
        }
        if(null == giftList || giftList.size()==0){
            HttpReqStatus sendableGiftReqStatus = mHangoutRoomGiftManager.getRoomGiftRequestStatus();
            if(HttpReqStatus.Reqing == sendableGiftReqStatus){
                //刷新之中
                showDataTipsViewByStatus(true,false,false);
            } else if(HttpReqStatus.ResFailed == sendableGiftReqStatus){
                //加载出错
                showDataTipsViewByStatus(false,false,true);
            }else{
                //没有数据
                showDataTipsViewByStatus(false,true,false);
            }
        }else{
            showDataTipsViewByStatus(false,false,false);
        }
    }

    /**
     * 展示当前数据获取请求状态
     * @param isLoading
     * @param isEmpty
     * @param isError
     */
    private void showDataTipsViewByStatus(boolean isLoading, boolean isEmpty, boolean isError){
        ll_loading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
        ll_emptyData.setVisibility(isEmpty ? View.VISIBLE : View.GONE);
        if(isEmpty && tvEmptyDesc != null){
            tvEmptyDesc.setText(R.string.hangout_gift_empty);
        }
        ll_errorRetry.setVisibility(isError ? View.VISIBLE : View.GONE);
    }

    /**
     * 更新礼物展示界面
     */
    @SuppressLint("NewApi")
    private void updateGiftView(){
        Log.d(TAG,"updateGiftView");
        List<GiftItem> listData = refreshGiftDataOnView();
        setViewLayoutParams();
        //更新礼物页的选中状态，默认选中第一个
        if(giftAdapters.size()>0){
            showDataTipsViewByStatus(false,false,false);
            if(null == lastSelectedGiftItem){
                lastSelectedGiftItem = (GiftItem) giftAdapters.get(0).getList().get(0);
            }
            //计算当前页的索引,切换
            int currPageSelectedIndex = listData.indexOf(lastSelectedGiftItem)/ barAndStoreGiftNumPerPage;
            updateIndicatorStatus(currPageSelectedIndex);
            sl_giftPagerContainer.setToScreen(currPageSelectedIndex);
            //更新礼物选中状态
            updateItemViewSelectedStatus();
        }else{
            showDataTipsViewByStatus(false,true,false);
        }
    }

    private void setViewLayoutParams() {
        Log.d(TAG,"setViewLayoutParams");
        updateIndicatorView(pageCount);
        //设置礼物列表滑动组件的实际高度
        FrameLayout.LayoutParams sl_lp = (FrameLayout.LayoutParams)sl_giftPagerContainer.getLayoutParams();
        sl_lp.height = gridViewHeight;
        sl_giftPagerContainer.setLayoutParams(sl_lp);

        //fl_giftListContainer包裹内容
        FrameLayout.LayoutParams giftListLp = (FrameLayout.LayoutParams)fl_giftListContainer.getLayoutParams();
        giftListLp.height = gridViewHeight;
        giftListLp.gravity = Gravity.TOP;
        //bar/store礼物，sl_giftPagerContainer高度等于fl_giftListContainer，
        // fl_giftPageContainer高度等于barGiftItemViewHeight*2+35dp
        //celeb礼物时，sl_giftPagerContainer高度等于fl_giftListContainer，
        // fl_giftPageContainer高度等于barGiftItemViewHeight*2+35dp
        //但是fl_giftListContainer的高度<barGiftItemViewHeight*2 所以需要居中显示
        int lineCount = barAndStoreGiftNumPerPage / barAndStoreGiftColumnNumPerPage;
        gridViewHeight = lineCount*barGiftItemViewHeight;
        giftListLp.topMargin = 2 == lastSelectedTabIndex ? (gridViewHeight-giftListLp.height)/2 : 0;
        Log.d(TAG,"setViewLayoutParams-giftListLp.height:"+giftListLp.height+" giftListLp.topMargin:"+giftListLp.topMargin);
        //将fl_giftPageContainer高度设置为(屏幕宽度一半+35dp)
        FrameLayout.LayoutParams giftPageContainerLp = (FrameLayout.LayoutParams) fl_giftPageContainer.getLayoutParams();
        giftPageContainerLp.height = gridViewHeight+DisplayUtil.dip2px(mActivity.get(),35f);
        Log.d(TAG,"setViewLayoutParams-giftPageContainerLp.height:"+giftPageContainerLp.height);

        FrameLayout.LayoutParams llLoadingLp = (FrameLayout.LayoutParams) ll_loading.getLayoutParams();
        llLoadingLp.height = giftPageContainerLp.height;
        Log.d(TAG,"setViewLayoutParams-llLoadingLp.height:"+llLoadingLp.height);

        FrameLayout.LayoutParams llErrorRetryLp = (FrameLayout.LayoutParams) ll_errorRetry.getLayoutParams();
        llErrorRetryLp.height = giftPageContainerLp.height;
        Log.d(TAG,"setViewLayoutParams-llErrorRetryLp.height:"+llErrorRetryLp.height);
        //设置dialog的实际高度
        dialogMaxHeight = giftPageContainerLp.height+giftPageContainerLp.topMargin;
        FrameLayout.LayoutParams fl_lp = (FrameLayout.LayoutParams) fl_giftDialogContainer.getLayoutParams();
        fl_lp.height = dialogMaxHeight;
        Log.d(TAG,"setViewLayoutParams-fl_lp.height:"+fl_lp.height);
    }

    @NonNull
    private List<GiftItem> refreshGiftDataOnView() {
        List<GiftItem> listData = null;
        int numPerPage = 0;
        int numPerLine = 0;

        if(0 == lastSelectedTabIndex){
            listData = barCounterGiftItems;
            numPerPage = barAndStoreGiftNumPerPage;
            numPerLine = barAndStoreGiftColumnNumPerPage;
            gridViewItemWidth = DisplayUtil.getScreenWidth(mActivity.get())/ numPerPage;
        }else if(1 == lastSelectedTabIndex){
            listData = storeGiftItems;
            numPerPage = barAndStoreGiftNumPerPage;
            numPerLine = barAndStoreGiftColumnNumPerPage;
            gridViewItemWidth = DisplayUtil.getScreenWidth(mActivity.get())/ numPerPage;
        }else{
            listData = celebGiftItems;
            numPerPage = celebGiftNumPerPage;
            numPerLine = celebGiftColumnNumPerPage;
        }
        lineNum = numPerPage/numPerLine;
        gridViewHeight = 2 == lastSelectedTabIndex ? lineNum*celebGiftItemViewHeight : lineNum*barGiftItemViewHeight;
        pageCount = (listData.size()/ numPerPage)+ (0 == listData.size()% numPerPage ? 0 : 1);
        Log.d(TAG,"refreshGiftDataOnView-listData.size:"+ listData.size()
                +" pageCount:"+pageCount +" numPerPage:"+ numPerPage+" numPerLine:"+numPerLine
                +" gridViewHeight:"+gridViewHeight+" lastSelectedTabIndex:"+lastSelectedTabIndex
                +" lineNum:"+lineNum);
        sl_giftPagerContainer.removeAllViews();
        giftAdapters.clear();
        NoScrollGridView gridView = null;
        for(int index=0 ; index<pageCount; index++){
            gridView = (NoScrollGridView) View.inflate(mActivity.get(), R.layout.item_simple_gridview_1,null);
            int maxPagePosition = numPerPage *(index+1);
            final HangOutGiftAdapter<GiftItem> giftAdapter = new HangOutGiftAdapter(mActivity.get(),
                    2 == lastSelectedTabIndex ? R.layout.item_giftlist_dialog_hangout_celeb
                            : R.layout.item_giftlist_dialog_hangout_barnormal,
                    listData.subList(numPerPage *index, maxPagePosition< listData.size() ?
                            maxPagePosition : listData.size()));
            giftAdapter.setOnItemListener(new CanOnItemListener(){
                @Override
                public void onItemChildClick(View view, int position) {
                    GiftItem selectedGiftItem = (GiftItem) giftAdapter.getList().get(position);
                    Log.d(TAG,"refreshGiftDataOnView-onItemChildClick position:"+position
                            +" selectedGiftItem.id:"+selectedGiftItem.id
                            +" selectedGiftItem.name:"+selectedGiftItem.name
                            +" selectedGiftItem.giftType:"+selectedGiftItem.giftType);
                    boolean diffGift = selectedGiftItem != lastSelectedGiftItem;
                    lastSelectedGiftItem = selectedGiftItem;
                    if(diffGift){
                        //更改选中状态
                        updateItemViewSelectedStatus();
                    }
                    sendGift(lastSelectedGiftItem,diffGift);

                }
            });
            gridView.setAdapter(giftAdapter);
            giftAdapters.add(giftAdapter);
            gridView.setNumColumns(numPerLine);// 每行显示几个
            gridView.setGravity(Gravity.CENTER);
            gridView.setHorizontalSpacing(2 == lastSelectedTabIndex ? celebHorizontalSpacing : 0);
            if(2 != lastSelectedTabIndex){
                gridView.setColumnWidth(gridViewItemWidth);
                gridView.setHorizontalSpacing(0);
            }else{
                gridView.setColumnWidth(celebGiftItemViewWidth);
                gridView.setHorizontalSpacing(celebHorizontalSpacing);
            }
            gridView.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
            gridView.measure(0,0);
            ViewGroup.LayoutParams gridViewLp = new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,gridViewHeight);
            sl_giftPagerContainer.addView(gridView,gridViewLp);
        }
        return listData;
    }

    /**
     * 更新选中状态
     */
    private void updateItemViewSelectedStatus(){
        HangOutGiftAdapter.selectedGiftItem = lastSelectedGiftItem;
        //更新选中状态
        for(CanAdapter adapter : giftAdapters){
            adapter.notifyDataSetChanged();
        }
    }

    private View.OnClickListener onIndicViewClickListener;

    /**
     * 更新指示器图标数量展示，当礼物数量发生变动的时候调用
     * @param pageCount 礼物页数
     */
    private void updateIndicatorView(int pageCount){
        ll_indicator.removeAllViews();
        int endIndex = pageCount-1;
        int indicatorWidth = DisplayUtil.dip2px(mActivity.get(),6f);
        int indicatorMargin = DisplayUtil.dip2px(mActivity.get(),4f);
        if(null == onIndicViewClickListener){
            onIndicViewClickListener = new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Integer index = (Integer)v.getTag();
                    Log.d(TAG,"updateIndicatorView-onClick-index:"+index.intValue());
                    sl_giftPagerContainer.setToScreen(index.intValue());
                }
            };
        }

        for(int index=0; index<pageCount; index++){
            ImageView indicator = new ImageView(getContext());
            LinearLayout.LayoutParams lp_indicator =
                    new LinearLayout.LayoutParams(indicatorWidth, indicatorWidth);
            lp_indicator.gravity = Gravity.CENTER;
            lp_indicator.leftMargin = 0 == index ? 0 : indicatorMargin;//px 需要转换成dip单位
            lp_indicator.rightMargin = endIndex == index ? 0 : indicatorMargin;
            indicator.setLayoutParams(lp_indicator);
            indicator.setBackgroundDrawable(mActivity.get()
                    .getResources().getDrawable(R.drawable.selector_hangout_gift_indicator));
            indicator.setTag(index);
            indicator.setOnClickListener(onIndicViewClickListener);
            ll_indicator.addView(indicator);
        }
    }

    /**
     * 更新指示器状态
     * @param selectedIndex 当前礼物页索引
     */
    private void updateIndicatorStatus(int selectedIndex){
        currPageIndex = selectedIndex;
        int pageCount = ll_indicator.getChildCount();
        for(int index = 0; index<pageCount; index++){
            View view = ll_indicator.getChildAt(index);
            if(null != view && View.VISIBLE == view.getVisibility()){
                view.setSelected(selectedIndex == index);
            }
        }
    }

    /**
     * 送礼(调接口)
     */
    private synchronized void sendGift(GiftItem giftItem, boolean diffGift){
        Log.d(TAG,"sendGift-giftItem:"+giftItem+" diffGift:"+diffGift);
        if(null == giftItem){
            return;
        }
        //对gift是否为normal的判断加不加没有影响应该，但是为了保持同ios男士端做法一直，加上
        boolean isRepeat = giftItem.giftType == GiftItem.GiftType.Normal && giftItem.canMultiClick
                && !diffGift && (System.currentTimeMillis()- lastGiftSendTime)<=3000l;
        if(limitGiftNumMap.containsKey(giftItem.id) && null != mActivity && null !=mActivity.get() && null != mActivity.get().mIMHangOutRoomItem){
            HangOutGiftSender.getInstance().sendHangOutGift(giftItem, isRepeat, mActivity.get().mIMHangOutRoomItem.manId,
                    mActivity.get().mIMHangOutRoomItem.manNickName,1, false,false,this);
            lastGiftSendTime = System.currentTimeMillis();
        }
    }

    public void notifyGiftSentFailed(){
        Log.d(TAG,"notifyGiftSentFailed");
    }

    @Override
    public void onClick(View view){
        int i = view.getId();
        if (i == R.id.tv_errerReload) {
            if (null != mActivity && mActivity.get() != null) {
                mActivity.get().reloadLimitGiftData();
            }
            showDataTipsView();
        } else if (i == R.id.fl_giftDialogRootView) {
            dismiss();

        }
    }

    //------------------------数据处理方法------------------------------------------
    /**
     * 通知界面背包列表数据发生更改
     */
    public void notifyHangOutGiftDataChanged(){
        Log.d(TAG,"notifyHangOutGiftDataChanged");
        updateHangOutRoomGiftData();
        //界面展示为loading、empty、error-reload则更新界面展示
        hasHangOutGiftDataChanged = true;
        if(isShowing()){
            updateGiftView();
            showDataTipsView();
            hasHangOutGiftDataChanged = false;
        }
        Log.d(TAG,"notifyHangOutGiftDataChanged-hasHangOutGiftDataChanged:"+hasHangOutGiftDataChanged);
    }

    /**
     * 更新背包礼物列表
     */
    private void updateHangOutRoomGiftData(){
        synchronized (giftItemMap){
            //更新数据
            AnchorHangoutGiftListItem anchorHangoutGiftListItem = mHangoutRoomGiftManager.getLoaclHangoutGiftItem();
            barCounterGiftItems.clear();
            storeGiftItems.clear();
            celebGiftItems.clear();
            limitGiftNumMap.clear();
            giftItemMap.clear();
            GiftItem giftItem = null;
            if(null == anchorHangoutGiftListItem){
                return;
            }
            NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
            if(null != anchorHangoutGiftListItem.buyforList){
                for(GiftLimitNumItem item : anchorHangoutGiftListItem.buyforList){
                    if(item.giftNum>0){
                        limitGiftNumMap.put(item.giftId,item);
                        giftItem = normalGiftManager.getLocalGiftDetail(item.giftId);
                        if(null != giftItem){
                            barCounterGiftItems.add(giftItem);
                            giftItemMap.put(giftItem.id,giftItem);
                        }else{
                            //礼物详情不在，本地刷新
                            normalGiftManager.getGiftDetail(item.giftId, null);
                        }
                    }

                }
            }
            if(null != anchorHangoutGiftListItem.normalList){
                for(GiftLimitNumItem item : anchorHangoutGiftListItem.normalList){
                    if(item.giftNum>0){
                        limitGiftNumMap.put(item.giftId,item);
                        giftItem = normalGiftManager.getLocalGiftDetail(item.giftId);
                        if(null != giftItem){
                            storeGiftItems.add(giftItem);
                            giftItemMap.put(giftItem.id,giftItem);
                        }else{
                            //礼物详情不在，本地刷新
                            normalGiftManager.getGiftDetail(item.giftId, null);
                        }
                    }
                }
            }
            if(null != anchorHangoutGiftListItem.celebrationList){
                for(GiftLimitNumItem item : anchorHangoutGiftListItem.celebrationList){
                    if(item.giftNum>0){
                        limitGiftNumMap.put(item.giftId,item);
                        giftItem = normalGiftManager.getLocalGiftDetail(item.giftId);
                        if(null != giftItem){
                            celebGiftItems.add(giftItem);
                            giftItemMap.put(giftItem.id,giftItem);
                        }else{
                            //礼物详情不在，本地刷新
                            normalGiftManager.getGiftDetail(item.giftId, null);
                        }
                    }
                }
            }
            HangOutGiftAdapter.giftLimitNumItemMap = limitGiftNumMap;
        }
    }

    public void setImHangoutRoomItem(IMHangoutRoomItem imHangoutRoomItem){
        this.imHangoutRoomItem = imHangoutRoomItem;
        if(isShowing()){
            if(null != giftAdapters){
                for (CanAdapter giftAdapter : giftAdapters){
                    giftAdapter.notifyDataSetChanged();
                }
            }
        }

    }

    /**
     * 对dialog本地背包礼物的数量数据执行减法
     * @param giftId
     * @param subNum
     * @return
     */
    public synchronized boolean subHangOutGiftNumById(String giftId, int subNum){
        boolean result = false;
        if(limitGiftNumMap.containsKey(giftId) && giftItemMap.containsKey(giftId)){
            GiftLimitNumItem giftLimitNumItem = limitGiftNumMap.get(giftId);
            giftLimitNumItem.giftNum-=subNum;
            if(giftLimitNumItem.giftNum>0){
                limitGiftNumMap.put(giftId,giftLimitNumItem);
            }else{
                limitGiftNumMap.remove(giftId);
                GiftItem delGiftItem = null;
                delGiftItem = giftItemMap.remove(giftId);
                if(null != barCounterGiftItems && barCounterGiftItems.contains(delGiftItem)){
                    barCounterGiftItems.remove(delGiftItem);
                }
                if(null != storeGiftItems && storeGiftItems.contains(delGiftItem)){
                    storeGiftItems.remove(delGiftItem);
                }
                if(null != celebGiftItems && celebGiftItems.contains(delGiftItem)){
                    celebGiftItems.remove(delGiftItem);
                }
            }
            result = true;
        }
        Log.d(TAG,"subHangOutGiftNumById-result:"+result);
        return result;
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        Log.d(TAG,"onBackPressed");
    }

    private boolean outSizeTouchHasChecked = false;

    public void setOutSizeTouchHasChecked(boolean outSizeTouchHasChecked){
        this.outSizeTouchHasChecked = outSizeTouchHasChecked;
    }

    @Override
    public boolean onTouchEvent(@NonNull MotionEvent event) {
        Log.d(TAG,"onTouchEvent-event.action:"+event.getAction());
        if (MotionEvent.ACTION_OUTSIDE == event.getAction() && !outSizeTouchHasChecked) {
            if(isShowing()){
                dismiss();
            }
            return true;
        }

        return super.onTouchEvent(event);
    }

    private int getTabIndexByGiftType(GiftItem.GiftType giftType){
        int tabIndex = 0;
        if(GiftItem.GiftType.Bar == giftType){
            tabIndex = 0;
        }else if(GiftItem.GiftType.Celebrate == giftType){
            tabIndex = 2;
        }else{
            tabIndex = 1;
        }
        Log.d(TAG,"getTabIndexByGiftType-giftType:"+giftType+" tabIndex:"+tabIndex);
        return tabIndex;
    }

    @Override
    public void onHangOutGiftReqSent(GiftItem giftItem, HangOutGiftSender.ErrorCode errorCode,
                                     String message, boolean isRepeat, int sendNum) {
        Log.d(TAG,"onHangOutGiftReqSent-giftItem.id:"+giftItem.id+" errorCode:"+errorCode
                +" message:"+message+" isRepeat:"+isRepeat+" giftNum:"+sendNum);
        if(HangOutGiftSender.ErrorCode.SUCCESS.equals(errorCode)){
            subHangOutGiftNumById(giftItem.id,sendNum);
            //更新礼物页的选中状态，默认选中第一个
            if(limitGiftNumMap.size()>=0 && lastSelectedTabIndex == getTabIndexByGiftType(giftItem.giftType)){
                if(!limitGiftNumMap.containsKey(giftItem.id)){
                    //如果该礼物送光了 并且此时tab还停留在礼物对应的tab位置
                    //更新gift列表
                    refreshGiftDataOnView();
                    //更新指示器数量
                    updateIndicatorView(pageCount);
                    //更新默认选择的礼物的可发送数量
                    if(null != giftAdapters && giftAdapters.size()>0){
                        lastSelectedGiftItem = (GiftItem) giftAdapters.get(0).getList().get(0);
                        //更新item的选中状态
                        updateItemViewSelectedStatus();
                        //更新指示器的选中状态
                        updateIndicatorStatus(0);
                        sl_giftPagerContainer.setToScreen(0);
                        Log.d(TAG,"onHangOutGiftReqSent-lastSelectedGiftItem.name:"+lastSelectedGiftItem.name
                                +" lastSelectedGiftItem.id:"+lastSelectedGiftItem.id);
                    }else{
                        lastSelectedGiftItem = null;
                        showDataTipsViewByStatus(false,true,false);
                    }
                }else{
                    //更新指定gift的totalNum
                    if(currPageIndex<giftAdapters.size()){
                        HangOutGiftAdapter giftAdapter = (HangOutGiftAdapter) giftAdapters.get(currPageIndex);
                        giftAdapter.notifyDataSetChanged();
                    }
                }
            }
        }
    }
}
