package com.qpidnetwork.livemodule.liveshow.welcome;

import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.home.EditProfileActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.livemodule.liveshow.model.LoginParam;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;

/**
 * Description:应用的启动页
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class PeacockActivity extends BaseFragmentActivity implements IAuthorizationListener{

    private static final int MESSAGE_AUTOLOGIN_OVERTIME = 1;
    private static final int MESSAGE_LOGIN_CALLBACK = 2;

    private EditText et_token;
    private TextView tv_testLogin;
    private View ll_handlerLogin;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_peacock);
        initView();
        initData();
    }

    private void initView(){
        et_token = (EditText)findViewById(R.id.et_token);
        ll_handlerLogin = findViewById(R.id.ll_handlerLogin);
        tv_testLogin = (TextView) findViewById(R.id.tv_testLogin);
        tv_testLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(TextUtils.isEmpty(et_token.getText())){
                    Toast.makeText(PeacockActivity.this,"输入测试帐号的token！",Toast.LENGTH_SHORT).show();
                    return;
                }
                String token = et_token.getText().toString();
                showToast(getResources().getString(R.string.tip_waitlogin));
                LoginManager.getInstance().login("", token);
            }
        });

        //test
        Button btnLogin = (Button)findViewById(R.id.btn_login);
        btnLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(PeacockActivity.this, LiveLoginActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                finish();
            }
        });
        Button btnEdit = (Button)findViewById(R.id.btn_edit);
        btnEdit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EditProfileActivity.show(mContext);
            }
        });
    }

    private void initData(){
        LoginManager.getInstance().register(this);
//        if(LoginManager.getInstance().autoLogin()){
//            //上次成功登录未注销，自动登录
//            showProgressDialog(getResources().getString(R.string.tip_waitlogin));
//            sendUiMessageDelayed(MESSAGE_AUTOLOGIN_OVERTIME, getResources().getInteger(R.integer.autoLoginMaxTime));
//        }else{
        ll_handlerLogin.setVisibility(View.VISIBLE);
        LoginParam param = LoginManager.getInstance().getAccountInfo();
        if(param != null && !TextUtils.isEmpty(param.qnToken)){
            et_token.setText(param.qnToken);
        }
//            String token = "Harry_HHeEoKeotNFp";
//            showProgressDialog(getResources().getString(R.string.tip_waitlogin));
//            LoginManager.getInstance().login(token);
//        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case MESSAGE_AUTOLOGIN_OVERTIME: {
                //3秒自动登录未成功，直接跳转Home页
                Intent intent = new Intent(PeacockActivity.this, MainFragmentActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                finish();
            }break;

            case MESSAGE_LOGIN_CALLBACK: {
                hideProgressDialog();
                removeUiMessages(MESSAGE_AUTOLOGIN_OVERTIME);
                HttpRespObject responseObj = (HttpRespObject)msg.obj;
                if(responseObj.isSuccess){
                    Intent intent = new Intent(PeacockActivity.this, MainFragmentActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(intent);
                    finish();
                }else{
                    //跳转登录页面
//                    startActivity(new Intent(PeacockActivity.this, LoginChooserActivity.class));
//                    finish();
                    showToast("登录失败！");
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
    public void onLogout(boolean isMannual) {

    }
}
