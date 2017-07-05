package com.qpidnetwork.liveshow.liveroom.gift.normal;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;

import com.qpidnetwork.liveshow.R;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 *  礼品背景
 * Created by Jagger on 2017/6/8.
 */

public abstract class LiveGiftView implements LiveGiftManager.onGiftStateChangeListener {

    private int MAX_GIFT_SUM = 2;   //最大可以显示礼品总数
    private Map<Integer , LiveGiftItemView> mMapGiftLocal = new HashMap();
    private ViewGroup mRootView;
    private LiveGiftBgView mLiveGiftBgView;
    private View mAnchorView;
    private Context mContext;
    private int mDuration4NumShow = 1000;

    public LiveGiftView(Activity activity){
        if (activity == null){
            throw new NullPointerException("Activity should not be null");
        }

        mContext = activity;
        mRootView = (ViewGroup) activity.findViewById(Window.ID_ANDROID_CONTENT);

        View lgRootView = mRootView.findViewById(R.id.livegift_rootview);

        if (lgRootView instanceof  LiveGiftBgView){
            mLiveGiftBgView = (LiveGiftBgView) lgRootView;
        }else {
            mLiveGiftBgView = new LiveGiftBgView(activity);
            mLiveGiftBgView.setId(R.id.livegift_rootview);
            mRootView.addView(mLiveGiftBgView);
        }

        LiveGiftManager.getInstance().registerOnGiftStateChangeLinstener(this);

    }

    public void bind(View anchorView){
        mAnchorView = anchorView;
    }

    /**
     * 显示一项
     * @param gifgItemView
     * @param topOffset
     * @param leftOffset
     */
    private int show(LiveGiftItemView gifgItemView , int topOffset, int leftOffset){
        Rect rect = new Rect();
        mAnchorView.getGlobalVisibleRect(rect);
        int[] location = new int[2];
        mLiveGiftBgView.getLocationOnScreen(location);
        rect.offset(-location[0], -location[1]);

        int widthMeasureSpec = View.MeasureSpec.makeMeasureSpec((1 << 30) - 1, View.MeasureSpec.AT_MOST);
        int heightMeasureSpec = View.MeasureSpec.makeMeasureSpec((1 << 30) - 1, View.MeasureSpec.AT_MOST);
        gifgItemView.measure(widthMeasureSpec,heightMeasureSpec);

        int itemHeight = gifgItemView.getMeasuredHeight();
        int itemWidth = ScreenUtils.getScreenWidth(mContext);// 因为LiveGiftItemView的宽是match_parent

        //中点Y坐标：锚控件TOP/2 - 状态栏高度 计算出可显示的范围的中间Y坐标
//        int midY = rect.top / 2 - ScreenUtils.getStatusHeight(mContext);
        int midY = rect.top - itemHeight;   //按HUNTER需求改为这样子：锚控件TOP - 一个ITEM的高度为中点

        //礼物位置
        int itemLocal = getItemLocalCanshow();

        if(itemLocal != -1){
//            int itemHeight = gifgItemView.getMeasuredHeight();
//            int itemWidth = ScreenUtils.getScreenWidth(mContext);// 因为LiveGiftItemView的宽是match_parent

            int topMargin;
            int leftMargin =  0 - itemWidth;    // + leftOffset

            if(itemLocal <=  MAX_GIFT_SUM/2){   //如果是上半部分
                topMargin = midY  - ( itemHeight * itemLocal );
            }else{
                topMargin = midY  + ( itemHeight * (itemLocal/2 - 1) );
            }

            FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.topMargin = topMargin;
            lp.leftMargin = leftMargin;
            mLiveGiftBgView.addView(gifgItemView,lp);
            mMapGiftLocal.put(itemLocal , gifgItemView);
            //播放飞入动画
            playInAnimator(gifgItemView);
        }
        return itemLocal;
    }

    /**
     * 删掉一项
     * @param local
     */
    private void removeOneItem(int local){
        if(mMapGiftLocal.containsKey(local)){
            //取出是哪个子VIEW要被删除
            LiveGiftItemView removeItemview = mMapGiftLocal.get(local);

            //播放删除动画
            playFadeAnimator(removeItemview);

            //从视图数据列表中删除
            mMapGiftLocal.remove(local);
        }
    }

    /**
     * 连击动画持续时间（毫秒）
     * @param mDuration4NumShow
     */
    public void setDuration4NumShow(int mDuration4NumShow) {
        this.mDuration4NumShow = mDuration4NumShow;
    }

    /**
     * 加入礼物
     */
    public void addGift(LiveGift liveGift){
        LiveGiftManager.getInstance().addLiveGift(liveGift);
    }

    /**
     * 整个消失
     */
    public void dismiss(){
        mMapGiftLocal.clear();
        LiveGiftManager.getInstance().destory();
        mLiveGiftBgView.removeAllViews();
        mRootView.removeView(mLiveGiftBgView);
    }

    /**
     * 取可用的位置
     * @return
     */
    private int getItemLocalCanshow(){
        int local = -1;

        for(int i = 1 ; i <= MAX_GIFT_SUM; i++){    //从1算起，为了方便计算高度
            if(!mMapGiftLocal.containsKey(i)){
                local = i;
                break;
            }
        }
        return local;
    }

    /**
     * 动画--从左到右的飞入
     * @param view
     */
    private void playInAnimator(final LiveGiftItemView view) {
        PropertyValuesHolder translationX = PropertyValuesHolder.ofFloat("translationX", 0 ,  ScreenUtils.getScreenWidth(mContext)); //0对于子控件自身坐标 ，因为LiveGiftItemView的宽是match_parent
        ObjectAnimator animator = ObjectAnimator.ofPropertyValuesHolder(view, translationX);
        animator.setDuration(500);
        animator.addListener(new AnimatorListenerAdapter(){
            @Override
            public void onAnimationEnd(Animator animation) {
                //播放连击动画
                view.play();
            }
        });
        animator.start();
    }

    /**
     * 动画--向上飞出
     * @param view
     */
    private void playFadeAnimator(final LiveGiftItemView view) {
        PropertyValuesHolder translationY = PropertyValuesHolder.ofFloat("translationY", 0 , 0 - view.getHeight()); //0对于子控件自身坐标
        PropertyValuesHolder alpha = PropertyValuesHolder.ofFloat("alpha", 1.0f, 0f);
        ObjectAnimator animator = ObjectAnimator.ofPropertyValuesHolder(view, translationY, alpha);
//        animator.setStartDelay(startDelay);
        animator.setDuration(500);
        animator.addListener(new AnimatorListenerAdapter(){
            @Override
            public void onAnimationEnd(Animator animation) {
                //从视图UI中删除
                mLiveGiftBgView.removeView(view);

                //从管理器中删除
                LiveGiftManager.getInstance().removeLiveGift(view.getLiveGift());
            }
        });
        animator.start();
    }

    @Override
    public void onUpdateGiftRange(LiveGift liveGift, LiveGift.ClickRange newClickRange) {
        Set set = mMapGiftLocal.entrySet();
        Iterator iterator=set.iterator();
        while (iterator.hasNext()){
            Map.Entry  mapItem = (Map.Entry) iterator.next();
            ((LiveGiftItemView)mapItem.getValue()).play();
        }
    }

    @Override
    public void onAddNewGift(LiveGift liveGift) {
        LiveGiftItemView itemView = new LiveGiftItemView(mContext);
        itemView.setLiveGift(liveGift);
        itemView.setDuration4NumShow(mDuration4NumShow);

        //让外部构造子VIEW
        onSetChileView(liveGift , itemView);

        //在这显示出来
        int local = show(itemView , 10 , 10);

        //让字VIEW记着它当前位置
        itemView.setLocalInLiveGiftView(local);

        //子VIEW连击动画监听
        itemView.setOnPlayListener(new LiveGiftItemView.onPlayListener() {
            @Override
            public void onPlayEnd(int local) {
                removeOneItem(local);
            }
        });

    }

    public abstract void onSetChileView(LiveGift liveGift , LiveGiftItemView v);

    private class LiveGiftBgView extends FrameLayout {

        public LiveGiftBgView(Context context) {
            this(context, null);
        }

        public LiveGiftBgView(Context context, AttributeSet attrs) {
            this(context, attrs, 0);
        }

        public LiveGiftBgView(Context context, AttributeSet attrs, int defStyle) {
            super(context, attrs, defStyle);

        }
    }
}
