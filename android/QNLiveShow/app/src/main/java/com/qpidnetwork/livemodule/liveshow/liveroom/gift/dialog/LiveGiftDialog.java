package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.graphics.Color;
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
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftTab;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.ScrollLayout;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import static com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftTab.giftTabs;

public class LiveGiftDialog extends Dialog implements View.OnClickListener,GiftSender.GiftSendResultListener{

    private final String TAG = LiveGiftDialog.class.getSimpleName();
    private WeakReference<BaseFragmentActivity> mActivity;
    private View ll_countChooser;
    private TextView tv_sendGift,tv_giftCount,tv_timeCount;
    private ImageView iv_countIndicator;
    private ScrollLayout sl_giftPagerContainer;
    private LinearLayout ll_indicator;
    private TabPageIndicator tpi_giftTypeConstainer;
    private ListView lv_giftCount;
    private TextView tv_currGold;
    private View fl_giftDialogContainer;
    private LinearLayout ll_repeatSendAnim;
    private LinearLayout ll_giftPageContainer;

    private List<GiftItem> gifts = new ArrayList<>();
    private GiftItem lastSelectedGiftItem = null;
    private GiftItem lastRepeatSentGiftItem = null;
    private GiftTab.GiftTabFlag lastClickedGiftTab = null;

    private int giftNumPerPage = 0, giftColumnNumPerPage = 0;
    private double userCoins = 0f;//float

    private List<CanAdapter> giftAdapters = new ArrayList<>();
    private GiftRepeatSendTimerManager timerManager;

    private GiftCountSelectorAdapter giftCountSelectorAdapter;
    private int dialogMaxHeight = 0;

    //定时器相关
    private long periodTime = 0;    //定时器时间间隔
    private int mLastRepeatCount = 0;   //dialog取消时，当前停留的位置
    private long mLastDismissTime = 0;   //用于Dialog重现显示，恢复之前的连击动画

    public LiveGiftDialog(BaseFragmentActivity context){
        super(context, R.style.CustomTheme_LiveGiftDialog);
        this.mActivity = new WeakReference<BaseFragmentActivity>(context);

        //计算定时器间隔
        timerManager = new GiftRepeatSendTimerManager();
        timerManager.setOnTimerTaskExecuteListener(onTimerTaskExecuteListener);
        int repeatSendStartCount = getContext().getResources().getInteger(R.integer.repeatSendStartCount);
        int repeatSendAnimTime = getContext().getResources().getInteger(R.integer.repeatSendAnimTime);
        this.periodTime = repeatSendAnimTime/repeatSendStartCount;
    }

    public void setData(List<GiftItem> giftItems){
        this.gifts.clear();
        this.gifts.addAll(giftItems);
    }

    public void setUserCoins(double userCoins){
        this.userCoins = userCoins;
        if(null != tv_currGold){
            tv_currGold.setText(String.valueOf(userCoins));
        }
    }

    public void setOnOutSideTouchEventListener(OnOutSideTouchEventListener onOutSideTouchEventListener){
        this.onOutSideTouchEventListener = onOutSideTouchEventListener;
    }

    private OnOutSideTouchEventListener onOutSideTouchEventListener;

    public interface OnOutSideTouchEventListener{
        void onOutSideTouchEvent();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        Log.d(TAG,"onBackPressed");
        if(null != onOutSideTouchEventListener){
            onOutSideTouchEventListener.onOutSideTouchEvent();
        }
    }

    @Override
    public boolean onTouchEvent(@NonNull MotionEvent event) {
        Log.d(TAG,"onTouchEvent-event.action:"+event.getAction());
        if (MotionEvent.ACTION_OUTSIDE == event.getAction()) {
            if(null != onOutSideTouchEventListener){
                onOutSideTouchEventListener.onOutSideTouchEvent();
            }
            dismiss();
            return true;
        }

        return super.onTouchEvent(event);
    }

    @Override
    protected void onStop() {
        super.onStop();
        //dismiss定时器
        stopTimer();
        ll_repeatSendAnim.setVisibility(View.GONE);
        lv_giftCount.setVisibility(View.GONE);
        tv_sendGift.setVisibility(View.VISIBLE);
        ll_countChooser.setVisibility(View.VISIBLE);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        mLastDismissTime = System.currentTimeMillis();
    }

    @Override
    public void show() {
        super.show();
        //判断是否需要重启连击动画
        long surplusTime = periodTime * mLastRepeatCount;
        long overTime = System.currentTimeMillis() - mLastDismissTime;
        if(overTime < surplusTime){
            //连击动画未结束
            long startCount = (surplusTime - overTime)/periodTime;
            startTimer((int)startCount);
            changeSendAnimVisible();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);
        initData();
        View rootView = View.inflate(getContext(),R.layout.view_live_gift_dialog,null);
        setContentView(rootView);
        initView(rootView);
    }

    private void initData(){
        giftNumPerPage = getContext().getResources().getInteger(R.integer.giftNumPerPage);
        giftColumnNumPerPage = getContext().getResources().getInteger(R.integer.giftColumnNumPerPage);
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


    private void initView(View rootView){
        Log.d(TAG,"initView");
        ll_countChooser = rootView.findViewById(R.id.ll_countChooser);
        fl_giftDialogContainer = rootView.findViewById(R.id.fl_giftDialogContainer);
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
        tv_timeCount = (TextView) rootView.findViewById(R.id.tv_timeCount);
        tv_giftCount = (TextView) rootView.findViewById(R.id.tv_giftCount);
        tv_currGold = (TextView) rootView.findViewById(R.id.tv_currGold);
        tv_currGold.setText(String.valueOf(userCoins));
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
        tpi_giftTypeConstainer = (TabPageIndicator) rootView.findViewById(R.id.tpi_giftTypeConstainer);
        ll_giftPageContainer = (LinearLayout) rootView.findViewById(R.id.ll_giftPageContainer);
        updateGiftTypeTab(giftTabs);
        updateGiftView(GiftTab.GiftTabFlag.STORE);
    }

    /**
     * 添加tab
     * @param giftTypes
     */
    private void updateGiftTypeTab(final String[] giftTypes){
        tpi_giftTypeConstainer.setTitles(giftTypes);
        tpi_giftTypeConstainer.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        tpi_giftTypeConstainer.setOnTabClickListener(new TabPageIndicator.OnTabClickListener() {
            @Override
            public void onTabClicked(int position, String tit) {
                Log.d(TAG,"onTabClicked-position:"+position);
                updateRepeatAnimStatus(null, GiftSender.ErrorCode.FAILED_OTHER);
                GiftTab.GiftTabFlag giftTab = GiftTab.GiftTabFlag.values()[position];
                if(lastClickedGiftTab != giftTab){
                    updateGiftView(giftTab);
                }
            }
        });
    }

    /**
     * 更新礼物展示界面
     */
    @SuppressLint("NewApi")
    private void updateGiftView(final GiftTab.GiftTabFlag giftTab){
        lastClickedGiftTab = giftTab;
        sl_giftPagerContainer.removeAllViews();
        giftAdapters = null == giftAdapters ? new ArrayList<CanAdapter>() : giftAdapters;
        giftAdapters.clear();
        int pageCount = (gifts.size()/giftNumPerPage)+ (0 == gifts.size()%giftNumPerPage ? 0 : 1);
        Log.d(TAG,"updateGiftView-gifts.size:"+gifts.size()+" pageCount:"+pageCount
                +" giftNumPerPage:"+giftNumPerPage);
        int lineCount = giftNumPerPage/ giftColumnNumPerPage;
        int gridViewHeight = DisplayUtil.getScreenWidth(mActivity.get())/lineCount;
        GridView gridView = null;
        for(int index=0 ; index<pageCount; index++){
            gridView = (GridView) View.inflate(mActivity.get(),R.layout.item_simple_gridview_1,null);
            int maxPagePosition = giftNumPerPage*(index+1);
            final CanAdapter<GiftItem> girdAdapter = new GiftAdapter(mActivity.get(),
                    R.layout.item_girdview_gift, gifts.subList(giftNumPerPage*index,
                            maxPagePosition<gifts.size() ? maxPagePosition : gifts.size()),giftTab);
            girdAdapter.setOnItemListener(new CanOnItemListener(){
                @Override
                public void onItemChildClick(View view, int position) {
                    final List<Integer> numList = getGiftNumList(girdAdapter.getList(),giftTab,position);
                    updateGiftCountSelected(numList,numList.size()-1);
                    updateRepeatAnimStatus(null, GiftSender.ErrorCode.FAILED_OTHER);
                    updateItemViewSelectedStatus(lastSelectedGiftItem.id);
                }
            });
            gridView.setAdapter(girdAdapter);
            giftAdapters.add(girdAdapter);
            gridView.setNumColumns(giftColumnNumPerPage);// 每行显示几个
            ViewGroup.LayoutParams gridViewLp = new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,gridViewHeight);
            Log.d(TAG,"updateGiftView-gridViewHeight:"+gridViewHeight);
            sl_giftPagerContainer.addView(gridView,gridViewLp);
        }
        //设置礼物列表滑动组件的实际高度
        LinearLayout.LayoutParams sl_lp = (LinearLayout.LayoutParams)sl_giftPagerContainer.getLayoutParams();
        sl_lp.height = gridViewHeight+sl_giftPagerContainer.getPaddingTop()+sl_giftPagerContainer.getPaddingBottom();
        sl_giftPagerContainer.setLayoutParams(sl_lp);
        updateIndicatorView(pageCount);
        //设置dialog的实际高度
        FrameLayout.LayoutParams giftPageContainerLp = (FrameLayout.LayoutParams)ll_giftPageContainer.getLayoutParams();
        ll_giftPageContainer.measure(0,0);
        dialogMaxHeight = ll_giftPageContainer.getMeasuredHeight()+giftPageContainerLp.bottomMargin;
        ViewGroup.LayoutParams fl_lp = fl_giftDialogContainer.getLayoutParams();
        fl_lp.height = dialogMaxHeight;
        Log.d(TAG,"updateGiftView-fl_lp.height:"+fl_lp.height);
        fl_giftDialogContainer.setLayoutParams(fl_lp);
        updateIndicatorStatus(0);
        //更新礼物页的选中状态，默认选中第一个
        if(gifts.size()>0){
            final List<Integer> numList = getGiftNumList(giftAdapters.get(0).getList(),giftTab,0);
            updateGiftCountSelected(numList,numList.size()-1);
            updateItemViewSelectedStatus(lastSelectedGiftItem.id);
        }
    }

    private List<Integer> getGiftNumList(List<GiftItem> subList, GiftTab.GiftTabFlag giftTab, int position){
        final List<Integer> numList = new ArrayList<Integer>();
        lastSelectedGiftItem = subList.get(position);
        for(Integer num : lastSelectedGiftItem.giftChooser){
            numList.add(num);
        }
        return numList;
    }

    /**
     * 更新选中状态
     */
    private void updateItemViewSelectedStatus(String selectedGiftId){
        GiftAdapter.selectedGiftId = selectedGiftId;
        for(CanAdapter giftAdapter : giftAdapters){
            giftAdapter.notifyDataSetChanged();
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
            tv_sendGift.setVisibility(lastSelectedGiftItem.id == lastRepeatSentGiftItem.id ? View.GONE : View.VISIBLE);
            ll_countChooser.setVisibility(lastSelectedGiftItem.id == lastRepeatSentGiftItem.id ? View.GONE : View.VISIBLE);
        }else{
            ll_repeatSendAnim.setVisibility(View.GONE);
            tv_sendGift.setVisibility(View.VISIBLE);
            ll_countChooser.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 更新指示器图标数量展示，当礼物数量发生变动的时候调用
     * @param pageCount 礼物页数
     */
    private void updateIndicatorView(int pageCount){
        ll_indicator.removeAllViews();
        int endIndex = pageCount-1;
        int indicatorWidth = DisplayUtil.dip2px(mActivity.get(),6f);
        int indicatorMargin = DisplayUtil.dip2px(mActivity.get(),4f);
        View.OnClickListener onClickListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Integer index = (Integer)v.getTag();
                updateIndicatorView(index);
                sl_giftPagerContainer.setToScreen(index.intValue());
            }
        };
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
            indicator.setOnClickListener(onClickListener);
            ll_indicator.addView(indicator);
        }
    }

    /**
     * 更新指示器状态
     * @param selectedIndex 当前礼物页索引
     */
    private void updateIndicatorStatus(int selectedIndex){
        int pageCount = ll_indicator.getChildCount();
        for(int index = 0; index<pageCount; index++){
            View view = ll_indicator.getChildAt(index);
            if(null != view && View.VISIBLE == view.getVisibility()){
                view.setSelected(selectedIndex == index);
            }
        }
        View view = ll_indicator.getChildAt(selectedIndex);
        if(null != view){
           view.callOnClick();
        }
    }

    /**
     * 送礼(调接口)
     * @param isRepeat 连送标识
     */
    private void sendGift(boolean isRepeat){
        if(lastClickedGiftTab == GiftTab.GiftTabFlag.STORE){
            GiftSender.getInstance().sendStoreGift(lastSelectedGiftItem, isRepeat,
                    Integer.valueOf(tv_giftCount.getText().toString()), this);
        }else{
            GiftSender.getInstance().sendBackpackGift(lastSelectedGiftItem, isRepeat,
                    Integer.valueOf(tv_giftCount.getText().toString()), this);
        }
    }

    @Override
    public void onGiftReqSent(GiftItem giftItem, GiftSender.ErrorCode errorCode,
                              String message, double localCoins, boolean isRepeat) {
        //1.如果是首次发送，那么因为有本地金币数量的判断，所以也该有本地金币数量更新的逻辑
        if(!isRepeat){
            setUserCoins(localCoins);
        }
        updateRepeatAnimStatus(giftItem,errorCode);
        if(!GiftSender.ErrorCode.SUCCESS.equals(errorCode) && null != message){
            Toast.makeText(mActivity.get(),message,Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void onPackReqSend(GiftItem giftItem, GiftSender.ErrorCode errorCode,
                              String message, boolean isRepeat) {
        updateRepeatAnimStatus(giftItem,errorCode);
        if(!GiftSender.ErrorCode.SUCCESS.equals(errorCode) && null != message){
            Toast.makeText(mActivity.get(),message,Toast.LENGTH_SHORT).show();
        }
        //更新数量
        for(CanAdapter adapter : giftAdapters){
            adapter.notifyDataSetChanged();
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
            case R.id.ll_repeatSendAnim:
                //重置动画
                startTimer(getContext().getResources().getInteger(R.integer.repeatSendStartCount));
                sendGift(true);
                break;
            case R.id.tv_sendGift:
                //这个按钮可点击的时候，说明要么是刚开始送礼，要么是上个连送礼物动画播放过程中，切换了选择的礼物
                if(null != lastSelectedGiftItem){
                    sendGift(false);
                }
                lv_giftCount.setVisibility(View.GONE);
                break;
            case R.id.ll_countChooser:
                if(ll_repeatSendAnim.getVisibility() == View.GONE){
                    boolean isShowing = lv_giftCount.getVisibility() == View.VISIBLE;
                    iv_countIndicator.setSelected(isShowing);
                    lv_giftCount.setVisibility(isShowing ? View.GONE : View.VISIBLE);
//                    Toast.makeText(getContext(),"tv_giftCount",Toast.LENGTH_SHORT).show();
                }
                break;
        }
    }

    /******************************* 定时器相关  *************************************/
    /**
     * 指定初始位置启动定时器
     * @param startCount
     */
    private void startTimer(int startCount){
        if(timerManager != null){
            timerManager.start(startCount, periodTime);
        }
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
}
