package com.qpidnetwork.anchor.view;

import android.content.Context;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.ScrollView;

/**
 * Description:
 * <p>
 * Created by Harry on 2018/1/12.
 */

public class LiveRoomScrollView extends ScrollView {

    public LiveRoomScrollView(Context context) {
        super(context);
    }

    public LiveRoomScrollView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public LiveRoomScrollView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public LiveRoomScrollView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    private boolean scrollFuncEnable = true;

    public void setScrollFuncEnable(boolean scrollFuncEnable){
        this.scrollFuncEnable = scrollFuncEnable;
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        if(scrollFuncEnable){
            return super.onTouchEvent(ev);
        }
        return false;

    }
}
