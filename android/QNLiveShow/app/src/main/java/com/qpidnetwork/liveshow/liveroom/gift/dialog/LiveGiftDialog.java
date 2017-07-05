package com.qpidnetwork.liveshow.liveroom.gift.dialog;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.httprequest.item.GiftItem;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.utils.DisplayUtil;
import com.qpidnetwork.view.ScrollLayout;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.qpidnetwork.utils.DisplayUtil.getResources;


public class LiveGiftDialog extends Dialog implements View.OnClickListener{

    private final String TAG = LiveGiftDialog.class.getSimpleName();
    private WeakReference<BaseFragmentActivity> mActivity;
    private View ll_countChooser;
    private TextView tv_sendGift,tv_giftCount,tv_timeCount;
    private ImageView iv_countIndicator;
    private ScrollLayout sl_giftPagerContainer;
    private LinearLayout ll_indicator;
    private List<String> giftCountItems = new ArrayList<>();
    private LinearLayout ll_repeatSendAnim;
    private List<GiftItem> giftItems = new ArrayList<GiftItem>();
    private GiftItem lastSelectedGiftItem = null;
    private GiftItem lastRepeatSentGiftItem = null;
    private boolean isRepeatSendAnimNow = false;
    private ListView lv_giftCount;
    private int repeatSendStartCount,repeatSendAnimTime;
    private int giftNumPerPage = 0, giftLineNumPerPage = 0;
    private double userCoins = 0f;//float
    private TextView tv_currGold;
    private List<GiftAdapter> giftAdapters = new ArrayList<>();
    private GiftRepeatSendTimerManager timerManager;

    public LiveGiftDialog(BaseFragmentActivity context){
        super(context, R.style.CustomTheme_LiveGiftDialog);
        this.mActivity = new WeakReference<BaseFragmentActivity>(context);
    }

    public void setGiftItems(GiftItem[] allGiftList){
        if(null != allGiftList && allGiftList.length>0){
            giftItems = Arrays.asList(allGiftList);
        }
    }

    public void setUserCoins(double userCoins){
        this.userCoins = userCoins;
        if(null != tv_currGold){
//            tv_currGold.setText(String.valueOf(userCoins));
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
        if(null != timerManager){
            timerManager.stop();
        }
        ll_repeatSendAnim.setVisibility(View.GONE);
        lv_giftCount.setVisibility(View.GONE);
        tv_sendGift.setVisibility(View.VISIBLE);
        ll_countChooser.setVisibility(View.VISIBLE);
    }

    @Override
    public void dismiss() {
        super.dismiss();
    }

    @Override
    public void show() {
        super.show();
        changeSendAnimVisible();
        if(null != timerManager){
            timerManager.resume();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");
        // Make us non-modal, so that others can receive touch events.
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL, WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        // ...but notify us that it happened.
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH, WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);
        initData();
        View rootView = View.inflate(getContext(),R.layout.view_live_gift_dialog,null);
        initView(rootView);
        setContentView(rootView);
        getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    private void initData(){
        giftNumPerPage = getContext().getResources().getInteger(R.integer.giftNumPerPage);
        giftLineNumPerPage = getContext().getResources().getInteger(R.integer.giftLineNumPerPage);
    }

    private void initView(View rootView){
        giftCountItems = Arrays.asList(getContext().getResources().getStringArray(R.array.giftCountListData));
        ll_countChooser = rootView.findViewById(R.id.ll_countChooser);
        lv_giftCount = (ListView) rootView.findViewById(R.id.lv_giftCount);
        final GiftCountSelectorAdapter giftCountSelectorAdapter = new GiftCountSelectorAdapter(mActivity.get(), R.layout.item_simple_list_gift_count, giftCountItems);
        lv_giftCount.setAdapter(giftCountSelectorAdapter);
        lv_giftCount.setVisibility(View.GONE);
        giftCountSelectorAdapter.setOnItemListener(new CanOnItemListener(){
            @Override
            public void onItemChildClick(View view, int position) {
                lv_giftCount.setVisibility(View.GONE);
                iv_countIndicator.setSelected(true);
                tv_giftCount.setText(giftCountItems.get(position));
                Toast.makeText(mActivity.get(), giftCountItems.get(position), Toast.LENGTH_SHORT).show();
                giftCountSelectorAdapter.setSelectedPosition(position);
                giftCountSelectorAdapter.notifyDataSetChanged();

            }
        });
        ll_countChooser.setOnClickListener(this);
        iv_countIndicator = (ImageView) rootView.findViewById(R.id.iv_countIndicator);
        iv_countIndicator.setSelected(true);
        tv_sendGift = (TextView) rootView.findViewById(R.id.tv_sendGift);
        tv_timeCount = (TextView) rootView.findViewById(R.id.tv_timeCount);
        tv_giftCount = (TextView) rootView.findViewById(R.id.tv_giftCount);
        tv_giftCount.setText(giftCountItems.get(0));
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
        updateGiftView();
        tv_sendGift.setOnClickListener(this);
    }

    /**
     * 更新礼物展示界面
     */
    @SuppressLint("NewApi")
    private void updateGiftView(){
        sl_giftPagerContainer.removeAllViews();
        if(null == giftAdapters){
            giftAdapters = new ArrayList<>();
        }
        giftAdapters.clear();
        int pageCount = (giftItems.size()/giftNumPerPage)+ (0 == giftItems.size()%giftNumPerPage ? 0 : 1);
        Log.d(TAG,"updateGiftView-giftItems.size:"+giftItems.size()+" pageCount:"+pageCount+" giftNumPerPage:"+giftNumPerPage);
        int lineCount = giftNumPerPage/ giftLineNumPerPage;
        int gridViewHeight = DisplayUtil.getScreenWidth(mActivity.get())/lineCount;
        GridView gridView = null;
        for(int index=0 ; index<pageCount; index++){
            gridView = (GridView) View.inflate(mActivity.get(),R.layout.item_simple_gridview_1,null);
            int maxPagePosition = giftNumPerPage*(index+1);
            final GiftAdapter girdAdapter = new GiftAdapter(mActivity.get(),R.layout.item_girdview_gift,
                    giftItems.subList(giftNumPerPage*index,maxPagePosition<giftItems.size() ? maxPagePosition : giftItems.size()));
            girdAdapter.setOnItemListener(new CanOnItemListener(){
                @Override
                public void onItemChildClick(View view, int position) {
                    GiftItem item = (GiftItem) girdAdapter.getItem(position);
                    lastSelectedGiftItem = item;

                    changeSendAnimVisible();
                    updateItemViewSelectedStatus(lastSelectedGiftItem.id);
                }
            });
            gridView.setAdapter(girdAdapter);
            giftAdapters.add(girdAdapter);
            gridView.setNumColumns(giftLineNumPerPage);// 每行显示几个
            ViewGroup.LayoutParams gridViewLp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.WRAP_CONTENT);
            gridView.setLayoutParams(gridViewLp);
            Log.d(TAG,"updateGiftView-gridViewHeight:"+gridViewHeight);
            gridViewLp = gridView.getLayoutParams();
            //设置每个GridView相同的高度
            gridViewLp.height = gridViewHeight;
            gridView.setLayoutParams(gridViewLp);
            sl_giftPagerContainer.addView(gridView);
        }
        ViewGroup.LayoutParams sl_lp = sl_giftPagerContainer.getLayoutParams();
        sl_lp.height = gridViewHeight+sl_giftPagerContainer.getPaddingTop()+sl_giftPagerContainer.getPaddingBottom();
        sl_giftPagerContainer.setLayoutParams(sl_lp);
        updateIndicatorView(pageCount);
        updateIndicatorStatus(0);
        if(giftItems.size()>0){//默认选中第一个
            lastSelectedGiftItem = giftItems.get(0);
            updateItemViewSelectedStatus(lastSelectedGiftItem.id);
        }

    }

    /**
     * 更新选中状态
     */
    private void updateItemViewSelectedStatus(String selectedGiftId){
        GiftAdapter.selectedGiftId = selectedGiftId;
        for(GiftAdapter giftAdapter : giftAdapters){
            giftAdapter.notifyDataSetChanged();
        }
    }

    /**
     * 更新连送按钮的显示状态
     */
    private void changeSendAnimVisible(){
        Log.d(TAG,"changeSendAnimVisible");
        iv_countIndicator.setSelected(true);
        if(isRepeatSendAnimNow){
            ll_repeatSendAnim.setVisibility(lastSelectedGiftItem.id == lastRepeatSentGiftItem.id ? View.VISIBLE : View.GONE);
            tv_sendGift.setVisibility(lastSelectedGiftItem.id == lastRepeatSentGiftItem.id ? View.GONE : View.VISIBLE);
            ll_countChooser.setVisibility(lastSelectedGiftItem.id == lastRepeatSentGiftItem.id ? View.GONE : View.VISIBLE);
        }else{
            boolean noRepeatSent = null == lastRepeatSentGiftItem;
            ll_repeatSendAnim.setVisibility(noRepeatSent ? View.GONE : View.VISIBLE);
            tv_sendGift.setVisibility(noRepeatSent ? View.VISIBLE : View.GONE);
            ll_countChooser.setVisibility(noRepeatSent ? View.VISIBLE : View.GONE);
        }
    }

    private OnTimerTaskExecuteListener onTimerTaskExecuteListener = new OnTimerTaskExecuteListener() {
        @Override
        public void onTaskExecute(final int executeCount) {
            //两种更新textView的方式，目前这两种都存在一个bug，
            // 就是第一次进入activity，点击连送，关闭activity并再次进入，再次连送时textView就更新不了了
//                    if(null != mActivity && null != mActivity.get()){
//                        mActivity.get().runOnUiThread(new Runnable() {
//                            @Override
//                            public void run() {
//                                Log.d(TAG,"runOnUiThread-tv_timeCount.vibility:"+(tv_timeCount.getVisibility() == View.VISIBLE));
//                                synchronized (tv_timeCount){
//                                    if(null != tv_timeCount){
//                                        tv_timeCount.setText(String.valueOf(executeCount));
//                                    }
//                                }
//                            }
//                        });
//                    }
            Message msg = mmHandler.obtainMessage(MSG_WAHT_UPDATE_COUNTER);
            msg.arg1 = executeCount;
            mmHandler.sendMessage(msg);
        }

        @Override
        public void onTaskEnd() {
            isRepeatSendAnimNow = false;
            timerManager.stop();
            //连送通道关闭
            lastRepeatSentGiftItem = null;
//                    mActivity.get().runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            changeSendAnimVisible();
//                        }
//                    });
            mmHandler.sendMessage(mmHandler.obtainMessage(MSG_WAHT_END_COUNTER));


        }
    };

    /**
     * 开启连送通道按钮倒计时动画
     */
    private void startRepeatSendAnimTask(){
        repeatSendStartCount = getContext().getResources().getInteger(R.integer.repeatSendStartCount);
        repeatSendAnimTime = getContext().getResources().getInteger(R.integer.repeatSendAnimTime);
        if(null == timerManager){
            timerManager = GiftRepeatSendTimerManager.getInstance();
        }
        timerManager.setOnTimerTaskExecuteListener(onTimerTaskExecuteListener);
        timerManager.start(repeatSendStartCount, repeatSendAnimTime);
        isRepeatSendAnimNow = true;
    }


    private final int MSG_WAHT_UPDATE_COUNTER = 1;
    private final int MSG_WAHT_END_COUNTER = 2;
    private Handler mmHandler = new Handler() {
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_WAHT_UPDATE_COUNTER:
//                    if (null != tv_timeCount) {
//                        tv_timeCount.setText(String.valueOf(msg.arg1));
//                    }
                    String timeCount = String.valueOf(msg.arg1);
                    Log.d(TAG,"MSG_WAHT_UPDATE_COUNTER-tv_timeCount:"+timeCount);
                    ((TextView)findViewById(R.id.tv_timeCount)).setText(timeCount);
                    ((TextView)findViewById(R.id.tv_timeCount)).setTextColor(Color.parseColor("#383838"));
                    tv_currGold.setText(String.valueOf(timeCount));
                    break;
                case MSG_WAHT_END_COUNTER:
                    changeSendAnimVisible();
                    break;
                default:
                    super.handleMessage(msg);
                    break;
            }
        }
    };
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
            LinearLayout.LayoutParams lp_indicator = new LinearLayout.LayoutParams(indicatorWidth, indicatorWidth);
            lp_indicator.gravity = Gravity.CENTER;
            lp_indicator.leftMargin = 0 == index ? 0 : indicatorMargin;//px 需要转换成dip单位
            lp_indicator.rightMargin = endIndex == index ? 0 : indicatorMargin;
            indicator.setLayoutParams(lp_indicator);
            indicator.setBackgroundDrawable(getResources().getDrawable(R.drawable.selector_page_indicator));
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
            if(View.VISIBLE == view.getVisibility()){
                view.setSelected(selectedIndex == index);
            }
        }
    }

    private int lastSentGiftTotalNum = 0;
    private int mMultiClickId = 0;

    /**
     * 送礼(调接口+动画展示)
     * @param isRepeat 连送标识
     * @param showGiftAnimDirect 是否直接显示送礼动画，不论送礼接口是否调用成功？
     */
    private void sendGift(boolean isRepeat, boolean showGiftAnimDirect){
        int multi_click_start = 0;
        int multi_click_end = 0;
        if(isRepeat){
            lastSentGiftTotalNum+=1;
            multi_click_start = lastSentGiftTotalNum;
            multi_click_end = lastSentGiftTotalNum;
        }else{
            //每次重新开始发送，重新生成
            mMultiClickId = (int)(System.currentTimeMillis()/1000);
            multi_click_start = 1;
            lastSentGiftTotalNum = Integer.valueOf(tv_giftCount.getText().toString());
            multi_click_end = lastSentGiftTotalNum;
        }

        //通知发送
        if(null != liveGiftSentListener && lastSelectedGiftItem != null){
            boolean isMultiClick = true;
            if(lastSelectedGiftItem.giftType == GiftItem.GiftType.AdvancedAnimation){
                isMultiClick = false;
            }
            liveGiftSentListener.onGiftSent(lastSelectedGiftItem, isMultiClick, multi_click_start, multi_click_end, mMultiClickId);
        }
    }

    @Override
    public void onClick(View view){
        switch (view.getId()){
            case R.id.ll_repeatSendAnim:
                startRepeatSendAnimTask();
                sendGift(true,false);
                break;
            case R.id.tv_sendGift:
                //这个按钮可点击的时候，说明要么是刚开始送礼，要么是上个连送礼物动画播放过程中，切换了选择的礼物
                if(null != lastSelectedGiftItem){
                    isRepeatSendAnimNow = false;
                    if(lastSelectedGiftItem.multiClickable){
                        lastRepeatSentGiftItem = lastSelectedGiftItem;
                        changeSendAnimVisible();
                        startRepeatSendAnimTask();
                    }else if(null != lastRepeatSentGiftItem && lastRepeatSentGiftItem.id != lastSelectedGiftItem.id){
                        lastRepeatSentGiftItem = null;
                        if(null != timerManager){
                            timerManager.stop();
                        }
                        changeSendAnimVisible();
                    }

                    sendGift(false,false);
                }
                break;
            case R.id.ll_countChooser:
                if(ll_repeatSendAnim.getVisibility() == View.GONE){
                    boolean isShowing = lv_giftCount.getVisibility() == View.VISIBLE;
                    iv_countIndicator.setSelected(isShowing);
                    lv_giftCount.setVisibility(isShowing ? View.GONE : View.VISIBLE);
                    Toast.makeText(getContext(),"tv_giftCount",Toast.LENGTH_SHORT).show();
                }
                break;
        }
    }



    private OnLiveGiftSentListener liveGiftSentListener;
    public void setLiveGiftSentListener(OnLiveGiftSentListener liveGiftSentListener){
        this.liveGiftSentListener = liveGiftSentListener;
    }


}
