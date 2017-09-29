package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.TextUtils;
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
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.BaseCommonLiveRoomActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftTab;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.PackageGiftManager;
import com.qpidnetwork.livemodule.liveshow.model.HttpReqStatus;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.TestDataUtil;
import com.qpidnetwork.livemodule.view.AudienceBalanceInfoPopupWindow;
import com.qpidnetwork.livemodule.view.ScrollLayout;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftTab.giftTabs;

public class LiveGiftDialog extends Dialog implements View.OnClickListener,GiftSender.GiftSendResultListener{

    private final String TAG = LiveGiftDialog.class.getSimpleName();
    private WeakReference<BaseCommonLiveRoomActivity> mActivity;
    //tab
    private View ll_StoreGiftTab;
    private ImageView iv_StoreGiftTab;
    private TextView tv_StoreGiftTab;
    private View ll_PkgGiftTab;
    private ImageView iv_PkgGiftTab;
    private TextView tv_PkgGiftTab;

    private View fl_giftDialogRootView;

    //gift list
    private View fl_giftDialogContainer;
    private LinearLayout ll_giftPageContainer;
    private ScrollLayout sl_giftPagerContainer;
    private List<GiftAdapter> giftAdapters = new ArrayList<>();
    //gift send count selector
    private View ll_countChooser;
    private ListView lv_giftCount;
    private TextView tv_giftCount;
    private ImageView iv_countIndicator;
    private GiftCountSelectorAdapter giftCountSelectorAdapter;
    //gift send view
    private TextView tv_sendGift;
    private View ll_sendGift;
    private LinearLayout ll_repeatSendAnim;
    private boolean isSendGiftUnUsable = false;
    //indicator
    private LinearLayout ll_indicator;
    //提示
    private LinearLayout ll_loading;
    private LinearLayout ll_emptyData;
    private LinearLayout ll_errorRetry;
    private TextView tv_reloadGiftList;
    //dialog和adapters共用的数据
    private List<GiftItem> giftItems = new ArrayList<>();
    public static GiftItem lastSelectedGiftItem = null;
    private List<GiftItem> packagGiftItems = new ArrayList<>();
    private Map<String,SendableGiftItem> sendableGiftItemMap = new HashMap<>();
    private Map<String,GiftItem> packageGiftIdItems = new HashMap<>();
    private Map<String,Integer> packageGiftNums = new HashMap<>();
    private GiftItem lastRepeatSentGiftItem = null;
    private GiftTab.GiftTabFlag lastClickedGiftTab = null;
    private IMRoomInItem imRoomInItem;
    private int lastGiftSendNum = 0;

    //定时器相关
    private TextView tv_timeCount;
    private long periodTime = 0;    //定时器时间间隔
    private int mLastRepeatCount = 0;   //dialog取消时，当前停留的位置
    private long mLastDismissTime = 0;   //用于Dialog重现显示，恢复之前的连击动画
    private GiftRepeatSendTimerManager timerManager;
    //dialog属性
    private int dialogMaxHeight = 0;
    private int lineCount;
    private int gridViewHeight;
    private int gridViewItemWidth;
    private int pageCount;
    private int currPageIndex = 0;
    private int giftNumPerPage = 0;
    private int giftColumnNumPerPage = 0;

    private boolean isBackPackDataChanged = false;
    private boolean isSendableGiftDataChanged = false;
    private boolean notFirstDialogShow = false;

    private View rootView;

    public LiveGiftDialog(BaseCommonLiveRoomActivity context){
        super(context, R.style.CustomTheme_LiveGiftDialog);
        this.mActivity = new WeakReference<BaseCommonLiveRoomActivity>(context);
        //计算定时器间隔
        int repeatSendStartCount = getContext().getResources().getInteger(R.integer.repeatSendStartCount);
        int repeatSendAnimTime = getContext().getResources().getInteger(R.integer.repeatSendAnimTime);
        this.periodTime = repeatSendAnimTime/repeatSendStartCount;
        giftNumPerPage = getContext().getResources().getInteger(R.integer.giftNumPerPage);
        giftColumnNumPerPage = getContext().getResources().getInteger(R.integer.giftColumnNumPerPage);
        gridViewItemWidth = DisplayUtil.getScreenWidth(mActivity.get())/giftColumnNumPerPage;
        lineCount = giftNumPerPage/ giftColumnNumPerPage;
        gridViewHeight = DisplayUtil.getScreenWidth(mActivity.get())/lineCount;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);
        rootView = View.inflate(getContext(),R.layout.view_live_gift_dialog,null);
        setContentView(rootView);
        initView(rootView);
    }

    private void initView(View rootView){
        Log.d(TAG,"initView");
        ll_countChooser = rootView.findViewById(R.id.ll_countChooser);
        fl_giftDialogRootView = rootView.findViewById(R.id.fl_giftDialogRootView);
        fl_giftDialogRootView.setOnClickListener(this);
        fl_giftDialogContainer = rootView.findViewById(R.id.fl_giftDialogContainer);
        fl_giftDialogContainer.setOnClickListener(this);
        lv_giftCount = (ListView) rootView.findViewById(R.id.lv_giftCount);
        giftCountSelectorAdapter = new GiftCountSelectorAdapter(mActivity.get(),
                R.layout.item_simple_list_gift_count);
        lv_giftCount.setAdapter(giftCountSelectorAdapter);
        lv_giftCount.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                giftCountSelectorAdapter.notifyDataSetChanged();
                return false;
            }
        });
        lv_giftCount.setVisibility(View.GONE);
        giftCountSelectorAdapter.setOnItemListener(new CanOnItemListener(){
            @Override
            public void onItemChildClick(View view, int position) {
                updateGiftCountSelected(null,position);
            }
        });
        ll_countChooser.setOnClickListener(this);
        iv_countIndicator = (ImageView) rootView.findViewById(R.id.iv_countIndicator);
        iv_countIndicator.setSelected(true);
        tv_sendGift = (TextView) rootView.findViewById(R.id.tv_sendGift);
        ll_sendGift = rootView.findViewById(R.id.ll_sendGift);
        tv_timeCount = (TextView) rootView.findViewById(R.id.tv_timeCount);
        tv_giftCount = (TextView) rootView.findViewById(R.id.tv_giftCount);
        sl_giftPagerContainer = (ScrollLayout) rootView.findViewById(R.id.sl_giftPagerContainer);
        sl_giftPagerContainer.setOnScreenChangeListener(new ScrollLayout.OnScreenChangeListener() {
            @Override
            public void onScreenChange(int currentIndex) {
                updateIndicatorStatus(currentIndex);
            }
        });
        ll_indicator = (LinearLayout) rootView.findViewById(R.id.ll_indicator);
        ll_repeatSendAnim = (LinearLayout) rootView.findViewById(R.id.ll_repeatSendAnim);
        ll_repeatSendAnim.setOnClickListener(this);
        tv_sendGift.setOnClickListener(this);
        ll_sendGift.setOnClickListener(this);
        ll_StoreGiftTab = rootView.findViewById(R.id.ll_StoreGiftTab);
        iv_StoreGiftTab = (ImageView) rootView.findViewById(R.id.iv_StoreGiftTab);
        tv_StoreGiftTab = (TextView) rootView.findViewById(R.id.tv_StoreGiftTab);
        ll_PkgGiftTab = rootView.findViewById(R.id.ll_PkgGiftTab);
        iv_PkgGiftTab = (ImageView) rootView.findViewById(R.id.iv_PkgGiftTab);
        tv_PkgGiftTab = (TextView) rootView.findViewById(R.id.tv_PkgGiftTab);
        ll_giftPageContainer = (LinearLayout) rootView.findViewById(R.id.ll_giftPageContainer);
        ll_loading = (LinearLayout) rootView.findViewById(R.id.ll_loading);
        ll_loading.setVisibility(View.GONE);
        ll_emptyData = (LinearLayout) rootView.findViewById(R.id.ll_emptyData);
        ll_emptyData.setVisibility(View.GONE);
        ll_errorRetry = (LinearLayout) rootView.findViewById(R.id.ll_errorRetry);
        ll_errorRetry.setVisibility(View.GONE);
        tv_reloadGiftList = (TextView) rootView.findViewById(R.id.tv_reloadGiftList);
        tv_reloadGiftList.setOnClickListener(this);
        rootView.findViewById(R.id.ll_userBalance).setOnClickListener(this);
        updateGiftTypeTab(giftTabs);
        lastClickedGiftTab = GiftTab.GiftTabFlag.STORE;
        updateGiftView();

    }

    @Override
    public void show() {
        Log.d(TAG,"show");
        super.show();
        if(isBackPackDataChanged){
            //更新gift列表的item数量
            updateBackPackGiftData();
        }
        if(notFirstDialogShow){
            List<GiftItem> listData = new ArrayList<>();
            if(lastClickedGiftTab == GiftTab.GiftTabFlag.STORE){
                if(isSendableGiftDataChanged){
                    listData = refreshGiftDataOnView();
                    isSendableGiftDataChanged = false;
                }else{
                    listData = giftItems;
                }
            }else if(lastClickedGiftTab == GiftTab.GiftTabFlag.BACKPACK){
                if(isBackPackDataChanged){
                    listData = refreshGiftDataOnView();
                    isBackPackDataChanged = false;
                }else{
                    listData = packagGiftItems;
                }
            }
            //更新指示器数量
            updateIndicatorView(pageCount);
            //连送动画
            if(null != lastSelectedGiftItem){
                Log.d(TAG,"show-lastSelectedGiftItem.id:"+lastSelectedGiftItem.id);
            }else{
                Log.d(TAG,"show-lastSelectedGiftItem:"+null);
            }
            if(null != lastRepeatSentGiftItem){
                Log.d(TAG,"show-lastRepeatSentGiftItem.id:"+lastRepeatSentGiftItem.id);
            }else{
                Log.d(TAG,"show-lastRepeatSentGiftItem:"+null);
            }
            boolean isNeedShowLashResendAnim = null != lastRepeatSentGiftItem && null != lastSelectedGiftItem
                    && lastRepeatSentGiftItem.equals(lastSelectedGiftItem)
                    && listData.contains(lastSelectedGiftItem);
            Log.d(TAG,"show-isNeedShowLashResendAnim:"+isNeedShowLashResendAnim);
            if(isNeedShowLashResendAnim){

                //判断是否需要重启连击动画
                long surplusTime = periodTime * mLastRepeatCount;
                long overTime = System.currentTimeMillis() - mLastDismissTime;
                Log.d(TAG,"show-periodTime:"+periodTime+" mLastRepeatCount:"+mLastRepeatCount+" surplusTime:"+surplusTime+" overTime:"+overTime);
                if(overTime < surplusTime){
                    //连击动画未结束
                    long startCount = (surplusTime - overTime)/periodTime;
                    startTimer((int)startCount);
                    changeSendAnimVisible();
                }
//                //根据选中的礼物的index，计算pageindex，跳转指定的page
//                int pageIndex = listData.size()/giftNumPerPage+1;
//                if(pageIndex<pageCount){
//                    sl_giftPagerContainer.setToScreen(pageIndex);
//                }
            }
            //更新item的选中状态
            if(null != lastSelectedGiftItem){
                updateItemViewSelectedStatus(lastSelectedGiftItem.id);
            }

        }
        notFirstDialogShow = true;
        showDataTipsView();
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG,"dismiss");
        //dismiss定时器
        stopTimer();
        ll_repeatSendAnim.setVisibility(View.GONE);
        lv_giftCount.setVisibility(View.GONE);
        ll_sendGift.setVisibility(View.VISIBLE);
        ll_countChooser.setVisibility(View.VISIBLE);
    }

    @Override
    public void dismiss() {
        Log.d(TAG,"dismiss");
        super.dismiss();
        mLastDismissTime = System.currentTimeMillis();
    }

    private void updateGiftCountSelected(List<Integer> numList, int position){
        if(null != numList){
            giftCountSelectorAdapter.setList(numList);
        }
        giftCountSelectorAdapter.setSelectedPosition(position);
        giftCountSelectorAdapter.notifyDataSetChanged();
        lv_giftCount.setVisibility(View.GONE);
        iv_countIndicator.setSelected(true);
        tv_giftCount.setText(String.valueOf(giftCountSelectorAdapter.getList().get(position)));
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

    private View.OnClickListener tabClickListener;

    /**
     * 添加tab
     * @param giftTypes
     */
    private void updateGiftTypeTab(final String[] giftTypes){
        ll_StoreGiftTab.setTag(giftTabs[0]);
        ll_PkgGiftTab.setTag(giftTabs[1]);
        if(null == tabClickListener){
            tabClickListener = new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    GiftTab.GiftTabFlag giftTab = null;
                    switch (v.getId()){
                        case R.id.ll_StoreGiftTab:
                            giftTab = GiftTab.GiftTabFlag.STORE;
                            break;
                        case R.id.ll_PkgGiftTab:
                            giftTab = GiftTab.GiftTabFlag.BACKPACK;
                            //store背景色变
                            break;
                        default:
                            giftTab = GiftTab.GiftTabFlag.STORE;
                            break;
                    }
                    ll_StoreGiftTab.setBackgroundColor(giftTab == GiftTab.GiftTabFlag.STORE ? Color.BLACK : Color.parseColor("#2b2b2b"));
                    iv_StoreGiftTab.setImageDrawable(mActivity.get().getResources().getDrawable(
                            giftTab == GiftTab.GiftTabFlag.STORE ? R.drawable.ic_gifttab_store_selected : R.drawable.ic_gifttab_store_unselected));
                    tv_StoreGiftTab.setTextColor(Color.parseColor(giftTab == GiftTab.GiftTabFlag.STORE ? "#f7cd3a" : "#59ffffff"));
                    ll_PkgGiftTab.setBackgroundColor(giftTab == GiftTab.GiftTabFlag.BACKPACK ? Color.BLACK : Color.parseColor("#2b2b2b"));
                    iv_PkgGiftTab.setImageDrawable(mActivity.get().getResources().getDrawable(
                            giftTab == GiftTab.GiftTabFlag.BACKPACK ? R.drawable.ic_gifttab_pkg_selected : R.drawable.ic_gifttab_pkg_unselected));
                    tv_PkgGiftTab.setTextColor(Color.parseColor(giftTab == GiftTab.GiftTabFlag.BACKPACK ? "#f7cd3a" : "#59ffffff"));
                    updateRepeatAnimStatus(null, GiftSender.ErrorCode.FAILED_OTHER);
                    if(lastClickedGiftTab != giftTab){
                        lastClickedGiftTab = giftTab;
                        updateGiftView();
                        showDataTipsView();
                    }

                }
            };
            ll_StoreGiftTab.setOnClickListener(tabClickListener);
            ll_PkgGiftTab.setOnClickListener(tabClickListener);
        }
    }

    /**
     * 展示错误提示界面，应该在tab点击的时候，判断展示
     */
    private void showDataTipsView(){
        HttpReqStatus sendableGiftReqStatus = NormalGiftManager.getInstance().getRoomSendableGiftReqStatus(imRoomInItem.roomId);
        if(lastClickedGiftTab == GiftTab.GiftTabFlag.STORE){
            if(null == giftItems || giftItems.size() == 0){
                //对于房间可发送礼物而言，暂定为，只要dialog的数据为空，即视为数据请求中
                if(HttpReqStatus.Reqing ==sendableGiftReqStatus
                        || HttpReqStatus.Reqing == NormalGiftManager.getInstance().allGiftConfigReqStatus){
                    showDataTipsViewByStatus(true,false,false);
                }else if(HttpReqStatus.ResFailed == NormalGiftManager.getInstance().getRoomSendableGiftReqStatus(imRoomInItem.roomId)
                        || HttpReqStatus.ResFailed == NormalGiftManager.getInstance().allGiftConfigReqStatus){
                    showDataTipsViewByStatus(false,false,true);
                }else{
                    showDataTipsViewByStatus(false,true,false);
                }
            }else{
                showDataTipsViewByStatus(false,false,false);
            }
        }else{
            if(null == packagGiftItems || packagGiftItems.size()==0){
                if(PackageGiftManager.getInstance().packageGiftReqStatus==HttpReqStatus.ResFailed
                        || HttpReqStatus.ResFailed == NormalGiftManager.getInstance().allGiftConfigReqStatus
                        || HttpReqStatus.ResFailed == sendableGiftReqStatus){
                    //加载出错
                    showDataTipsViewByStatus(false,false,true);
                }else if(HttpReqStatus.Reqing == NormalGiftManager.getInstance().allGiftConfigReqStatus
                    || PackageGiftManager.getInstance().packageGiftReqStatus==HttpReqStatus.Reqing
                        || HttpReqStatus.Reqing == sendableGiftReqStatus){
                    //刷新之中
                    showDataTipsViewByStatus(true,false,false);
                }else{
                    //没有数据
                    showDataTipsViewByStatus(false,true,false);
                }
            }else{
                showDataTipsViewByStatus(false,false,false);
            }
        }
    }

    private void showDataTipsViewByStatus(boolean isLoading, boolean isEmpty, boolean isError){
        ll_loading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
        ll_emptyData.setVisibility(isEmpty ? View.VISIBLE : View.GONE);
        ll_errorRetry.setVisibility(isError ? View.VISIBLE : View.GONE);
    }

    /**
     * 更新礼物展示界面
     */
    @SuppressLint("NewApi")
    private void updateGiftView(){
        Log.d(TAG,"updateGiftView");
        refreshGiftDataOnView();
        setViewLayoutParams();
        //更新指示器的选中状态
        updateIndicatorStatus(0);
        //更新礼物页的选中状态，默认选中第一个
        if(giftAdapters.size()>0){
            lastSelectedGiftItem = (GiftItem) giftAdapters.get(0).getList().get(0);
            final List<Integer> numList = getGiftNumList();
            updateGiftCountSelected(numList,0);
            updateItemViewSelectedStatus(lastSelectedGiftItem.id);
            showGiftLevelTips();
        }
    }

    private void setViewLayoutParams() {
        updateIndicatorView(pageCount);
        if(notFirstDialogShow){
           return;
        }
        //设置礼物列表滑动组件的实际高度
        LinearLayout.LayoutParams sl_lp = (LinearLayout.LayoutParams)sl_giftPagerContainer.getLayoutParams();
        sl_lp.height = gridViewHeight+sl_giftPagerContainer.getPaddingTop()+sl_giftPagerContainer.getPaddingBottom();
        sl_giftPagerContainer.setLayoutParams(sl_lp);


        ll_giftPageContainer.measure(0,0);
        FrameLayout.LayoutParams rlLoadingLp = (FrameLayout.LayoutParams) ll_loading.getLayoutParams();
        rlLoadingLp.height = ll_giftPageContainer.getMeasuredHeight();
        ll_loading.setLayoutParams(rlLoadingLp);
        //设置dialog的实际高度
        FrameLayout.LayoutParams giftPageContainerLp = (FrameLayout.LayoutParams)ll_giftPageContainer.getLayoutParams();
        dialogMaxHeight = ll_giftPageContainer.getMeasuredHeight()+giftPageContainerLp.bottomMargin;
        FrameLayout.LayoutParams fl_lp = (FrameLayout.LayoutParams) fl_giftDialogContainer.getLayoutParams();
        fl_lp.height = dialogMaxHeight;
        fl_lp.gravity = Gravity.BOTTOM;
        Log.d(TAG,"updateGiftView-fl_lp.height:"+fl_lp.height);
        fl_giftDialogContainer.setLayoutParams(fl_lp);
    }

    @NonNull
    private List<GiftItem> refreshGiftDataOnView() {
        List<GiftItem> listData = new ArrayList<>();
        if(lastClickedGiftTab == GiftTab.GiftTabFlag.BACKPACK){
            listData = packagGiftItems;
            isBackPackDataChanged = false;
        }else{
            listData = giftItems;
        }

        pageCount = (listData.size()/giftNumPerPage)+ (0 == listData.size()%giftNumPerPage ? 0 : 1);
        Log.d(TAG,"refreshGiftDataOnView-listData.size:"+ listData.size()+" pageCount:"+pageCount
                +" giftNumPerPage:"+giftNumPerPage);
        //只在有数据的情况下 update views
        sl_giftPagerContainer.removeAllViews();
        giftAdapters = null == giftAdapters ? new ArrayList<GiftAdapter>() : giftAdapters;
        giftAdapters.clear();
        GridView gridView = null;
        for(int index=0 ; index<pageCount; index++){
            gridView = (GridView) View.inflate(mActivity.get(), R.layout.item_simple_gridview_1,null);
            int maxPagePosition = giftNumPerPage*(index+1);
            final GiftAdapter<GiftItem> storeGiftAdapter = new GiftAdapter(mActivity.get(),
                    R.layout.item_girdview_gift, listData.subList(giftNumPerPage*index,
                    maxPagePosition< listData.size() ? maxPagePosition : listData.size()),lastClickedGiftTab);
            if(lastClickedGiftTab == GiftTab.GiftTabFlag.BACKPACK){
                storeGiftAdapter.setPackageGiftNums(packageGiftNums);
            }
            storeGiftAdapter.setItemWidth(gridViewItemWidth);
            storeGiftAdapter.setOnItemListener(new CanOnItemListener(){
                @Override
                public void onItemChildClick(View view, int position) {
                    GiftItem selectedGiftItem = (GiftItem) storeGiftAdapter.getList().get(position);
                    if(selectedGiftItem != lastSelectedGiftItem){
                        lastSelectedGiftItem = selectedGiftItem;
                        final List<Integer> numList = getGiftNumList();
                        updateGiftCountSelected(numList,0);
//                    updateRepeatAnimStatus(null, GiftSender.ErrorCode.FAILED_OTHER);
                        //改变按钮状态
                        changeSendAnimVisible();
                        updateItemViewSelectedStatus(lastSelectedGiftItem.id);
                        showGiftLevelTips();
                    }
                }
            });
            gridView.setAdapter(storeGiftAdapter);
            giftAdapters.add(storeGiftAdapter);
            gridView.setNumColumns(giftColumnNumPerPage);// 每行显示几个
            gridView.setColumnWidth(gridViewItemWidth);
            gridView.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
            ViewGroup.LayoutParams gridViewLp = new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,gridViewHeight);
            Log.d(TAG,"refreshGiftDataOnView-gridViewHeight:"+gridViewHeight);
            sl_giftPagerContainer.addView(gridView,gridViewLp);
        }
        return listData;
    }


    private void showGiftLevelTips(){
        String msg = "";
        if(lastSelectedGiftItem.levelLimit > imRoomInItem.manLevel){
            msg = mActivity.get().getResources().getString(
                    R.string.liveroom_gift_user_levellimit);

        }else if(lastSelectedGiftItem.lovelevelLimit > imRoomInItem.loveLevel){
            msg = mActivity.get().getResources().getString(
                    R.string.liveroom_gift_intimacy_levellimit);
        }
        if(!TextUtils.isEmpty(msg) && null != mActivity && null != mActivity.get()){
            mActivity.get().showGiftTips(msg);

        }
        isSendGiftUnUsable = !TextUtils.isEmpty(msg);
        Log.d(TAG,"showGiftLevelTips-msg:"+msg+" isSendGiftUnUsable:"+isSendGiftUnUsable);
    }

    /**
     * 更新选中状态
     */
    private void updateItemViewSelectedStatus(String selectedGiftId){
        GiftAdapter.selectedGiftId = selectedGiftId;
        //更新选中状态
        for(CanAdapter adapter : giftAdapters){
            adapter.notifyDataSetChanged();
        }
    }

    /**
     * 更新连送按钮的显示状态
     */
    private void changeSendAnimVisible(){
        Log.d(TAG,"changeSendAnimVisible");
        iv_countIndicator.setSelected(true);
        if(lastRepeatSentGiftItem != null){
            //当前是否有连击中礼物
            ll_repeatSendAnim.setVisibility(lastSelectedGiftItem.id == lastRepeatSentGiftItem.id ? View.VISIBLE : View.GONE);
            ll_sendGift.setVisibility(lastSelectedGiftItem.id == lastRepeatSentGiftItem.id ? View.INVISIBLE : View.VISIBLE);
            ll_countChooser.setVisibility(lastSelectedGiftItem.id == lastRepeatSentGiftItem.id ? View.GONE : View.VISIBLE);
        }else{
            ll_repeatSendAnim.setVisibility(View.GONE);
            ll_sendGift.setVisibility(View.VISIBLE);
            ll_countChooser.setVisibility(View.VISIBLE);
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
                    .getResources().getDrawable(R.drawable.selector_page_indicator));
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
        int slCurScreenIndex = sl_giftPagerContainer.getCurScreenIndex();
        Log.d(TAG,"updateIndicatorStatus-selectedIndex:"+selectedIndex+" slCurScreenIndex:"+slCurScreenIndex);
        if(selectedIndex != slCurScreenIndex){
            return;
        }
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
     * @param isRepeat 连送标识
     */
    private void sendGift(GiftItem giftItem,boolean isRepeat, int num){
        Log.d(TAG,"sendGift-giftItem:"+giftItem+" isRepeat:"+isRepeat+" num:"+num);
        if(null == giftItem){
            return;
        }

        if(lastClickedGiftTab == GiftTab.GiftTabFlag.STORE){
            GiftSender.getInstance().sendStoreGift(giftItem, isRepeat, num, this);
        }else{
            if(packageGiftNums.containsKey(giftItem.id)){
                GiftSender.getInstance().sendBackpackGift(giftItem, isRepeat, num,
                        packageGiftNums.get(giftItem.id), this);
            }

        }
    }

    @Override
    public void onGiftReqSent(GiftItem giftItem, GiftSender.ErrorCode errorCode,
                              String message, double localCoins, boolean isRepeat, int sendNum) {
        //1.如果是首次发送，那么因为有本地金币数量的判断，所以也该有本地金币数量更新的逻辑
        lastGiftSendNum = sendNum;
        updateRepeatAnimStatus(giftItem,errorCode);
        if(errorCode == GiftSender.ErrorCode.FAILED_CREDITS_NOTENOUGHT){
            if(null != mActivity && null != mActivity.get()){
                mActivity.get().showCreditNoEnoughPopupWindow(R.string.liveroom_gift_credits_noenough
                        ,rootView,true);
            }
        }
    }

    @Override
    public void onPackReqSend(GiftItem giftItem, GiftSender.ErrorCode errorCode,
                              String message, boolean isRepeat, int sendNum) {
        lastGiftSendNum = sendNum;
        updateRepeatAnimStatus(giftItem,errorCode);
        if(GiftSender.ErrorCode.FAILED_NUMBS_NOTENOUGHT.equals(errorCode)){
            Toast.makeText(mActivity.get(),
                    mActivity.get().getResources().getString(R.string.live_gift_send_failed_numnoenough,giftItem.name)
                    ,Toast.LENGTH_SHORT).show();
            return;
        }
        if(GiftSender.ErrorCode.SUCCESS.equals(errorCode)){
            subPackageGiftNumById(giftItem.id,sendNum);
        }

        //更新礼物页的选中状态，默认选中第一个
        if(packagGiftItems.size()>=0){
            if(!packagGiftItems.contains(giftItem)){
                //更新gift列表的item数量
                refreshGiftDataOnView();
                //更新指示器数量
                updateIndicatorView(pageCount);
                //更新默认选择的礼物的可发送数量
                if(null != giftAdapters && giftAdapters.size()>0){
                    GiftItem selectedGiftItem = (GiftItem) giftAdapters.get(0).getList().get(0);
                    lastSelectedGiftItem = selectedGiftItem;
                    final List<Integer> numList = getGiftNumList();
                    updateGiftCountSelected(numList,0);
                    //更新item的选中状态
                    updateItemViewSelectedStatus(lastSelectedGiftItem.id);
                    showGiftLevelTips();
                }
                updateRepeatAnimStatus(null, GiftSender.ErrorCode.FAILED_OTHER);
            }else{
                //更新指定gift的totalNum
                if(currPageIndex<giftAdapters.size()){
                    GiftAdapter giftAdapter = giftAdapters.get(currPageIndex);
                    giftAdapter.setPackageGiftNums(packageGiftNums);
                    giftAdapter.notifyDataSetChanged();
                }
            }
        }
    }

    /**
     * 更新连击礼物倒计时动画的显示状态
     * @param giftItem
     * @param errorCode
     */
    private void updateRepeatAnimStatus(GiftItem giftItem,GiftSender.ErrorCode errorCode){
        Log.d(TAG,"updateRepeatAnimStatus-errorCode:"+errorCode);
        //2.根据是否连击，及可连击礼物请求是否插入队列，来判断是否需要展示倒计时
        if(errorCode.equals(GiftSender.ErrorCode.SUCCESS)){
            //成功，是连击礼物，则展示倒计时
            if(null !=giftItem &&  giftItem.canMultiClick){
                Log.d(TAG,"updateRepeatAnimStatus-multiClickable:"+giftItem.canMultiClick);
                lastRepeatSentGiftItem = giftItem;
                //重置播放动画
                startTimer(mActivity.get().getResources().getInteger(R.integer.repeatSendStartCount));
            }
        }else{
            //失败，无论是否是连击礼物，都停止倒计时，并提示失败信息
            lastRepeatSentGiftItem = null;
            stopTimer();
        }
        //改变按钮状态
        changeSendAnimVisible();
    }

    @Override
    public void onClick(View view){
        switch (view.getId()){
            case R.id.tv_reloadGiftList:
                if(TestDataUtil.isTestGiftErrorDeal){
                    TestDataUtil.isTestGiftErrorDeal = false;
                }
                if(null != mActivity && mActivity.get() != null){
                    mActivity.get().initRoomGiftDataSet();
                }
                showDataTipsView();
                break;
            case R.id.ll_userBalance:
                showAudienceBalanceInfoDialog();
                break;
            case R.id.fl_giftDialogContainer:
                break;
            case R.id.fl_giftDialogRootView:
                dismiss();
                break;
            case R.id.ll_repeatSendAnim:
                //重置动画
                startTimer(getContext().getResources().getInteger(R.integer.repeatSendStartCount));
                Log.d(TAG,"onClick-repeatSendGift-numStr:"+lastGiftSendNum);
                sendGift(lastRepeatSentGiftItem,true,lastGiftSendNum);
                break;
            case R.id.tv_sendGift:
            case R.id.ll_sendGift:
                if(isSendGiftUnUsable){
                    return;
                }
                //这个按钮可点击的时候，说明要么是刚开始送礼，要么是上个连送礼物动画播放过程中，切换了选择的礼物
                if(null != lastSelectedGiftItem){
                    if(lastClickedGiftTab == GiftTab.GiftTabFlag.BACKPACK
                            && null != sendableGiftItemMap
                            && !sendableGiftItemMap.containsKey(lastSelectedGiftItem.id)){
                        mActivity.get().showGiftTips(mActivity.get().getResources().getString(
                                R.string.liveroom_gift_pack_notsendable));
                        return;
                    }

                    String numStr = tv_giftCount.getText().toString();
                    Log.d(TAG,"onClick-sendGift-numStr:"+numStr);
                    if(!TextUtils.isEmpty(numStr)){
                      int num = Integer.valueOf(numStr);
                      sendGift(lastSelectedGiftItem,false,num);
                    }
                }
                lv_giftCount.setVisibility(View.GONE);
                break;
            case R.id.ll_countChooser:
                if(ll_repeatSendAnim.getVisibility() == View.GONE){
                    boolean isShowing = lv_giftCount.getVisibility() == View.VISIBLE;
                    iv_countIndicator.setSelected(isShowing);
                    lv_giftCount.setVisibility(isShowing ? View.GONE : View.VISIBLE);
                }
                break;
            default:
                break;
        }
    }

    //------------------------数据处理方法------------------------------------------

    /**
     * 更新普通房间可发送礼物
     */
    public void updateStoreGiftData(List<GiftItem> sendableGiftDetails){
        this.giftItems.clear();
        this.giftItems.addAll(sendableGiftDetails);
        isSendableGiftDataChanged = true;
        //界面展示为loading、empty、error-reload则更新界面展示
        if(isShowing() && null != lastClickedGiftTab && lastClickedGiftTab == GiftTab.GiftTabFlag.STORE){
            if((null != ll_emptyData && ll_emptyData.getVisibility() == View.VISIBLE)
                    || (null != ll_errorRetry && ll_errorRetry.getVisibility() == View.VISIBLE)
                    || (null != ll_loading && ll_loading.getVisibility() == View.VISIBLE)){
                updateGiftView();
                showDataTipsView();
                isSendableGiftDataChanged = false;
            }
        }
    }

    public void setBackPackDataChanged(){
        isBackPackDataChanged = true;
        //界面展示为loading、empty、error-reload则更新界面展示
        if(null == packagGiftItems || packagGiftItems.size()==0){
            updateBackPackGiftData();
            isBackPackDataChanged = false;
        }
        if(isShowing() && null != lastClickedGiftTab && lastClickedGiftTab == GiftTab.GiftTabFlag.BACKPACK){
            if((null != ll_emptyData && ll_emptyData.getVisibility() == View.VISIBLE)
                    || (null != ll_errorRetry && ll_errorRetry.getVisibility() == View.VISIBLE)
                    || (null != ll_loading && ll_loading.getVisibility() == View.VISIBLE)){
                updateGiftView();
                showDataTipsView();
            }
        }
    }

    /**
     * 更新背包礼物列表
     */
    public void updateBackPackGiftData(){
        List<GiftItem> pkgGiftItems = PackageGiftManager.getInstance().getLocalPackageGiftDetails();
        Map<String,Integer> pkgGiftNums = PackageGiftManager.getInstance().getLocalPackageGiftNumData();
        sendableGiftItemMap = NormalGiftManager.getInstance().getLocalRoomSendableGiftMap(imRoomInItem.roomId);
        packagGiftItems.clear();
        packageGiftNums.clear();
        packageGiftIdItems.clear();
        //深赋值，避免Integer内存引用相同，导致manager更新引起dialog的直接性更改
        for(GiftItem giftItem : pkgGiftItems){
            packagGiftItems.add(giftItem);
            packageGiftNums.put(giftItem.id,new Integer(pkgGiftNums.get(giftItem.id).intValue()));
            packageGiftIdItems.put(giftItem.id,giftItem);
        }
    }

    public void setImRoomInItem(IMRoomInItem imRoomInItem){
        this.imRoomInItem = imRoomInItem;
        GiftAdapter.currIMRoomInItem = imRoomInItem;
        if(isShowing()){
            if(null != giftAdapters){
                for (GiftAdapter giftAdapter : giftAdapters){
                    giftAdapter.notifyDataSetChanged();
                }
            }
        }

    }

    /**
     * 获取位置position对应的礼物的可发送数量数组
     * @return
     */
    private List<Integer> getGiftNumList(){
        final List<Integer> numList = new ArrayList<Integer>();
        for(Integer num : lastSelectedGiftItem.giftChooser){
            numList.add(num);
        }
        return numList;
    }

    /**
     * 对dialog本地背包礼物的数量数据执行减法
     * @param giftId
     * @param subNum
     * @return
     */
    public boolean subPackageGiftNumById(String giftId,int subNum){
        Log.d(TAG,"subPackageGiftNumById-giftId:"+giftId+" subNum:"+subNum);
        synchronized (packageGiftNums){
            boolean result = false;
            if(packageGiftNums.containsKey(giftId)){
                int totalNum = packageGiftNums.get(giftId);
                totalNum-=subNum;
                Log.d(TAG,"subPackageGiftNumById-giftId:"+giftId+" totalNum:"+totalNum);
                if(totalNum>0){
                    packageGiftNums.put(giftId,totalNum);
                }else{
                    packageGiftNums.remove(giftId);
                    GiftItem delGiftItem = packageGiftIdItems.remove(giftId);
                    packagGiftItems.remove(delGiftItem);
                }
                result = true;
            }
            Log.d(TAG,"subPackageGiftNumById-result:"+result);
            return result;
        }
    }

    //---------------------------------------自定义Toast-------------------------------



    //------------------------用户信用点信息对话框-----------------------------------------
    private AudienceBalanceInfoPopupWindow pw_audienceBalanceInfo;

    private void showAudienceBalanceInfoDialog(){
        if(null == pw_audienceBalanceInfo){
            pw_audienceBalanceInfo = new AudienceBalanceInfoPopupWindow(mActivity.get().getApplicationContext());
            pw_audienceBalanceInfo.setBackgroundDrawable(new ColorDrawable(Color.WHITE));
        }
        pw_audienceBalanceInfo.setUserLevel(imRoomInItem.manLevel);
        pw_audienceBalanceInfo.showAtLocation(rootView,Gravity.BOTTOM,ViewGroup.LayoutParams.FILL_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);

    }

    /******************************* 定时器相关  *************************************/
    /**
     * 指定初始位置启动定时器
     * @param startCount
     */
    private void startTimer(int startCount){
        if(null == timerManager){
            timerManager = new GiftRepeatSendTimerManager();
            timerManager.setOnTimerTaskExecuteListener(onTimerTaskExecuteListener);
        }

        timerManager.start(startCount, periodTime);
    }

    /**
     * 停止定时器
     */
    private void stopTimer(){
        if(null != timerManager){
            timerManager.stop();
        }
    }

    /**
     * 监听器
     */
    private OnTimerTaskExecuteListener onTimerTaskExecuteListener = new OnTimerTaskExecuteListener() {
        @Override
        public void onTaskExecute(final int executeCount) {
            if(mActivity.get() != null){
                mActivity.get().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        //记录最后一次显示
                        mLastRepeatCount = executeCount;

                        if (null != tv_timeCount) {
                            tv_timeCount.setText(String.valueOf(executeCount));
                            tv_timeCount.setTextColor(Color.parseColor("#383838"));
                        }
                        Log.d(TAG,"MSG_WAHT_UPDATE_COUNTER-tv_timeCount:"+executeCount);
                    }
                });
            }
        }

        @Override
        public void onTaskEnd() {
            //连送通道关闭
            lastRepeatSentGiftItem = null;
//            mmHandler.sendMessage(mmHandler.obtainMessage(MSG_WAHT_END_COUNTER));
            if(mActivity.get() != null){
                mActivity.get().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        changeSendAnimVisible();
                    }
                });
            }
        }
    };

    //----------------OnOutSideTouchEventListener------------------------------------------------------

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        Log.d(TAG,"onBackPressed");
    }

    @Override
    public boolean onTouchEvent(@NonNull MotionEvent event) {
        Log.d(TAG,"onTouchEvent-event.action:"+event.getAction());
        if (MotionEvent.ACTION_OUTSIDE == event.getAction()) {
            dismiss();
            return true;
        }

        return super.onTouchEvent(event);
    }
}
