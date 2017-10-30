package com.qpidnetwork.livemodule.view.listener;

import android.view.MotionEvent;
import android.view.View;

import com.qpidnetwork.livemodule.utils.Log;

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

    public ViewDragTouchListener() {
        Log.d(TAG,"ViewDragTouchListener");
    }
    public ViewDragTouchListener(long delay) {
        Log.d(TAG,"ViewDragTouchListener-delay:"+delay);
        this.delay = delay;
    }
    @Override
    public boolean onTouch(View v, MotionEvent event) {
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
        return false;
    }

    private OnViewDragStatusChangedListener listener;
    public void setOnViewDragListener(OnViewDragStatusChangedListener listener){
        this.listener = listener;
    }
    public interface OnViewDragStatusChangedListener {
        void onViewDragged(int l, int t, int r, int b);
    }

}
