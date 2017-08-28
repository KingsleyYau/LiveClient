package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;

/**
 * 监测软键盘弹出收起时间FrameLayout
 * Created by Hunter Mun on 2017/6/16.
 */

public class SoftKeyboradListenFrameLayout extends FrameLayout{

    private InputWindowListener mListener;

    public SoftKeyboradListenFrameLayout(Context context){
        super(context);
    }

    public SoftKeyboradListenFrameLayout(Context context, AttributeSet attrs){
        super(context, attrs);
    }

    public SoftKeyboradListenFrameLayout(Context context, AttributeSet attrs, int defStyleAttr){
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        if(oldh > h){
            if(mListener != null){
                mListener.onSoftKeyboardShow();
            }
        }else{
            if(mListener != null){
                mListener.onSoftKeyboardHide();
            }
        }
    }

    /**
     * 设置size改变监听
     * @param listener
     */
    public void setInputWindowListener(InputWindowListener listener){
        mListener = listener;
    }

    public interface InputWindowListener{
        void onSoftKeyboardShow();
        void onSoftKeyboardHide();

    }
}
