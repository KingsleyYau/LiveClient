package com.qpidnetwork.livemodule.liveshow.login;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.Html;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.item.GenderType;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.onRegisterListener;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Facebook邮箱登录界面
 * Created by Jagger on 2017/12/27.
 */
public class LiveFBEmailLoginActivity extends BaseActionBarFragmentActivity{

    private static String KEY_EMAIL = "KEY_EMAIL";

    //控件
    private MaterialTextField mEtPassword;
    private Button mBtnSummit;
    private TextView mTvEmailTips;

    //变量
    private String mStrEmail;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = LiveFBEmailLoginActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_live_fb_email_login);

        //设置头
        setTitle(getString(R.string.live_sing_up_fb_mail_title), Color.WHITE);

        //
        initIntent();
        initUI();
    }

    /**
     * 使用这个Activity所需要的参数
     * @param context
     * @param email
     * @return
     */
    public static Intent getIntent(Context context , String email){
        Intent i  = new Intent(context , LiveFBEmailLoginActivity.class);
        i.putExtra(KEY_EMAIL , email);
        return i;
    }

    /**
     * 取 传入的参数
     */
    private void initIntent(){
        Bundle bundle = getIntent().getExtras();
        if( bundle != null) {
            if(bundle.containsKey(KEY_EMAIL)){
                mStrEmail =  bundle.getString(KEY_EMAIL);
            }

        }
    }

    private void initUI() {
        mTvEmailTips = (TextView) findViewById(R.id.tv_fb_mail_tips);
        mTvEmailTips.setText(Html.fromHtml(String.format(getResources().getString(R.string.live_sing_up_fb_mail_tips2), mStrEmail)));

        mBtnSummit = (Button)findViewById(R.id.btn_submit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedLogin();
            }
        });

        //
        TextWatcher textWatcher = new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                                      int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                                          int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                doCheckData();
            }
        };
        mEtPassword = (MaterialTextField) findViewById(R.id.et_password);
        mEtPassword.setHint(getString(R.string.live_password));
        //设置分割线颜色
        mEtPassword.setNormalStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtPassword.setFocusedStateColor(getResources().getColor(R.color.email_sign_up_devide));
        //获取焦点是et底部分割线是否加粗
        mEtPassword.boldDevideOnFocus = false;
        //设置字体大小
        mEtPassword.getEditor().setTextSize(15);
        //设置字体颜色
        mEtPassword.getEditor().setTextColor(getResources().getColor(R.color.custom_dialog_txt_color_simple));
        mEtPassword.getEditor().setHintTextColor(getResources().getColor(R.color.email_sign_up_hint_txt));
        mEtPassword.getEditor().addTextChangedListener(textWatcher);
        mEtPassword.setPassword();

        doCheckData();
    }

    @SuppressLint("HandlerLeak")
    private Handler mHandler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            hideLoadingDialog();
            if(msg.obj != null ){
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    //注册成功,返回登录界面自动登录
//                    sendBroadcast(new Intent(LiveLoginActivity.ACTION_AUTO_LOGIN));
//                    finish();
                    LiveLoginActivity.show(mContext , LiveLoginActivity.OPEN_TYPE_AUTO_LOGIN , "");
                }else{
                    //如果错误
                    showToast(response.errMsg);

                }
            }
        }
    };

    /**
     * 检查数据是否完整
     */
    private void doCheckData(){
        if(mEtPassword.getText().length() < 1){
            mBtnSummit.setEnabled(false);
            mBtnSummit.setTextColor(getResources().getColor(R.color.submit_unusable));
        }else{
            mBtnSummit.setTextColor(Color.WHITE);
            mBtnSummit.setEnabled(true);
        }
    }

    private void onClickedLogin(){
        Log.d(TAG,"onClickedLogin");
        showLoadingDialog();
        //2.4 Facebook注册及登录
        LoginManager.getInstance().register(LoginManager.LoginType.FACEBOOK,
                mStrEmail, mEtPassword.getText().toString(), GenderType.Man, "", "", "",
                new onRegisterListener() {
                    @Override
                    public void onResult(boolean isSuccess, int errCode, String errMsg, String sessionId) {
                        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, sessionId);
                        Message msg = new Message();
                        msg.obj = response;
                        mHandler.sendMessage(msg);
                    }
                });
    }
}
