package com.qpidnetwork.anchor.liveshow.liveroom.gift.normal;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.DecelerateInterpolator;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.qpidnetwork.anchor.R;

import java.util.ArrayList;

/**
 * Created by Jagger on 2017/6/8.
 */

public class LiveGiftItemView extends LinearLayout{
    private int HOLD_TIME = 2 * 1000;           //停留在某消息的时间最大时间

    private Context mContext;
    //控件
    private View ll_giftItemParentView;
    private LinearLayout mLinearLayoutChildView;
    private LinearLayout ll_bg;
    private RelativeLayout mLinearLayoutNum;

    private ImageView mImgx, mImg0, mImg1, mImg2, mImg3;
    private ArrayList<ImageView> mImgNums = new ArrayList<>();

    //变量
    private LiveGift mLiveGift;
    private int mShowNum = 1;
    private int mLocalInLiveGiftView ;
    private onPlayListener mOnPlayListener;
    private int mDuration4NumShow = 1000;
    private PlayState mPlayState;
    private AnimatorSet mAnimatorSet;
    private boolean isDetachWindow = false; //是否已删除
    private int imgXResId = -1, img0ResId = -1, img1ResId = -1, img2ResId = -1, img3ResId = -1, img4ResId = -1, img5ResId = -1, img6ResId = -1, img7ResId = -1, img8ResId = -1, img9ResId = -1; //外部自定义连击数字图片资源ID

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
        ll_bg = findViewById(R.id.ll_bg);
        ll_giftItemParentView = findViewById(R.id.ll_giftItemParentView);
        mLinearLayoutNum = (RelativeLayout)findViewById(R.id.llayout_num);

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
    }

    //------------------- 外部使用方法 start -------------------
    public void setLiveGift(LiveGift liveGift){
        mLiveGift = liveGift;
    }

    public void setChildView(View view){
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                mContext.getResources().getDimensionPixelSize(R.dimen.liveroom_mulitgift_height));
        mLinearLayoutChildView.addView(view,lp);
    }

    /**
     * 由于外部定义礼物布局和礼物X数字动画都在礼物背景之上，所以背景不能为外部定义礼物布局，要另外设置
     * @param background
     */
    public void setBg(Drawable background){
        ll_bg.setBackgroundDrawable(background);
    }

    /**
     * 自定义连击数字图片资源ID （X）
     * @param imgXResId
     */
    public void setImgXResId(int imgXResId) {
        this.imgXResId = imgXResId;
    }

    /**
     * 自定义连击数字图片资源ID （0）
     */
    public void setImg0ResId(int img0ResId) {
        this.img0ResId = img0ResId;
    }

    /**
     * 自定义连击数字图片资源ID （1）
     */
    public void setImg1ResId(int img1ResId) {
        this.img1ResId = img1ResId;
    }

    /**
     * 自定义连击数字图片资源ID （2）
     */
    public void setImg2ResId(int img2ResId) {
        this.img2ResId = img2ResId;
    }

    /**
     * 自定义连击数字图片资源ID （3）
     */
    public void setImg3ResId(int img3ResId) {
        this.img3ResId = img3ResId;
    }

    /**
     * 自定义连击数字图片资源ID （4）
     */
    public void setImg4ResId(int img4ResId) {
        this.img4ResId = img4ResId;
    }

    /**
     * 自定义连击数字图片资源ID （5）
     */
    public void setImg5ResId(int img5ResId) {
        this.img5ResId = img5ResId;
    }

    /**
     * 自定义连击数字图片资源ID （6）
     */
    public void setImg6ResId(int img6ResId) {
        this.img6ResId = img6ResId;
    }

    /**
     * 自定义连击数字图片资源ID （7）
     */
    public void setImg7ResId(int img7ResId) {
        this.img7ResId = img7ResId;
    }

    /**
     * 自定义连击数字图片资源ID （8）
     */
    public void setImg8ResId(int img8ResId) {
        this.img8ResId = img8ResId;
    }

    /**
     * 自定义连击数字图片资源ID （9）
     */
    public void setImg9ResId(int img9ResId) {
        this.img9ResId = img9ResId;
    }

    //------------------- 外部使用方法 end -------------------

    public LiveGift getLiveGift() {
        return mLiveGift;
    }

    public void setLocalInLiveGiftView(int mLocalInLiveGiftView) {
        this.mLocalInLiveGiftView = mLocalInLiveGiftView;
    }

    public void setOnPlayListener(onPlayListener mOnPlayListener) {
        this.mOnPlayListener = mOnPlayListener;
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
        //取出list列表的最后一个,比较是否显示到了连击数的最大边界值
        if(mShowNum <= mLiveGift.getRanges().get(mLiveGift.getRanges().size() - 1).getRangeEnd()){
            String number = String.valueOf(mShowNum);
            //x
            if(imgXResId != -1){
                mImgx.setImageResource(imgXResId);
            }else{
                mImgx.setImageResource(R.drawable.ic_live_gift_anim_number_x);
            }


            //将对应的数字放入对应的ImageView中
            for (int i = 0; i < number.length(); i++) {
                if(i < mImgNums.size()){
                    mImgNums.get(i).setImageResource(getTimerImageResId(number.charAt(i)));
                }
            }
            //动态扩大边距，以免动画边显示不全
//            mLinearLayoutNum.setPadding(ScreenUtils.dp2px(mContext , 6*number.length()),0,ScreenUtils.dp2px(mContext , 6*number.length()),0);
            //播放数字动画
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
                if(img0ResId != -1){
                    imageResId = img0ResId;
                }else{
                    imageResId = R.drawable.ic_live_gift_anim_number_0;
                }
                break;
            case '1':
                if(img1ResId != -1){
                    imageResId = img1ResId;
                }else {
                    imageResId = R.drawable.ic_live_gift_anim_number_1;
                }
                break;
            case '2':
                if(img2ResId != -1){
                    imageResId = img2ResId;
                }else {
                    imageResId = R.drawable.ic_live_gift_anim_number_2;
                }
                break;
            case '3':
                if(img3ResId != -1){
                    imageResId = img3ResId;
                }else {
                    imageResId = R.drawable.ic_live_gift_anim_number_3;
                }
                break;
            case '4':
                if(img4ResId != -1){
                    imageResId = img4ResId;
                }else {
                    imageResId = R.drawable.ic_live_gift_anim_number_4;
                }
                break;
            case '5':
                if(img5ResId != -1){
                    imageResId = img5ResId;
                }else {
                    imageResId = R.drawable.ic_live_gift_anim_number_5;
                }
                break;
            case '6':
                if(img6ResId != -1){
                    imageResId = img6ResId;
                }else {
                    imageResId = R.drawable.ic_live_gift_anim_number_6;
                }
                break;
            case '7':
                if(img7ResId != -1){
                    imageResId = img7ResId;
                }else {
                    imageResId = R.drawable.ic_live_gift_anim_number_7;
                }
                break;
            case '8':
                if(img8ResId != -1){
                    imageResId = img8ResId;
                }else {
                    imageResId = R.drawable.ic_live_gift_anim_number_8;
                }
                break;
            case '9':
                if(img9ResId != -1){
                    imageResId = img9ResId;
                }else {
                    imageResId = R.drawable.ic_live_gift_anim_number_9;
                }
                break;
        }
        return imageResId;
    }

    /**
     * 播放数字动画
     * @param view
     */
    private void playNumAnima(View view) {
        //自己写的第一种方式
//        AnimationSet animationSet = (AnimationSet) AnimationUtils.loadAnimation(mContext, R.anim.anim_gift_view);
//        animationSet.setAnimationListener(new Animation.AnimationListener(){
//            @Override
//            public void onAnimationStart(Animation animation) {
//
//            }
//
//            @Override
//            public void onAnimationEnd(Animation animation) {
//                //播放下一个数字
//                if(!playRangeNext()){
//                    //如果没下一个数字
//                    starHolingTimer();
//                }
//            }
//
//            @Override
//            public void onAnimationRepeat(Animation animation) {
//
//            }
//        });
////        animationSet.setDuration(980l);//mDuration4NumShow
//        view.startAnimation(animationSet);

        //自己写的第2种方式<该方式已在UI基本确认的基础上>
        //设置旋转与缩放动画的中心点
        view.setPivotX(view.getWidth()/4);
        view.setPivotY(view.getHeight()/4);
//        ObjectAnimator animator1 = ObjectAnimator.ofFloat(view, "alpha", 0.5f/*, 0.3f, 0.5f */, 0.7f, 1f);
        ObjectAnimator animator1 = ObjectAnimator.ofFloat(view, "alpha", 0.1f, 0.3f, 0.5f, 0.7f, 1f);
        animator1.setDuration(mDuration4NumShow);//980l
//        ObjectAnimator animator2 = ObjectAnimator.ofFloat(view, "scaleY", 2.0f,/*0.8f,*/0.6f, 1f);
        ObjectAnimator animator2 = ObjectAnimator.ofFloat(view, "scaleY", 2.2f, 0.8f, 1.5f, 0.6f, 1f);
        animator2.setDuration(mDuration4NumShow);
//        ObjectAnimator animator3 = ObjectAnimator.ofFloat(view, "scaleX", 2.0f,/*0.8f,*/0.6f, 1f);
        ObjectAnimator animator3 = ObjectAnimator.ofFloat(view, "scaleX", 2.2f, 0.8f, 1.5f, 0.6f, 1f);
        animator3.setDuration(mDuration4NumShow);

        mAnimatorSet = new AnimatorSet();
        mAnimatorSet.playTogether(animator1,animator2,animator3);
        mAnimatorSet.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationEnd(Animator animation) {
                if(!isDetachWindow){
                    //播放下一个数字
                    if (!playRangeNext()) {
                        //如果没下一个数字
                        starHolingTimer();
                    }
                }
            }

            @Override
            public void onAnimationCancel(Animator animation) {
            }

            @Override
            public void onAnimationRepeat(Animator animation) {}

            @Override
            public void onAnimationStart(Animator animation) {}
        });
        //先加速后减速
        mAnimatorSet.setInterpolator(new DecelerateInterpolator());
        mAnimatorSet.start();
    }

    private Runnable mAnimationEndRunnable = new Runnable() {
        @Override
        public void run() {
            //可以结束了
            if(mOnPlayListener != null){
                mOnPlayListener.onPlayEnd(mLocalInLiveGiftView);
            }
            mPlayState = PlayState.end;
        }
    };

    /**
     * 开启 停留计时
     */
    private void starHolingTimer(){
        mPlayState = PlayState.waiting;
        //如果有，移除之前设置的定时任务
        removeCallbacks(mAnimationEndRunnable);
        //发起新的定时任务
        postDelayed(mAnimationEndRunnable, HOLD_TIME);
    }

    /**
     * 停止 停留计时
     */
    private void stopHolingTimer(){
        removeCallbacks(mAnimationEndRunnable);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        //可以结束了
        if(mOnPlayListener != null){
            mOnPlayListener.onPlayEnd(mLocalInLiveGiftView);
        }
        isDetachWindow = true;      //标注已被删除不可见
        mOnPlayListener = null;
        if(mAnimatorSet != null){
            mAnimatorSet.cancel();
        }
        removeCallbacks(mAnimationEndRunnable);
        mPlayState = PlayState.end;
    }

    public interface onPlayListener{
        void onPlayEnd(int local);
    }

}
