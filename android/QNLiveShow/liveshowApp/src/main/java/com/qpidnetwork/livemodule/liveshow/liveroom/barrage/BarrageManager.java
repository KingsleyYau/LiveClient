package com.qpidnetwork.livemodule.liveshow.liveroom.barrage;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.AnimationUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.liveroom.BaseCommonLiveRoomActivity;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 弹幕动画Manager(管理View的动画效果)
 * Created by Hunter Mun on 2017/6/19.
 */

public class BarrageManager<T> {

    private WeakReference<BaseCommonLiveRoomActivity> mActivity;
    private List<View> mViewsList;                              //可展示View列表
    private List<T> mBarrageDataList;                          //存储带播放的弹幕队列
    private HashMap<Animation, View> mAnimationViewMap;      //存储动画和View列表，用于会话结束时找回可使用View
    private IBarrageViewFiller<T> mBarrageFiller;               //弹幕view填充器
    private View ll_bulletScreen;
    private boolean isSolftInputShow = false;


    public BarrageManager(BaseCommonLiveRoomActivity context, List<View> listViews, View ll_bulletScreen){
        this.mActivity = new WeakReference<BaseCommonLiveRoomActivity>(context);
        this.mViewsList = listViews;
        mBarrageDataList = new ArrayList<T>();
        mAnimationViewMap = new HashMap<Animation, View>();
        this.ll_bulletScreen = ll_bulletScreen;
    }

    /**
     * 设置单个view填充器
     * @param filler
     */
    public void setBarrageFiller(IBarrageViewFiller filler){
        this.mBarrageFiller = filler;
    }

    /**
     * 添加barrageItem
     * @param barrageItem
     */
    public void addBarrageItem(T barrageItem){
        View usableView = getUsableView();
        if(usableView != null){
            startAnimation(usableView, barrageItem);
        }else{
            synchronized (mBarrageDataList){
                mBarrageDataList.add(barrageItem);
            }
        }
    }

    /**
     * 在头部添加
     * @param barrageItem
     */
    public void addBarrageItemFirst(T barrageItem){
        View usableView = getUsableView();
        if(usableView != null){
            startAnimation(usableView, barrageItem);
        }else{
            synchronized (mBarrageDataList){
                mBarrageDataList.add(0, barrageItem);
            }
        }
    }

    public synchronized void changeBulletScreenBg(boolean isNeedShowBg){
        isSolftInputShow = isNeedShowBg;
        if(null != ll_bulletScreen && View.VISIBLE == ll_bulletScreen.getVisibility()){
            if(null != mActivity && null != mActivity.get() && null != mActivity.get().mIMRoomInItem){
                ll_bulletScreen.setBackgroundDrawable(isNeedShowBg ?
                        mActivity.get().roomThemeManager.getRoomBarrageBgDrawable(
                                mActivity.get().mIMRoomInItem.roomType): new ColorDrawable(Color.TRANSPARENT));
            }
        }
    }

    /**
     * 开启Barrage动画，由add动作及动画结束自动触发
     */
    private synchronized void startAnimation(View view, T barrageItem){

        if(mBarrageFiller != null){
            mBarrageFiller.onBarrageViewFill(view, barrageItem);
        }

        AnimationSet animationSet = (AnimationSet) AnimationUtils.loadAnimation(mActivity.get(), R.anim.anim_bullet_screen_view);
        mAnimationViewMap.put(animationSet, view);

        animationSet.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
                mAnimationViewMap.get(animation).setVisibility(View.VISIBLE);
            }

            @Override
            public void onAnimationEnd(Animation animation) {
                //播放结束，取出数据，重复使用view播放
                View view = mAnimationViewMap.remove(animation);
                if(view != null) {
                    view.setVisibility(View.INVISIBLE);
                }

                //播放结束取出数据继续动画
                T barrageItem = null;
                synchronized (mBarrageDataList){
                    if(mBarrageDataList.size() > 0 ){
                        barrageItem = mBarrageDataList.remove(0);
                    }else{
                        playBarrageViewOutAnim();
                    }
                }
                if(barrageItem != null) {
                    startAnimation(view, barrageItem);
                }
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });
        view.startAnimation(animationSet);
        playBarrageViewEnterAnim();
    }

    private void playBarrageViewEnterAnim(){
        if(View.INVISIBLE == ll_bulletScreen.getVisibility()){
            ll_bulletScreen.setBackgroundColor(isSolftInputShow ? Color.parseColor("#deffffff") : Color.TRANSPARENT);
            AnimationSet animationSet1 = (AnimationSet) AnimationUtils.loadAnimation(mActivity.get(), R.anim.barrage_view_enter);
            animationSet1.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {
                    ll_bulletScreen.setVisibility(View.VISIBLE);
                }

                @Override
                public void onAnimationEnd(Animation animation) {}

                @Override
                public void onAnimationRepeat(Animation animation) {}
            });
            ll_bulletScreen.startAnimation(animationSet1);
        }
    }

    private void playBarrageViewOutAnim(){
        if(View.VISIBLE == ll_bulletScreen.getVisibility()){
            AnimationSet animationSet1 = (AnimationSet) AnimationUtils.loadAnimation(mActivity.get(), R.anim.barrage_view_exit);
            animationSet1.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {

                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    ll_bulletScreen.setVisibility(View.INVISIBLE);
                }

                @Override
                public void onAnimationRepeat(Animation animation) {}
            });
            ll_bulletScreen.startAnimation(animationSet1);
        }
    }

    /**
     * 获取当前可用的View
     * @return
     */
    private View getUsableView(){
        View usableView = null;
        synchronized (mAnimationViewMap){
            if(mAnimationViewMap.size() < mViewsList.size()) {
                for (View view : mViewsList) {
                    if (!mAnimationViewMap.values().contains(view)) {
                        usableView = view;
                        break;
                    }
                }
            }
        }
        return usableView;
    }

    /**
     * 界面返回，清除所有动画
     */
    public void onDestroy(){
        //清除所有待完成任务
        synchronized (mBarrageDataList){
            mBarrageDataList.clear();
        }

        //停止所有未完成动画
        for(View view : mViewsList){
            view.clearAnimation();
        }

        //清除动画View绑定
        mAnimationViewMap.clear();
    }
}
