package com.qpidnetwork.liveshow.liveroom.gift.normal;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.qpidnetwork.liveshow.R;

import java.util.ArrayList;
import java.util.TimerTask;

/**
 * Created by Jagger on 2017/6/8.
 */

public class LiveGiftItemView extends LinearLayout{
    private int HOLD_TIME = 2 * 1000;           //停留在某消息的时间最大时间

    private Context mContext;
    //控件
    private LinearLayout mLinearLayoutChildView;
    private LinearLayout mLinearLayoutNum;
    private ImageView mImgx, mImg0, mImg1, mImg2, mImg3;
    private ArrayList<ImageView> mImgNums = new ArrayList<>();

    //变量
    private LiveGift mLiveGift;
    private int mShowNum = 1;
    private LinearLayout.LayoutParams mLayoutParamsImg ;
    private int mLocalInLiveGiftView ;
    private onPlayListener mOnPlayListener;
    private int mDuration4NumShow = 1000;
    private java.util.Timer mHoldingTimer;
    private TimerTask mHoldingTask;
    private PlayState mPlayState;

    enum PlayState{
        preparing,
        playing,
        end,
        waiting
    }

    public LiveGiftItemView(Context context) {
        super(context);
        init(context);
    }

    public LiveGiftItemView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public LiveGiftItemView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }


    private void init(Context context){
        mContext = context;
        mPlayState = PlayState.preparing;

        // 加载布局
        LayoutInflater.from(context).inflate(R.layout.layout_livegiftview, this);

        mLinearLayoutChildView = (LinearLayout)findViewById(R.id.childView);
        mLinearLayoutNum = (LinearLayout)findViewById(R.id.llayout_num);

        //图片大小
        mLayoutParamsImg = new LinearLayout.LayoutParams(ScreenUtils.dp2px(mContext , 20), ScreenUtils.dp2px(mContext , 40));

        //数字图片
        mImgx = (ImageView)findViewById(R.id.img_x);
        mImg0 = (ImageView)findViewById(R.id.img_0);
        mImg1 = (ImageView)findViewById(R.id.img_1);
        mImg2 = (ImageView)findViewById(R.id.img_2);
        mImg3 = (ImageView)findViewById(R.id.img_3);
        //放入列表，方便赋值
        mImgNums.add(mImg0);
        mImgNums.add(mImg1);
        mImgNums.add(mImg2);
        mImgNums.add(mImg3);

        //计时器
        mHoldingTimer = new java.util.Timer(true);
    }

    public void setLiveGift(LiveGift liveGift){
        mLiveGift = liveGift;
    }

    public LiveGift getLiveGift() {
        return mLiveGift;
    }

    public void setLocalInLiveGiftView(int mLocalInLiveGiftView) {
        this.mLocalInLiveGiftView = mLocalInLiveGiftView;
    }

    public void setOnPlayListener(onPlayListener mOnPlayListener) {
        this.mOnPlayListener = mOnPlayListener;
    }

    public void setChildView(View view){
        mLinearLayoutChildView.addView(view);
    }

    /**
     * 连击动画持续时间（毫秒）
     * @param mDuration4NumShow
     */
    public void setDuration4NumShow(int mDuration4NumShow) {
        this.mDuration4NumShow = mDuration4NumShow;
    }

    //播放连击数
    public void play(){
        if(mPlayState == PlayState.preparing){
            mShowNum = mLiveGift.getRanges().get(0).getRangeStart();
            playRangeNext();
        }else if(mPlayState == PlayState.waiting){
            playRangeNext();
        }

    }

    //播放下一个连击数动画
    private boolean playRangeNext(){
        boolean isHasNext = true;
        if(mShowNum <= mLiveGift.getRanges().get(mLiveGift.getRanges().size() - 1).getRangeEnd()){
            String number = String.valueOf(mShowNum);
            //x
            mImgx.setImageResource(R.drawable.ic_live_gift_anim_number_x);

            //将对应的数字放入对应的ImageView中
            mLayoutParamsImg.setMargins(0,0,0,0);
            for (int i = 0; i < number.length(); i++) {
                if(i < mImgNums.size()){
                    mImgNums.get(i).setImageResource(getTimerImageResId(number.charAt(i)));
                    //默认IMAGEVIEW宽度为0，有数字才变大，以免动画中心偏移了
                    mImgNums.get(i).setLayoutParams(mLayoutParamsImg);
                }
            }

            //动态扩大边距，以免动画边显示不全
            mLinearLayoutNum.setPadding(ScreenUtils.dp2px(mContext , 6*number.length()),0,ScreenUtils.dp2px(mContext , 6*number.length()),0);

            //
            playNumAnima(mLinearLayoutNum);
            mShowNum ++;
            isHasNext = true;
            mPlayState = PlayState.playing;
            stopHolingTimer();
        }else {
            isHasNext = false;
        }
        return isHasNext;
    }

    /**
     * 数字转图片资源ID
     * @param number
     * @return
     */
    private int getTimerImageResId(char number) {
        int imageResId = -1;
        switch (number) {
            case '0':
                imageResId = R.drawable.ic_live_gift_anim_number_0;
                break;
            case '1':
                imageResId = R.drawable.ic_live_gift_anim_number_1;
                break;
            case '2':
                imageResId = R.drawable.ic_live_gift_anim_number_2;
                break;
            case '3':
                imageResId = R.drawable.ic_live_gift_anim_number_3;
                break;
            case '4':
                imageResId = R.drawable.ic_live_gift_anim_number_4;
                break;
            case '5':
                imageResId = R.drawable.ic_live_gift_anim_number_5;
                break;
            case '6':
                imageResId = R.drawable.ic_live_gift_anim_number_6;
                break;
            case '7':
                imageResId = R.drawable.ic_live_gift_anim_number_7;
                break;
            case '8':
                imageResId = R.drawable.ic_live_gift_anim_number_8;
                break;
            case '9':
                imageResId = R.drawable.ic_live_gift_anim_number_9;
                break;
        }
        return imageResId;
    }

    /**
     * 播放数字动画
     * @param view
     */
    private void playNumAnima(View view)
    {
        PropertyValuesHolder pvhX = PropertyValuesHolder.ofFloat("alpha", 1f, 0.2f, 0.8f , 1f);
        PropertyValuesHolder pvhY = PropertyValuesHolder.ofFloat("scaleX", 1.5f, 0.2f, 1.5f , 1f);
        PropertyValuesHolder pvhZ = PropertyValuesHolder.ofFloat("scaleY", 1.5f, 0.2f, 1.5f , 1f);
        ObjectAnimator anim = ObjectAnimator.ofPropertyValuesHolder(view, pvhX, pvhY,pvhZ);
        anim.setDuration(mDuration4NumShow).start();
        anim.addListener(new AnimatorListenerAdapter(){
            @Override
            public void onAnimationEnd(Animator animation) {
                //播放下一个数字
                if(!playRangeNext()){
                    //如果没下一个数字
                    starHolingTimer();
                }
            }

        });
    }

    /**
     * 开启 停留计时
     */
    private void starHolingTimer(){
        if(mHoldingTimer != null){
            mPlayState = PlayState.waiting;

            if(mHoldingTask != null ){
                mHoldingTask.cancel();  //将原任务从队列中移除
            }

            mHoldingTask = new TimerTask() {
                public void run() {
                    //滑动到底
                    post(new Runnable() {
                        @Override
                        public void run() {
                            //可以结束了
                            if(mOnPlayListener != null){
                                mOnPlayListener.onPlayEnd(mLocalInLiveGiftView);
                            }
                            mPlayState = PlayState.end;
                        }
                    });

                }
            };
        }
        mHoldingTimer.schedule(mHoldingTask , HOLD_TIME);
    }

    /**
     * 停止 停留计时
     */
    private void stopHolingTimer(){
        if(mHoldingTask != null ){
            mHoldingTask.cancel();  //将原任务从队列中移除
        }
    }

    public interface onPlayListener{
        void onPlayEnd(int local);
    }

}
