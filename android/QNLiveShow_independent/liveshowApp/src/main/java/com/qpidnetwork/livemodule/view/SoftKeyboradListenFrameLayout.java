package com.qpidnetwork.livemodule.view;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.Window;
import android.widget.FrameLayout;

/**
 * 监测软键盘弹出收起时间FrameLayout
 * Created by Hunter Mun on 2017/6/16.
 */

public class SoftKeyboradListenFrameLayout extends FrameLayout{

    private InputWindowListener mListener;
    private SoftKeyboardStateHelper mSoftKeyboardStateHelper;//键盘显示事件

    public SoftKeyboradListenFrameLayout(Context context){
        super(context);
        init(context);
    }

    public SoftKeyboradListenFrameLayout(Context context, AttributeSet attrs){
        super(context, attrs);
        init(context);
    }

    public SoftKeyboradListenFrameLayout(Context context, AttributeSet attrs, int defStyleAttr){
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context){
        mSoftKeyboardStateHelper = new SoftKeyboardStateHelper(((Activity)context).findViewById(Window.ID_ANDROID_CONTENT));
        mSoftKeyboardStateHelper.addSoftKeyboardStateListener(new SoftKeyboardStateHelper.SoftKeyboardStateListener() {

            @Override
            public void onSoftKeyboardOpened(int keyboardHeightInPx) {
                // TODO Auto-generated method stub
                if(mListener != null){
                    mListener.onSoftKeyboardShow();
                }
            }

            @Override
            public void onSoftKeyboardClosed() {
                // TODO Auto-generated method stub
                if(mListener != null){
                    mListener.onSoftKeyboardHide();
                }
            }
        });
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
//        if(oldh > h){
//            if(mListener != null){
//                mListener.onSoftKeyboardShow();
//            }
//        }else{
//            if(mListener != null){
//                mListener.onSoftKeyboardHide();
//            }
//        }
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
