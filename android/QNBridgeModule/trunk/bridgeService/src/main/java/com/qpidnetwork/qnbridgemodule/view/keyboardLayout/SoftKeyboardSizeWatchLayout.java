package com.qpidnetwork.qnbridgemodule.view.keyboardLayout;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.ViewTreeObserver;
import android.widget.RelativeLayout;

import java.util.ArrayList;
import java.util.List;

/**
 * 源自：https://github.com/w446108264/XhsEmoticonsKeyboard
 * @author Jagger 2018-7-26
 */
public class SoftKeyboardSizeWatchLayout extends RelativeLayout {

    private Context mContext;
    private int mOldh = -1;
    private int mNowh = -1;
    protected int mScreenHeight = 0;
    protected boolean mIsSoftKeyboardPop = false;

    public SoftKeyboardSizeWatchLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.mContext = context;
        getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                Rect r = new Rect();
                ((Activity) mContext).getWindow().getDecorView().getWindowVisibleDisplayFrame(r);
                if (mScreenHeight == 0) {
                    mScreenHeight = r.bottom;
                }
                mNowh = mScreenHeight - r.bottom;
                if (mOldh != -1 && mNowh != mOldh) {
                    if (mNowh > 0) {
                        mIsSoftKeyboardPop = true;
                        if (mListenerList != null) {
                            for (OnResizeListener l : mListenerList) {
                                l.OnSoftPop(mNowh);
                            }
                        }
                    } else {
                        mIsSoftKeyboardPop = false;
                        if (mListenerList != null) {
                            for (OnResizeListener l : mListenerList) {
                                l.OnSoftClose();
                            }
                        }
                    }
                }
                mOldh = mNowh;
            }
        });
    }

    public boolean isSoftKeyboardPop() {
        return mIsSoftKeyboardPop;
    }

    private List<OnResizeListener> mListenerList;

    /**
     * 绑定监听器
     * @param l
     */
    public void addOnResizeListener(OnResizeListener l) {
        if (mListenerList == null) {
            mListenerList = new ArrayList<>();
        }
        mListenerList.add(l);
    }

    /**
     * 解除绑定监听器
     * @param l
     */
    public void removeOnResizeListener(OnResizeListener l){
        if(mListenerList != null){
            mListenerList.remove(l);
        }
    }

    public interface OnResizeListener {
        /**
         * 软键盘弹起
         */
        void OnSoftPop(int height);

        /**
         * 软键盘关闭
         */
        void OnSoftClose();
    }
}