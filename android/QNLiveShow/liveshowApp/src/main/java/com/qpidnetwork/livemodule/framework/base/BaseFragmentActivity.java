package com.qpidnetwork.livemodule.framework.base;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.barlibrary.ImmersionBar;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.CustomShowTimeToast;
import com.qpidnetwork.livemodule.liveshow.liveroom.recharge.CreditsTipsPopupWindow;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.MaterialProgressDialog;
import com.qpidnetwork.livemodule.view.SimpleDoubleBtnTipsDialog;

import java.lang.ref.WeakReference;

/**
 * Created by Hunter Mun on 2017/9/4.
 */

public class BaseFragmentActivity extends AnalyticsFragmentActivity implements View.OnClickListener{

    protected String TAG = BaseFragmentActivity.class.getName();

    protected Activity mContext;
    protected MaterialProgressDialog progressDialog;
    protected MaterialProgressDialog progressDialogTranslucent;
    protected int mProgressDialogCount = 0;

    private boolean isActivityVisible = false;//判断activity是否可见，用于处理异步Dialog显示 windowToken异常
    protected Toast customToast;
    protected CustomShowTimeToast customShowTimeToast;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);

        mContext = this;

        mProgressDialogCount = 0;
        progressDialog = new MaterialProgressDialog(this);
        progressDialog.setCanceledOnTouchOutside(false);

        progressDialogTranslucent = new MaterialProgressDialog(this , R.style.themeDialog);
        progressDialogTranslucent.setCanceledOnTouchOutside(false);

        customToast = new Toast(this);
        customToast.setGravity(Gravity.CENTER,0, 0);
        customToast.setView(View.inflate(this,R.layout.view_custom_toast, null));

        customShowTimeToast = new CustomShowTimeToast(this,3000l);
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onResume() {
        super.onResume();
        isActivityVisible = true;
    }

    @Override
    protected void onPause() {
        super.onPause();
        isActivityVisible = false;
    }

    @Override
    protected void onDestroy(){
        super.onDestroy();
		/*防止异常杀死界面重启后，dialog 失去windowDecor导致调用Dismiss IllegalArgumentException*/
        hideProgressDialog();
    }

    /**
     * 偏底部
     * @param msg
     */
    public void showThreeSecondTips(String msg,int gravity){
        if(null != customShowTimeToast){
            customShowTimeToast.show(msg);
        }
    }

    /**
     * 屏幕中间
     * @param tips
     */
    public void showToast(String tips){
        customToast.setText(tips);
        customToast.setDuration(Toast.LENGTH_SHORT);
        customToast.show();
    }

    public void showToast(int strResId){
        customToast.setText(getResources().getString(strResId));
        customToast.setDuration(Toast.LENGTH_SHORT);
        customToast.show();
    }

    /**
     * 显示progressDialog
     * @param tips 提示文字
     */
    public void showProgressDialog(String tips){
        mProgressDialogCount++;
        if( !progressDialog.isShowing() && isActivityVisible) {
            progressDialog.setMessage(tips);
            progressDialog.show();
        }
    }

    /**
     * 显示progressDialog
     * @param tips 提示文字
     */
    public void showProgressDialogBgTranslucent(String tips){
        if(progressDialogTranslucent != null && !progressDialogTranslucent.isShowing()){
            progressDialogTranslucent.setMessage(tips);
            progressDialogTranslucent.show();
        }
    }

    /**
     * 隐藏progressDialog
     */
    public void hideProgressDialog(){
        try {
            if( mProgressDialogCount > 0 ) {
                mProgressDialogCount--;
                if( mProgressDialogCount == 0 && progressDialog != null ) {
                    progressDialog.dismiss();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if(progressDialogTranslucent != null){
            progressDialogTranslucent.dismiss();
        }
    }

    public void setImmersionBarArtts(int barColorResId){
        ImmersionBar.with(this)
                .fitsSystemWindows(true)
                .statusBarColorTransform(barColorResId)   //状态栏变色后的颜色
                .transparentNavigationBar()               //透明导航栏
                .statusBarDarkFont(true,0f)                  //状态栏字体是深色
                .init();                                  //必须调用方可沉浸式
    }

    public void setImmersionBarArtts(String barColorStr){
        ImmersionBar.with(this)
                .fitsSystemWindows(true)
                .statusBarColorTransform(barColorStr)   //状态栏变色后的颜色
                .transparentNavigationBar()               //透明导航栏
                .statusBarDarkFont(true,0f)                  //状态栏字体是深色
                .init();                                  //必须调用方可沉浸式
    }

    protected Handler mHandler = new UiHandler(this) {
        public void handleMessage(android.os.Message msg) {
            super.handleMessage(msg);
            if (getActivityReference() != null && getActivityReference().get() != null) {
                handleUiMessage(msg);
            }
        }
    };

    protected static class UiHandler extends Handler {
        private final WeakReference<BaseFragmentActivity> mActivityReference;

        public UiHandler(BaseFragmentActivity activity) {
            mActivityReference = new WeakReference<BaseFragmentActivity>(activity);
        }

        public WeakReference<BaseFragmentActivity> getActivityReference() {
            return mActivityReference;
        }
    }

    /**
     * 判断当前activity是否可见，用于Dialog显示判断Token使用
     * @return
     */
    public boolean isActivityVisible(){
        return isActivityVisible;
    }

    /**
     * 处理更新UI任务
     *
     * @param msg
     */
    protected void handleUiMessage(Message msg) {
        if(null != msg){
            Log.d(TAG,"handleUiMessage-msg.what:"+msg.what);
        }else{
            Log.d(TAG,"handleUiMessage");
        }

    }

    /**
     * 发送UI更新操作
     *
     * @param msg
     */
    protected void sendUiMessage(Message msg) {
        mHandler.sendMessage(msg);
    }

    protected void sendUiMessageDelayed(Message msg, long delayMillis) {
        mHandler.sendMessageDelayed(msg, delayMillis);
    }

    protected void sendUiMessageDelayed(int what, long delayMillis) {
        mHandler.sendEmptyMessageDelayed(what, delayMillis);
    }

    protected void removeUiMessages(int what) {
        mHandler.removeMessages(what);
    }

    /**
     * 发送UI更新操作
     *
     * @param what
     */
    protected void sendEmptyUiMessage(int what) {
        mHandler.sendEmptyMessage(what);
    }

    protected void sendEmptyUiMessageDelayed(int what, long delayMillis) {
        mHandler.sendEmptyMessageDelayed(what, delayMillis);
    }

    protected void postUiRunnableDelayed(Runnable runnable, long delay){
        mHandler.postDelayed(runnable, delay);
    }

    protected void removeCallback(Runnable runnable){
        mHandler.removeCallbacks(runnable);
    }

    /**
     * 隐藏输入法界面，并使et失去焦点
     * @param et
     * @param clearFocus 是否使控件et失去焦点
     */
    public void hideSoftInput(EditText et, boolean clearFocus){
        if(et == null){
            return;
        }
        InputMethodManager imm_etLiveMsg = (InputMethodManager) et.getContext().getApplicationContext()
                .getSystemService(Context.INPUT_METHOD_SERVICE);
        imm_etLiveMsg.hideSoftInputFromWindow(et.getWindowToken(),
                InputMethodManager.HIDE_NOT_ALWAYS);
        if(clearFocus){
            et.clearFocus();
        }
    }

    /**
     * 自动弹出输入法界面，并使et获取焦点
     * @param et
     */
    public void showSoftInput(EditText et){
        if(et == null){
            return;
        }
        et.requestFocus();
        //自动弹出软键盘
        final InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(et, 0);
    }

    @Override
    public void onClick(View v) {
        Log.d(TAG,"onClick");
    }

    //******************************** 通用的提示弹框 ****************************************
    protected CreditsTipsPopupWindow creditsTipsPopupWindow;
    public void showCreditNoEnoughPopupWindow(int tipsResId, View parentView, boolean isFromDialog){
        if(null == creditsTipsPopupWindow){
            creditsTipsPopupWindow = new CreditsTipsPopupWindow(this);
            creditsTipsPopupWindow.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        }
        if(!creditsTipsPopupWindow.isShowing()){
            creditsTipsPopupWindow.setCreditsTips(getResources().getString(tipsResId));
            creditsTipsPopupWindow.showAtLocation(parentView, Gravity.CENTER, isFromDialog);
        }
    }

    public void showSimpleTipsDialog(int tipsResId,int cancelResId, int confirmResId,SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener listener){
        SimpleDoubleBtnTipsDialog simpleDoubleBtnTipsDialog = new SimpleDoubleBtnTipsDialog(this);
        simpleDoubleBtnTipsDialog.setOnBtnClickListener(listener);
        simpleDoubleBtnTipsDialog.show(getResources().getString(tipsResId),
                getResources().getString(confirmResId),getResources().getString(cancelResId));
    }

}
