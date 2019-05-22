package com.qpidnetwork.livemodule.liveshow.pay;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.view.KeyEvent;

import com.qpidnetwork.livemodule.httprequest.OnMobilePayGotoCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniPayment;
import com.qpidnetwork.livemodule.httprequest.item.LSOrderType;
import com.qpidnetwork.livemodule.liveshow.BaseWebViewActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;

/**
 * 买点页面
 * @author Jagger 2018-10-12
 */
public class LiveBuyCreditActivity extends BaseWebViewActivity {

    public static String KEY_ORDER_TYPE_INDEX = "KEY_ORDER_TYPE_INDEX";
    public static String KEY_CLICK_FROM = "KEY_CLICK_FROM";
    public static String KEY_NUMBER_ID = "KEY_NUMBER_ID";

    private final int CALLBACK_GET_URL = 101;

    private LSOrderType mLSOrderType;
    private String mClickFrom;
    private String mNumberId;

    /**
     *
     * @param context
     * @param orderType LSOrderType枚举索引
     * @param clickFrom
     * @param numberId
     */
    public static void lunchActivity(Context context, int orderType, String clickFrom, String numberId){
        Intent intent = new Intent(context, LiveBuyCreditActivity.class);
        intent.putExtra(KEY_ORDER_TYPE_INDEX, orderType);
        intent.putExtra(KEY_CLICK_FROM, clickFrom);
        intent.putExtra(KEY_NUMBER_ID, numberId);
        intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, true);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        doGetIntent();
        if(!checkApiLimit()){
            return;
        }
        doGetURL();
    }

    /**
     * 解参数
     */
    private void doGetIntent(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null) {
            if(bundle.containsKey(KEY_ORDER_TYPE_INDEX)){
                mLSOrderType = LSOrderType.values()[ bundle.getInt(KEY_ORDER_TYPE_INDEX, 0) ];
            }

            if(bundle.containsKey(KEY_CLICK_FROM)){
                mClickFrom = bundle.getString(KEY_CLICK_FROM);
            }

            if(bundle.containsKey(KEY_NUMBER_ID)){
                mNumberId = bundle.getString(KEY_NUMBER_ID);
            }
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if (mWebView != null && mWebView.canGoBack()) {
            backToFirstPage();
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }


    public void backToFirstPage(){
        if(mWebView.canGoBackOrForward(1 - mWebView.copyBackForwardList().getSize())){
            mWebView.goBackOrForward(1 - mWebView.copyBackForwardList().getSize());
        }
    }

    /**
     * 请求接口取买点页URL
     */
    private void doGetURL(){
        RequestJniPayment.MobilePayGoto(mLSOrderType, mClickFrom, mNumberId, new OnMobilePayGotoCallback() {
            @Override
            public void onMobilePayGoto(boolean isSuccess, int errCode, String errMsg, String redirtctUrl) {
                Message msg = Message.obtain();
                msg.what = CALLBACK_GET_URL;
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, redirtctUrl);
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        switch (msg.what) {
            case CALLBACK_GET_URL:
                if(msg.obj != null && mWebView != null){
                    HttpRespObject httpRespObject = (HttpRespObject)msg.obj;
                    if(httpRespObject.isSuccess){
                        mUrl = String.valueOf(httpRespObject.data);
                        loadUrl(false, false);
                    }else {
                        onLoadError();
                    }
                }

                break;
            default:
                break;
        }
    }

    @Override
    protected void onRetryClicked() {
        //TODO
        doGetURL();

        super.onRetryClicked();
    }
}
