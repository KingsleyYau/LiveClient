package com.qpidnetwork.liveshow.welcome;

import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.view.View;

import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.httprequest.item.LoginItem;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.liveshow.authorization.LoginManager;
import com.qpidnetwork.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.liveshow.model.http.HttpRespObject;

/**
 * Description:应用的启动页
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class PeacockActivity extends BaseFragmentActivity implements IAuthorizationListener{

    private static final int MESSAGE_AUTOLOGIN_OVERTIME = 1;
    private static final int MESSAGE_LOGIN_CALLBACK = 2;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        setTitleBarVisibility(View.GONE);
        initData();
    }

    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return R.layout.activity_peacock;
    }

    private void initData(){
        LoginManager.getInstance().register(this);
        if(LoginManager.getInstance().autoLogin()){
            //上次成功登录未注销，自动登录
            sendUiMessageDelayed(MESSAGE_AUTOLOGIN_OVERTIME, 3000);
        }else{
            startActivity(new Intent(PeacockActivity.this, LoginChooserActivity.class));
            finish();
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case MESSAGE_AUTOLOGIN_OVERTIME: {
                //3秒自动登录未成功，直接跳转Home页
                startActivity(new Intent(PeacockActivity.this, MainFragmentActivity.class));
                finish();
            }break;

            case MESSAGE_LOGIN_CALLBACK: {
                removeUiMessages(MESSAGE_AUTOLOGIN_OVERTIME);
                HttpRespObject responseObj = (HttpRespObject)msg.obj;
                if(responseObj.isSuccess){
                    boolean hasFinishedWelcome = new LocalPreferenceManager(mContext).getFirstLaunchFlags();
                    Class clazz = hasFinishedWelcome ? MainFragmentActivity.class : WelcomeActivity.class;
                    startActivity(new Intent(PeacockActivity.this, clazz));
                    finish();
                }else{
                    //跳转登录页面
                    startActivity(new Intent(PeacockActivity.this, LoginChooserActivity.class));
                    finish();
                }
            }break;

            default:
                break;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        LoginManager.getInstance().unRegister(this);

    }

    /***************************  监听登录返回    ***************************/
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        Message msg = Message.obtain();
        msg.what = MESSAGE_LOGIN_CALLBACK;
        msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, item);
        sendUiMessage(msg);
    }

    @Override
    public void onLogout() {

    }
}
