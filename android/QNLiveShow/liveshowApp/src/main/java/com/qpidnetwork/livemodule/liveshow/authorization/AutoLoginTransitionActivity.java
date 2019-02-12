package com.qpidnetwork.livemodule.liveshow.authorization;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.view.ButtonRaised;

/**
 * 登录过渡页
 * @author Jagger 2018-8-16
 */
public class AutoLoginTransitionActivity extends BaseFragmentActivity implements IAuthorizationListener {

    private static final String LAUNCH_URL = "launchUrl";
    //UIHandler常量
    private final int UI_LOGIN_SUCCESS = 3001;
    private final int UI_LOGIN_FAIL = 3002;

    private RelativeLayout mRlLoginLoading;
    private LinearLayout mLoginLoading , mLoginFail;
    private ButtonRaised mBtnRelogin;

    private String mLaunchUrl = "";

    public static void launchActivity(Context context, String url){
        Intent intent = new Intent(context, AutoLoginTransitionActivity.class);
        intent.putExtra(LAUNCH_URL, url);
        context.startActivity(intent);
        if(context instanceof Activity){
            ((Activity)context).overridePendingTransition(R.anim.anim_activity_fade_in, R.anim.anim_activity_fade_out);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_login_transition);

        //UI
        mRlLoginLoading = (RelativeLayout)findViewById(R.id.rl_login_loading);
        mLoginLoading = (LinearLayout)findViewById(R.id.ll_main_login);
        mLoginFail = (LinearLayout)findViewById(R.id.ll_main_login_fail);
        mBtnRelogin = (ButtonRaised)findViewById(R.id.btn_reload);
        mBtnRelogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLoging();

//                LoginManager.getInstance().reLogin();
            }
        });

        //参数
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(LAUNCH_URL)){
                mLaunchUrl = bundle.getString(LAUNCH_URL);
            }
        }

        //监听登录
        LoginManager.getInstance().register(this);

        //如果登录中, 只看到loading
        if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logining){
            showLoging();
        }else if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Default){
            showLoging();
//            LoginManager.getInstance().reLogin();
        }else{
            doLoginSuccess();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //反注册 监听登录
        LoginManager.getInstance().unRegister(this);
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        if(isSuccess){
            //监听一次即可
            LoginManager.getInstance().unRegister(this);

            //更新UI
            sendEmptyUiMessage(UI_LOGIN_SUCCESS);

        }else {
            //更新UI
            sendEmptyUiMessage(UI_LOGIN_FAIL);
        }
    }

    @Override
    public void onLogout(boolean isMannual) {

    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            //登录成功
            case UI_LOGIN_SUCCESS: {
//                showLoginSuccess();
                doLoginSuccess();
            }break;
            case UI_LOGIN_FAIL:
//                showLoginFail();
                finish();
                break;
        }
    }

    private void showLoging(){
        mRlLoginLoading.setVisibility(View.VISIBLE);
        mLoginLoading.setVisibility(View.VISIBLE);
        mLoginFail.setVisibility(View.GONE);
    }

    private void showLoginFail(){
        mRlLoginLoading.setVisibility(View.VISIBLE);
        mLoginLoading.setVisibility(View.GONE);
        mLoginFail.setVisibility(View.VISIBLE);
    }

    private void showLoginSuccess(){
        mRlLoginLoading.setVisibility(View.GONE);
        mLoginLoading.setVisibility(View.VISIBLE);
        mLoginFail.setVisibility(View.GONE);
    }

    private void doLoginSuccess(){
        //如果登录成功，去主HOME
        MainFragmentActivity.launchActivityWIthUrl(this, "", mLaunchUrl);
        finish();
    }
}
