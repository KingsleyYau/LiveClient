package com.qpidnetwork.livemodule.framework.base;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
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
import com.qpidnetwork.livemodule.liveshow.LoadingDialog;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.CustomShowTimeToast;
import com.qpidnetwork.livemodule.liveshow.liveroom.recharge.CreditsTipsDialog;
import com.qpidnetwork.livemodule.utils.EToast2;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.MaterialProgressDialog;
import com.qpidnetwork.livemodule.view.SimpleDoubleBtnTipsDialog;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;

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
    protected EToast2 threeSecondToast;

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
        //礼物相关的3秒提示，显示在屏幕底部，其他的3秒提示包括非自定义时间的toast全部显示在屏幕中间
        customShowTimeToast = new CustomShowTimeToast(this,3000l);
        //被踢下线广播接收器
        initKickedOffReceiver();
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
        dimissLoadingDialog();
        //反注册被踢下线广播接收器
        if(mKickedOffReceiver != null){
            unregisterReceiver(mKickedOffReceiver);
        }
    }

    /**
     * 设置 被踢下线广播接收器是否生效
     * @param enable
     */
    public void setKickedOffReceiverEnable(boolean enable){
        if(!enable){
            //反注册被踢下线广播接收器
            unregisterReceiver(mKickedOffReceiver);
            mKickedOffReceiver = null;
        }
    }

    /**
     * 注册 被踢下线广播接收器
     */
    private void initKickedOffReceiver(){
        //注册广播
        IntentFilter filter = new IntentFilter();
        filter.addAction(CommonConstant.ACTION_KICKED_OFF);
        registerReceiver(mKickedOffReceiver, filter);
    }

    /**
     * 广播接收器
     */
    private BroadcastReceiver mKickedOffReceiver = new BroadcastReceiver(){

        @Override
        public void onReceive(Context context, Intent intent) {
            // TODO Auto-generated method stub
            if(intent.getAction().equals(CommonConstant.ACTION_KICKED_OFF)){
                finish();
            }
        }

    };

    /**
     * @param msg
     * @param gravity
     */
    public void showThreeSecondTips(String msg,int gravity){
        Log.d(TAG,"showThreeSecondTips-msg:"+msg +" gravity:"+gravity);
        boolean isShowCustomToast = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT
                && !EToast2.isNotificationEnabled(this);
        if (isShowCustomToast || EToast2.isErrToastDevice()) {
            EToast2.makeText(this,msg,EToast2.LENGTH_LONG).setGravity(gravity).show();
        }else{
            if(null != customShowTimeToast){
                customShowTimeToast.setGravity(gravity);
                customShowTimeToast.show(msg);
            }
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
     * @deprecated 最好使用showLoadingDialog吧，方面界面展现统一(Samson要求loading使用系统组件,也即ProgressBar)
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
     * @deprecated 最好使用showLoadingDialog吧，方面界面展现统一(Samson要求loading使用系统组件,也即ProgressBar)
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
     * @deprecated 最好使用showLoadingDialog吧，方面界面展现统一(Samson要求loading使用系统组件,也即ProgressBar)
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

    @SuppressLint("HandlerLeak")
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
    public void showSimpleTipsDialog(int tipsResId,int cancelResId,
                                     int confirmResId,SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener listener){
        SimpleDoubleBtnTipsDialog simpleDoubleBtnTipsDialog = new SimpleDoubleBtnTipsDialog(this);
        simpleDoubleBtnTipsDialog.setOnBtnClickListener(listener);
        simpleDoubleBtnTipsDialog.show(getResources().getString(tipsResId),
                getResources().getString(confirmResId),getResources().getString(cancelResId));
    }

    protected CreditsTipsDialog creditsTipsDialog;
    public void showCreditNoEnoughDialog(int tipsResId){
        if(null == creditsTipsDialog){
            creditsTipsDialog = new CreditsTipsDialog(this);
        }
        if(!creditsTipsDialog.isShowing()){
            creditsTipsDialog.setCreditsTips(getResources().getString(tipsResId));
            creditsTipsDialog.show();
        }
    }

    protected LoadingDialog loadingDialog;

    /**
     * 统一loading样式
     *
     * 通过new ProgressBar的形式，不太方便调试界面loading动画的周期时间及效果，
     * xml则比较方便，因此将ProgressBar挪到dialog里面来展示
     */
    public void showLoadingDialog(){
        Log.d(TAG,"showLoadingDialog");
        if(null == loadingDialog){
            loadingDialog = new LoadingDialog(this);
            loadingDialog.setCanceledOnTouchOutside(false);
            loadingDialog.setCancelable(true);
        }
        mProgressDialogCount++;
        boolean isShowing = loadingDialog.isShowing();
        Log.d(TAG,"showLoadingDialog-mProgressDialogCount:"+mProgressDialogCount+" isShowing0:"+isShowing);
        if(!isShowing/* && isActivityVisible*/){
            loadingDialog.show();
            isShowing = loadingDialog.isShowing();
            Log.d(TAG,"showLoadingDialog-isShowing1:"+isShowing);
        }
    }

    private void dimissLoadingDialog(){
        Log.d(TAG,"dimissLoadingDialog");
        if(null != loadingDialog && loadingDialog.isShowing() ) {
            loadingDialog.dismiss();
        }
    }

    public void hideLoadingDialog(){
        Log.d(TAG,"hideLoadingDialog");
        try {
            if( mProgressDialogCount > 0 ) {
                mProgressDialogCount--;
                Log.d(TAG,"hideLoadingDialog-mProgressDialogCount:"+mProgressDialogCount);
                if(mProgressDialogCount == 0 && null != loadingDialog && loadingDialog.isShowing() ) {
                    loadingDialog.dismiss();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
