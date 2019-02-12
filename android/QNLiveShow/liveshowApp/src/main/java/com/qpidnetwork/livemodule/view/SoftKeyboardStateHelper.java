package com.qpidnetwork.livemodule.view;

import android.graphics.Rect;
import android.view.View;
import android.view.ViewTreeObserver;

import java.util.LinkedList;
import java.util.List;

public class SoftKeyboardStateHelper implements ViewTreeObserver.OnGlobalLayoutListener {

    public interface SoftKeyboardStateListener {
        void onSoftKeyboardOpened(int keyboardHeightInPx);

        void onSoftKeyboardClosed();
    }

    private final List<SoftKeyboardStateListener> listeners = new LinkedList<SoftKeyboardStateListener>();
    private final View activityRootView;
    private int lastSoftKeyboardHeightInPx;
    //        private int usableHeightSansKeyboard = 220;
    private boolean isSoftKeyboardOpened;

    private int mOldh = -1;
    private int mNowh = -1;
    protected int mScreenHeight = 0;

    public SoftKeyboardStateHelper(View activityRootView) {
        this(activityRootView, false);
    }

    public SoftKeyboardStateHelper(View activityRootView, boolean isSoftKeyboardOpened) {
        this.activityRootView = activityRootView;
        this.isSoftKeyboardOpened = isSoftKeyboardOpened;
//                FrameLayout content = (FrameLayout)activityRootView;
//                content.getChildAt(0).getViewTreeObserver().addOnGlobalLayoutListener(this);
        activityRootView.getViewTreeObserver().addOnGlobalLayoutListener(this);
    }

    @Override
    public void onGlobalLayout() {
//        final Rect r = new Rect();
//        //r will be populated with the coordinates of your view that area still visible.
//        activityRootView.getWindowVisibleDisplayFrame(r);
//
//        final int heightDiff = activityRootView.getRootView().getHeight() - (r.bottom - r.top);
//        this.usableHeightSansKeyboard = activityRootView.getRootView().getHeight() / 4;
//
//        if (!isSoftKeyboardOpened && heightDiff > usableHeightSansKeyboard) { // if more than 100 pixels, its probably a keyboard...
//            isSoftKeyboardOpened = true;
//            notifyOnSoftKeyboardOpened(heightDiff);
//        } else if (isSoftKeyboardOpened && heightDiff < usableHeightSansKeyboard) {
//            isSoftKeyboardOpened = false;
//            notifyOnSoftKeyboardClosed();
//        }


        /**
         * 2018/11/08 Hardy
         * @see SoftKeyboardSizeWatchLayout
         *
         * 黑莓这种带有物理键盘的设备，其有 2 种软键盘：
         * 正常键盘：只能通过点击物理键盘中的某一个按键才能调出
         * 小键盘：高度很小，当 app 需输入文本时，总是默认调出它
         *
         * 上述方法，对屏幕高度的 1/4 高度判断，导致不回调 UI 外层键盘弹出的事件，而引发的一系列 UI 问题。
         * 故去掉屏幕高度的 1/4 高度，改成变化高度 > 0 ，即认为弹出键盘，回调 UI 外层，兼容了黑莓类似这种带
         * 物理键盘的设备。
         */
        Rect r = new Rect();
        activityRootView.getWindowVisibleDisplayFrame(r);
        if (mScreenHeight == 0) {
            mScreenHeight = r.bottom;
        }
        mNowh = mScreenHeight - r.bottom;
        if (mOldh != -1 && mNowh != mOldh) {
            if (mNowh > 0) {
                isSoftKeyboardOpened = true;
                notifyOnSoftKeyboardOpened(mNowh);
            } else {
                isSoftKeyboardOpened = false;
                notifyOnSoftKeyboardClosed();
            }
        }
        mOldh = mNowh;
    }

    public void setIsSoftKeyboardOpened(boolean isSoftKeyboardOpened) {
        this.isSoftKeyboardOpened = isSoftKeyboardOpened;
    }

    public boolean isSoftKeyboardOpened() {
        return isSoftKeyboardOpened;
    }

    /**
     * Default value is zero (0)
     *
     * @return last saved keyboard height in px
     */
    public int getLastSoftKeyboardHeightInPx() {
        return lastSoftKeyboardHeightInPx;
    }

    public void addSoftKeyboardStateListener(SoftKeyboardStateListener listener) {
        listeners.add(listener);
    }

    public void removeSoftKeyboardStateListener(SoftKeyboardStateListener listener) {
        listeners.remove(listener);
    }

    public void removeAllSoftKeyboardStateListener() {
        listeners.clear();
    }

    private void notifyOnSoftKeyboardOpened(int keyboardHeightInPx) {
        this.lastSoftKeyboardHeightInPx = keyboardHeightInPx;

        for (SoftKeyboardStateListener listener : listeners) {
            if (listener != null) {
                listener.onSoftKeyboardOpened(keyboardHeightInPx);
            }
        }
    }

    private void notifyOnSoftKeyboardClosed() {
        for (SoftKeyboardStateListener listener : listeners) {
            if (listener != null) {
                listener.onSoftKeyboardClosed();
            }
        }
    }
}