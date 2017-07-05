package com.qpidnetwork.liveshow.authorization;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.view.View;

import com.qpidnetwork.httprequest.OnRequestCallback;
import com.qpidnetwork.httprequest.item.LoginItem;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.liveshow.welcome.LoginChooserActivity;
import com.qpidnetwork.view.SimpleDoubleBtnTipsDialog;

/**
 * Description:发送短信验证码
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class SignUpSendVerifCodeActivity extends BaseVerificationCodeActivity implements IAuthorizationListener{

    //验证码注册返回
    private final int MSG_WHAT_SINGUPRESULT = 1;
    private final int MSG_WHAT_LOGINRESULT= 2;

    private SimpleDoubleBtnTipsDialog dialog;

    public static Intent getIntent(Activity context, String countryCode, String countryName, String phoneNum){
        Intent intent = new Intent(context, SignUpSendVerifCodeActivity.class);
        intent.putExtra(BaseVerificationCodeActivity.BUNDLE_SELECTED_COUNTRY_CODE, countryCode);
        intent.putExtra(BaseVerificationCodeActivity.BUNDLE_SELECTED_COUNTRY_NAME, countryName);
        intent.putExtra(BaseVerificationCodeActivity.BUNDLE_REGISTER_PHONENUMBER, phoneNum);
        return intent;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        setTitleBarVisibility(View.VISIBLE);
        setBackTitleVisibility(View.VISIBLE);
        setTitle(R.string.txt_verification);
        sendVerifCode();
        LoginManager.getInstance().register(this);
    }

    public void onClick(View view){
        switch (view.getId()){
            case R.id.tv_tipTimeCount:
                sendVerifCode();
                break;
            case R.id.tv_nextOperate:
                if(checkInput()){
                    //验证码校验，密码设置,也即调用SingUp接口
                    phoneRegister(et_editPassWord.getText().toString(),et_verifCode.getText().toString());
                }
                break;
            default:
                super.onClick(view);
        }
    }

    /**
     * 验证码号注册
     * @param password
     * @param verifCode
     */
    private void phoneRegister(String password, String verifCode){
        showCustomDialog(0,0,R.string.tip_regAccount,false,false,null);
        LoginManager.getInstance().phoneNumRegister(phoneNumber, countryCode, verifCode, password, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                Message msg = Message.obtain();
                msg.what = MSG_WHAT_SINGUPRESULT;
                msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
                sendUiMessage(msg);
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case MSG_WHAT_SINGUPRESULT:{
                HttpRespObject resp = (HttpRespObject)msg.obj;
                String password = et_editPassWord.getText().toString();
                if(resp.isSuccess){
                    //注册成功自动登录
                    LoginManager.getInstance().loginByPhone(countryCode, phoneNumber, password, true);
                }else{
                    dismissCustomDialog();
                    showToast(resp.errMsg);
                }
            }break;
            case MSG_WHAT_LOGINRESULT:{
                dismissCustomDialog();
                HttpRespObject resp = (HttpRespObject)msg.obj;
                if(resp.isSuccess){
                    //逐层关闭界面,遗漏Welcome逻辑
                    setResult(LoginChooserActivity.RSP_SINGUP_SUCCESSED);
                    finish();
                }else{
                    showToast(resp.errMsg);
//                    setResult(LoginChooserActivity.RSP_SINGUP_FAILED);

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

    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return super.getActivityViewId();
    }

    /******************************  登录通知回调  *********************************/
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        Message msg = Message.obtain();
        msg.what = MSG_WHAT_LOGINRESULT;
        msg.obj = new HttpRespObject(isSuccess,errCode,errMsg,item);
        sendUiMessage(msg);
    }

    @Override
    public void onLogout() {

    }
}
