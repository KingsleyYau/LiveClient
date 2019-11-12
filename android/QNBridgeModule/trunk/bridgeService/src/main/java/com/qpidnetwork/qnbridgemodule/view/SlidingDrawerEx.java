package com.qpidnetwork.qnbridgemodule.view;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.SlidingDrawer;

import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * 我们需要分别处理handle中不同的事件，他本身是不支持的，这样就需要我们自己定义，重写他的方法
 * https://blog.csdn.net/qq_35534596/article/details/85258529
 *
 * @author Jagger 2019-5-30
 */
public class SlidingDrawerEx extends SlidingDrawer {
    private int[] mTouchableIds = null;    //Handle 部分其他控件ID

    public void setTouchableIds(int... mTouchableIds) {
        this.mTouchableIds = mTouchableIds;
    }

    public SlidingDrawerEx(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public SlidingDrawerEx(Context context, AttributeSet attrs, int defStyle){
        super(context, attrs, defStyle);
    }

    /*
     * 获取控件的屏幕区域
     */
    public Rect getRectOnScreen(View view){
        Rect rect = new Rect();
        int[] location = new int[2];
        View parent = view;
        if(view.getParent() instanceof View){
            parent = (View)view.getParent();
        }
        parent.getLocationOnScreen(location);
        view.getHitRect(rect);
        rect.offset(location[0], location[1]);
        return rect;
    }

    public boolean onInterceptTouchEvent(MotionEvent event) {
        // 触摸位置转换为屏幕坐标
        int[] location = new int[2];
        int x = (int)event.getX();
        int y = (int)event.getY();
        this.getLocationOnScreen(location);
        x += location[0];
        y += location[1];

        // handle部分独立按钮
        if(mTouchableIds != null){
            for(int id : mTouchableIds){
                View view = findViewById(id);
                Rect rect = getRectOnScreen(view);
                if(rect.contains(x,y)){
                    //不能把 MotionEvent.ACTION_MOVE 传到子控件，会影响点击灵敏度
                    if(event.getAction() == MotionEvent.ACTION_DOWN || event.getAction() == MotionEvent.ACTION_UP) {
                        boolean result = view.dispatchTouchEvent(event);
//                        Log.i("SlidingDrawerEx", "Hit TouchableIds :" + result + "," + event.getAction());
                    }
                    return false;
                }
            }
        }

        // 抽屉行为控件
        if(event.getAction() == MotionEvent.ACTION_DOWN ){//&& mHandleId != 0){
            View view = getHandle();//findViewById(mHandleId);
            Rect rect = getRectOnScreen(view);
            if(rect.contains(x, y)){//点击抽屉控件时交由系统处理
//                Log.i("SlidingDrawerEx", "Hit handle");
            }else{
                return false;
            }
        }
        return super.onInterceptTouchEvent(event);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return super.onTouchEvent(event);
    }
}
