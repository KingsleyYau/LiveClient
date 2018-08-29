package com.qpidnetwork.anchor.framework.livemsglist;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.livemsglist.interfaces.IListFunction;
import com.qpidnetwork.anchor.utils.Log;

/**
 * 可扩展的列表控件
 * Created by Jagger on 2017/6/2.
 */

public class LiveMessageListView extends RelativeLayout implements IListFunction {

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

    private void init(Context context){
        //列表
        mMessageRecyclerView = new MessageRecyclerView(context);
        LayoutParams listLP = new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.WRAP_CONTENT);
        listLP.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        mMessageRecyclerView.setLayoutParams(listLP);
        mMessageRecyclerView.setOnMsgUnreadListener(onMsgUnreadListener);
        //未读提示
        mUnreadTxt = new TextView(context);
        LayoutParams txtLP = new LayoutParams(80,80);
        txtLP.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        mUnreadTxt.setLayoutParams(txtLP);
        mUnreadTxt.setText("??");
        mUnreadTxt.setBackgroundResource(R.drawable.livemessagelist_paopao2);
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

    public void setMaxHeight(int height){

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

    @Override
    public void setMaxMsgSum(int maxMsgSum) {
        mMessageRecyclerView.setMaxMsgSum(maxMsgSum);
    }

    @Override
    public void setHoldingTime(int time) {
        mMessageRecyclerView.setHoldingTime(time);
    }

    /**
     * 未读数背景图
     * @param drawable
     */
    public void setUnreadTxtBgDrawable(Drawable drawable){
        mUnreadTxtBgDrawable = drawable;
    }

}
