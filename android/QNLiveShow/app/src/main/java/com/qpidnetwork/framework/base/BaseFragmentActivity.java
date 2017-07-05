package com.qpidnetwork.framework.base;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.utils.DisplayUtil;
import com.qpidnetwork.view.SimpleDoubleBtnTipsDialog;

import java.lang.ref.WeakReference;

/**
 * Created by Harry on 2017/5/19.
 */

public abstract class BaseFragmentActivity extends FragmentActivity implements View.OnClickListener {

    public String TAG = BaseFragmentActivity.class.getSimpleName();

    public TextView tv_backTitle;
    public TextView tv_title;
    public View rl_title_bar;
    public FrameLayout fl_baseContainer;
    public SimpleDoubleBtnTipsDialog dialog;
    public boolean isDebug = true;

    public Activity mContext;

    /**
     * 隐藏输入法界面，并使et失去焦点
     * @param et
     */
    public void hideSoftInput(EditText et){
        if(et == null){
            return;
        }
        InputMethodManager imm_etLiveMsg = (InputMethodManager) et.getContext().getApplicationContext()
                .getSystemService(Context.INPUT_METHOD_SERVICE);
        imm_etLiveMsg.hideSoftInputFromWindow(et.getWindowToken(),
                InputMethodManager.HIDE_NOT_ALWAYS);
        et.clearFocus();
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

    /**
     * 隐藏自定义对话框
     */
    public void dismissCustomDialog(){
        if(null != dialog && dialog.isShowing()){
            dialog.dismiss();
        }
    }

    /**
     * 弹出自定义对话框
     * @param canStrId
     * @param confirmStrId
     * @param contentStrId
     * @param cancelOnTouchOut
     * @param cancelable
     * @param listener
     */
    public void showCustomDialog(int canStrId, int confirmStrId, int contentStrId,
                                 boolean cancelOnTouchOut, boolean cancelable,
                                 SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener listener){
        dismissCustomDialog();
        dialog = new SimpleDoubleBtnTipsDialog(this, canStrId, confirmStrId, contentStrId, listener);
        dialog.setCanceledOnTouchOutside(cancelOnTouchOut);
        dialog.setCancelable(cancelable);
        dialog.show();
    }

    /**
     *
     * @param canStrId
     * @param confirmStrId
     * @param contentStrId
     * @param cancelOnTouchOut
     * @param cancelable
     * @param cancelTxtColor
     * @param confirmTxtColor
     * @param cancelBgDrawableId
     * @param confirmBgDrawableId
     * @param listener
     */
    public void showCustomDialog(int canStrId, int confirmStrId, int contentStrId,
                                 boolean cancelOnTouchOut, boolean cancelable,int cancelTxtColor,
                                 int confirmTxtColor,int cancelBgDrawableId,int confirmBgDrawableId,
                                 SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener listener){
        dismissCustomDialog();
        dialog = new SimpleDoubleBtnTipsDialog(this, canStrId, confirmStrId, contentStrId, listener);
        dialog.setCanceledOnTouchOutside(cancelOnTouchOut);
        dialog.setCancelable(cancelable);
        dialog.setCancelBtnStyle(cancelTxtColor,cancelBgDrawableId);
        dialog.setConfirmBtnStyle(confirmTxtColor,confirmBgDrawableId);
        dialog.show();
    }

    public void showToast(int strId){
        Toast.makeText(this, getString(strId), Toast.LENGTH_SHORT).show();
    }

    public void showToast(String tip){
        Toast.makeText(this, tip, Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");
        setContentView(R.layout.fragment_activity_base_container);
        mContext = this;

        tv_backTitle = (TextView) findViewById(R.id.tv_backTitle);
        rl_title_bar = findViewById(R.id.rl_title_bar);
        tv_title = (TextView) findViewById(R.id.tv_title);
        fl_baseContainer = ((FrameLayout)findViewById(R.id.fl_baseContainer));
        fl_baseContainer.addView(View.inflate(this,getActivityViewId(),null));
        DisplayUtil.modifyStatusBar(this,false,getResources().getColor(R.color.txt_color_oninput));
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Log.d(TAG,"onNewIntent");
    }

    @Override
    public void onClick(View v) {
        Log.d(TAG,"onClick");
        switch (v.getId()){
            case R.id.tv_backTitle:
                onBackTitleClicked();
                break;
        }
    }



    /**
     * 设置标题
     * @param strId
     */
    public void setTitle(int strId){
        Log.d(TAG,"setTitle-strId:"+strId);
        setTitleVisibility(0 == strId ? View.INVISIBLE : View.VISIBLE);
        if(0 != strId){
            tv_title.setText(getString(strId));
        }
    }

    public void setTitleVisibility(int visibility){
        Log.d(TAG,"setTitleVisibility-visibility:"+visibility);
        tv_title.setVisibility(visibility);
    }



    /**
     * 设置TitleBar是否可见
     * @param visibility
     */
    public void setTitleBarVisibility(int visibility){
        Log.d(TAG,"setTitleBarVisibility-visibility:"+visibility);
        rl_title_bar.setVisibility(visibility);
    }

    /**
     * 设置TitleBar的背景色
     * @param color 透明或者指定的主题色
     */
    public void setTitleBarBackGroundColor(int color){
        Log.d(TAG,"setTitleBarBackGroundColor-color:"+color);
        rl_title_bar.setBackgroundColor(getResources().getColor(color));
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return super.onKeyDown(keyCode, event);
    }


    /**
     * 返回标题的单击事件
     */
    public void onBackTitleClicked(){
        Log.d(TAG,"onBackTitleClicked");
        BaseFragmentActivity.this.finish();
    }

    /**
     * 返回按钮是否可见
     * @param visibility
     */
    public void setBackTitleVisibility(int visibility){
        Log.d(TAG,"setBackTitleVisibility-visibility:"+visibility);
        tv_backTitle.setVisibility(visibility);
    }

    /**
     * 返回当前activity的视图布局ID
     * @return
     */
    public abstract int getActivityViewId();

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG,"onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG,"onPause");
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG,"onStop");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG,"onDestroy");
    }

    /*********************  解决Handler内存泄漏问题  **************************/
    protected Handler mHandler = new UiHandler(this) {
        public void handleMessage(android.os.Message msg) {
            super.handleMessage(msg);
            if (getActivityReference() != null && getActivityReference().get() != null) {
                handleUiMessage(msg);
            }
        }
    };

    private static class UiHandler extends Handler {
        private final WeakReference<BaseFragmentActivity> mActivityReference;

        public UiHandler(BaseFragmentActivity activity) {
            mActivityReference = new WeakReference<BaseFragmentActivity>(activity);
        }

        public WeakReference<BaseFragmentActivity> getActivityReference() {
            return mActivityReference;
        }
    }

    /**
     * 处理更新UI任务
     *
     * @param msg
     */
    protected void handleUiMessage(Message msg) {
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

    protected  void postUiRunnableDelayed(Runnable runnable, long delayMillis){
        mHandler.postDelayed(runnable, delayMillis);
    }

}
