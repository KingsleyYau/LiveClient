package com.qpidnetwork.anchor.liveshow.liveroom.gift.dialog;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.graphics.Color;
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

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.anchor.framework.widget.NoScrollGridView;
import com.qpidnetwork.anchor.httprequest.OnGiftLimitNumListCallback;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.GiftLimitNumItem;
import com.qpidnetwork.anchor.im.IMLiveRoomEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.liveshow.liveroom.BaseImplLiveRoomActivity;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.anchor.liveshow.model.http.HttpReqStatus;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.view.ScrollLayout;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 新改版礼物列表:
 * 1.GiftSender和NewGiftSendReqManager修改为私有变量-构造实例的方式
 * 2.初始化的时候就获取一次礼物列表数据,每次show的时候就判断礼物数据是否已经请求成功，
 *      成功则每次show的时候都过滤一遍本地详情，以避免部分详情刷新不及时导致界面看不到该礼物
 *      未请求或者请求失败则重新调用接口获取
 * 3.Dialog作为Activity处理礼物发送的业务逻辑，即接口回调实现放到dialog内部处理,以求尽量保持同activity少有交互
 * 4.优化代码结构
 */
public class LiveGiftDialog extends Dialog implements View.OnClickListener, GiftSender.GiftSendResultListener,IMLiveRoomEventListener {

    private final String TAG = LiveGiftDialog.class.getSimpleName();
    private WeakReference<BaseImplLiveRoomActivity> mActivity;
    private View fl_giftDialogContainer;
    private LinearLayout ll_giftPageContainer;
    private ScrollLayout sl_giftPagerContainer;
    private List<LimitGiftAdapter> giftAdapters = new ArrayList<>();
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
    //indicator
    private LinearLayout ll_indicator;
    //提示
    private LinearLayout ll_loading;
    private LinearLayout ll_emptyData;
    private TextView tvEmptyDesc;
    private LinearLayout ll_errorRetry;
    private TextView tv_reloadGiftList;
    //dialog和adapters共用的数据
    private GiftItem lastSelectedGiftItem = null;//用于礼物发送、连送动画逻辑展示
    private GiftItem lastRepeatSentGiftItem = null;
    private int lastGiftSendNum = 0;
    private List<GiftLimitNumItem> giftLimitNumItems = new ArrayList<>();
    private Map<String,GiftLimitNumItem> limitGiftNumMap = new HashMap<>();

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
    private boolean canOpenNumberSelector = true;
    private View rootView;

    //房间礼物管理器，管理直播间中礼物列表
    private RoomGiftManager mRoomGiftManager;
    private GiftSender giftSender;

    public LiveGiftDialog(BaseImplLiveRoomActivity context, RoomGiftManager roomGiftManager,GiftSender giftSender){
        super(context, R.style.CustomTheme_LiveGiftDialog);
        this.mActivity = new WeakReference<>(context);
        this.mRoomGiftManager = roomGiftManager;
        this.giftSender = giftSender;
        //计算定时器间隔
        int repeatSendStartCount = getContext().getResources().getInteger(R.integer.repeatSendStartCount);
        int repeatSendAnimTime = getContext().getResources().getInteger(R.integer.repeatSendAnimTime);
        this.periodTime = repeatSendAnimTime/repeatSendStartCount;
        giftNumPerPage = getContext().getResources().getInteger(R.integer.giftNumPerPage);
        giftColumnNumPerPage = getContext().getResources().getInteger(R.integer.giftColumnNumPerPage);
        gridViewItemWidth = DisplayUtil.getScreenWidth(mActivity.get())/giftColumnNumPerPage;
        lineCount = giftNumPerPage/ giftColumnNumPerPage;
        gridViewHeight = DisplayUtil.getScreenWidth(mActivity.get())/lineCount;
        getRoomGiftList();
    }

    public void registerIMLiveRoomEventListener(){
        IMManager.getInstance().registerIMLiveRoomEventListener(this);
    }

    public void unregisterIMLiveRoomEventListener(){
        IMManager.getInstance().unregisterIMLiveRoomEventListener(this);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL, WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH, WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);
        rootView = View.inflate(getContext(),R.layout.view_live_gift_dialog_new,null);
        setContentView(rootView);
        initView(rootView);
        //设置界面布局高度等参数
        setViewLayoutParams();
    }

    private CanOnItemListener canOnItemListener = new CanOnItemListener(){
        @Override
        public void onItemChildClick(View view, int position) {
            updateGiftCountSelected(null,position);
        }
    };

    private ScrollLayout.OnScreenChangeListener onScreenChangeListener = new ScrollLayout.OnScreenChangeListener() {
        @Override
        public void onScreenChange(int currentIndex) {
            updateIndicatorStatus(currentIndex);
        }
    };

    private void initView(View rootView){
        Log.d(TAG,"initView");
        ll_countChooser = rootView.findViewById(R.id.ll_countChooser);
        rootView.findViewById(R.id.fl_giftDialogRootView).setOnClickListener(this);
        fl_giftDialogContainer = rootView.findViewById(R.id.fl_giftDialogContainer);
        fl_giftDialogContainer.setOnClickListener(this);
        lv_giftCount = (ListView) rootView.findViewById(R.id.lv_giftCount);
        giftCountSelectorAdapter = new GiftCountSelectorAdapter(getContext(), R.layout.item_simple_list_gift_count);
        lv_giftCount.setAdapter(giftCountSelectorAdapter);
        lv_giftCount.setVisibility(View.GONE);
        giftCountSelectorAdapter.setOnItemListener(canOnItemListener);
        ll_countChooser.setOnClickListener(this);
        iv_countIndicator = (ImageView) rootView.findViewById(R.id.iv_countIndicator);
        iv_countIndicator.setSelected(true);
        tv_sendGift = (TextView) rootView.findViewById(R.id.tv_sendGift);
        ll_sendGift = rootView.findViewById(R.id.ll_sendGift);
        tv_timeCount = (TextView) rootView.findViewById(R.id.tv_timeCount);
        tv_giftCount = (TextView) rootView.findViewById(R.id.tv_giftCount);
        sl_giftPagerContainer = (ScrollLayout) rootView.findViewById(R.id.sl_giftPagerContainer);
        sl_giftPagerContainer.setOnScreenChangeListener(onScreenChangeListener);
        ll_indicator = (LinearLayout) rootView.findViewById(R.id.ll_indicator);
        ll_repeatSendAnim = (LinearLayout) rootView.findViewById(R.id.ll_repeatSendAnim);
        ll_repeatSendAnim.setOnClickListener(this);
        tv_sendGift.setOnClickListener(this);
        ll_sendGift.setOnClickListener(this);
        ll_giftPageContainer = (LinearLayout) rootView.findViewById(R.id.fl_giftPageContainer);
        ll_loading = (LinearLayout) rootView.findViewById(R.id.ll_loading);
        ll_loading.setVisibility(View.GONE);
        ll_emptyData = (LinearLayout) rootView.findViewById(R.id.ll_emptyData);
        tvEmptyDesc = (TextView) rootView.findViewById(R.id.tvEmptyDesc);
        ll_emptyData.setVisibility(View.GONE);
        ll_errorRetry = (LinearLayout) rootView.findViewById(R.id.ll_errorRetry);
        ll_errorRetry.setVisibility(View.GONE);
        tv_reloadGiftList = (TextView) rootView.findViewById(R.id.tv_reloadGiftList);
        tv_reloadGiftList.setOnClickListener(this);
    }

    public void show() {
        Log.d(TAG,"show");
        super.show();
        checkGiftData();
        showDataTipsView();
        updateGiftView();
    }

    /**
     * 判断是否继续展示连击倒计时动画
     */
    private void checkGiftRepeatSendAnim() {
        boolean isNeedShowLastResendAnim = null != lastRepeatSentGiftItem && null != lastSelectedGiftItem
                && lastRepeatSentGiftItem.equals(lastSelectedGiftItem) && limitGiftNumMap.size()>0 &&  limitGiftNumMap.containsKey(lastSelectedGiftItem.id);
        Log.d(TAG,"checkGiftRepeatSendAnim-isNeedShowLastResendAnim:"+isNeedShowLastResendAnim);
        if(isNeedShowLastResendAnim){
            //判断是否需要重启连击动画
            long surplusTime = periodTime * mLastRepeatCount;
            long overTime = System.currentTimeMillis() - mLastDismissTime;
            Log.d(TAG,"checkGiftRepeatSendAnim-periodTime:"+periodTime+" mLastRepeatCount:" +mLastRepeatCount
                    +" surplusTime:"+surplusTime+" overTime:"+overTime);
            if(overTime < surplusTime){
                //连击动画未结束
                long startCount = (surplusTime - overTime)/periodTime;
                startTimer((int)startCount);
                changeSendAnimVisible();
            }
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        //dismiss定时器
        stopTimer();
        ll_repeatSendAnim.setVisibility(View.GONE);
        lv_giftCount.setVisibility(View.GONE);
        ll_sendGift.setVisibility(View.VISIBLE);
        ll_countChooser.setVisibility(View.VISIBLE);
    }

    @Override
    public void dismiss() {
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
        List<Integer> currNumList = giftCountSelectorAdapter.getList();
        if(null == currNumList || currNumList.size() == 0){
            tv_giftCount.setText("1");
        }else{
            tv_giftCount.setText(String.valueOf(currNumList.get(position)));
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
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

    @Override
    public boolean onTouchEvent(@NonNull MotionEvent event) {
        Log.d(TAG,"onTouchEvent-event.action:"+event.getAction());
        if (MotionEvent.ACTION_OUTSIDE == event.getAction()) {
            dismiss();
            return true;
        }

        return super.onTouchEvent(event);
    }

    /**
     * 展示错误提示界面，应该在tab点击的时候，判断展示
     */
    private void showDataTipsView(){
        if(null == giftLimitNumItems || giftLimitNumItems.size()==0){
            HttpReqStatus reqStatus = mRoomGiftManager.getRoomGiftRequestStatus();
            if(HttpReqStatus.Reqing == reqStatus){
                //刷新之中
                canOpenNumberSelector = false;
                setSendGiftBtnEnable(false);
                showDataTipsViewByStatus(true,false,false);
            } else if(HttpReqStatus.ResFailed == reqStatus){
                //加载出错
                canOpenNumberSelector = false;
                setSendGiftBtnEnable(false);
                showDataTipsViewByStatus(false,false,true);
            }else{
                //没有数据
                canOpenNumberSelector = false;
                setSendGiftBtnEnable(false);
                showDataTipsViewByStatus(false,true,false);
            }
        }else{
            canOpenNumberSelector = true;
            showDataTipsViewByStatus(false,false,false);
            setSendGiftBtnEnable(true);
        }
    }

    private void showDataTipsViewByStatus(boolean isLoading, boolean isEmpty, boolean isError){
        ll_loading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
        ll_emptyData.setVisibility(isEmpty ? View.VISIBLE : View.GONE);
        if(isEmpty && tvEmptyDesc != null){
            tvEmptyDesc.setText(R.string.liveroom_gift_pack_empty);
        }
        ll_errorRetry.setVisibility(isError ? View.VISIBLE : View.GONE);
    }

    /**
     * 更新礼物展示界面
     */
    @SuppressLint("NewApi")
    private void updateGiftView(){
        Log.d(TAG,"updateGiftView");
        refreshGiftDataOnView();
        //更新指示器数量
        updateIndicatorView();
        boolean hasGiftDataOnView = null != giftLimitNumItems && giftLimitNumItems.size()>0;
        setSendGiftBtnEnable(hasGiftDataOnView);
        showDataTipsViewByStatus(false,!hasGiftDataOnView,false);
        //更新礼物页的选中状态，默认选中第一个
        if(giftAdapters.size()==0){
            lastSelectedGiftItem = null;
            lastRepeatSentGiftItem = null;
            return;
        }
        if(null == lastSelectedGiftItem){
            GiftLimitNumItem item =  (GiftLimitNumItem) giftAdapters.get(0).getList().get(0);
            lastSelectedGiftItem = NormalGiftManager.getInstance().getLocalGiftDetail(item.giftId);
        }
        //计算当前页的索引,切换
        int currPageSelectedIndex = giftLimitNumItems.indexOf(limitGiftNumMap.get(lastSelectedGiftItem.id))/giftNumPerPage;
        //更新页面指示器选中状态
        updateIndicatorStatus(currPageSelectedIndex);
        sl_giftPagerContainer.abortScrollAnimation();
        sl_giftPagerContainer.setToScreen(currPageSelectedIndex);
        Log.d(TAG,"updateGiftView-currPageSelectedIndex:"+currPageSelectedIndex);
        //更新礼物可选数量
        final List<Integer> numList = getGiftNumList();
        //设置默认选择礼物数量选项
        updateGiftCountSelected(numList,0);
        //更新礼物选中状态
        updateItemViewSelectedStatus(lastSelectedGiftItem.id);
        //判断是否继续显示送礼倒计时动画
        checkGiftRepeatSendAnim();
    }

    private void setViewLayoutParams() {
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
        fl_giftDialogContainer.setLayoutParams(fl_lp);
    }

    /**
     * 刷新礼物数据到界面
     * @return
     */
    private void refreshGiftDataOnView() {
        //giftItems基本默认为空ArrayList
        pageCount = (giftLimitNumItems.size()/giftNumPerPage)+ (0 == giftLimitNumItems.size()%giftNumPerPage ? 0 : 1);
        Log.d(TAG,"refreshGiftDataOnView-listData.size:"+ giftLimitNumItems.size()+" pageCount:"+pageCount +" giftNumPerPage:"+giftNumPerPage);
        //只在有数据的情况下 update views
        sl_giftPagerContainer.removeAllViews();
        giftAdapters.clear();
        NoScrollGridView gridView = null;
        for(int index=0 ; index<pageCount; index++){
            gridView = (NoScrollGridView) View.inflate(getContext(), R.layout.item_simple_gridview_1,null);
            int maxPagePosition = giftNumPerPage*(index+1);
            final LimitGiftAdapter<GiftLimitNumItem> giftAdapter = new LimitGiftAdapter(getContext(),
                    R.layout.item_girdview_gift, giftLimitNumItems.subList(giftNumPerPage*index,
                    maxPagePosition< giftLimitNumItems.size() ? maxPagePosition : giftLimitNumItems.size()));
            giftAdapter.setItemWidth(gridViewItemWidth);
            giftAdapter.setOnItemListener(new CanOnItemListener(){
                @Override
                public void onItemChildClick(View view, int position) {
                    GiftLimitNumItem selectedGiftItem = (GiftLimitNumItem) giftAdapter.getList().get(position);
                    GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(selectedGiftItem.giftId);
                    boolean diffGift = giftItem != lastSelectedGiftItem;
                    lastSelectedGiftItem = giftItem;
                    if(diffGift){
                        //更改可选数量
                        final List<Integer> numList = getGiftNumList();
                        updateGiftCountSelected(numList,0);
                        //改变连送动画状态
                        lastRepeatSentGiftItem = null;
                        changeSendAnimVisible();
                        //更改选中状态
                        updateItemViewSelectedStatus(lastSelectedGiftItem.id);
                        setSendGiftBtnEnable(true);
                    }
                }
            });
            gridView.setAdapter(giftAdapter);
            giftAdapters.add(giftAdapter);
            gridView.setNumColumns(giftColumnNumPerPage);// 每行显示几个
            gridView.setColumnWidth(gridViewItemWidth);
            gridView.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
            ViewGroup.LayoutParams gridViewLp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,gridViewHeight);
            Log.d(TAG,"refreshGiftDataOnView-gridViewHeight:"+gridViewHeight);
            sl_giftPagerContainer.addView(gridView,gridViewLp);
        }
    }

    private void setSendGiftBtnEnable(boolean enabled){
        tv_sendGift.setBackgroundDrawable(getContext().getResources().getDrawable(
                enabled ?R.drawable.selector_live_buttom_gift_send :R.drawable.bg_live_buttom_gift_send_unusable));
        tv_sendGift.setEnabled(enabled);
        tv_sendGift.setTextColor(enabled ? getContext().getResources().getColor(R.color.custom_dialog_txt_color_simple) : Color.WHITE);
        ll_countChooser.setEnabled(enabled);
        ll_countChooser.setBackgroundDrawable(getContext().getResources().getDrawable(
                enabled ? R.drawable.bg_live_buttom_gift_count_chooser_usuable :  R.drawable.bg_live_buttom_gift_count_chooser_unusuable
        ));
    }

    /**
     * 更新选中状态
     */
    private void updateItemViewSelectedStatus(String selectedGiftId){
        //更新选中状态
        for(LimitGiftAdapter adapter : giftAdapters){
            adapter.setSelectedGiftId(selectedGiftId);
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

    private View.OnClickListener onIndicViewClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            Integer index = (Integer)v.getTag();
            Log.d(TAG,"updateIndicatorView-onClick-index:"+index.intValue());
            sl_giftPagerContainer.setToScreen(index.intValue());
        }
    };

    /**
     * 更新指示器图标数量展示，当礼物数量发生变动的时候调用
     */
    private void updateIndicatorView(){
        ll_indicator.removeAllViews();
        int endIndex = pageCount-1;
        int indicatorWidth = DisplayUtil.dip2px(getContext(),6f);
        int indicatorMargin = DisplayUtil.dip2px(getContext(),4f);
        for(int index=0; index<pageCount; index++){
            ImageView indicator = new ImageView(getContext());
            LinearLayout.LayoutParams lp_indicator = new LinearLayout.LayoutParams(indicatorWidth, indicatorWidth);
            lp_indicator.gravity = Gravity.CENTER;
            lp_indicator.leftMargin = 0 == index ? 0 : indicatorMargin;//px 需要转换成dip单位
            lp_indicator.rightMargin = endIndex == index ? 0 : indicatorMargin;
            indicator.setLayoutParams(lp_indicator);
            indicator.setBackgroundDrawable(getContext().getResources().getDrawable(R.drawable.selector_page_indicator));
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
     * 发送礼物按钮点击事件
     * 判断当前背包礼物是否可发送
     */
    private void sendGift() {
        Log.d(TAG,"sendGift");
        //这个按钮可点击的时候，说明要么是刚开始送礼，要么是上个连送礼物动画播放过程中，切换了选择的礼物
        if (null != lastSelectedGiftItem) {
            //判断背包礼物不可发送的情况
            String numStr = tv_giftCount.getText().toString();
            Log.d(TAG, "sendGift-numStr:" + numStr);
            if (!TextUtils.isEmpty(numStr)) {
                sendGift(lastSelectedGiftItem, false, Integer.valueOf(numStr));
            }
        }
        lv_giftCount.setVisibility(View.GONE);
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
        if(limitGiftNumMap.containsKey(giftItem.id)){
            giftSender.sendBackpackGift(giftItem, isRepeat, num, limitGiftNumMap.get(giftItem.id).giftNum, this);
        }
    }

    @Override
    public void onPackReqSend(GiftItem giftItem, GiftSender.ErrorCode errorCode, String message, boolean isRepeat, int sendNum) {
        Log.d(TAG,"onPackReqSend-giftItem.id:"+giftItem.id+" errorCode:"+errorCode +" message:"+message+" isRepeat:"+isRepeat+" sendNum:"+sendNum);
        lastGiftSendNum = sendNum;
        if(GiftSender.ErrorCode.SUCCESS.equals(errorCode)){
            subPackageGiftNumById(giftItem.id,sendNum);
            //更新礼物页的选中状态，默认选中第一个
            if(!limitGiftNumMap.containsKey(giftItem.id)){
                lastSelectedGiftItem = null;
                updateRepeatAnimStatus(null, GiftSender.ErrorCode.FAILED_OTHER);
                updateGiftView();
                return;
            }else{
                //更新指定gift的totalNum
                if(currPageIndex<giftAdapters.size()){
                    giftAdapters.get(currPageIndex).notifyDataSetChanged();
                }
            }
        }
        updateRepeatAnimStatus(giftItem,errorCode);
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
                startTimer(getContext().getResources().getInteger(R.integer.repeatSendStartCount));
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
        int i = view.getId();
        if (i == R.id.tv_reloadGiftList) {
            getRoomGiftList();
            showDataTipsView();
        } else if (i == R.id.fl_giftDialogRootView) {
            dismiss();
        } else if (i == R.id.ll_repeatSendAnim) {//重置动画
            startTimer(getContext().getResources().getInteger(R.integer.repeatSendStartCount));
            Log.d(TAG, "onClick-repeatSendGift-numStr:" + lastGiftSendNum);
            sendGift(lastRepeatSentGiftItem, true, lastGiftSendNum);
        } else if (i == R.id.tv_sendGift || i == R.id.ll_sendGift) {
            //修复不可发送的礼物也会调发送礼物接口的bug
            if(tv_sendGift.isEnabled()){
                sendGift();
            }
        } else if (i == R.id.ll_countChooser) {
            if (ll_repeatSendAnim.getVisibility() == View.GONE && canOpenNumberSelector) {
                boolean isShowing = lv_giftCount.getVisibility() == View.VISIBLE;
                iv_countIndicator.setSelected(isShowing);
                lv_giftCount.setVisibility(isShowing ? View.GONE : View.VISIBLE);
            }
        }
    }

    //------------------------数据处理方法------------------------------------------
    /**
     * 通知界面背包列表数据发生更改
     */
    public void notifyLimitGiftDataChanged(){
        Log.d(TAG,"notifyLimitGiftDataChanged");
        updateLimitGiftData();
        //界面展示为loading、empty、error-reload则更新界面展示
        if(isShowing()){
            updateGiftView();
            showDataTipsView();
        }
    }

    /**
     * 更新背包礼物列表
     */
    public void updateLimitGiftData(){
        synchronized (giftLimitNumItems){
            //更新数据
            List<GiftLimitNumItem> limitGiftItems = mRoomGiftManager.getLocalRoomGiftList();
            giftLimitNumItems.clear();
            limitGiftNumMap.clear();
            //normalgiftmanager中会查询并保存allgiftdetail到本地，故只需查询本地即可
            NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
            for(GiftLimitNumItem giftLimitNumItem : limitGiftItems){
                if(giftLimitNumItem.giftNum>0){
                    if(null != normalGiftManager.getLocalGiftDetail(giftLimitNumItem.giftId)){
                        limitGiftNumMap.put(giftLimitNumItem.giftId,giftLimitNumItem);
                        giftLimitNumItems.add(giftLimitNumItem);
                    }else{
                        //礼物详情不在，本地刷新
                        normalGiftManager.getGiftDetail(giftLimitNumItem.giftId, null);
                    }
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
        Log.d(TAG,"subHangOutGiftNumById-giftId:"+giftId+" subNum:"+subNum);
        synchronized (limitGiftNumMap){
            boolean result = false;
            if(limitGiftNumMap.containsKey(giftId)){
                GiftLimitNumItem giftLimitNumItem = limitGiftNumMap.get(giftId);
                giftLimitNumItem.giftNum-=subNum;
                Log.d(TAG,"subHangOutGiftNumById-giftId:"+giftId+" giftLimitNumItem.giftNum:"+giftLimitNumItem.giftNum);
                if(giftLimitNumItem.giftNum>0){
                    limitGiftNumMap.put(giftId,giftLimitNumItem);
                }else{
                    limitGiftNumMap.remove(giftId);
                    giftLimitNumItems.remove(giftLimitNumItem);
                }
                result = true;
            }
            Log.d(TAG,"subHangOutGiftNumById-result:"+result);
            return result;
        }
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
            if(null == mActivity || null == mActivity.get()){
                return;
            }
            mActivity.get().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //记录最后一次显示
                    mLastRepeatCount = executeCount;
                    if (null != tv_timeCount) {
                        tv_timeCount.setText(String.valueOf(executeCount));
                    }
                    Log.d(TAG,"MSG_WAHT_UPDATE_COUNTER-tv_timeCount:"+executeCount);
                }
            });
        }

        @Override
        public void onTaskEnd() {
            //连送通道关闭
            lastRepeatSentGiftItem = null;
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

    /**
     * 检测并刷新数据
     */
    private void checkGiftData(){
        //增加每次点击显示，如果本地数据刷新失败（即本地无数据）则重新调接口刷新数据
        if(mRoomGiftManager != null){
            HttpReqStatus sendableGiftReqStatus = mRoomGiftManager.getRoomGiftRequestStatus();
            if(sendableGiftReqStatus == HttpReqStatus.ResFailed || sendableGiftReqStatus == HttpReqStatus.NoReq){
                getRoomGiftList();
            }else{
                //每次show方法调用的时候都重新检索以下本地详情是否存在以进行过滤显示0
                updateLimitGiftData();
            }
        }
    }

    /**
     * 同步获取直播间礼物列表
     */
    public void getRoomGiftList(){
        if(mRoomGiftManager != null){
            mRoomGiftManager.getRoomGiftList(new OnGiftLimitNumListCallback() {
                @Override
                public void onGiftLimitNumList(boolean isSuccess, int errCode, String errMsg, GiftLimitNumItem[] giftList) {
                    Log.d(TAG,"getRoomGiftList-onGiftLimitNumList:isSuccess"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                    if(null == mActivity || null == mActivity.get()){
                        return;
                    }
                    mActivity.get().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            notifyLimitGiftDataChanged();
                        }
                    });
                }
            });
        }
    }

    @Override
    public void OnSendGift(boolean success, final IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {
        Log.d(TAG,"OnSendGift-success:"+success+" errType:"+errType+" errMsg:"+errMsg+" msgItem:"+msgItem);
        //需要查询是否是大礼物发送失败，提示用户
        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS || null == msgItem || null == msgItem.giftMsgContent){
            return;
        }
        final GiftItem giftDetail = NormalGiftManager.getInstance().getLocalGiftDetail(msgItem.giftMsgContent.giftId);
        if(null == giftDetail || giftDetail.giftType != GiftItem.GiftType.Advanced || null == mActivity || null == mActivity.get()){
            return;
        }
        mActivity.get().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                updateRepeatAnimStatus(null,GiftSender.ErrorCode.FAILED_OTHER);
                //豪华非背包礼物，发送失败，弹toast，清理发送队列，关闭倒计时动画
                mActivity.get().showThreeSecondTips(mActivity.get().getResources().getString(R.string.live_gift_send_failed,giftDetail.name),
                        Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL);
            }
        });
    }

    //-----------------------------------其他用不到的接口实现------------------------------------------
    @Override
    public void OnRecvRoomCloseNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {}

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg) {}

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl,
                                      String riderId, String riderName, String riderUrl, int fansNum, boolean isHasTicket) {}

    @Override
    public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum) {}

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, IMClientListener.LCC_ERR_TYPE err, String errMsg) {}

    @Override
    public void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId) {}

    @Override
    public void OnSendRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {}

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {}

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {}

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {}

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {}

    @Override
    public void OnRecvTalentRequestNotice(String talentInvitationId, String name, String userId, String nickName) {}

    @Override
    public void OnRecvInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg,
                                             IMClientListener.IMVideoInteractiveOperateType operateType, String[] pushUrls) {}


}
