package com.qpidnetwork.livemodule.framework.widget;

import android.content.Context;
import android.util.AttributeSet;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.webkit.WebView;


/**
 * Created by jianghejie on 15/7/16.
 */
public class ObservableWebView extends WebView {
    private OnScrollChangedCallback mOnScrollChangedCallback;

    public ObservableWebView(final Context context) {
        super(context);
    }

    public ObservableWebView(final Context context, final AttributeSet attrs) {
        super(context, attrs);
    }

    public ObservableWebView(final Context context, final AttributeSet attrs,
                             final int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    protected void onScrollChanged(final int l, final int t, final int oldl,
                                   final int oldt) {
        super.onScrollChanged(l, t, oldl, oldt);
        Log.i("Jagger" , "l:"+l +",t:" + t + ",oldl:"+oldl+",oldt:" + oldt);

        if (mOnScrollChangedCallback != null) {
//            mOnScrollChangedCallback.onScroll(l - oldl, t - oldt);
            // webview的高度
            float webcontent = getContentHeight() * getScale();
            // 当前webview的高度
            float webnow = getHeight() + getScrollY();
            if (Math.abs(webcontent - webnow) < 1) {
                //处于底端
                mOnScrollChangedCallback.onPageEnd(l, t, oldl, oldt);
            } else if (getScrollY() == 0) {
                //处于顶端
                mOnScrollChangedCallback.onPageTop(l, t, oldl, oldt);
            } else {
                mOnScrollChangedCallback.onScrollChanged(l, t, oldl, oldt);
            }
        }
    }

    public OnScrollChangedCallback getOnScrollChangedCallback() {
        return mOnScrollChangedCallback;
    }

    public void setOnScrollChangedCallback(
            final OnScrollChangedCallback onScrollChangedCallback) {
        mOnScrollChangedCallback = onScrollChangedCallback;
    }

    /**
     * Impliment in the activity/fragment/view that you want to listen to the webview
     */
    public static interface OnScrollChangedCallback {
        public void onPageEnd(int l, int t, int oldl, int oldt);

        public void onPageTop(int l, int t, int oldl, int oldt);

        public void onScrollChanged(int l, int t, int oldl, int oldt);
    }
}
