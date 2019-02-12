package com.qpidnetwork.livemodule.framework.base;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Vibrator;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.CustomShowTimeToast;
import com.qpidnetwork.livemodule.liveshow.liveroom.recharge.CreditsTipsDialog;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.utils.EToast2;
import com.qpidnetwork.livemodule.view.FlatToast;
import com.qpidnetwork.livemodule.view.MaterialProgressDialog;
import com.qpidnetwork.livemodule.view.SimpleDoubleBtnTipsDialog;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionResetManager;
import com.qpidnetwork.qnbridgemodule.util.BroadcastManager;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.statusBar.ImmersionBar;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.lang.ref.WeakReference;

/**
 * Created by Hunter Mun on 2017/9/4.
 */

public class BaseFragmentActivity extends AnalyticsFragmentActivity implements View.OnClickListener {

    protected String TAG = BaseFragmentActivity.class.getName();

    protected Activity mContext;
    protected FlatToast mToast;
    protected MaterialProgressDialog progressDialog;
    protected MaterialProgressDialog progressDialogTranslucent;
    protected int mProgressDialogCount = 0;

    private boolean isActivityVisible = false;//判断activity是否可见，用于处理异步Dialog显示 windowToken异常
    protected Toast customToast;
    protected CustomShowTimeToast customShowTimeToast;
    protected EToast2 threeSecondToast;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);

        //add by Jagger 2018-7-19
        //原因：权限被禁止后，用户调用系统“设置”打开权限再返回APP时，系统会重启APP，走了Application的onCreate()并回到当前界面，
        //     但APP所有变量都被重置了。所以只有重新走一次启动流程，才能正常运行。参考：https://www.jianshu.com/p/cb68ca511776
        //疑问：例如拍照后savedInstanceState不为空，这样是否会导致重启APP。
        //     经测试，Activity的android:screenOrientation="portrait"时，拍照后不会调用onCreate,
        //     所以这种方法来处理暂时是可行的
        //在系统“设置”修改权限后，返回APP，重启
//        if (null != savedInstanceState) {
//            //注：不能通过ServiceManager重启。因为Application重启后，直播模块已从ServiceManager反注册，只有登录成功后，才会注册到ServiceManager中去。
//            sendBroadcast(new Intent(CommonConstant.ACTION_NOTIFICATION_APP_PERMISSION_RESET));
////            finish();
//        }
        if (PermissionResetManager.isPermissionReset(this, savedInstanceState)) {
            finish();
        }
        //end

        mContext = this;
        mProgressDialogCount = 0;
        progressDialog = new MaterialProgressDialog(this);
        progressDialog.setCanceledOnTouchOutside(false);
        progressDialogTranslucent = new MaterialProgressDialog(this, R.style.themeDialog);
        progressDialogTranslucent.setCanceledOnTouchOutside(false);

        customToast = new Toast(this);
        customToast.setGravity(Gravity.CENTER, 0, 0);
        customToast.setView(View.inflate(this, R.layout.view_custom_toast, null));
        //礼物相关的3秒提示，显示在屏幕底部，其他的3秒提示包括非自定义时间的toast全部显示在屏幕中间
        customShowTimeToast = new CustomShowTimeToast(this, 3000l);

        //add by Jagger 2018-11-8 把状态栏跟Toolbar默认bg颜色设置成一样且文字变成深色
//        setImmersionBarArtts(R.color.bg_MainActivity);
        setImmersionBarArtts(R.color.transparent_7);

        //注册关闭广播接收器
        registerCloseBroadcastReceiver();
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onResume() {
        super.onResume();
        isActivityVisible = true;

        //注册session过期广播接收器
        registerBroadcastReceiver();

        //公共处理，保存栈顶activity
        LiveModule.getInstance().updateLiveTopActivity(this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        isActivityVisible = false;

        try {
//            unregisterReceiver(sessionTimeoutReceiver);
            BroadcastManager.unregisterReceiver(mContext,sessionTimeoutReceiver);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        /*防止异常杀死界面重启后，dialog 失去windowDecor导致调用Dismiss IllegalArgumentException*/
        hideProgressDialog();
        //注销广播接收器
        try {
//            unregisterReceiver(activityClostReceiver);
            BroadcastManager.unregisterReceiver(mContext,activityClostReceiver);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        }

        //公共处理，注销栈顶activity设置
        LiveModule.getInstance().destroyTopActivity(this);

        //状态栏:必须调用该方法，防止内存泄漏
        ImmersionBar.with(this).destroy();
    }

    /**
     * @param msg
     * @param gravity
     */
    public void showThreeSecondTips(String msg, int gravity) {
        Log.d(TAG, "showThreeSecondTips-msg:" + msg + " gravity:" + gravity);

        //add by Jagger 2018-5-16
        //以免出现弹出空的提示
        if (TextUtils.isEmpty(msg)) {
            return;
        }

        boolean isShowCustomToast = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT
                && !EToast2.isNotificationEnabled(this);
        if (isShowCustomToast || EToast2.isErrToastDevice()) {
            EToast2.makeText(this, msg, EToast2.LENGTH_LONG).setGravity(gravity).show();
        } else {
            if (null != customShowTimeToast) {
                customShowTimeToast.setGravity(gravity);
                customShowTimeToast.show(msg);
            }
        }
    }

    /**
     * 屏幕中间
     *
     * @param tips
     */
    public void showToast(String tips) {
        //add by Jagger 2018-5-16
        //以免出现弹出空的提示
        if (TextUtils.isEmpty(tips)) {
            return;
        }

        customToast.setText(tips);
        customToast.setDuration(Toast.LENGTH_SHORT);
        customToast.show();
    }

    public void showToast(int strResId) {
        customToast.setText(getResources().getString(strResId));
        customToast.setDuration(Toast.LENGTH_SHORT);
        customToast.show();
    }

    public void showToastProgressing(String text) {
        if (mToast != null) {
            if (mToast.isShowing()) mToast.cancel();
            mToast = null;
        }
        mToast = new FlatToast(this);
        mToast.setProgressing(text);
        if (isActivityVisible) {
            mToast.show();
        }
    }

    public void showToastDone(String text) {
        if (mToast != null && mToast.isShowing()) {
            mToast.setDone(text);
        }
    }

    public void showToastFailed(String text) {
        if (mToast != null && mToast.isShowing()) {
            mToast.setFailed(text);
        }
    }

    public void cancelToast() {
        if (mToast != null) {
            if (mToast.isShowing()) {
                mToast.cancel();
            }
            mToast = null;
        }
    }

    public void cancelToastImmediately() {
        if (mToast != null) {
            if (mToast.isShowing()) {
                mToast.cancelImmediately();
            }
            mToast = null;
        }
    }

    /**
     * 2018/11/2    Hardy
     * 设置弹窗是否可以点击外部消失
     *
     * @param isCancel true: 可消失
     *                 false: 不可消失
     */
    protected void setProgressDialogCanceled(boolean isCancel) {
        if (progressDialog != null && isActivityVisible) {
            progressDialog.setCancelable(isCancel);
            progressDialog.setCanceledOnTouchOutside(isCancel);
        }
    }

    /**
     * 显示progressDialog
     *
     * @param tips 提示文字
     */
    public void showProgressDialog(String tips) {
        mProgressDialogCount++;
        if (!progressDialog.isShowing() && isActivityVisible) {
            progressDialog.setMessage(tips);
            progressDialog.show();
        }
    }

    /**
     * 显示progressDialog
     *
     * @param tips 提示文字
     */
    public void showProgressDialogBgTranslucent(String tips) {
        if (progressDialogTranslucent != null && !progressDialogTranslucent.isShowing()) {
            progressDialogTranslucent.setMessage(tips);
            progressDialogTranslucent.show();
        }
    }

    /**
     * 隐藏progressDialog
     */
    public void hideProgressDialog() {
        try {
            if (mProgressDialogCount > 0) {
                mProgressDialogCount--;
                if (mProgressDialogCount == 0 && progressDialog != null) {
                    progressDialog.dismiss();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (progressDialogTranslucent != null) {
            progressDialogTranslucent.dismiss();
        }
    }

    protected void setImmersionBarArtts(int barColorResId) {
        ImmersionBar.with(this)
                .statusBarColor(barColorResId)   //状态栏变色后的颜色
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
     *
     * @return
     */
    public boolean isActivityVisible() {
        return isActivityVisible;
    }

    /**
     * 处理更新UI任务
     *
     * @param msg
     */
    protected void handleUiMessage(Message msg) {
        if (null != msg) {
            Log.d(TAG, "handleUiMessage-msg.what:" + msg.what);
        } else {
            Log.d(TAG, "handleUiMessage");
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

    protected void postUiRunnableDelayed(Runnable runnable, long delay) {
        mHandler.postDelayed(runnable, delay);
    }

    protected void removeCallback(Runnable runnable) {
        mHandler.removeCallbacks(runnable);
    }

    /**
     * 隐藏软键盘
     */
    protected void hideSoftInput() {
        InputMethodManager manager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        // manager.toggleSoftInput(InputMethodManager.HIDE_NOT_ALWAYS, 0);
        if (getCurrentFocus() != null) {
            manager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(),
                    InputMethodManager.HIDE_NOT_ALWAYS);
        }

    }

    /**
     * 隐藏输入法界面，并使et失去焦点
     *
     * @param et
     * @param clearFocus 是否使控件et失去焦点
     */
    public void hideSoftInput(EditText et, boolean clearFocus) {
        if (et == null) {
            return;
        }
        InputMethodManager imm_etLiveMsg = (InputMethodManager) et.getContext().getApplicationContext()
                .getSystemService(Context.INPUT_METHOD_SERVICE);
        imm_etLiveMsg.hideSoftInputFromWindow(et.getWindowToken(),
                InputMethodManager.HIDE_NOT_ALWAYS);
        if (clearFocus) {
            et.clearFocus();
        }
    }

    /**
     * 自动弹出输入法界面，并使et获取焦点
     *
     * @param et
     */
    public void showSoftInput(EditText et) {
        if (et == null) {
            return;
        }
        et.requestFocus();
        //自动弹出软键盘
        final InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(et, 0);
    }

    @Override
    public void onClick(View v) {
        Log.d(TAG, "onClick");
    }

    //******************************** 状态栏控制 ****************************************
//    /**
//     * 全透状态栏
//     */
//    protected void setStatusBarFullTransparent() {
//        if (Build.VERSION.SDK_INT >= 21) {//21表示5.0
//            Window window = getWindow();
//            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
//            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
//                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
//            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
//            window.setStatusBarColor(Color.TRANSPARENT);
//        } else if (Build.VERSION.SDK_INT >= 19) {//19表示4.4
//            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
//            //虚拟键盘也透明
//            //getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
//        }
//    }
//
//    /**
//     * 半透明状态栏
//     */
//    protected void setHalfTransparent() {
//
//        if (Build.VERSION.SDK_INT >= 21) {//21表示5.0
//            View decorView = getWindow().getDecorView();
//            int option = View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE;
//            decorView.setSystemUiVisibility(option);
//            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
//
//        } else if (Build.VERSION.SDK_INT >= 19) {//19表示4.4
//            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
//            //虚拟键盘也透明
//            // getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
//        }
//    }
//
//    /**
//     * 如果需要内容紧贴着StatusBar
//     * 应该在对应的xml布局文件中，设置根布局fitsSystemWindows=true。
//     */
//    private View contentViewGroup;
//
//    protected void setFitSystemWindow(boolean fitSystemWindow) {
//        if (contentViewGroup == null) {
//            contentViewGroup = ((ViewGroup) findViewById(android.R.id.content)).getChildAt(0);
//        }
//        contentViewGroup.setFitsSystemWindows(fitSystemWindow);
//    }
//
//    /**
//     * 为了兼容4.4的抽屉布局->透明状态栏
//     */
//    protected void setDrawerLayoutFitSystemWindow() {
//        if (Build.VERSION.SDK_INT == 19) {//19表示4.4
//            int statusBarHeight = getStatusHeight(this);
//            if (contentViewGroup == null) {
//                contentViewGroup = ((ViewGroup) findViewById(android.R.id.content)).getChildAt(0);
//            }
//            if (contentViewGroup instanceof DrawerLayout) {
//                DrawerLayout drawerLayout = (DrawerLayout) contentViewGroup;
//                drawerLayout.setClipToPadding(true);
//                drawerLayout.setFitsSystemWindows(false);
//                for (int i = 0; i < drawerLayout.getChildCount(); i++) {
//                    View child = drawerLayout.getChildAt(i);
//                    child.setFitsSystemWindows(false);
//                    child.setPadding(0,statusBarHeight, 0, 0);
//                }
//
//            }
//        }
//    }

    //******************************** 通用的提示弹框 ****************************************
    public void showSimpleTipsDialog(int tipsResId, int cancelResId,
                                     int confirmResId, SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener listener) {
        SimpleDoubleBtnTipsDialog simpleDoubleBtnTipsDialog = new SimpleDoubleBtnTipsDialog(this);
        simpleDoubleBtnTipsDialog.setOnBtnClickListener(listener);
        simpleDoubleBtnTipsDialog.show(getResources().getString(tipsResId),
                getResources().getString(confirmResId), getResources().getString(cancelResId));
    }

    protected CreditsTipsDialog creditsTipsDialog;

    public void showCreditNoEnoughDialog(int tipsResId) {
        if (null == creditsTipsDialog) {
            creditsTipsDialog = new CreditsTipsDialog(this);
        }
        if (!creditsTipsDialog.isShowing()) {
            creditsTipsDialog.setCreditsTips(getResources().getString(tipsResId));
            creditsTipsDialog.setmNoMoneyParamsBean(new NoMoneyParamsBean());
            creditsTipsDialog.show();
        }
    }

    public void showCreditNoEnoughDialog(String message, NoMoneyParamsBean paramsBean) {
        if (null == creditsTipsDialog) {
            creditsTipsDialog = new CreditsTipsDialog(this);
        }
        if (!creditsTipsDialog.isShowing()) {
            creditsTipsDialog.setCreditsTips(message);
            creditsTipsDialog.setmNoMoneyParamsBean(paramsBean);
            creditsTipsDialog.show();
        }
    }

    //******************************** session过期广播通知 ****************************************

    /**
     * 注册广播接收器
     * add by Jagger
     */
    private void registerBroadcastReceiver() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(CommonConstant.ACTION_SESSION_TIMEOUT);
//        registerReceiver(sessionTimeoutReceiver, filter);
        BroadcastManager.registerReceiver(mContext,sessionTimeoutReceiver, filter);
    }

    /**
     * 广播接收器
     */
    private BroadcastReceiver sessionTimeoutReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(android.content.Context context, android.content.Intent intent) {
            String action = intent.getAction();
            if (action.equals(CommonConstant.ACTION_SESSION_TIMEOUT)) {
                //收到session过期
                showSessionTimeoutDialog();
            }
        }
    };

    /**
     * 注册广播接收器
     * add by Jagger
     */
    private void registerCloseBroadcastReceiver() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(CommonConstant.ACTION_ACTIVITY_CLOSE);
//        registerReceiver(activityClostReceiver, filter);
        BroadcastManager.registerReceiver(mContext,activityClostReceiver, filter);
    }

    /**
     * 广播接收器
     */
    private BroadcastReceiver activityClostReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(android.content.Context context, android.content.Intent intent) {
            String action = intent.getAction();
            WebSiteConfigManager.WebSiteType webSiteType = WebSiteConfigManager.getInstance().getCurrentWebSiteType();
            if (action.equals(CommonConstant.ACTION_ACTIVITY_CLOSE) && !isActivityVisible && webSiteType != WebSiteConfigManager.WebSiteType.CharmLive) {
                //收到关闭当前activity广播
                finish();
            }
        }
    };

    /**
     * 显示session过期dialog提示
     */
    private void showSessionTimeoutDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this)
                .setMessage(getResources().getString(R.string.live_session_timeout_desc))
                .setCancelable(false)
                .setPositiveButton(getResources().getString(R.string.live_common_btn_yes), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        //点击触发被踢
                        LiveModule.getInstance().onModuleSessionOverTime();
                    }
                });
        if (isActivityVisible()) {
            builder.create().show();
        }
    }

    /**
     * 震动动画
     * @param v
     * @param vibrate
     */
    public void shakeView(View v, boolean vibrate){

        if(vibrate){
            try{
                Vibrator vibrator = (Vibrator)this.getSystemService(Context.VIBRATOR_SERVICE);
                long [] pattern = {100, 200, 0};   //stop | vibrate | stop | vibrate
                vibrator.vibrate(pattern, -1);
            }catch(Exception e){
                //No vibrate if no permission
            }
        }
        v.requestFocus();
        Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake_anim);
        v.startAnimation(shake);
    }

}
