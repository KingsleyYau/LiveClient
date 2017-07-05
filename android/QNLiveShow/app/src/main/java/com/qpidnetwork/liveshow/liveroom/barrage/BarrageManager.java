package com.qpidnetwork.liveshow.liveroom.barrage;

import android.content.Context;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.AnimationUtils;

import com.qpidnetwork.liveshow.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 弹幕动画Manager(管理View的动画效果)
 * Created by Hunter Mun on 2017/6/19.
 */

public class BarrageManager<T> {

    private Context mContext;
    private List<View> mViewsList;                              //可展示View列表
    private List<T> mBarrageDataList;
    private HashMap<Animation, View> mAnimationViewMap;      //存储动画和View列表，用于会话结束时找回可使用View
    private IBarrageViewFiller<T> mBarrageFiller;               //弹幕view填充器

    public BarrageManager(Context context, List<View> listViews){
        this.mContext = context;
        this.mViewsList = listViews;
        mBarrageDataList = new ArrayList<T>();
        mAnimationViewMap = new HashMap<Animation, View>();
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

    /**
     * 开启Barrage动画，由add动作及动画结束自动触发
     */
    private synchronized void startAnimation(View view, T barrageItem){

        if(mBarrageFiller != null){
            mBarrageFiller.onBarrageViewFill(view, barrageItem);
        }

        AnimationSet animationSet = (AnimationSet) AnimationUtils.loadAnimation(mContext, R.anim.anim_bullet_screen_view);
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
                view.setVisibility(View.INVISIBLE);

                //播放结束取出数据继续动画
                T barrageItem = null;
                synchronized (mBarrageDataList){
                    if(mBarrageDataList.size() > 0 ){
                        barrageItem = mBarrageDataList.remove(0);
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
}
