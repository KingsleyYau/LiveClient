package com.qpidnetwork.anchor.view.listener;

import android.app.Activity;
import android.graphics.Rect;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

import com.qpidnetwork.anchor.utils.Log;

/**
 * Description:
 * 参考:http://blog.csdn.net/Mingyueyixi/article/details/70288632
 * <p>
 * Created by Harry on 2017/10/17.
 */

public class ViewDragTouchListener implements View.OnTouchListener {
    private final String TAG = ViewDragTouchListener.class.getSimpleName();

    private float downX;
    private float downY;
    private long downTime;
    private long delay = 0l;
    private int l;
    private int r;
    private int t;
    private int b;

    private WindowManager windowManager ;
    private int screenWidth , screenHeight;

    public ViewDragTouchListener() {
        Log.d(TAG,"ViewDragTouchListener");
    }
    public ViewDragTouchListener(long delay) {
        Log.d(TAG,"ViewDragTouchListener-delay:"+delay);
        this.delay = delay;
    }
    @Override
    public boolean onTouch(View v, MotionEvent event) {
        Rect rect = new Rect();
        ((Activity)v.getContext()).getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);
        screenWidth = rect.width();
        screenHeight = rect.height();

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                Log.d(TAG,"onTouch-ACTION_DOWN");
                downX = event.getX();
                downY = event.getY();
                downTime = System.currentTimeMillis();
                break;
            case MotionEvent.ACTION_MOVE:
                Log.d(TAG,"onTouch-ACTION_MOVE");
                if(System.currentTimeMillis() - downTime>= delay){
                    final float xDistance = event.getX() - downX;
                    final float yDistance = event.getY() - downY;
                    if (xDistance != 0 && yDistance != 0) {
                        l = (int) (v.getLeft() + xDistance);
                        r = (int) (v.getRight() + xDistance);
                        t = (int) (v.getTop() + yDistance);
                        b = (int) (v.getBottom() + yDistance);

                        //add by Jagger 2017-12-5
                        //不让VIEW超出屏幕外
                        if(l <= 0){
                            l = 0;
                            r = v.getWidth();
                        }

                        if(r >= screenWidth ){
                            l = screenWidth - v.getWidth();
                            r = screenWidth;
                        }

                        if(t <= 0){
                            t = 0;
                            b = v.getHeight();
                        }

                        if(b >= screenHeight){
                            t = screenHeight - v.getHeight();
                            b = screenHeight;
                        }
                        //end

                        v.layout(l, t, r, b);
                    }
                }
                break;
            case MotionEvent.ACTION_UP:
                Log.d(TAG,"onTouch-ACTION_UP");
                if(null != listener){
                    listener.onViewDragged(l,t,r,b);
                }
                break;
        }
        return true;
    }

    private OnViewDragStatusChangedListener listener;
    public void setOnViewDragListener(OnViewDragStatusChangedListener listener){
        this.listener = listener;
    }
    public interface OnViewDragStatusChangedListener {
        void onViewDragged(int l, int t, int r, int b);
    }

}
