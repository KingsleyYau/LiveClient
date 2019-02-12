package com.qpidnetwork.livemodule.liveshow.model.js;

import android.content.Context;
import android.text.TextUtils;
import android.util.JsonReader;
import android.webkit.JavascriptInterface;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.IOException;
import java.io.StringReader;

/**
 * Description:
 * web:js method中:LiveApp.callbackAppGAEvent(eventName)
 * <p>
 * Created by Harry on 2017/11/3.
 */

public class CallbackAppGAEventJSObj extends Object {

    public static final String WEBVIEW_SESSION_ERROR_NO = "10004";
    public static final String WEBVIEW_NOCREDIT_ERROR_NO = "10005";

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
    public void callbackAppPublicGAEvent(String category, String eventName, String label){
        Log.d(TAG,"callbackAppPublicGAEvent-category:" + category + " eventName: " + eventName + " label: " + label);

        //添加GA统计
        AnalyticsManager.getsInstance().ReportEvent(category, eventName, label);
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
            mListener.onEventPageError(errCode, "", null);
        }
    }

    @JavascriptInterface
    public void callbackWebAuthExpired(String errMsg){
        Log.d(TAG,":callbackWebAuthExpired errMsg: " + errMsg);
        if(mListener != null){
            mListener.onEventPageError(WEBVIEW_SESSION_ERROR_NO, errMsg, null);
        }
    }

    @JavascriptInterface
    public void callbackWebRechange(String errMsg, String jsonParams){
        Log.d(TAG,":callbackWebRechange errMsg: " + errMsg + " jsonParams: " + jsonParams);
        if(mListener != null){
            NoMoneyParamsBean params = new NoMoneyParamsBean();
            try{
                params = parseJSNomoneyParams(jsonParams);
            }catch (Exception e){
                e.printStackTrace();
            }
            mListener.onEventPageError(WEBVIEW_NOCREDIT_ERROR_NO, errMsg, params);
        }
    }

    @JavascriptInterface
    public void callbackShowNavigation(String isShow){
        Log.d(TAG,":callbackShowNavigation isShow: " + isShow);
        if(mListener != null){
            mListener.onEventShowNavigation(isShow);
        }
    }

    /****************************** JS带回没点参数解析 **********************************************/

    private static final String JSON_PARAM_KEY_ORDER_TYPE = "order_type";
    private static final String JSON_PARAM_KEY_CLICK_FROM = "click_from";
    private static final String JSON_PARAM_KEY_NUMBER = "number";

    /**
     * 解析没钱js回调所带的买点参数
     * @param jsonParams
     * @return
     */
    private NoMoneyParamsBean parseJSNomoneyParams(String jsonParams)throws IOException {
        NoMoneyParamsBean params = new NoMoneyParamsBean();
        //创建JsonReader对象
        JsonReader jsReader = new JsonReader(new StringReader(jsonParams));
        jsReader.beginObject();
        while(jsReader.hasNext()){
            String tagName = jsReader.nextName();
            if (tagName.equals(JSON_PARAM_KEY_ORDER_TYPE)) {
                params.setOrderTyp(jsReader.nextString());
            }else if (tagName.equals(JSON_PARAM_KEY_CLICK_FROM)) {
                params.clickFrom = jsReader.nextString();
            }else if (tagName.equals(JSON_PARAM_KEY_NUMBER)) {
                params.number = jsReader.nextString();
            }else {
                //跳过当前值
                jsReader.skipValue();
            }
        }
        jsReader.endObject();
        return params;
    }

}
