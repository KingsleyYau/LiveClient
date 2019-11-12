package com.qpidnetwork.livemodule.framework.livemsglist;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.livemsglist.interfaces.IListFunction;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * 可扩展的列表控件
 * Created by Jagger on 2017/6/2.
 */

public class LiveMessageListView extends FrameLayout implements IListFunction {

    private MessageRecyclerView mMessageRecyclerView;
    private TextView mUnreadTxt ;
    private Drawable mUnreadTxtBgDrawable;
    private String TAG = LiveMessageListView.class.getSimpleName();

    public MessageRecyclerView.onMsgUnreadListener onMsgUnreadListener= new MessageRecyclerView.onMsgUnreadListener() {
        @SuppressLint("NewApi")
        @Override
        public void onMsgUnreadSum(int unreadSum) {
            if(mUnreadTxtBgDrawable != null){
                mUnreadTxt.setBackground(mUnreadTxtBgDrawable);
            }
            if(null != mUnreadTxt){
                mUnreadTxt.setText(String.valueOf(unreadSum));
                mUnreadTxt.setVisibility(View.VISIBLE);
            }
        }

        @Override
        public void onReadAll() {
            if(null != mUnreadTxt){
                mUnreadTxt.setText("");
                mUnreadTxt.setVisibility(View.INVISIBLE);
            }
        }
    };

    /**
     * 读取最新未读消息
     */
    public void loadNewestUnreadMsg(){
//        Log.d(TAG,"loadNewestUnreadMsg");
        mMessageRecyclerView.loadNewestUnreadMsg();
    }

    /**
     * 设置未读消息监听
     * @param onMsgUnreadListener
     */
    public void setOnMsgUnreadListener(MessageRecyclerView.onMsgUnreadListener onMsgUnreadListener){
        this.onMsgUnreadListener = onMsgUnreadListener;
        mMessageRecyclerView.setOnMsgUnreadListener(onMsgUnreadListener);
    }

    public void setGradualColor(int gradualColor){
        this.mMessageRecyclerView.setGradualColor(gradualColor);
    }

    public LiveMessageListView(Context context) {
        super(context);
        init(context);
    }

    public LiveMessageListView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public LiveMessageListView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

//    public LiveMessageListView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
//        super(context, attrs, defStyleAttr, defStyleRes);
//    }


    public void addItemDecoration(RecyclerView.ItemDecoration itemDecoration){
        mMessageRecyclerView.addItemDecoration(itemDecoration);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        //可以取得自己高度
//        Log.i("Jagger" , "zzzzzzzzz:"+getLayoutParams().height);
    }

    private void init(Context context){
        //列表
        mMessageRecyclerView = new MessageRecyclerView(context);
        LayoutParams listLP = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        listLP.gravity = Gravity.BOTTOM;                            //for FrameLayout
//        listLP.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);       //for RelativeLayout
        mMessageRecyclerView.setLayoutParams(listLP);
        mMessageRecyclerView.setOnMsgUnreadListener(onMsgUnreadListener);
        //未读提示
        mUnreadTxt = new TextView(context);
        LayoutParams txtLP = new LayoutParams(80,80);
        listLP.gravity = Gravity.BOTTOM;                            //for FrameLayout
//        txtLP.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);        //for RelativeLayout
        mUnreadTxt.setLayoutParams(txtLP);
        mUnreadTxt.setText("??");
        mUnreadTxt.setTextColor(getResources().getColor(R.color.text_color_dark));
        mUnreadTxt.setBackgroundResource(R.drawable.livemessagelist_paopao_default);
        mUnreadTxt.setGravity(Gravity.CENTER);
        mUnreadTxt.setVisibility(View.INVISIBLE);

        this.addView(mMessageRecyclerView);
        this.addView(mUnreadTxt);

        //关闭滚动条
        mMessageRecyclerView.setOverScrollMode(View.OVER_SCROLL_NEVER);
    }

    @Override
    public void setAdapter(LiveMessageListAdapter adapter) {
        mMessageRecyclerView.setAdapter(adapter);
    }

    public void setVerticalSpace(int space){
        Log.d(TAG,"setVerticalSpace-space:"+space);
        mMessageRecyclerView.setVerticalSpace(space);
    }

    @Override
    public void addNewLiveMsg(Object item) {
        mMessageRecyclerView.addNewLiveMsg(item);
    }

    /**
     * 获取本地缓存的最后一条数据
     * @return
     */
    public Object getLastData(){
        Object item = null;
        if(mMessageRecyclerView != null){
            item = mMessageRecyclerView.getLastDataItem();
        }
        return item;
    }

    /**
     * 列表阅读状态
     * @return
     */
    public MessageRecyclerView.ReadingStatus getReadingStatus(){
        return mMessageRecyclerView.getReadingStatus();
    }

    @Override
    public void setMaxMsgSum(int maxMsgSum) {
        mMessageRecyclerView.setMaxMsgSum(maxMsgSum);
    }

    @Override
    public void setHoldingTime(int time) {
        mMessageRecyclerView.setHoldingTime(time);
    }

    @Override
    public void setDisplayDirection(MessageRecyclerView.DisplayDirection displayDirection) {
        mMessageRecyclerView.setDisplayDirection(displayDirection);
    }

    /**
     * 未读数背景图
     * @param drawable
     */
    public void setUnreadTxtBgDrawable(Drawable drawable){
        mUnreadTxtBgDrawable = drawable;
    }


    /**
     * 2019/4/22 Hardy
     */
    public void onDestroy(){
        if (mMessageRecyclerView != null) {
            mMessageRecyclerView.onDestroy();
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        //可视状态影响是否统计未读数逻辑
        mMessageRecyclerView.setVisibility(visibility);
    }
}
