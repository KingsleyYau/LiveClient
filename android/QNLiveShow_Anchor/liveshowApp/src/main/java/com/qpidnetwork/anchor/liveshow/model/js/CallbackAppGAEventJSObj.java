package com.qpidnetwork.anchor.liveshow.model.js;

import android.content.Context;
import android.text.TextUtils;
import android.webkit.JavascriptInterface;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.anchor.utils.Log;

/**
 * Description:
 * web:js method中:LiveApp.callbackAppGAEvent(eventName)
 * <p>
 * Created by Harry on 2017/11/3.
 */

public class CallbackAppGAEventJSObj extends Object {

    private final String TAG = CallbackAppGAEventJSObj.class.getSimpleName();
    private Context mContext;
    private JSCallbackListener mListener;

    public CallbackAppGAEventJSObj(Context context){
        this.mContext = context;
    }

    /**
     * 设置监听器
     * @param listener
     */
    public void setJSCallbackListener(JSCallbackListener listener){
        this.mListener = listener;
    }

    @JavascriptInterface
    public void callbackAppGAEvent(String eventName){
        Log.d(TAG,"callbackAppGAEvent-eventName:"+eventName);

        //添加GA统计
        if(!TextUtils.isEmpty(eventName)){
            String category = mContext.getResources().getString(R.string.Live_Broadcast_Category);
            String label = category + ":" +  eventName;
            AnalyticsManager.getsInstance().ReportEvent(category, eventName, label);
        }
    }

    @JavascriptInterface
    public void callbackCloseWebView(){
        Log.d(TAG,":callbackCloseWebView");
        if(mListener != null){
            mListener.onEventClose();
        }
    }

    @JavascriptInterface
    public void callbackWebReload(String errCode){
        Log.d(TAG,":callbackWebReload errCode: " + errCode);
        if(mListener != null){
            mListener.onEventPageError(errCode);
        }
    }
}
